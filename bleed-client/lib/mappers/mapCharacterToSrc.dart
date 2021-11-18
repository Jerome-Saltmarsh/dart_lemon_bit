

import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';

double _runningFrames = 4.0;
double _manSize = 64.0;

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
              return images.manIdle;
            case Weapon.HandGun:
              return images.manIdleHandgun1;
            case Weapon.Shotgun:
              return images.manIdleShotgun01;
            case Weapon.SniperRifle:
              return images.manIdleShotgun01;
            case Weapon.AssaultRifle:
              return images.manIdleShotgun01;
          }
          break;
        case CharacterState.Walking:
          switch(weapon){
            case Weapon.Unarmed:
              return images.manWalkingUnarmed;
            case Weapon.HandGun:
              return images.manWalkingHandgun1;
            case Weapon.Shotgun:
              return images.manWalkingShotgunShade1;
            case Weapon.SniperRifle:
              return images.manWalkingShotgunShade1;
            case Weapon.AssaultRifle:
              return images.manWalkingShotgunShade1;
          }
          break;
        case CharacterState.Dead:
          return images.manDying1;
        case CharacterState.Aiming:
          throw Exception();
        case CharacterState.Firing:
          switch(weapon){
            case Weapon.Unarmed:
              return images.manStriking;
            case Weapon.HandGun:
              return images.manFiringHandgun1;
            case Weapon.Shotgun:
              return images.manFiringShotgun1;
            case Weapon.SniperRifle:
              return images.manFiringShotgun1;
            case Weapon.AssaultRifle:
              return images.manFiringShotgun1;
          }
          break;
        case CharacterState.Striking:
          return images.manStriking;
        case CharacterState.Running:
          return images.manUnarmedRunning1;
        case CharacterState.Reloading:
          return images.manChanging1;
        case CharacterState.ChangingWeapon:
          return images.manChanging1;
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

void mapCharacterToSrc({
  CharacterType type,
  CharacterState state,
  Weapon weapon,
  Direction direction,
  int frame,
  Shade shade,
  Float32List src,
}){
  switch(type){
    case CharacterType.Human:
      switch(state){
        case CharacterState.Idle:
          // TODO: Handle this case.
          break;
        case CharacterState.Walking:
          // TODO: Handle this case.
          break;
        case CharacterState.Dead:
          // TODO: Handle this case.
          break;
        case CharacterState.Aiming:
          // TODO: Handle this case.
          break;
        case CharacterState.Firing:
          // TODO: Handle this case.
          break;
        case CharacterState.Striking:
          // TODO: Handle this case.
          break;
        case CharacterState.Running:
          // weapon gets ignore
          double left = direction.index * _runningFrames + frame;
          double top = shade.index * _manSize;
          double right = left + _manSize;
          double bottom = top + _manSize;
          src[0] = left;
          src[1] = top;
          src[2] = right;
          src[3] = bottom;
          break;

        case CharacterState.Reloading:
          // TODO: Handle this case.
          break;
        case CharacterState.ChangingWeapon:
          // TODO: Handle this case.
          break;
      }
      break;
    case CharacterType.Zombie:
    // TODO: Handle this case.
      break;
  }
  throw Exception();
}