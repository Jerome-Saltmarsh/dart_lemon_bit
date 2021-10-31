import 'dart:ui';

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';

Image mapShadeToImage(Shading shading){
  switch(shading){
    case Shading.Bright:
      return images.tilesLight;
    case Shading.Medium:
      return images.tilesMedium;
    case Shading.Dark:
      return images.tilesDark;
    default:
      throw Exception("unknown shade");
  }
}
