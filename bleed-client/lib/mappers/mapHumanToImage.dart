import 'dart:ui';

import 'package:bleed_client/classes/Human.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/images.dart';


Image mapHumanToImage(Human human){
  switch(human.state){
    case CharacterState.ChangingWeapon:
      return images.manChanging;
    case CharacterState.Running:
      return images.manRunning;
    case CharacterState.Firing:
      switch(human.weapon){
        case Weapon.HandGun:
          return images.manFiringHandgun;
      }
      return images.manFiringShotgun;
    default:
      return images.man;
  }
}
