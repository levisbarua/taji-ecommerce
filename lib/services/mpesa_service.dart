import 'dart:convert';
import 'dart:io';

class MpesaService {
  static const String _edgeFunctionUrl =
      'https://jkcegzquyhekepznqeob.supabase.co/functions/v1/mpesa-stkpush';

  static String? _supabaseAnonKey;

  static void configure({String? supabaseAnonKey}) {
    _supabaseAnonKey = supabaseAnonKey;
  }

  /// Initiate STK Push via Supabase Edge Function.
  /// Falls back to simulated demo if Edge Function is unreachable.
  static Future<Map<String, dynamic>> stkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    String transactionDesc = 'Taji App Payment',
  }) async {
    String phone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) {
      phone = '254${phone.substring(1)}';
    } else if (phone.startsWith('7')) {
      phone = '254$phone';
    } else if (!phone.startsWith('254')) {
      phone = '254$phone';
    }

    if (phone.length != 12) {
      return {'success': false, 'message': 'Invalid phone number. Use 0715XXXXXX format.'};
    }

    if (_supabaseAnonKey == null) {
      return _simulateStkPush(phone, amount, accountReference);
    }

    try {
      final client = HttpClient();
      client.userAgent = 'TajiApp/1.0';
      final request = await client.postUrl(Uri.parse(_edgeFunctionUrl));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('apikey', _supabaseAnonKey!);
      request.headers.set('Authorization', 'Bearer $_supabaseAnonKey');

      final body = jsonEncode({
        'phoneNumber': phone,
        'amount': amount,
        'accountReference': accountReference,
        'transactionDesc': transactionDesc,
      });

      request.write(body);
      final response = await request.close().timeout(const Duration(seconds: 30));
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);

      if (data is Map && data['ResponseCode'] == '0') {
        return {
          'success': true,
          'message': 'STK Push sent. Check your phone to enter M-Pesa PIN.',
          'checkoutRequestID': data['CheckoutRequestID'],
          'merchantRequestID': data['MerchantRequestID'],
        };
      } else {
        return {
          'success': false,
          'message': data is Map ? (data['ResponseDescription'] ?? 'M-Pesa request failed.') : 'Invalid response',
        };
      }
    } catch (_) {
      return _simulateStkPush(phone, amount, accountReference);
    }
  }

  static Map<String, dynamic> _simulateStkPush(String phone, double amount, String reference) {
    return {
      'success': true,
      'message': 'Demo: STK Push sent to $phone. Enter your M-Pesa PIN on your phone.',
      'checkoutRequestID': 'demo_${DateTime.now().millisecondsSinceEpoch}',
      'isDemo': true,
    };
  }
}