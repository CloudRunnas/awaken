import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('ImagePicker instantiation', (tester) async {
    final picker = ImagePicker();
    expect(picker, isA<ImagePicker>());

    try {
      await picker.pickImage(source: ImageSource.gallery);
    } catch (_) {
      // Gallery picker requires platform UI.
    }
  });
}
