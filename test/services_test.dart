import 'package:flutter_test/flutter_test.dart';
import 'package:taji_app/services/update_service.dart';
import 'package:taji_app/services/user_session.dart';

void main() {
  group('UpdateService', () {
    test('version comparison: same version', () {
      final result = UpdateService.compareVersions('0.1.0', '0.1.0');
      expect(result, 0);
    });

    test('version comparison: newer is greater', () {
      final result = UpdateService.compareVersions('0.2.0', '0.1.0');
      expect(result, greaterThan(0));
    });

    test('version comparison: older is less', () {
      final result = UpdateService.compareVersions('0.1.0', '0.2.0');
      expect(result, lessThan(0));
    });

    test('version comparison: major version', () {
      final result = UpdateService.compareVersions('1.0.0', '0.9.9');
      expect(result, greaterThan(0));
    });

    test('version comparison: three parts', () {
      final result = UpdateService.compareVersions('0.1.0', '0.1.1');
      expect(result, lessThan(0));
    });
  });

  group('UserSession', () {
    test('isAdmin returns true for admin email', () {
      expect(UserSession.isAdmin('barualevis@gmail.com'), isTrue);
    });

    test('isAdmin returns false for other emails', () {
      expect(UserSession.isAdmin('user@example.com'), isFalse);
    });

    test('isAdmin returns false for null', () {
      expect(UserSession.isAdmin(null), isFalse);
    });

    test('isAdmin returns false for empty string', () {
      expect(UserSession.isAdmin(''), isFalse);
    });
  });
}
