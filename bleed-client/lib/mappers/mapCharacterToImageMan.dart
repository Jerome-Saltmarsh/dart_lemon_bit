import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';

Image mapCharacterToImageMan(CharacterState state, Weapon weapon, Shading shade){
  switch(state){
    case CharacterState.Idle:
      if (weapon == Weapon.HandGun){
        return images.manIdleHandgun;
      }
      if (weapon == Weapon.Shotgun){
        return images.manShotgunIdle;
      }
      if (weapon == Weapon.SniperRifle){
        return images.manShotgunIdle;
      }
      if (weapon == Weapon.AssaultRifle){
        return images.manShotgunIdle;
      }
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
      if (weapon == Weapon.HandGun){
        return images.manWalkingHandgun;
      }
      if (weapon == Weapon.Shotgun){
        switch(shade){
          case Shading.Bright:
            return images.manWalkingShotgunShade1;
          case Shading.Medium:
            return images.manWalkingShotgunShade2;
          case Shading.Dark:
            return images.manWalkingShotgunShade3;
          case Shading.VeryDark:
            return images.manWalkingShotgunShade3;
        }
        throw Exception();
      }
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
