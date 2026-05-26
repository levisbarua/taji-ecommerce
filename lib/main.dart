import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'utils/constants.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  runApp(const TajiApp());
}

class TajiApp extends StatelessWidget {
  const TajiApp({super.key});

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
          home: const HomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
