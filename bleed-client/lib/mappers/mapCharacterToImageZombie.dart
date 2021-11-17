import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/images.dart';

Image mapCharacterToImageZombie(CharacterState state, Weapon weapon, Shade shading){
  switch(state){
    case CharacterState.Idle:
      switch(shading){
        case Shade.Bright:
          return images.zombieIdleBright;
        case Shade.Medium:
          return images.zombieIdleMedium;
        case Shade.Dark:
          return images.zombieIdleDark;
      }
      throw Exception();
    case CharacterState.Dead:
      switch(shading){
        case Shade.Bright:
          return images.zombieDyingBright;
        case Shade.Medium:
          return images.zombieDyingMedium;
        case Shade.Dark:
          return images.zombieDyingDark;
      }
      throw Exception();
    case CharacterState.Striking:
      switch(shading){
        case Shade.Bright:
          return images.zombieStriking1;
        case Shade.Medium:
          return images.zombieStriking2;
        case Shade.Dark:
          return images.zombieStriking3;
      }
      throw Exception();
    case CharacterState.Walking:
      switch(shading){
        case Shade.Bright:
          return images.zombieWalkingBright;
        case Shade.Medium:
          return images.zombieWalkingMedium;
        case Shade.Dark:
          return images.zombieWalkingDark;
      }
      throw Exception();
    default:
      throw Exception("could not map zombie image");
  }
}
