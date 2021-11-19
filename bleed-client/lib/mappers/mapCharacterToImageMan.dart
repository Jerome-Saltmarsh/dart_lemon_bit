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

  if (type == CharacterType.Human){
    return images.human;
  }

  switch(type){
    case CharacterType.Zombie:
      switch(state){
        case CharacterState.Idle:
          return images.zombieIdle;
        case CharacterState.Walking:
          return images.zombieWalking;
        case CharacterState.Dead:
          return images.zombieDying;
        case CharacterState.Aiming:
          throw Exception();
        case CharacterState.Firing:
          throw Exception();
        case CharacterState.Striking:
          return images.zombieStriking;
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
