import 'dart:io';
import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:phoenix/src/beginning/pages/settings/settings_pages/glass_effect.dart';
import 'package:phoenix/src/beginning/utilities/translation/deepl_languages.dart';
import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'package:phoenix/src/beginning/widgets/artwork_background.dart';
import 'package:phoenix/src/beginning/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:phoenix/src/beginning/utilities/provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class Interface extends StatefulWidget {
  const Interface({Key? key}) : super(key: key);

  @override
  State<Interface> createState() => _InterfaceState();
}

class _InterfaceState extends State<Interface> {
  @override
  void initState() {
    rootCrossfadeState = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    rootCrossfadeState = Provider.of<Leprovider>(context);
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      orientedCar = true;
      deviceHeight = MediaQuery.of(context).size.width;
      deviceWidth = MediaQuery.of(context).size.height;
    } else {
      orientedCar = false;
      deviceHeight = MediaQuery.of(context).size.height;
      deviceWidth = MediaQuery.of(context).size.width;
    }
    return Consumer<Leprovider>(
      builder: (context, taste, _) {
        globaltaste = taste;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            shadowColor: Colors.transparent,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: Text(
              "Interface",
              style: TextStyle(
                color: Colors.white,
                fontSize: deviceWidth! / 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Theme(
            data: themeOfApp,
            child: Stack(
              children: [
                // ignore: prefer_const_constructors
                BackArt(),
                Container(
                  padding: EdgeInsets.only(
                      top: kToolbarHeight + MediaQuery.of(context).padding.top),
                  child: ListView(
                    padding: const EdgeInsets.all(0),
                    physics: musicBox.get("fluidAnimation") ?? true
                        ? const BouncingScrollPhysics()
                        : const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: const Text(
                            "Glass Effect",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          subtitle: const Text(
                            "Adjust blur and color of glass theme.",
                            style: TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                maintainState: false,
                                builder: (context) =>
                                    ChangeNotifierProvider<Leprovider>(
                                        create: (_) => Leprovider(),
                                        child: const GlassEffect()),
                              ),
                            );
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: const Text(
                            "Default Artwork",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          subtitle: const Text(
                            "Set custom image as default artwork.",
                            style: TextStyle(
                              color: Colors.white38,
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
                                    image: MemoryImage(defaultNone!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.image_rounded,
                            color: Colors.white,
                          ),
                          onLongPress: () async {
                            ByteData bytes =
                                await rootBundle.load('assets/res/default.jpg');
                            setState(() {
                              defaultNone = bytes.buffer.asUint8List();
                            });
                            await File(
                                    "${applicationFileDirectory.path}/artworks/null.jpeg")
                                .writeAsBytes(defaultNone!,
                                    mode: FileMode.write);
                            Flushbar(
                              messageText: const Text(
                                  "Default artwork has been reset",
                                  style: TextStyle(
                                      fontFamily: "Futura",
                                      color: Colors.white)),
                              icon: const Icon(
                                Icons.restore_rounded,
                                size: 28.0,
                                color: Colors.white,
                              ),
                              shouldIconPulse: true,
                              dismissDirection:
                                  FlushbarDismissDirection.HORIZONTAL,
                              duration: const Duration(seconds: 3),
                              borderColor: Colors.white.withOpacity(0.04),
                              borderWidth: 1,
                              backgroundColor: glassOpacity!,
                              flushbarStyle: FlushbarStyle.FLOATING,
                              isDismissible: true,
                              barBlur: musicBox.get("glassBlur") ?? 18,
                              margin: const EdgeInsets.only(
                                  bottom: 20, left: 8, right: 8),
                              borderRadius: BorderRadius.circular(15),
                            ).show(context);
                            musicBox.put("dominantDefault", null);
                            refresh = true;
                          },
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile image = (await picker.pickImage(
                                source: ImageSource.gallery))!;
                            Uint8List bytes = await image.readAsBytes();
                            setState(() {
                              defaultNone = bytes;
                            });
                            await File(
                                    "${applicationFileDirectory.path}/artworks/null.jpeg")
                                .writeAsBytes(bytes, mode: FileMode.write);
                            musicBox.put("dominantDefault", null);
                            refresh = true;
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          activeColor: kCorrect,
                          checkColor: kMaterialBlack,
                          subtitle: const Text(
                            "A fluid bouncing animation on scrolling",
                            style: TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                          title: const Text(
                            "Fluid",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          value: musicBox.get("fluidAnimation") ?? true,
                          onChanged: (newValue) {
                            setState(() {
                              musicBox.put("fluidAnimation", newValue);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          activeColor: kCorrect,
                          checkColor: kMaterialBlack,
                          subtitle: const Text(
                            "Read lyrics from audio tags before sidecar .lrc files.",
                            style: TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                          title: const Text(
                            "Prioritize Embedded Lyrics",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          value: musicBox.get("prioritizeEmbeddedLyrics") ??
                              false,
                          onChanged: (newValue) {
                            setState(() {
                              musicBox.put(
                                  "prioritizeEmbeddedLyrics", newValue);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: const Text(
                            "Übersetzungs-Sprache",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            "Zielsprache für Lyrics (Tap=Wort, Doppel-Tap=Vers, Long-Press=Springen).",
                            style: TextStyle(color: Colors.white38),
                          ),
                          trailing: DropdownButton<String>(
                            dropdownColor: kMaterialBlack,
                            value: kDeeplTargetLanguages.any((l) =>
                                    l.code ==
                                    (musicBox.get('translationTargetLang')
                                        as String?))
                                ? musicBox.get('translationTargetLang')
                                    as String?
                                : 'DE',
                            items: kDeeplTargetLanguages
                                .map(
                                  (lang) => DropdownMenuItem(
                                    value: lang.code,
                                    child: Text(
                                      '${lang.flag} ${lang.name}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Raleway',
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (code) {
                              if (code == null) return;
                              setState(() {
                                musicBox.put('translationTargetLang', code);
                              });
                            },
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: const Text(
                            "Lyrics-Schriftfarbe",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            "Textfarbe der synchronisierten Lyrics.",
                            style: TextStyle(color: Colors.white38),
                          ),
                          trailing: _colorSwatch(_lyricsTextColor()),
                          onTap: () async {
                            final color = await _pickColor(
                              title: "Lyrics-Schriftfarbe",
                              current: _lyricsTextColor(),
                            );
                            if (color == null) return;
                            setState(() {
                              musicBox.put('lyricsTextColor', color.toARGB32());
                            });
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: const Text(
                            "Lyrics-Container-Farbe",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            "Hintergrundfarbe hinter der aktuellen Lyrics-Zeile.",
                            style: TextStyle(color: Colors.white38),
                          ),
                          trailing: _colorSwatch(_lyricsContainerColor()),
                          onTap: () async {
                            final color = await _pickColor(
                              title: "Lyrics-Container-Farbe",
                              current: _lyricsContainerColor(),
                            );
                            if (color == null) return;
                            setState(() {
                              musicBox.put('lyricsContainerColor', color.toARGB32());
                            });
                          },
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(
                            "Lyrics-Container-Opacity (${(_lyricsContainerOpacity() * 100).round()}%)",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Transparenz des Lyrics-Hintergrundcontainers.",
                                style: TextStyle(color: Colors.white38),
                              ),
                              SliderTheme(
                                data: const SliderThemeData(
                                  trackHeight: 3,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 5,
                                  ),
                                  inactiveTrackColor: Colors.white10,
                                ),
                                child: Slider(
                                  value: _lyricsContainerOpacity(),
                                  min: 0,
                                  max: 1,
                                  divisions: 20,
                                  activeColor: Colors.white,
                                  onChanged: (value) {
                                    setState(() {
                                      musicBox.put(
                                          'lyricsContainerOpacity', value);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          activeColor: kCorrect,
                          checkColor: kMaterialBlack,
                          subtitle: const Text(
                            "Use albumart as background",
                            style: TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                          title: const Text(
                            "Dynamic Background",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          value: musicBox.get("dynamicArtDB") ?? true,
                          onChanged: (newValue) {
                            setState(() {
                              musicBox.put("dynamicArtDB", newValue);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          activeColor: kCorrect,
                          checkColor: kMaterialBlack,
                          subtitle: const Text(
                            "Square shaped artwork in lists",
                            style: TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                          title: const Text(
                            "Square Art",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          value: musicBox.get("squareArt") ?? true,
                          onChanged: (newValue) {
                            setState(() {
                              musicBox.put("squareArt", newValue);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          activeColor: kCorrect,
                          checkColor: kMaterialBlack,
                          subtitle: const Text(
                            "Position icons for driver's ease",
                            style: TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                          title: const Text(
                            "Left Steering",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          value: musicBox.get("androidAutoLefty") ?? true,
                          onChanged: (newValue) {
                            setState(() {
                              musicBox.put("androidAutoLefty", newValue);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          activeColor: kCorrect,
                          checkColor: kMaterialBlack,
                          subtitle: const Text(
                            "Show additional song data in now playing.",
                            style: TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                          title: const Text(
                            "Audiophile Data",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          value: musicBox.get("audiophileData") ?? true,
                          onChanged: (newValue) {
                            setState(() {
                              musicBox.put("audiophileData", newValue);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      // Material(
                      //   color: Colors.transparent,
                      //   child: CheckboxListTile(
                      //     activeColor: kCorrect,
                      //     checkColor:
                      //         darkModeOn ? kMaterialBlack : Colors.white,
                      //     subtitle: Text(
                      //       "Use regular mini-player design.",
                      //       style: TextStyle(
                      //         color:
                      //             darkModeOn ? Colors.white38 : Colors.black38,
                      //       ),
                      //     ),
                      //     title: Text(
                      //       "Classix Mini-Player",
                      //       style: TextStyle(
                      //         color: darkModeOn ? Colors.white : Colors.black,
                      //       ),
                      //     ),
                      //     value: musicBox.get("classix") ?? true,
                      //     onChanged: (newValue) {
                      //       setState(() {
                      //         musicBox.put("classix", newValue);
                      //       });
                      //     },
                      //     controlAffinity: ListTileControlAffinity.leading,
                      //   ),
                      // ),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                            subtitle: const Text(
                              "Show progress in mini-player.",
                              style: TextStyle(
                                color: Colors.white38,
                              ),
                            ),
                            title: const Text(
                              "Mini-Player Progress",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            trailing: DropdownButton<String>(
                              value:
                                  musicBox.get("miniPlayerProgress") ?? "Top",
                              icon: const Icon(Icons.arrow_drop_down_rounded,
                                  color: Colors.white70),
                              elevation: 25,
                              enableFeedback: true,
                              borderRadius: BorderRadius.circular(kRounded / 2),
                              dropdownColor: kMaterialBlack.withOpacity(0.8),
                              underline: Container(
                                height: 2,
                                color: kCorrect,
                              ),
                              style: const TextStyle(color: Colors.white),
                              onChanged: (String? newValue) async {
                                await musicBox.put(
                                    "miniPlayerProgress", newValue);
                                setState(() {});
                              },
                              items: <String>[
                                'Top',
                                'Bottom',
                                'Hidden',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _lyricsTextColor() {
    final stored = musicBox.get('lyricsTextColor');
    if (stored is int) return Color(stored);
    return Colors.white;
  }

  Color _lyricsContainerColor() {
    final stored = musicBox.get('lyricsContainerColor');
    if (stored is int) return Color(stored);
    return Colors.black;
  }

  double _lyricsContainerOpacity() {
    final stored = musicBox.get('lyricsContainerOpacity');
    if (stored is num) return stored.toDouble().clamp(0.0, 1.0);
    return 0.7;
  }

  Widget _colorSwatch(Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54, width: 1.5),
      ),
    );
  }

  Future<Color?> _pickColor({
    required String title,
    required Color current,
  }) {
    const presets = <Color>[
      Colors.white,
      Colors.black,
      Color(0xFFBDBDBD),
      Color(0xFF90CAF9),
      Color(0xFFA5D6A7),
      Color(0xFFFFCC80),
      Color(0xFFEF9A9A),
      Color(0xFFCE93D8),
      Color(0xFF80CBC4),
      Color(0xFFFFF59D),
    ];

    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kMaterialBlack,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontFamily: 'Raleway'),
          ),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presets.map((color) {
              final selected = color.toARGB32() == current.toARGB32();
              return GestureDetector(
                onTap: () => Navigator.pop(context, color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? kCorrect : Colors.white38,
                      width: selected ? 3 : 1.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }
}
