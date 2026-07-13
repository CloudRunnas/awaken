# integration_test (Dev-Dependency)

**Alt → Neu:** *(nicht vorhanden)* → `integration_test` (Flutter SDK)

## Zweck der Migration

Neue Dev-Dependency für Paket-Migrations-Integrations-Tests unter `integration_test/packages/`.

## Änderungen

| Datei | Zeile(n) | Alt | Neu | Zweck |
|-------|----------|-----|-----|-------|
| `pubspec.yaml` | 86–87 | *(nicht vorhanden)* | `integration_test:\n    sdk: flutter` | Integrations-Test-Infrastruktur für Migrationsvalidierung |

## Integration Test

`integration_test/test_driver/integration_test.dart` (Test-Treiber)
