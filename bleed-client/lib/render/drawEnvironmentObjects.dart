import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectTypeToImage.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';

final double _anchorX = 50;
final double _anchorY = 80;

void drawEnvironmentObjects() {
  for (EnvironmentObject environmentObject in game.environmentObjects) {
    globalCanvas.drawImage(
        mapEnvironmentObjectTypeToImage(environmentObject.type),
        Offset(environmentObject.x - _anchorX, environmentObject.y - _anchorY),
        paint);
  }
}
