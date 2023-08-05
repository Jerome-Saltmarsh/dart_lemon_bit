import 'package:flutter/material.dart';
import 'package:lemon_sprites/sprites/sprite.dart';
import 'package:lemon_sprites/sprites/style.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

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
          ],
        ),
        body: Center(
          child: buildImage(),
        ),
      ),
    );
  }

  Widget buildButtonLoad() =>
      onPressed(
        action: sprite.loadImage,
        child: Container(
          padding: style.buttonPadding,
          child: buildText('LOAD', color: style.buttonTextColor),
        ),
      );

  Widget buildImage() => WatchBuilder(sprite.image, (image) =>
    image == null ? nothing : Image.memory(image));
}
