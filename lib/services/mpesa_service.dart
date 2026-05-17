import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class MpesaService {
  /// For production, calls Supabase Edge Function which holds the real API keys.
  /// For demo/sandbox, provide consumerKey and consumerSecret here.
  static String? _consumerKey;
  static String? _consumerSecret;
  static String? _passkey;
  static String? _shortcode;
  static bool _useSandbox = true;

  static void configure({
    String? consumerKey,
    String? consumerSecret,
    String? passkey,
    String? shortcode = '174379',
    bool useSandbox = true,
  }) {
    _consumerKey = consumerKey;
    _consumerSecret = consumerSecret;
    _passkey = passkey;
    _shortcode = shortcode;
    _useSandbox = useSandbox;
  }

  static String get _baseUrl => _useSandbox
      ? 'https://sandbox.safaricom.co.ke'
      : 'https://api.safaricom.co.ke';

  /// Get OAuth token from Daraja API
  static Future<String?> _getToken() async {
    if (_consumerKey == null || _consumerSecret == null) return null;

    try {
      final credentials = base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'));
      final client = HttpClient();
      client.userAgent = 'TajiApp/1.0';
      final request = await client.getUrl(Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'));
      request.headers.set('Authorization', 'Basic $credentials');
      final response = await request.close().timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body);
      return data['access_token'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Initiate STK Push (Lipa Na M-Pesa Online)
  static Future<Map<String, dynamic>> stkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    String transactionDesc = 'Taji App Payment',
  }) async {
    // Format phone: 254XXXXXXXXX
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

    final sc = _shortcode ?? '174379';
    final pk = _passkey ?? 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
    final timestamp = _generateTimestamp();
    final password = base64Encode(utf8.encode('$sc$pk$timestamp'));
    final token = await _getToken();

    if (token == null) {
      // No API keys → return simulated success for demo
      return _simulateStkPush(phone, amount, accountReference);
    }

    try {
      final client = HttpClient();
      client.userAgent = 'TajiApp/1.0';
      final request = await client.postUrl(Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');

      final body = jsonEncode({
        'BusinessShortCode': sc,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.toStringAsFixed(0),
        'PartyA': phone,
        'PartyB': sc,
        'PhoneNumber': phone,
        'CallBackURL': 'https://jkcegzquyhekepznqeob.supabase.co/functions/v1/mpesa-callback',
        'AccountReference': accountReference,
        'TransactionDesc': transactionDesc,
      });

      request.write(body);
      final response = await request.close().timeout(const Duration(seconds: 30));
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);

      if (data['ResponseCode'] == '0') {
        return {
          'success': true,
          'message': 'STK Push sent. Check your phone to enter M-Pesa PIN.',
          'checkoutRequestID': data['CheckoutRequestID'],
          'merchantRequestID': data['MerchantRequestID'],
        };
      } else {
        return {
          'success': false,
          'message': data['ResponseDescription'] ?? 'M-Pesa request failed.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Demo mode: no real API keys, simulate the flow
  static Map<String, dynamic> _simulateStkPush(String phone, double amount, String reference) {
    debugPrint('--- M-PESA DEMO ---');
    debugPrint('Phone: $phone');
    debugPrint('Amount: KES ${amount.toStringAsFixed(0)}');
    debugPrint('Reference: $reference');
    debugPrint('Check your phone for STK Push prompt (demo)');
    debugPrint('---');

    return {
      'success': true,
      'message': 'Demo: STK Push sent to $phone. Enter your M-Pesa PIN on your phone.',
      'checkoutRequestID': 'demo_${DateTime.now().millisecondsSinceEpoch}',
      'isDemo': true,
    };
  }

  static String _generateTimestamp() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$y$m$d$h$min$s';
  }
}
