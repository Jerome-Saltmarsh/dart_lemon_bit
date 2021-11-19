import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';

const _frameSize = 64.0;

const List<int> _manFramesFiringHandgun = [1, 0];
const List<int> _manFramesFiringShotgun = [0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0];

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
      int _frame = min(2, frame);
      double _s = direction.index * _frameSize * 2;
      double _f = _frame * _frameSize;
      src[0] = _s + _f;
      src[1] = shade.index * _frameSize;
      src[2] = src[0] + _frameSize;
      src[3] = src[1] + _frameSize;
      return;
    case CharacterState.Aiming:
      // TODO This is wrong
      int _frame =
          _manFramesFiringHandgun[frame % _manFramesFiringHandgunLength];
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
          } else {
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
          int _frame = -1;
          if (frame < _manFramesFiringShotgunLength) {
            _frame = _manFramesFiringShotgun[frame];
          } else {
            _frame = _manFramesFiringShotgunLength - 1;
          }
          double _s = direction.index * _frameSize * 3;
          double _f = _frame * _frameSize;
          src[0] = _s + _f;
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
      throw Exception("Not Implemented");
    case CharacterState.Running:
      double _s = direction.index * _frameSize * 4;
      double _f = (frame % 4) * _frameSize;
      src[0] = _s + _f;
      src[1] = shade.index * _frameSize;
      src[2] = src[0] + _frameSize;
      src[3] = src[1] + _frameSize;
      return;

    case CharacterState.Reloading:
      throw Exception("Not Implemented");
    case CharacterState.ChangingWeapon:
      int _frame = -1;
      if (frame < 2) {
        _frame = frame;
      } else {
        _frame = 1;
      }
      double _s = direction.index * _frameSize * 2;
      double _f = _frame * _frameSize;
      src[0] = _s + _f;
      src[1] = shade.index * _frameSize;
      src[2] = src[0] + _frameSize;
      src[3] = src[1] + _frameSize;
      return;
  }
}
