import 'package:flutter/painting.dart';

class Visibility {
  static const Opaque = 0;
  static const Transparent = 1;
  static const Invisible = 2;
}

class VisibilityBlendModes {
  static const Opaque = BlendMode.dstATop;
  static const Transparent = BlendMode.srcIn;

  static BlendMode fromVisibility(int value){
     if (value == Visibility.Transparent) {
       return Transparent;
     }
     return Opaque;
  }
}