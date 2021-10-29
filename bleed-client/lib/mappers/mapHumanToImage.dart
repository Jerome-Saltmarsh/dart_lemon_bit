import 'dart:ui';

import 'package:bleed_client/classes/Human.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';

import '../images.dart';

Image mapHumanToImage(Human human){
  switch(human.state){
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
