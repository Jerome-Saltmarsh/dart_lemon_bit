
import 'dart:ui';

import 'package:gamestream_flutter/classes/Item.dart';

RSTransform mapItemToRSTransform(Item item){
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: 24,
    anchorY: 48,
    translateX: item.x,
    translateY: item.y,
  );
}