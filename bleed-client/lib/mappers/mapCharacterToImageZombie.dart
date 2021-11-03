import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';


Image mapCharacterToImageZombie(CharacterState state, Weapon weapon, Shading shading){
  switch(state){
    case CharacterState.Idle:
      switch(shading){
        case Shading.Bright:
          return images.zombieIdleBright;
        case Shading.Medium:
          return images.zombieIdleMedium;
        case Shading.Dark:
          return images.zombieIdleDark;
      }
      return images.zombieWalkingBright;
    case CharacterState.Dead:
      switch(shading){
        case Shading.Bright:
          return images.zombieDyingBright;
        case Shading.Medium:
          return images.zombieDyingMedium;
        case Shading.Dark:
          return images.zombieDyingDark;
      }
      return images.zombieWalkingBright;
    case CharacterState.Striking:
      return images.zombieStriking;
    case CharacterState.Walking:
      switch(shading){
        case Shading.Bright:
          return images.zombieWalkingMedium;
        case Shading.Medium:
          return images.zombieWalkingMedium;
        case Shading.Dark:
          return images.zombieWalkingDark;
      }
      return images.zombieWalkingBright;
    default:
      throw Exception("could not map zombie image");
  }
}
