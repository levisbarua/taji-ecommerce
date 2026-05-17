import 'package:flutter/material.dart';
import 'services/update_service.dart';
import 'services/user_session.dart';
import 'services/supabase_service.dart';
import 'services/mpesa_service.dart';
import 'utils/constants.dart';
import 'pages/home_page.dart';
import 'pages/shop_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  MpesaService.configure(
    consumerKey: 'QNdQTIXHnLzc711HW9i0AeyRnrTF0NJoKCYe0cxGLBzinZSg',
    consumerSecret: 'g9B8tgEimjDsJ4eDhVBMUbd29cFcUFldhpW1ZspQwHQwPSwNcVAefUMfGLuGlkev',
    passkey: 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919',
    shortcode: '174379',
    useSandbox: true,
  );

  runApp(const TajiApp());
}

class TajiApp extends StatefulWidget {
  const TajiApp({super.key});

  @override
  State<TajiApp> createState() => _TajiAppState();
}

class _TajiAppState extends State<TajiApp> {
  bool _checkedUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_checkedUpdate) {
        _checkedUpdate = true;
        _checkForUpdate();
      }
    });
  }

  Future<String?> _getSessionEmail() async {
    if (UserSession.hasSupabaseSession()) {
      final user = UserSession.currentSupabaseUser;
      if (user != null) {
        final email = user.email;
        if (email != null) {
          await UserSession.saveSession(email, user.id);
          return email;
        }
      }
    }
    return UserSession.getEmail();
  }

  Future<void> _checkForUpdate() async {
    const currentVersion = '0.1.0';
    final update = await UpdateService.checkForUpdate(currentVersion);
    if (update == null || !mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A202C),
        title: const Text('Update Available', style: TextStyle(color: pureWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('v${update['version']}', style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(update['notes'] as String, style: const TextStyle(color: pureWhite)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later', style: TextStyle(color: tajiTextMutedDark)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              UpdateService.downloadAndInstall(update['url'] as String, context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Taji App',
          themeMode: currentMode,
          theme: ThemeData(
            scaffoldBackgroundColor: tajiLightBg,
            cardColor: tajiLightSurface,
            colorScheme: const ColorScheme.light(
              primary: tajiAmber,
              onPrimary: tajiTextDark,
              secondary: tajiAmberDark,
              onSecondary: tajiTextDark,
              surface: tajiLightSurface,
              onSurface: tajiTextDark,
              error: tajiError,
              outline: tajiLightBorder,
              surfaceContainerHighest: tajiLightBg,
            ),
            dividerColor: tajiLightBorder,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            scaffoldBackgroundColor: tajiDarkBg,
            cardColor: tajiDarkSurface,
            colorScheme: const ColorScheme.dark(
              primary: tajiAmber,
              onPrimary: tajiTextDark,
              secondary: tajiAmberDark,
              onSecondary: tajiTextDark,
              surface: tajiDarkBg,
              onSurface: tajiTextLight,
              error: tajiError,
              outline: tajiDarkBorder,
              surfaceContainerHighest: tajiDarkSurface,
            ),
            dividerColor: tajiDarkBorder,
            useMaterial3: true,
          ),
          home: FutureBuilder<String?>(
            future: _getSessionEmail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator(color: pureYellow)));
              }
              if (snapshot.hasData && snapshot.data != null) {
                return ShopPage(isAdmin: UserSession.isAdmin(snapshot.data));
              }
              return Theme(
                data: ThemeData(
                  scaffoldBackgroundColor: tajiDarkBg,
                  colorScheme: const ColorScheme.dark(
                    primary: tajiAmber,
                    onPrimary: tajiTextDark,
                    secondary: tajiAmberDark,
                    surface: tajiDarkBg,
                    onSurface: tajiTextLight,
                    error: tajiError,
                    outline: tajiDarkBorder,
                    surfaceContainerHighest: tajiDarkSurface,
                  ),
                  dividerColor: tajiDarkBorder,
                  
                  useMaterial3: true,
                ),
                child: const HomePage(),
              );
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
