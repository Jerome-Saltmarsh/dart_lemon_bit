
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

class GameConstants {
  static const Node_Height = 24.0;
  static const Sprite_Width = 48.0;
  static const Sprite_Width_Half = 24.0;
  static const Sprite_Width_Padded = Sprite_Width + 1;
  static const Sprite_Height = 72.0;
  static const Sprite_Height_Third = 24.0;
  static const Sprite_Height_Padded = Sprite_Height + 1;
  static const Sprite_Height_Padded_00 = Sprite_Height_Padded * 0;
  static const Sprite_Height_Padded_01 = Sprite_Height_Padded * 1;
  static const Sprite_Height_Padded_02 = Sprite_Height_Padded * 2;
  static const Sprite_Height_Padded_03 = Sprite_Height_Padded * 3;
  static const Sprite_Height_Padded_04 = Sprite_Height_Padded * 4;
  static const Sprite_Height_Padded_05 = Sprite_Height_Padded * 5;
  static const Sprite_Height_Padded_06 = Sprite_Height_Padded * 6;
  static const Sprite_Height_Padded_07 = Sprite_Height_Padded * 7;
  static const Sprite_Height_Padded_08 = Sprite_Height_Padded * 8;
  static const Sprite_Height_Padded_09 = Sprite_Height_Padded * 9;
  static const Sprite_Height_Padded_10 = Sprite_Height_Padded * 10;
  static const Sprite_Height_Padded_11 = Sprite_Height_Padded * 11;
  static const Sprite_Height_Padded_12 = Sprite_Height_Padded * 12;
  static const Sprite_Height_Padded_13 = Sprite_Height_Padded * 13;
  static const Sprite_Height_Padded_14 = Sprite_Height_Padded * 14;
  static const Sprite_Height_Padded_15 = Sprite_Height_Padded * 15;
  static const Sprite_Height_Padded_16 = Sprite_Height_Padded * 16;
  static const Sprite_Height_Padded_17 = Sprite_Height_Padded * 17;
  static const Sprite_Height_Padded_18 = Sprite_Height_Padded * 18;
  static const Sprite_Height_Padded_19 = Sprite_Height_Padded * 19;

  static const Sprite_Anchor_Y = 0.3;
  static const Frames_Per_Particle_Animation_Frame = 2;

  static const Shade_Opacities = [0.0, 0.4, 0.6, 0.7, 0.8, 0.95, 1.0];
  static const Shade_Opacities_Transparent = [0.0, 0.2, 0.3, 0.35, 0.4, 0.45, 0.5];
  // static final Color_Shades = Shade_Opacities
  //     .map((opacity) => GameColors.black.withOpacity(opacity).value)
  //     .toList(growable: false);



  static var colorStart = HSVColor.fromColor(Color.fromRGBO(38, 34, 47, 1.0).withOpacity(0));
  static var colorEnd = HSVColor.fromColor(Color.fromRGBO(47, 34, 39, 1.0));

  static final V0 = Watch(0.00, onChanged: onChangedV);
  static final V1 = Watch(0.20, onChanged: onChangedV);
  static final V2 = Watch(0.40, onChanged: onChangedV);
  static final V3 = Watch(0.60, onChanged: onChangedV);
  static final V4 = Watch(0.80, onChanged: onChangedV);
  static final V5 = Watch(0.92, onChanged: onChangedV);
  static final V6 = Watch(1.00, onChanged: onChangedV);

  static final C0 = HSVColor.lerp(colorStart, colorEnd, V0.value);
  static final C1 = HSVColor.lerp(colorStart, colorEnd, V1.value);
  static final C2 = HSVColor.lerp(colorStart, colorEnd, V2.value);
  static final C3 = HSVColor.lerp(colorStart, colorEnd, V3.value);
  static final C4 = HSVColor.lerp(colorStart, colorEnd, V4.value);
  static final C5 = HSVColor.lerp(colorStart, colorEnd, V5.value);
  static final C6 = HSVColor.lerp(colorStart, colorEnd, V6.value);

  static void onChangedV(double v) => refreshShades();

  static void refreshShades(){
     Color_Shades[0] = HSVColor.lerp(colorStart, colorEnd, V0.value)!.toColor().value;
     Color_Shades[1] = HSVColor.lerp(colorStart, colorEnd, V1.value)!.toColor().value;
     Color_Shades[2] = HSVColor.lerp(colorStart, colorEnd, V2.value)!.toColor().value;
     Color_Shades[3] = HSVColor.lerp(colorStart, colorEnd, V3.value)!.toColor().value;
     Color_Shades[4] = HSVColor.lerp(colorStart, colorEnd, V4.value)!.toColor().value;
     Color_Shades[5] = HSVColor.lerp(colorStart, colorEnd, V5.value)!.toColor().value;
     Color_Shades[6] = HSVColor.lerp(colorStart, colorEnd, V6.value)!.toColor().value;
  }

  static final Color_Shades = [
    C0,
    C1,
    C2,
    C3,
    C4,
    C5,
    C6,
  ].map((e) => e!.toColor().value).toList(growable: false);

  static final Transparent =  GameColors.black.withOpacity(0.5).value;
}