import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';

Image mapCharacterToImageMan(CharacterState state, Weapon weapon, Shading shade){
  switch(state){
    case CharacterState.Idle:
      if (shade == Shading.Bright){
        return images.manIdleBright;
      }
      return images.manIdle;
    case CharacterState.Aiming:
      switch(weapon){
        case Weapon.HandGun:
          return images.manFiringHandgun;
        default:
          return images.manFiringShotgun;
      }
      return images.manFiringShotgun;
    case CharacterState.Dead:
      return images.manDying;
    case CharacterState.Striking:
      return images.manStriking;
    case CharacterState.ChangingWeapon:
      return images.manChanging;
    case CharacterState.Running:
      return images.manRunning;
    case CharacterState.Walking:
      if (shade == Shading.Bright){
        return images.manWalkingBright;
      }
      return images.manWalking;
    case CharacterState.Firing:
      switch(weapon){
        case Weapon.HandGun:
          return images.manFiringHandgun;
        default:
          return images.manFiringShotgun;
      }
      return images.manFiringShotgun;
    default:
      throw Exception("could not map man image");
  }
}
