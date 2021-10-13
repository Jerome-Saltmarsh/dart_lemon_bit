
import 'dart:ui';

import 'package:bleed_client/classes/InteractableNpc.dart';

RSTransform mapHumanToRSTransform(InteractableNpc npc) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: _frameWidthHalf,
    anchorY: _frameHeightHalf + 5,
    translateX: npc.x,
    translateY: npc.y,
  );
}

const int _frameWidth = 36;
const int _frameHeight = 35;
const double _frameWidthHalf = _frameWidth * 0.5;
const double _frameHeightHalf = _frameHeight * 0.5;