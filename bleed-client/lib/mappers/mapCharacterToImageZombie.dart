import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/images.dart';


Image mapCharacterToImageZombie(CharacterState state, Weapon weapon){
  switch(state){
    case CharacterState.Idle:
      return images.zombieIdle;
    case CharacterState.Dead:
      return images.zombieDying;
    case CharacterState.Striking:
      return images.zombieStriking;
    case CharacterState.Walking:
      return images.zombieWalking;
    default:
      throw Exception("could not map zombie image");
  }
}
