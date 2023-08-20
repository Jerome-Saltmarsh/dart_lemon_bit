
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as ui;
import 'package:image/image.dart' as img;
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
              action: sprite.compile,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: buildText("COMPILE")),
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

  Widget buildControlColumns() => buildControlWatchInt(sprite.columns, 'Columns');

  Widget buildControlRows() => buildControlWatchInt(sprite.rows, 'Rows');

  Widget buildControlWatchInt(WatchInt watchInt, String title) => Row(
            children: [
              text(title),
              WatchBuilder(watchInt, text),
              buildButton(
                  action: watchInt.decrement,
                  child: text('-'),
              ),
              buildButton(
                  action: watchInt.increment,
                  child: text('+'),
              ),
            ],
          );

  Widget buildButtonBind() =>
      WatchBuilder(sprite.imageSet, (imageSet) => buildButton(
        action: imageSet ? sprite.bind : null,
        child: buildText('BIND',
          color: imageSet ? Colors.black87 : Colors.black54,
        ),
      ));

  Widget buildButtonPack() =>
      WatchBuilder(sprite.previewBound, (image) => buildButton(
        action: image == null ? null : sprite.pack,
        child: buildText('PACK',
          color: image == null ? Colors.black54 : Colors.black87,
        ),
      ));

  Widget buildButtonLoad() =>
      buildButton(
        action: onButtonLoadPressed,
        child: buildButtonText('LOAD'),
      );

  Widget buildButtonCells() =>
      buildButton(
        action: sprite.buildCells,
        child: buildButtonText('Cells'),
      );

  Widget buildButtonAtlas() =>
      buildButton(
        action: sprite.buildAtlas,
        child: buildButtonText('Atlas'),
      );

  void onButtonLoadPressed() async {
    final files = await loadFilesFromDisk();
    if (files == null) {
      return;
    }
    sprite.loadFiles(files);
  }

  Widget buildButtonText(String value) =>
      buildText(value, color: style.buttonTextColor);

  Widget text(dynamic value) => buildText(value, color: style.textColor);

  Widget buildButton({
    required Widget child,
    Function? action,
  }) => onPressed(
    action: action,
    child: Container(
        padding: style.buttonPadding,
        child: child,
      ),
  );

  Future loadImage() async {
    final image = await loadImageFromFile();
    if (image == null) {
      return;
    }
    sprite.image = image;
  }

  Widget buildImage() => buildWatchImage(sprite.imageWatch);

  Widget buildImageGrid() => buildWatchImage(sprite.previewGrid);

  Widget buildBound() => buildWatchImage(sprite.previewBound);

  Widget buildPacked() => buildWatchImage(sprite.previewPacked);

  Widget buildWatchImage(Watch<img.Image?> watch) => SizedBox(
    width: style.imageWidth,
    child: WatchBuilder(watch, (image) {
      if (image == null) {
        return buildText('-', color: Colors.black38);
      }
      return ui.Image.memory(img.encodePng(image));
    }),
  );

  Widget buildButtonSave() => WatchBuilder(sprite.previewPacked, (image) => buildButton(
      action: image == null ? null : sprite.save,
      child: buildText('SAVE',
        color: image == null ? Colors.black54 : Colors.black87,
      ),
    ));

  Widget buildControlReduction() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: WatchBuilder(sprite.reduction, (reduction) {
         if (reduction <= 0){
           return nothing;
         }
         return text('Reduction: $reduction%');
      }),
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
}
