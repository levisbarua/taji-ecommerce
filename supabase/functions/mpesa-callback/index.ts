// M-Pesa Callback handler — logs payment results
// Safaricom sends callbacks to this URL after STK Push completion.
// Deploy: supabase functions deploy mpesa-callback
// For production, configure MPESA_ALLOWED_IPS env var with Safaricom's callback IPs.

import { serve } from 'https://deno.land/std@0.192.0/http/server.ts';

const ALLOWED_IPS = (Deno.env.get('MPESA_ALLOWED_IPS') || '').split(',').map(s => s.trim()).filter(Boolean);

serve(async (req) => {
  // Basic IP whitelist check (Safaricom publishes their callback IP ranges)
  if (ALLOWED_IPS.length > 0) {
    const clientIp = req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip') || '';
    if (!ALLOWED_IPS.some(ip => clientIp.includes(ip))) {
      console.warn(`Callback from unauthorized IP: ${clientIp}`);
      return new Response(JSON.stringify({ ResultCode: 1, ResultDesc: 'Rejected' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      });
    }
  }

  try {
    const body = await req.json();
    console.log('M-Pesa Callback:', JSON.stringify(body, null, 2));

    const callback = body?.Body?.stkCallback;
    if (callback) {
      const success = callback.ResultCode === 0;
      console.log(`Payment ${success ? 'SUCCESS' : 'FAILED'}: ${callback.ResultDesc}`);
      // TODO: Update order status in database using CheckoutRequestID
    }

    return new Response(JSON.stringify({ ResultCode: 0, ResultDesc: 'Success' }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (e) {
    console.error('Callback error:', e);
    return new Response(JSON.stringify({ ResultCode: 1, ResultDesc: 'Error' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});