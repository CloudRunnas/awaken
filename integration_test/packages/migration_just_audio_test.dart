import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('AudioPlayer and ConcatenatingAudioSource', (tester) async {
    final player = AudioPlayer();
    expect(player, isA<AudioPlayer>());

    final source = ConcatenatingAudioSource(
      children: [
        AudioSource.uri(Uri.parse('file:///dev/null')),
      ],
    );
    expect(source, isA<ConcatenatingAudioSource>());

    await player.dispose();
  });
}
