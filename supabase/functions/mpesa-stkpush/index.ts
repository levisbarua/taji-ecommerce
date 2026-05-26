// Supabase Edge Function: M-Pesa STK Push
// Deploy: supabase functions deploy mpesa-stkpush
// Secrets (set via: supabase secrets set MPESA_CONSUMER_KEY=...):
//   MPESA_CONSUMER_KEY, MPESA_CONSUMER_SECRET, MPESA_PASSKEY, MPESA_SHORTCODE
// Requires valid JWT from authenticated user.

import { serve } from 'https://deno.land/std@0.192.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const CONSUMER_KEY = Deno.env.get('MPESA_CONSUMER_KEY');
const CONSUMER_SECRET = Deno.env.get('MPESA_CONSUMER_SECRET');
const PASSKEY = Deno.env.get('MPESA_PASSKEY');
const SHORTCODE = Deno.env.get('MPESA_SHORTCODE') || '174379';
const BASE_URL = Deno.env.get('MPESA_ENV') === 'production'
  ? 'https://api.safaricom.co.ke'
  : 'https://sandbox.safaricom.co.ke';
const CALLBACK_URL = Deno.env.get('MPESA_CALLBACK_URL') ||
  'https://jkcegzquyhekepznqeob.supabase.co/functions/v1/mpesa-callback';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;

async function getToken(): Promise<string | null> {
  if (!CONSUMER_KEY || !CONSUMER_SECRET) return null;
  const credentials = btoa(`${CONSUMER_KEY}:${CONSUMER_SECRET}`);
  const res = await fetch(`${BASE_URL}/oauth/v1/generate?grant_type=client_credentials`, {
    headers: { Authorization: `Basic ${credentials}` },
  });
  if (!res.ok) return null;
  const data = await res.json();
  return data.access_token;
}

function generateTimestamp(): string {
  const now = new Date();
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, '0');
  const d = String(now.getDate()).padStart(2, '0');
  const h = String(now.getHours()).padStart(2, '0');
  const min = String(now.getMinutes()).padStart(2, '0');
  const s = String(now.getSeconds()).padStart(2, '0');
  return `${y}${m}${d}${h}${min}${s}`;
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 });
  }

  // Verify JWT: only authenticated users can initiate payments
  const authHeader = req.headers.get('Authorization')?.replace('Bearer ', '');
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${authHeader}` } },
  });
  const { data: { user }, error: authError } = await supabase.auth.getUser(authHeader);
  if (authError || !user) {
    return new Response(JSON.stringify({ error: 'Invalid token' }), { status: 401 });
  }

  try {
    const { phoneNumber, amount, accountReference, transactionDesc } = await req.json();

    if (!phoneNumber || amount == null) {
      return new Response(JSON.stringify({ error: 'phoneNumber and amount required' }), { status: 400 });
    }

    // Type and range validation
    const numAmount = Number(amount);
    if (isNaN(numAmount) || numAmount <= 0 || numAmount > 150000) {
      return new Response(JSON.stringify({ error: 'Amount must be between 1 and 150,000' }), { status: 400 });
    }

    let phone = String(phoneNumber).replace(/\D/g, '');
    if (phone.startsWith('0')) phone = '254' + phone.slice(1);
    else if (phone.startsWith('7')) phone = '254' + phone;
    else if (!phone.startsWith('254')) phone = '254' + phone;

    if (phone.length !== 12) {
      return new Response(JSON.stringify({ error: 'Invalid phone number' }), { status: 400 });
    }

    const token = await getToken();
    if (!token) {
      return new Response(JSON.stringify({ error: 'Payment service unavailable' }), { status: 503 });
    }

    const timestamp = generateTimestamp();
    const password = btoa(`${SHORTCODE}${PASSKEY}${timestamp}`);

    const body = {
      BusinessShortCode: SHORTCODE,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.round(numAmount).toString(),
      PartyA: phone,
      PartyB: SHORTCODE,
      PhoneNumber: phone,
      CallBackURL: CALLBACK_URL,
      AccountReference: accountReference || 'TajiApp',
      TransactionDesc: transactionDesc || 'Taji App Payment',
    };

    const res = await fetch(`${BASE_URL}/mpesa/stkpush/v1/processrequest`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const data = await res.json();
    return new Response(JSON.stringify(data), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: 'Internal error' }), { status: 500 });
  }
});