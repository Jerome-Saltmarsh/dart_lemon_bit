
import 'package:image/image.dart';
import 'package:lemon_atlas/enums/character_type.dart';
import 'package:lemon_atlas/functions/build_character_kid.dart';
import 'package:lemon_atlas/functions/build_renders.dart';
import 'package:lemon_atlas/functions/build_character_fallen.dart';
import 'package:shell/shell.dart';

import 'package:flutter/material.dart';
import 'package:lemon_atlas/enums/kid_part.dart';
import 'package:lemon_atlas/enums/character_state.dart';
import 'package:lemon_atlas/ui/style.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

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

  void renderSelected() async {
    const blender = '"C:/Program Files/Blender Foundation/Blender 3.5/blender"';
    const script = 'C:/Users/Jerome/github/bleed/lemon_atlas/scripts/render.py';
    const blend = 'C:/Users/Jerome/github/bleed/resources/blender/character_kid.blend';
    const command = '$blender $blend --background --python $script';
    print(command);

    final process = await Shell().start(
      blender,
      arguments: [blend, '--background', '--python', script],
    );
    final exitCode = await process.exitCode;

    print(exitCode);
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

    buildRenders(images, rows: 1, columns: images.length);
  }
}
