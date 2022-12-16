import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

class GameLighting {
  static final Default_Color_Start =  Color.fromRGBO(38, 34, 47, 1.0).withOpacity(0);
  static final Default_Color_End =    Color.fromRGBO(47, 34, 39, 1.0).withOpacity(1);

  static final Color_Lightning = Colors.white.withOpacity(Engine.GoldenRatio_0_381);

  static final Hue = Watch(0.0, onChanged: (double hueValue){
     assert(hueValue >= 0);
     hueValue = (hueValue) % 360.0;
     Color_Start_Hue = hueValue;
     Color_End_Hue = hueValue + Hue_Shift.value;
  });

  static final Color_Start = Watch(Default_Color_Start, onChanged: refreshShades);
  static final Color_End = Watch(Default_Color_End, onChanged: refreshShades);
  static final Hue_Shift = Watch(randomBetween(0, 360), onChanged: refreshHues);
  static final Hue_Offset = Watch(randomBetween(0, 360), onChanged: refreshHues);

  static void refreshHues([double value = 0.0]){
    Color_Start_Hue = Hue.value + Hue_Offset.value;
    Color_End_Hue = Color_Start_Hue + Hue_Shift.value;
  }

  static double get Color_Start_Hue => HSVColor.fromColor(Color_Start.value).hue;
  static double get Color_End_Hue => HSVColor.fromColor(Color_End.value).hue;

  static set Color_Start_Hue(double value) {
    assert(value >= 0);
    Color_Start.value = HSVColor.fromColor(Color_Start.value).withHue(value % 360.0).toColor().withOpacity(0);
  }

  static set Color_End_Hue(double value) {
    assert(value >= 0);
    Color_End.value = HSVColor.fromColor(Color_End.value).withHue(value % 360.0).toColor();
  }

  static set ColorEndOpacity(double value){
    // if (colorEnd.value.opacity == value) return;
    if ((Color_End.value.opacity - value).abs() < 0.01) return;
    Color_End.value = Color_End.value.withOpacity(value);
  }

  static final V0 = Watch(0.00, onChanged: refreshShades);
  static final V1 = Watch(0.20, onChanged: refreshShades);
  static final V2 = Watch(0.40, onChanged: refreshShades);
  static final V3 = Watch(0.60, onChanged: refreshShades);
  static final V4 = Watch(0.80, onChanged: refreshShades);
  static final V5 = Watch(0.92, onChanged: refreshShades);
  static final V6 = Watch(1.00, onChanged: refreshShades);

  static final VArray = [
    V0, V1, V2, V3, V4, V5, V6
  ];

  static final Color_Shades = Uint32List(7);
  static final Transparent =  GameColors.black.withOpacity(0.5).value;

  static void refreshShades([dynamic v]){
    final start = HSVColor.fromColor(Color_Start.value);
    final end = HSVColor.fromColor(Color_End.value);
    Color_Shades[0] = HSVColor.lerp(start, end, V0.value)!.toColor().value;
    Color_Shades[1] = HSVColor.lerp(start, end, V1.value)!.toColor().value;
    Color_Shades[2] = HSVColor.lerp(start, end, V2.value)!.toColor().value;
    Color_Shades[3] = HSVColor.lerp(start, end, V3.value)!.toColor().value;
    Color_Shades[4] = HSVColor.lerp(start, end, V4.value)!.toColor().value;
    Color_Shades[5] = HSVColor.lerp(start, end, V5.value)!.toColor().value;
    Color_Shades[6] = HSVColor.lerp(start, end, V6.value)!.toColor().value;
  }
}