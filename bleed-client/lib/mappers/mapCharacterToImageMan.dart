import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';

Image mapCharacterToImage({
  CharacterType type,
  CharacterState state,
  Weapon weapon
}){
  switch(type){
    case CharacterType.Human:
      switch(state){
        case CharacterState.Idle:
          switch(weapon){
            case Weapon.Unarmed:
              return images.manIdleUnarmed;
            case Weapon.HandGun:
              return images.manIdleHandgun;
            case Weapon.Shotgun:
              return images.manIdleShotgun;
            case Weapon.SniperRifle:
              return images.manIdleShotgun;
            case Weapon.AssaultRifle:
              return images.manIdleShotgun;
          }
          break;
        case CharacterState.Walking:
          switch(weapon){
            case Weapon.Unarmed:
              return images.manWalkingUnarmed;
            case Weapon.HandGun:
              return images.manWalkingHandgun;
            case Weapon.Shotgun:
              return images.manWalkingShotgun;
            case Weapon.SniperRifle:
              return images.manWalkingShotgun;
            case Weapon.AssaultRifle:
              return images.manWalkingShotgun;
          }
          break;
        case CharacterState.Dead:
          return images.manDying;
        case CharacterState.Aiming:
          switch(weapon){
            case Weapon.HandGun:
              return images.manFiringHandgun;
            case Weapon.Shotgun:
              return images.manFiringShotgun;
            case Weapon.SniperRifle:
              return images.manFiringShotgun;
            case Weapon.AssaultRifle:
              return images.manFiringShotgun;
          }
          throw Exception();
        case CharacterState.Firing:
          switch(weapon){
            case Weapon.Unarmed:
              return images.manStriking;
            case Weapon.HandGun:
              return images.manFiringHandgun;
            case Weapon.Shotgun:
              return images.manFiringShotgun;
            case Weapon.SniperRifle:
              return images.manFiringShotgun;
            case Weapon.AssaultRifle:
              return images.manFiringShotgun;
          }
          break;
        case CharacterState.Striking:
          return images.manStriking;
        case CharacterState.Running:
          return images.manRunningUnarmed;
        case CharacterState.Reloading:
          return images.manChanging;
        case CharacterState.ChangingWeapon:
          return images.manChanging;
      }
      break;
    case CharacterType.Zombie:
      switch(state){
        case CharacterState.Idle:
          return images.zombieIdleBright;
        case CharacterState.Walking:
          return images.zombieWalkingBright;
        case CharacterState.Dead:
          return images.zombieDyingBright;
        case CharacterState.Aiming:
          throw Exception();
        case CharacterState.Firing:
          throw Exception();
        case CharacterState.Striking:
          return images.zombieStriking1;
        case CharacterState.Running:
          throw Exception();
        case CharacterState.Reloading:
          throw Exception();
        case CharacterState.ChangingWeapon:
          throw Exception();
      }
      break;
  }
  throw Exception();
}
