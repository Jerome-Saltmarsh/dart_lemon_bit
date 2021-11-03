import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/paint.dart';
import 'package:bleed_client/state/environmentObjects.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectTypeToImage.dart';

final double _anchorX = 50;
final double _anchorY = 80;

void drawEnvironmentObjects() {
  for (EnvironmentObject environmentObject in environmentObjects) {
    globalCanvas.drawImage(
        mapEnvironmentObjectTypeToImage(environmentObject.type),
        Offset(environmentObject.x - _anchorX, environmentObject.y - _anchorY),
        paint);
  }
}
