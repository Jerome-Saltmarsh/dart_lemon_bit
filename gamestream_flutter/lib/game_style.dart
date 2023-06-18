
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

import 'gamestream/games/isometric/game_isometric_colors.dart';

class GameStyle {
  static final Container_Color = GameIsometricColors.brownDark;
  static final Container_Padding = EdgeInsets.all(16);
  static final ExperienceBarColorBackground = Colors.white.withOpacity(Engine.GoldenRatio_0_381);
  static final ExperienceBarColorFill = Colors.white;
  static final ExperienceBarWidth = 200.0;
  static final ExperienceBarHeight = 20.0;
  static final Window_Attributes_Width = 300.0;
  static final Window_Attributes_Height = 400.0;
  static final Window_PlayerItems_Width = 370.0;
  static const Player_Stats_Text_Color = Colors.black54;
  static const Player_Weapons_Icon_Size = 60.0;
  static const Player_Weapons_Border_Size = 3.0;
  static const Default_Padding = 12.0;
  static final Text_Color_Default = Colors.white.withOpacity(0.85);
  static const Padding_2 = EdgeInsets.all(2);
  static const Padding_4 = EdgeInsets.all(4);
  static const Padding_6 = EdgeInsets.all(6);
  static const Padding_10 = EdgeInsets.all(10);
}

class FontSize {
  static const VerySmall = Regular * Engine.GoldenRatio_0_381;
  static const Small = Regular * Engine.GoldenRatio_0_618;
  static const Regular = 18.0;
  static const Large = Regular * Engine.GoldenRatio_1_381;
  static const VeryLarge = Large * Engine.GoldenRatio_1_618;
}
