// M-Pesa Callback handler — logs payment results
import { serve } from 'https://deno.land/std@0.192.0/http/server.ts';

serve(async (req) => {
  try {
    const body = await req.json();
    console.log('M-Pesa Callback:', JSON.stringify(body, null, 2));

    // Body.stkCallback contains: MerchantRequestID, CheckoutRequestID, ResultCode, ResultDesc
    const callback = body?.Body?.stkCallback;
    if (callback) {
      const success = callback.ResultCode === 0;
      console.log(`Payment ${success ? 'SUCCESS' : 'FAILED'}: ${callback.ResultDesc}`);
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
