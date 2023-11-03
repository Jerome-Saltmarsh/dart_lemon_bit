import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_math/src.dart';

class AmuletWorldMap extends StatelessWidget {
  final Amulet amulet;
  final paint = Paint()..color = Colors.white;
  final double size;

  AmuletWorldMap({
    super.key,
    required this.amulet,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {


    final canvas = CustomCanvas(
      paint: (canvas, canvasSize) {
        final amulet = this.amulet;
        final worldMapPicture = amulet.worldMapPicture;
        if (worldMapPicture == null) {
          return;
        }

        const mapSize = 100.0;
        final canvasWidth = canvasSize.width;
        final canvasHeight = canvasSize.height;
        final centerX = canvasWidth * 0.5;
        final centerY = canvasHeight * 0.5;
        final player = amulet.player;
        final position = player.position;
        final scene = amulet.scene;
        final ratioX = position.x / scene.lengthRows;
        final ratioY = position.y / scene.lengthColumns;
        final posX = amulet.worldRow * mapSize + (mapSize * ratioX);
        final posY = amulet.worldColumn * mapSize + (mapSize * ratioY);
        paint.color = Colors.red;

        final translateX = centerX - posX;
        final translateY = centerY - posY;

        canvas.translate(centerX, -50);
        canvas.rotate(piQuarter);
        canvas.translate(translateX, translateY);

        canvas.drawImage(worldMapPicture, Offset(0, 0), paint);
        canvas.drawCircle(Offset(posX, posY), 5, paint);
        paint.color = Colors.blue;
        // canvas.drawCircle(Offset(centerX, centerY), 5, paint);



      },
    );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: amulet.style.containerColor,
      ),
      child: ClipOval(
        child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: amulet.style.containerColor,
            ),
            child: CustomTicker(
              onTrick: (duration) {

              },
              child: canvas,
            ),
          ),
      ),
    );
  }
}
