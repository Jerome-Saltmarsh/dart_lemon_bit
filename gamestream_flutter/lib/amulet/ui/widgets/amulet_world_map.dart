import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:lemon_engine/lemon_engine.dart';

class AmuletWorldMap extends StatelessWidget {
  final Amulet amulet;
  final paint = Paint()..color = Colors.white;
  final double size;
  var frame = 0;

  AmuletWorldMap({
    super.key,
    required this.amulet,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {


    final canvas = CustomCanvas(
      paint: (canvas, size) {
        final amulet = this.amulet;
        final worldMapPicture = amulet.worldMapPicture;
        if (worldMapPicture == null) {
          return;
        }

        const size = 100.0;

        final player = amulet.player;
        final position = player.position;
        final scene = amulet.scene;
        final ratioX = position.x / scene.lengthRows;
        final ratioY = position.y / scene.lengthColumns;
        final posX = amulet.worldRow * size + (size * ratioX);
        final posY = amulet.worldColumn * size + (size * ratioY);
        // final globalLengthX = size * amulet.worldRow;
        // final globalLengthY = size * amulet.worldColumns;

        paint.color = Colors.red;
        // canvas.translate(posX - (size * 0.5), posY - (size * 0.5));
        canvas.drawPicture(worldMapPicture);
        canvas.drawCircle(Offset(posX, posY), 10, paint);
      },
    );

    return Container(
        width: size,
        height: size,
        color: Colors.white,
        child: CustomTicker(
          onTrick: (duration) {
            frame++;
          },
          child: canvas,
        ),
      );
  }
}
