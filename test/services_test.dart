import 'package:flutter_test/flutter_test.dart';
import 'package:taji_app/services/update_service.dart';

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

    test('version comparison: single vs three parts', () {
      final result = UpdateService.compareVersions('5', '0.1.0');
      expect(result, greaterThan(0));
    });
  });
}
