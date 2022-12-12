
import 'package:gamestream_flutter/game_colors.dart';

class GameConstants {
  static const Node_Height = 24.0;
  static const Sprite_Width = 48.0;
  static const Sprite_Width_Half = 24.0;
  static const Sprite_Width_Padded = Sprite_Width + 1;
  static const Sprite_Height = 72.0;
  static const Sprite_Height_Third = 24.0;
  static const Sprite_Height_Padded = Sprite_Height + 1;
  static const Sprite_Anchor_Y = 0.3;
  static const Frames_Per_Particle_Animation_Frame = 2;

  static const Shade_Opacities = [0.0, 0.4, 0.6, 0.7, 0.8, 0.95, 1.0];
  static const Shade_Opacities_Transparent = [0.0, 0.2, 0.3, 0.35, 0.4, 0.45, 0.5];
  static final Color_Shades = Shade_Opacities
      .map((opacity) => GameColors.black.withOpacity(opacity).value)
      .toList(growable: false);

  static final Transparent =  GameColors.black.withOpacity(0.5).value;
}