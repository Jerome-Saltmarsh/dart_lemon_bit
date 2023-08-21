
import 'package:flutter/material.dart';
import 'package:lemon_atlas/sprites/kid_part.dart';
import 'package:lemon_atlas/sprites/kid_state.dart';
import 'package:lemon_atlas/sprites/sprite.dart';
import 'package:lemon_atlas/sprites/style.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class AmuletSprites extends StatelessWidget {

  final changeNotifier = Watch(0);
  final Sprite sprite;
  final Style style;

  final activeKidStates = <KidState>[];
  final activeKidParts = <KidPart>[];

  AmuletSprites({
    super.key,
    required this.sprite,
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
              action: packSelected,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: buildText("PACK")),
            ),
            onPressed(
              action: packSelected,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: buildText("SPRITE")),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: KidState.values.map((e) => onPressed(
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

  void toggleKidState(KidState kidState){
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

  void packSelected() {
    for (final state in activeKidStates) {
      for (final part in activeKidParts) {
        sprite.buildKidStateAndPart(
            state: state,
            part: part,
            rows: 8,
            columns: 8,
        );
      }
    }
  }
}
