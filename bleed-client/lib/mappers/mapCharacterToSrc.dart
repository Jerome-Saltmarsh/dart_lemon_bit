

import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';

double _runWidth = 30;
double _runHeight = 30;

double _runningFrames = 4.0;

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
          double top = shade.index * _runHeight;
          double right = left + _runWidth;
          double bottom = top + _runHeight;
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