import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/images.dart';


Image mapCharacterToImageZombie(CharacterState state, Weapon weapon){
  switch(state){
    case CharacterState.Dead:
      return images.manDying;
    case CharacterState.Striking:
      return images.manStriking;
    case CharacterState.ChangingWeapon:
      return images.manChanging;
    case CharacterState.Walking:
      return images.zombieWalking;
    case CharacterState.Running:
      return images.manRunning;
    case CharacterState.Firing:
      switch(weapon){
        case Weapon.HandGun:
          return images.manFiringHandgun;
      }
      return images.manFiringShotgun;
    default:
      return images.man;
  }
}
