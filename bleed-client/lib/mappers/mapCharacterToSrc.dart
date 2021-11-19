import 'dart:typed_data';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';

const _runningFrames = 4.0;
const _framesDying = 4;
const _frameSize = 64.0;

const List<int> _manFramesFiringHandgun = [1, 0];
const List<int> _manFramesFiringShotgun = [0, 1, 1, 2, 1];

final _manFramesFiringHandgunLength = _manFramesFiringHandgun.length;
final _manFramesFiringShotgunLength = _manFramesFiringShotgun.length;

void mapCharacterToSrc({
  CharacterType type,
  CharacterState state,
  Weapon weapon,
  Direction direction,
  int frame,
  Shade shade,
  Float32List src,
}) {
  switch (type) {
    case CharacterType.Human:
      switch (state) {
        case CharacterState.Idle:
          src[0] = direction.index * _frameSize;
          src[1] = shade.index * _frameSize;
          src[2] = src[0] + _frameSize;
          src[3] = src[1] + _frameSize;
          return;
        case CharacterState.Walking:
          double _s = direction.index * _frameSize * 4;
          double _f = (frame % 4) * _frameSize;
          src[0] = _s + _f;
          src[1] = shade.index * _frameSize;
          src[2] = src[0] + _frameSize;
          src[3] = src[1] + _frameSize;
          return;
        case CharacterState.Dead:
          src[0] = direction.index * _frameSize + ((frame % _framesDying) * _frameSize);
          src[1] = shade.index * _frameSize;
          src[2] = src[0] + _frameSize;
          src[3] = src[1] + _frameSize;
          return;
        case CharacterState.Aiming:
          // TODO This is wrong
          int _frame = _manFramesFiringHandgun[
          frame % _manFramesFiringHandgunLength];
          src[0] = direction.index + (_frame * _frameSize);
          src[1] = shade.index * _frameSize;
          src[2] = src[0] + _frameSize;
          src[3] = src[1] + _frameSize;
          return;
        case CharacterState.Firing:
          switch (weapon) {
            case Weapon.HandGun:
              int _frame = -1;
              if (frame < _manFramesFiringHandgunLength) {
                _frame = _manFramesFiringHandgun[frame];
              }else{
                _frame = _manFramesFiringHandgunLength - 1;
              }
              double _s = direction.index * _frameSize * 2;
              double _f = _frame * _frameSize;
              src[0] = _s + _f;
              src[1] = shade.index * _frameSize;
              src[2] = src[0] + _frameSize;
              src[3] = src[1] + _frameSize;
              return;
            case Weapon.Shotgun:
              int _frame = _manFramesFiringShotgun[
                  frame % _manFramesFiringShotgunLength];
              src[0] = direction.index + (_frame * _frameSize);
              src[1] = shade.index * _frameSize;
              src[2] = src[0] + _frameSize;
              src[3] = src[1] + _frameSize;
              return;
            case Weapon.SniperRifle:
              int _frame = 0;
              src[0] = direction.index + (_frame * _frameSize);
              src[1] = shade.index * _frameSize;
              src[2] = src[0] + _frameSize;
              src[3] = src[1] + _frameSize;
              return;
            case Weapon.AssaultRifle:
              int _frame = 0;
              src[0] = direction.index + (_frame * _frameSize);
              src[1] = shade.index * _frameSize;
              src[2] = src[0] + _frameSize;
              src[3] = src[1] + _frameSize;
              return;
          }
          return;
        case CharacterState.Striking:
          // TODO: Handle this case.
          return;
        case CharacterState.Running:
          double left = direction.index * _runningFrames + frame;
          double top = shade.index * _frameSize;
          double right = left + _frameSize;
          double bottom = top + _frameSize;
          src[0] = left;
          src[1] = top;
          src[2] = right;
          src[3] = bottom;
          return;

        case CharacterState.Reloading:
          throw Exception();
        case CharacterState.ChangingWeapon:
          src[0] = direction.index + ((frame % 4) * _frameSize);
          src[1] = shade.index * _frameSize;
          src[2] = src[0] + _frameSize;
          src[3] = src[1] + _frameSize;
          return;
      }
      break;
    case CharacterType.Zombie:
      throw Exception();
  }
  throw Exception(
      "Could not map character to src: {type: $type, state: $state, weapon: $weapon, direction: $direction, frame: $frame, shade: $shade");
}
