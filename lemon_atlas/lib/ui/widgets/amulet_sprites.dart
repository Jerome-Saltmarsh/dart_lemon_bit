
import 'package:flutter/material.dart';
import 'package:lemon_atlas/amulet/enums/src.dart';
import 'package:lemon_atlas/amulet/functions/build_character_fallen.dart';
import 'package:lemon_atlas/amulet/functions/build_character_kid.dart';
import 'package:lemon_atlas/atlas/functions/compress_sprite.dart';
import 'package:lemon_atlas/io/load_file_sprite.dart';
import 'package:lemon_atlas/ui/classes/style.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../actions/src.dart';

class AmuletSprites extends StatelessWidget {

  final perspective = Watch(Perspective.isometric);
  final changeNotifier = Watch(0);
  final style = Style();
  final characterType = Watch(CharacterType.kid);
  final activeKidParts = <KidPart>[];

  AmuletSprites({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
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
            buildTogglePerspective(),
            const SizedBox(width: 100),
            buildButtonCompress(),
            buildButtonRun(),
            buildButtonFile(),
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

  Widget buildButtonRun() {
    return onPressed(
            action: buildSelected,
            child: Container(
                padding: const EdgeInsets.all(16),
                child: buildText("RUN")),
          );
  }

  Widget buildButtonCompress() =>
    onPressed(
      action: onButtonPressedCompress,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: buildText("COMPRESS")),
    );

  Widget buildButtonFile() => Builder(
    builder: (context) => onPressed(
      action: () => showDialogLoadImage(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: buildText("FILE")),
      )
  );

  void selectCharacterType(CharacterType value){
    characterType.value = value;
  }

  void toggleKidPart(KidPart kidPart){
    if (activeKidParts.contains(kidPart)){
      activeKidParts.remove(kidPart);
    } else {
      activeKidParts.add(kidPart);
    }
    changeNotifier.value++;
  }

  void onButtonPressedCompress() async {
    final sprite = await loadFileSprite();
    if (sprite != null) {
      compressSprite(sprite);
    }
  }

  void buildSelected() async {

    const statesIsometric = [
      CharacterState.idle,
      CharacterState.dead,
      CharacterState.running,
      CharacterState.strike,
      CharacterState.change,
      CharacterState.fire,
    ];

    const statesFront = [
      CharacterState.idle,
    ];

    final states = perspective.value == Perspective.isometric ? statesIsometric : statesFront;

    switch (characterType.value){
      case CharacterType.kid:
        for (final state in states) {
          for (final part in activeKidParts) {
            await buildCharacterKid(
              state: state,
              part: part,
              perspective: perspective.value,
            );
          }
        }
        break;
      case CharacterType.fallen:
        exportCharacterFallen();
        break;
    }
  }

  void exportCharacterFallen() {
    const [
      CharacterState.strike,
      CharacterState.running,
      CharacterState.hurt,
      CharacterState.dead,
      CharacterState.idle,
    ].forEach(buildCharacterFallen);
  }

  Widget buildTogglePerspective() =>
      WatchBuilder(perspective, (perspective) => onPressed(
          action: togglePerspective,
          child: buildText(perspective.name, color: Colors.red),
      ));

  void togglePerspective() =>
      perspective.value =
      perspective.value == Perspective.isometric
          ? Perspective.front
          : Perspective
          .isometric;
}
