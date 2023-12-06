import 'package:amulet_flutter/isometric/functions/get_render.dart';
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:amulet_engine/packages/lemon_math.dart';

class AmuletWorldMap extends StatelessWidget {
  final Amulet amulet;
  final paint = Paint()..color = Colors.white;
  final double size;
  final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
  );
  final textSpanHello = const TextSpan(style: TextStyle(color: Colors.white), text: 'hello');

  AmuletWorldMap({
    super.key,
    required this.amulet,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    print('amuletWorldMap.build()');

    final canvas = CustomCanvas(
      paint: (canvas, canvasSize) {
        final amulet = this.amulet;
        final worldMapPicture = amulet.worldMapPicture;
        if (worldMapPicture == null) {
          return;
        }

        const zoom = 2.5;

        canvas.scale(zoom, zoom);
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
        paint.color = Colors.white;

        final playerRenderX = getRenderX(posX, posY);
        final playerRenderY = getRenderY(posX, posY, 0);
        // final translateX = centerX - posX;
        // final translateY = centerY - posY;

        final cameraX = playerRenderX - (centerX / zoom);
        final cameraY = playerRenderY - (centerY / zoom);
        // canvas.translate(centerX, -50);
        canvas.rotate(piQuarter);
        canvas.translate(-cameraX, -cameraY);
        // canvas.translate(translateX, translateY);
        /// TODO Memory leak
        final renderPos = Offset(getRenderX(posX, posY), getRenderY(posX, posY, 0));
        canvas.drawImage(worldMapPicture, const Offset(0, 0), paint);
        canvas.rotate(-piQuarter);
        canvas.drawCircle(renderPos, 1, paint);
        textPainter.text = textSpanHello;
        textPainter.layout();
        textPainter.paint(canvas, renderPos);
        paint.color = Colors.blue;
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
            child: canvas,
          ),
      ),
    );
  }
}
