
import 'package:amulet_client/classes/amulet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_math/src.dart';

class AmuletWorldMap extends StatelessWidget {
  final Amulet amulet;
  final paint = Paint()..color = Colors.white;
  final double size;
  final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
  );
  final textSpanHello = const TextSpan(style: TextStyle(color: Colors.white), text: 'village');

  var cameraX = 50.0;
  var cameraY = 50.0;
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
          final worldPosX = amulet.worldRow * mapSize;
          final worldPosY = amulet.worldColumn * mapSize;
          final posX = worldPosX + (mapSize * ratioX);
          final posY = worldPosY + (mapSize * ratioY);
          paint.color = Colors.white;

          cameraX = posX;
          cameraY = posY;

          canvas.translate(-cameraX + screenCenterWorldX, -cameraY + screenCenterWorldY);
          canvas.rotate(piQuarter);
          canvas.translate(-cameraX, -cameraY);
          /// TODO Memory leak
          final targetOffset = Offset(cameraX, cameraY);
          canvas.drawImage(worldMapPicture, const Offset(0, 0), paint);
          canvas.drawCircle(targetOffset, 2, paint);

          // final offsetVillage = Offset(
          //     getRotationX(cameraX, cameraY, piQuarter),
          //     getRotationY(cameraX, cameraY, piQuarter),
          // );
          canvas.rotate(-piQuarter);
          final worldLocations = amulet.worldLocations;

          for (final worldLocation in worldLocations) {
            textPainter.text = worldLocation.textSpan;
            textPainter.layout();
            textPainter.paint(canvas, worldLocation.offset);
            canvas.drawCircle(worldLocation.offset, 2, paint);
          }
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

  double get screenCenterX => screenWidth * 0.5;
  double get screenCenterY => screenHeight * 0.5;
  double get screenCenterWorldX => screenToWorldX(screenCenterX);
  double get screenCenterWorldY => screenToWorldY(screenCenterY);

  double screenToWorldX(double value)  =>
      cameraX + value / zoom;

  double screenToWorldY(double value) =>
      cameraY + value / zoom;


}
