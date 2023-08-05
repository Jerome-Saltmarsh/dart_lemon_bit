
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as ui;
import 'package:image/image.dart';
import 'package:lemon_sprites/sprites/sprite.dart';
import 'package:lemon_sprites/sprites/style.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'functions/load_bytes_from_file.dart';

class SpriteApp extends StatelessWidget {

  final Sprite sprite;
  final Style style;

  const SpriteApp({
    super.key,
    required this.sprite,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LEMON-SPRITES',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('LEMON-SPRITES'),
          actions: [
            buildButtonLoad(),
            buildButtonPack(),
          ],
        ),
        body: Center(
          child: buildImage(),
        ),
      ),
    );
  }

  Widget buildButtonPack() =>
      WatchBuilder(sprite.image, (image) => buildButton(
        action: image == null ? null : sprite.pack,
        child: buildText('PACK',
          color: image == null ? Colors.black54 : Colors.black87,
        ),
      ));

  Widget buildButtonLoad() =>
      buildButton(
        action: onLoadButtonPressed,
        child: buildButtonText('LOAD'),
      );

  Widget buildButtonText(String value) =>
      buildText(value, color: style.buttonTextColor);

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

  Widget buildImage() => WatchBuilder(sprite.image, (image) {
    if (image == null) {
      return nothing;
    }
    return ui.Image.memory(encodePng(image));
  });

  Future onLoadButtonPressed() async {
    final image = await loadImageFromFile();
    if (image == null) {
      return;
    }
    sprite.image.value = image;
  }
}
