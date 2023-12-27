import 'package:amulet_engine/packages/lemon_math.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
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

  // double get cameraX => amulet.engine.cameraX / 48.0;
  // double get cameraY => amulet.engine.cameraY / 48.0;
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

          // targetX = 0.0;
          // targetY = 0.0;
          // canvas.translate(-cameraX + screenCenterWorldX, -cameraY + screenCenterWorldY);

          cameraX = posX;
          cameraY = posY;

          canvas.translate(-cameraX + screenCenterWorldX, -cameraY + screenCenterWorldY);
          canvas.rotate(piQuarter);
          canvas.translate(-cameraX, -cameraY);
          /// TODO Memory leak
          final targetOffset = Offset(cameraX, cameraY);
          canvas.drawImage(worldMapPicture, const Offset(0, 0), paint);
          // canvas.rotate(-piQuarter);
          canvas.drawCircle(targetOffset, 2, paint);
          // textPainter.text = textSpanHello;
          // textPainter.layout();
          // textPainter.paint(canvas, targetOffset);
          // paint.color = Colors.blue;
          // cameraFollowTarget(followSensitivity);
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

  // void cameraFollowTarget([double speed = 0.00075]) {
  //   // final diffX = screenCenterWorldX - targetX;
  //   // final diffY = screenCenterWorldY - targetY;
  //   cameraX -= (targetX * 75) * speed;
  //   cameraY -= (diffY * 75) * speed;
  // }

  double get screenCenterX => screenWidth * 0.5;
  double get screenCenterY => screenHeight * 0.5;
  double get screenCenterWorldX => screenToWorldX(screenCenterX);
  double get screenCenterWorldY => screenToWorldY(screenCenterY);

  double screenToWorldX(double value)  =>
      cameraX + value / zoom;

  double screenToWorldY(double value) =>
      cameraY + value / zoom;


  // void renderSpriteRotated({
  //   required ui.Image image,
  //   required double srcX,
  //   required double srcY,
  //   required double srcWidth,
  //   required double srcHeight,
  //   required double dstX,
  //   required double dstY,
  //   required double rotation,
  //   double anchorX = 0.5,
  //   double anchorY = 0.5,
  //   double scale = 1.0,
  //   int color = 1,
  // }){
  //   final scos = cos(rotation) * scale;
  //   final ssin = sin(rotation) * scale;
  //
  //   final width = -scos * anchorX + ssin * anchorY;
  //   final height = -ssin * anchorX - scos * anchorY;
  //
  //   final tx = dstX + width;
  //   final ty = dstY + height;
  //
  //   final scaledHeight = srcHeight * scale * anchorY;
  //   final scaledWidth = srcWidth * scale * anchorX;
  //
  //   const piHalf = pi * 0.5;
  //
  //   final adjX = adj(rotation - piHalf, scaledHeight);
  //   final adjY = opp(rotation - piHalf, scaledHeight);
  //
  //   final adjY2 = adj(rotation - piHalf, scaledWidth);
  //   final adjX2 = opp(rotation - piHalf, scaledWidth);
  //
  //   bufferImage = image;
  //   render(
  //     color: color,
  //     srcLeft: srcX,
  //     srcTop: srcY,
  //     srcRight: srcX + srcWidth,
  //     srcBottom: srcY + srcHeight,
  //     scale: cos(rotation) * scale,
  //     rotation: sin(rotation) * scale,
  //     dstX: tx + adjX2 + adjX,
  //     dstY: ty - adjY2 + adjY,
  //   );
  // }

}
