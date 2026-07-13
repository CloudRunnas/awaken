import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Gemeinsame Initialisierung für Paket-Kompatibilitätstests.
void initPackageIntegrationTest() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Prüft, dass ein Paket-API-Aufruf ohne Exception durchläuft.
Future<void> expectPackageApi(Future<void> Function() apiCall) async {
  await expectLater(apiCall(), completes);
}
