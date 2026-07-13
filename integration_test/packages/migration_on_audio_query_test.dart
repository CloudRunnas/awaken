import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('OnAudioQuery SongSortType OrderType API', (tester) async {
    final query = OnAudioQuery();
    expect(query, isA<OnAudioQuery>());

    const sortTypes = [
      SongSortType.TITLE,
      SongSortType.DATE_ADDED,
      SongSortType.ALBUM,
      SongSortType.ARTIST,
    ];
    expect(sortTypes, hasLength(4));
    expect(OrderType.ASC_OR_SMALLER, isA<OrderType>());
    expect(OrderType.DESC_OR_GREATER, isA<OrderType>());

    try {
      await query.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
      );
    } catch (_) {
      // Requires storage permission on device.
    }
  });
}
