import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

import 'classes/GameColor.dart';


class GameLighting {
  static final Default_Color_Start =  HSVColor.fromColor(Color.fromRGBO(38, 34, 47, 1.0).withOpacity(0));
  static final Default_Color_End =    Color.fromRGBO(47, 34, 39, 1.0).withOpacity(1);
  static final Color_Lightning = HSVColor.fromColor(Colors.white.withOpacity(Engine.GoldenRatio_0_381));
  static final Hue = Watch(0.0, onChanged: onChangedLighting);
  static final Color_Start = Watch(Default_Color_Start);
  static final Color_End = Watch(Default_Color_End);
  static final Hue_Shift = Watch(randomBetween(0, 360), onChanged: onChangedLighting);
  static final V0 = Watch(0.00, onChanged: onChangedLighting);
  static final V1 = Watch(0.20, onChanged: onChangedLighting);
  static final V2 = Watch(0.40, onChanged: onChangedLighting);
  static final V3 = Watch(0.60, onChanged: onChangedLighting);
  static final V4 = Watch(0.80, onChanged: onChangedLighting);
  static final V5 = Watch(0.92, onChanged: onChangedLighting);
  static final V6 = Watch(1.00, onChanged: onChangedLighting);

  static final VArray = [
    V0, V1, V2, V3, V4, V5, V6
  ];

  static final Color_Shades = gameCols.values;
  static final Transparent =  GameColors.black.withOpacity(0.5).value;

  // GETTERS

  static double get Color_Start_Hue => Color_Start.value.hue;
  static double get Color_End_Hue => HSVColor.fromColor(Color_End.value).hue;

  // SETTERS

  static set Color_Start_Hue(double value) {
    assert(value >= 0);
    Color_Start.value = HSVColor.fromAHSV(0, value, Color_Start.value.saturation, Color_Start.value.value);
  }

  static set Color_End_Hue(double value) {
    assert(value >= 0);
    Color_End.value = HSVColor.fromColor(Color_End.value).withHue(value % 360.0).toColor();
  }

  static set ColorEndOpacity(double value){
    if ((Color_End.value.opacity - value).abs() < 0.01) return;
    Color_End.value = Color_End.value.withOpacity(value);
  }

  // REACTIONS

  static void onChangedLighting(double v) => refreshShades();

  // METHODS

  /// EXPENSIVE OPERATION
  static void refreshShades(){
    gameCols.refreshValues();
    // Color_Start_Hue = Hue.value;
    // Color_End_Hue = Hue.value + Hue_Shift.value;
    //
    // final start = Color_Start.value;
    // final end = HSVColor.fromColor(Color_End.value);
    // Color_Shades[0] = HSVColor.lerp(start, end, V0.value)!.toColor().value;
    // Color_Shades[1] = HSVColor.lerp(start, end, V1.value)!.toColor().value;
    // Color_Shades[2] = HSVColor.lerp(start, end, V2.value)!.toColor().value;
    // Color_Shades[3] = HSVColor.lerp(start, end, V3.value)!.toColor().value;
    // Color_Shades[4] = HSVColor.lerp(start, end, V4.value)!.toColor().value;
    // Color_Shades[5] = HSVColor.lerp(start, end, V5.value)!.toColor().value;
    // Color_Shades[6] = HSVColor.lerp(start, end, V6.value)!.toColor().value;
  }
}

