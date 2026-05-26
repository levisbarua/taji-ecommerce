import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';

class UpdateService {
  static const String _repo = 'levisbarua/taji-ecommerce';
  static const String _apiUrl = 'https://api.github.com/repos/$_repo/releases/latest';

  static Future<Map<String, dynamic>?> checkForUpdate(String currentVersion) async {
    try {
      final client = HttpClient();
      client.userAgent = 'TajiApp/1.0';
      final request = await client.getUrl(Uri.parse(_apiUrl));
      final response = await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final tagName = data['tag_name'] as String? ?? '';
      final version = tagName.replaceAll(RegExp(r'^v'), '');
      if (version.isEmpty) return null;

      if (compareVersions(version, currentVersion) <= 0) return null;

      final assets = data['assets'] as List<dynamic>? ?? [];
      if (assets.isEmpty) return null;

      final apkAsset = assets.firstWhere(
        (a) => (a['name'] as String?)?.endsWith('.apk') ?? false,
        orElse: () => null,
      );
      if (apkAsset == null) return null;

      return {
        'version': version,
        'url': apkAsset['browser_download_url'] as String,
        'notes': data['body'] as String? ?? 'New version available',
      };
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  static int compareVersions(String a, String b) {
    final partsA = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < partsA.length && i < partsB.length; i++) {
      if (partsA[i] != partsB[i]) return partsA[i] - partsB[i];
    }
    return partsA.length - partsB.length;
  }

  /// Downloads APK and triggers installation on device.
  /// Uses FileProvider + android_intent_plus for direct install (seamless).
  /// Falls back to browser download if direct install fails.
  static Future<void> downloadAndInstall(String url, BuildContext context) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/taji_update.apk');

      if (file.existsSync()) await file.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading update...'), duration: Duration(minutes: 5)),
        );
      }

      final client = HttpClient();
      client.userAgent = 'TajiApp/1.0';
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(const Duration(seconds: 120));

      if (response.statusCode != 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download failed')));
        }
        return;
      }

      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.flush();
      await sink.close();

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download complete'), duration: Duration(seconds: 2)),
        );
      }

      // Try direct install via FileProvider + Android Intent
      if (Platform.isAndroid) {
        final installed = await _installApk(file);
        if (installed) return;
      }

      // Fallback: open download URL in browser
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening download in browser...')),
        );
      }
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  /// Installs APK using FileProvider content URI and Android Intent.
  /// Returns true if the install intent was launched successfully.
  static Future<bool> _installApk(File file) async {
    try {
      final authority = 'com.example.taji_app.fileprovider';
      final contentUri = 'content://$authority/apk_downloads/${file.uri.pathSegments.last}';

      const grantRead = 0x00000001; // FLAG_GRANT_READ_URI_PERMISSION
      const newTask = 0x10000000; // FLAG_ACTIVITY_NEW_TASK
      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: contentUri,
        type: 'application/vnd.android.package-archive',
        flags: [grantRead, newTask],
      );
      await intent.launch();
      return true;
    } catch (_) {
      return false;
    }
  }
}
