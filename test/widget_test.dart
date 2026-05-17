import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taji_app/utils/constants.dart';

void main() {
  group('Constants', () {
    test('colors are correct hex values', () {
      expect(tajiAmber, const Color(0xFFFFB800));
      expect(pureBlack, const Color(0xFF000000));
      expect(pureWhite, const Color(0xFFFFFFFF));
    });

    test('theme data builds without error', () {
      expect(buildLightTheme(), isNotNull);
      expect(buildDarkTheme(), isNotNull);
    });

    test('theme notifier defaults to dark mode', () {
      expect(themeNotifier.value, ThemeMode.dark);
    });
  });
}
