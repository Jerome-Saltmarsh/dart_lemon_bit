import 'package:amulet_engine/packages/lemon_math.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/isometric/functions/get_render.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/lemon_engine.dart';

class AmuletWorldMap extends StatelessWidget {
  final Amulet amulet;
  final paint = Paint()..color = Colors.white;
  final double size;
  final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
  );
  final textSpanHello = const TextSpan(style: TextStyle(color: Colors.white), text: 'hello');

  var targetX = 0.0;
  var targetY = 0.0;
  var cameraX = 0.0;
  var cameraY = 0.0;
  var screenWidth = 0.0;
  var screenHeight = 0.0;
  var zoom = 1.0;
  var scrollSensitivity = 0.00025;
  var followSensitivity = 0.001;

  static const zoomMin = 0.2;
  static const zoomMax = 6.0;



  AmuletWorldMap({
    super.key,
    required this.amulet,
    required this.size,
  });

  void _internalOnPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      zoom -=  event.scrollDelta.dy * scrollSensitivity;
      zoom = zoom.clamp(zoomMin, zoomMax);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('amuletWorldMap.build()');

    final canvas = Listener(
      onPointerSignal: _internalOnPointerSignal,
      child: CustomCanvas(
        paint: (canvas, canvasSize) {
          final amulet = this.amulet;
          final worldMapPicture = amulet.worldMapPicture;
          if (worldMapPicture == null) {
            return;
          }

          screenWidth = canvasSize.width;
          screenHeight = canvasSize.height;

          canvas.scale(zoom, zoom);
          const mapSize = 100.0;
          final player = amulet.player;
          final position = player.position;
          final scene = amulet.scene;
          final ratioX = position.x / scene.lengthRows;
          final ratioY = position.y / scene.lengthColumns;
          final posX = amulet.worldRow * mapSize + (mapSize * ratioX);
          final posY = amulet.worldColumn * mapSize + (mapSize * ratioY);
          paint.color = Colors.white;

          targetX = getRenderX(posX, posY);
          targetY = getRenderY(posX, posY, 0);
          canvas.translate(-cameraX, -cameraY);
          canvas.rotate(piQuarter);
          /// TODO Memory leak
          final targetOffset = Offset(targetX, targetY);
          canvas.drawImage(worldMapPicture, const Offset(0, 0), paint);
          canvas.rotate(-piQuarter);
          // canvas.rotate(-piQuarter);
          canvas.drawCircle(targetOffset, 2, paint);
          // canvas.drawCircle(Offset(screenCenterWorldX, screenCenterWorldY), 4, paint);
          // canvas.drawCircle(Offset(cameraX, cameraY), 6, paint);
          textPainter.text = textSpanHello;
          textPainter.layout();
          textPainter.paint(canvas, targetOffset);
          paint.color = Colors.blue;
          cameraFollowTarget(followSensitivity);
        },
      ),
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

  void cameraFollowTarget([double speed = 0.00075]) {
    final diffX = screenCenterWorldX - targetX;
    final diffY = screenCenterWorldY - targetY;
    cameraX -= (diffX * 75) * speed;
    cameraY -= (diffY * 75) * speed;
  }

  double get screenCenterX => screenWidth * 0.5;
  double get screenCenterY => screenHeight * 0.5;
  double get screenCenterWorldX => screenToWorldX(screenCenterX);
  double get screenCenterWorldY => screenToWorldY(screenCenterY);

  double screenToWorldX(double value)  =>
      cameraX + value / zoom;

  double screenToWorldY(double value) =>
      cameraY + value / zoom;
}
