import 'package:flutter_test/flutter_test.dart';
import 'package:murmory/core/audio/models.dart';

void main() {
  group('RecordedAudio Model Tests', () {
    test('instantiates with expected attributes', () {
      const audio = RecordedAudio(
        path: '/data/user/0/com.murmory.app/files/recordings/test.m4a',
        durationMs: 4500,
      );

      expect(audio.durationMs, 4500);
      expect(audio.path, contains('test.m4a'));
    });

    test('AudioLevel normalization bounds', () {
      const level = AudioLevel(0.8);
      expect(level.amplitude, inInclusiveRange(0.0, 1.0));
      expect(level.amplitude, 0.8);
    });
  });
}
