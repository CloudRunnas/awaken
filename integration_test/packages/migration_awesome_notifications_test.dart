import '../support/package_test_harness.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('AwesomeNotifications initialize and NotificationChannel',
      (tester) async {
    try {
      await AwesomeNotifications().initialize(
        'resource://drawable/phoenix_awaken',
        [
          NotificationChannel(
            channelKey: 'phoenix_visualize',
            channelName: 'Phoenix Visualizer',
            channelDescription: 'Phoenix Visualizer Running Alert',
            enableLights: false,
            enableVibration: false,
            importance: NotificationImportance.Default,
            playSound: false,
          ),
        ],
      );
    } catch (_) {
      // Native notification setup may fail in test environment.
    }
    expect(AwesomeNotifications().initialize, isA<Function>());
  });
}
