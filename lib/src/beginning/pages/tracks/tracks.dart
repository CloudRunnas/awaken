import 'package:page_transition/page_transition.dart';
import 'package:phoenix/src/beginning/begin.dart';
import 'package:phoenix/src/beginning/utilities/constants.dart';
import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'package:phoenix/src/beginning/utilities/init.dart';
import 'package:phoenix/src/beginning/utilities/page_backend/albums_back.dart';
import 'package:phoenix/src/beginning/widgets/dialogues/corrupted_file_dialog.dart';
import 'package:phoenix/src/beginning/widgets/list_header.dart';
import 'package:phoenix/src/beginning/utilities/audio_handlers/previous_play_skip.dart';
import 'package:phoenix/src/beginning/utilities/lyrics/lyrics_backend_scan.dart';
import 'package:phoenix/src/beginning/utilities/lyrics/track_lyrics_filter.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../widgets/dialogues/on_hold.dart';

class Allofem extends StatefulWidget {
  const Allofem({Key? key}) : super(key: key);

  @override
  State<Allofem> createState() => _AllofemState();
}

class _AllofemState extends State<Allofem>
    with AutomaticKeepAliveClientMixin<Allofem> {
  ScrollController? _scrollBarController;
  TracksLyricsFilter _filter = TracksLyricsFilter.all;

  @override
  void initState() {
    _scrollBarController = ScrollController();
    LyricsBackendScanQueue.inst.addListener(_onScanUpdate);
    super.initState();
  }

  @override
  void dispose() {
    LyricsBackendScanQueue.inst.removeListener(_onScanUpdate);
    _scrollBarController?.dispose();
    super.dispose();
  }

  void _onScanUpdate() {
    if (mounted) setState(() {});
  }

  List<int> _filteredIndices() {
    final indices = <int>[];
    for (var i = 0; i < songList.length; i++) {
      final path = songList[i].data;
      if (TrackLyricsClassifier.matches(path, _filter)) {
        indices.add(i);
      }
    }
    return indices;
  }

  Widget _filterChip(String label, TracksLyricsFilter value) {
    final selected = _filter == value;
    // Phoenix: cyan accent when selected; glass-dark unselected — never use
    // nowContrast (near-white) as fill or label/background collapse together.
    const selectedBg = Color(0xFF028ac4); // kPhoenixColor
    final unselectedBg = Colors.white.withOpacity(0.10);
    final labelColor = selected ? Colors.white : Colors.white70;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: selected,
        showCheckmark: false,
        selectedColor: selectedBg,
        backgroundColor: unselectedBg,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: selected ? selectedBg : Colors.white24,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRounded),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        onSelected: (_) {
          setState(() {
            // Single-select: tapping active filter clears to all.
            _filter = selected ? TracksLyricsFilter.all : value;
          });
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      orientedCar = true;
      deviceHeight = MediaQuery.of(context).size.width;
      deviceWidth = MediaQuery.of(context).size.height;
    } else {
      orientedCar = false;
      deviceHeight = MediaQuery.of(context).size.height;
      deviceWidth = MediaQuery.of(context).size.width;
    }

    if (!isPlayerShown) {
      pc.hide();
    }

    final filtered = _filteredIndices();

    return Scrollbar(
      controller: _scrollBarController,
      child: RefreshIndicator(
        key: Begin.refreshIndicatorKey,
        backgroundColor:
            musicBox.get("dynamicArtDB") ?? true ? nowColor : Colors.white,
        color:
            musicBox.get("dynamicArtDB") ?? true ? nowContrast : kMaterialBlack,
        onRefresh: () async {
          await fetchAll();
        },
        child: ListView.builder(
          controller: _scrollBarController,
          padding: const EdgeInsets.only(top: 3, bottom: 8),
          addAutomaticKeepAlives: true,
          physics: musicBox.get("fluidAnimation") ?? true
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          itemCount: filtered.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListHeader(deviceWidth, songList, "all");
            }
            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('No Lyrics', TracksLyricsFilter.noLyrics),
                      _filterChip('With Lyrics', TracksLyricsFilter.withLyrics),
                      _filterChip(
                        'With Synced Lyrics',
                        TracksLyricsFilter.withSyncedLyrics,
                      ),
                      _filterChip(
                        'With MusicSync-Lyrics',
                        TracksLyricsFilter.withMusicSyncLyrics,
                      ),
                    ],
                  ),
                ),
              );
            }
            final songIndex = filtered[index - 2];
            final SongModel song = songList[songIndex];
            return Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () async {
                  if (!Begin.isLoading) {
                    if (songListMediaItems[songIndex].duration ==
                        const Duration(milliseconds: 0)) {
                      corruptedFile(context);
                    } else {
                      await playThis(songIndex, "all");
                    }
                  }
                },
                onLongPress: () async {
                  if (!Begin.isLoading) {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.size,
                        alignment: Alignment.center,
                        duration: dialogueAnimationDuration,
                        reverseDuration: dialogueAnimationDuration,
                        child: OnHold(
                            classContext: context,
                            listOfSong: songList,
                            index: songIndex,
                            car: orientedCar,
                            heightOfDevice: deviceHeight,
                            widthOfDevice: deviceWidth,
                            songOf: "all"),
                      ),
                    );
                  }
                },
                title: Text(
                  song.title,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white70,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1.0),
                        blurRadius: 2.0,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                tileColor: Colors.transparent,
                subtitle: Opacity(
                  opacity: 0.5,
                  child: Text(
                    song.artist!,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white70,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1.0),
                          blurRadius: 1.0,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Card(
                  elevation: 3,
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: musicBox.get("squareArt") ?? true
                        ? kSqrConstraint
                        : kRectConstraint,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(artworksData[
                                  (musicBox.get("artworksPointer") ??
                                      {})[song.id]] ??
                              defaultNone!),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
