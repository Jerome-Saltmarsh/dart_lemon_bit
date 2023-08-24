
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:lemon_atlas/amulet/functions/build_character_fallen.dart';
import 'package:lemon_atlas/amulet/functions/build_character_kid.dart';
import 'package:lemon_atlas/amulet/enums/src.dart';
import 'package:lemon_atlas/atlas/functions/build_images.dart';
import 'package:lemon_atlas/ui/style.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'actions/load_images_convert_to_sprite_and_export_to_file.dart';

class AmuletSprites extends StatelessWidget {

  final changeNotifier = Watch(0);
  final Style style;

  final characterType = Watch(CharacterType.kid);
  final activeKidStates = <CharacterState>[];
  final activeKidParts = <KidPart>[];

  AmuletSprites({
    super.key,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMULET ATLAS',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('AMULET ATLAS'),
          actions: [
            onPressed(
              action: buildSelected,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: buildText("RUN")),
            ),
            onPressed(
              action: loadImagesFromFile,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: buildText("LOAD")),
            ),
            buildButtonAtlas(),
          ],
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            child:
                WatchBuilder(changeNotifier, (_){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: CharacterType.values.map((e) => onPressed(
                            action: () => selectCharacterType(e),
                            child: WatchBuilder(characterType, (activeCharacterType){
                                return buildText(e.name, color: activeCharacterType == e ? Colors.green : Colors.white70);
                            })
                  )).toList(growable: false)
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: CharacterState.values.map((e) => onPressed(
                            action: () => toggleKidState(e),
                            child: buildText(e.name, color: activeKidStates.contains(e) ? Colors.green : Colors.white70))).toList(growable: false),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: KidPart.values.map((e) => onPressed(
                            action: () => toggleKidPart(e),
                            child: buildText(e.name, color: activeKidParts.contains(e) ? Colors.green : Colors.white70))).toList(growable: false),
                      ),
                    ],
                  );
                })
          ),
        ),
      ),
    );
  }

  Widget buildButtonAtlas() => Builder(
    builder: (context) => onPressed(
      action: () => openLoadAtlasDialog(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: buildText("ATLAS")),
      )
  );

  void selectCharacterType(CharacterType value){
    characterType.value = value;
  }

  void toggleKidState(CharacterState kidState){
    if (activeKidStates.contains(kidState)){
      activeKidStates.remove(kidState);
    } else {
      activeKidStates.add(kidState);
    }
    changeNotifier.value++;
  }

  void toggleKidPart(KidPart kidPart){
    if (activeKidParts.contains(kidPart)){
      activeKidParts.remove(kidPart);
    } else {
      activeKidParts.add(kidPart);
    }
    changeNotifier.value++;
  }

  void buildSelected() {

    switch (characterType.value){
      case CharacterType.kid:
        for (final state in activeKidStates) {
          for (final part in activeKidParts) {
            buildCharacterKid(
              state: state,
              part: part,
            );
          }
        }
        break;
      case CharacterType.fallen:
        activeKidStates.forEach(buildCharacterFallen);
        break;
    }
  }

  void loadImagesFromFile() async {
    final files = await loadFilesFromDisk();
    if (files == null) throw Exception();
    final images = files
        .map((file) => decodeImage(file.bytes ?? (throw Exception())) ?? (throw Exception()))
        .toList(growable: false);

    buildImages(
        images,
        rows: 1,
        columns: images.length,
        directory: '${Directory.current.path}/assets/tmp',
        name: 'export',
    );
  }

  void openLoadAtlasDialog(BuildContext context) =>
      showDialog(context: context, builder: (dialogContext) {
        final rows = WatchInt(1, min: 1);
        final columns = WatchInt(1, min: 1);
        return AlertDialog(
        title: buildText('Load Atlas'),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRowWatchInt(rows, "ROWS"),
            buildRowWatchInt(columns, "COLUMNS"),
            onPressed(
              action: () => loadImagesConvertToSpriteAndExportToFile(
                  rows: rows.value,
                  columns: columns.value,
                ),
                child: buildText("NEXT"),
            )
          ],
        ),
      );
      });

  Widget buildRowWatchInt(WatchInt value, String name) => SizedBox(
    height: 60,
    width: 250,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 90,
                alignment: Alignment.centerLeft,
                child: buildText(name, color: Colors.white70)
              ),
              WatchBuilder(value, buildText),
            ],
          ),
          Row(
            children: [
              onPressed(
                action: value.decrement,
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  color: Colors.black12,
                  child: buildText('-'),
                ),
              ),
              onPressed(
                action: value.increment,
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  color: Colors.black12,
                  child: buildText('+'),
                ),
              ),
            ],
          )

        ],
      ),
  );
}
