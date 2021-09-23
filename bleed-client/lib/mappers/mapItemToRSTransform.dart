
import 'dart:ui';

import 'package:bleed_client/classes/Item.dart';

RSTransform mapItemToRSTransform(Item item){
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: 0,
    anchorY: 5,
    translateX: item.x,
    translateY: item.y,
  );
}