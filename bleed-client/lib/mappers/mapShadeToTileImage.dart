import 'dart:ui';

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';

Image mapShadeToImage(Shade shading){
  switch(shading){
    case Shade.Bright:
      return images.tilesLight;
    case Shade.Medium:
      return images.tilesMedium;
    case Shade.Dark:
      return images.tilesDark;
    default:
      throw Exception("unknown shade");
  }
}
