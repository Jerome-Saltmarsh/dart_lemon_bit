

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:lemon_engine/lemon_engine.dart';

class AmuletWorldMap extends StatelessWidget {
  final Amulet amulet;
  var frame = 0;

  AmuletWorldMap({
    super.key,
    required this.amulet,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 200,
    height: 200,
    color: Colors.white,
    child: CustomTicker(
      onTrick: (duration){
        frame++;
      },
      child: CustomCanvas(
        paint: (canvas, size) {
          final worldMapPicture = amulet.worldMapPicture;
          if (worldMapPicture == null) {
            return;
          }
          canvas.translate(frame.toDouble(), 0);
          canvas.drawPicture(worldMapPicture);
        },
        // frame: amulet.worldMapFrame,
      ),
    ),
  );
}
