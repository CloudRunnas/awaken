import '../support/package_test_harness.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAudioHandler extends BaseAudioHandler {}

void main() {
  initPackageIntegrationTest();

  testWidgets('AudioServiceConfig and BaseAudioHandler', (tester) async {
    const config = AudioServiceConfig(
      androidNotificationChannelName: 'Phoenix Music',
      androidNotificationIcon: 'drawable/phoenix_awaken',
      androidNotificationChannelDescription: 'Phoenix Music Notification',
    );
    expect(config.androidNotificationChannelName, 'Phoenix Music');

    final handler = _TestAudioHandler();
    expect(handler, isA<BaseAudioHandler>());
  });
}
