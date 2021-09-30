
import 'dart:ui';

import 'package:bleed_client/common/classes/Vector2.dart';

RSTransform mapCrateToRSTransform(Vector2 crate){
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: 24,
    anchorY: 48,
    translateX: crate.x,
    translateY: crate.y,
  );
}