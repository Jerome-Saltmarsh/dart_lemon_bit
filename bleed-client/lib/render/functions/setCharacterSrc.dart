import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:lemon_engine/classes/vector2.dart';

const _frameSize = 64.0;

const List<int> _manFramesFiringHandgun = [0, 1, 0];
const List<int> _manFramesFiringShotgun = [1, 0, 2, 0];

final _manFramesFiringHandgunMax = _manFramesFiringHandgun.length - 1;
final _manFramesFiringShotgunLength = _manFramesFiringShotgun.length - 1;

const _framesPerDirection2 = 2;
const _framesPerDirection3 = 3;
const _framesPerDirection4 = 4;

final Vector2 _humanIdleUnarmed = Vector2(1538, 1);
final Vector2 _humanIdleHandgun = Vector2(1026, 258);
final Vector2 _humanIdleShotgun = Vector2(1539, 258);
final Vector2 _humanWalkingUnarmed = Vector2(1, 1222);
final Vector2 _humanWalkingHandgun = Vector2(1, 708);
final Vector2 _humanWalkingShotgun = Vector2(1, 965);
final Vector2 _humanRunning = Vector2(0, 2206);
final Vector2 _humanChanging = Vector2(1, 1479);
final Vector2 _humanDying = Vector2(1, 1736);
final Vector2 _humanFiringHandgun = Vector2(1, 258);
final Vector2 _humanFiringShotgun = Vector2(1, 1);

void setCharacterSrc({
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
      switch(weapon){
        case Weapon.HandGun:
          src[0] = _humanIdleHandgun.x + (direction.index * _frameSize);
          src[1] = _humanIdleHandgun.y + (shade.index * _frameSize);
          break;
        case Weapon.Unarmed:
          src[0] = _humanIdleUnarmed.x + (direction.index * _frameSize);
          src[1] = _humanIdleUnarmed.y + (shade.index * _frameSize);
          break;
        default:
          src[0] = _humanIdleShotgun.x + (direction.index * _frameSize);
          src[1] = _humanIdleShotgun.y + (shade.index * _frameSize);
          break;
      }
      break;

    case CharacterState.Walking:
      double _s = direction.index * _frameSize * _framesPerDirection4;
      double _f = (frame % 4) * _frameSize;

      switch(weapon){
        case Weapon.HandGun:
          src[0] = _s + _f + _humanWalkingHandgun.x;
          src[1] = shade.index * _frameSize + _humanWalkingHandgun.y;
          break;
        case Weapon.Shotgun:
          src[0] = _s + _f + _humanWalkingShotgun.x;
          src[1] = shade.index * _frameSize + _humanWalkingShotgun.y;
          break;
        default:
          src[0] = _s + _f + _humanWalkingUnarmed.x;
          src[1] = shade.index * _frameSize + _humanWalkingUnarmed.y;
          break;
      }
      break;

    case CharacterState.Dead:
      int _frame = min(2, frame);
      double _s = direction.index * _frameSize * 2;
      double _f = _frame * _frameSize;
      src[0] = _s + _f + _humanDying.x;
      src[1] = shade.index * _frameSize + _humanDying.y;
      break;

    case CharacterState.Aiming:
      // TODO This is wrong
      int _frame =
          _manFramesFiringHandgun[frame % _manFramesFiringHandgunMax];
      src[0] = direction.index + (_frame * _frameSize);
      src[1] = shade.index * _frameSize;
      break;

    case CharacterState.Firing:
      switch (weapon) {
        case Weapon.HandGun:
          int _frame = _manFramesFiringHandgun[min(frame, _manFramesFiringHandgunMax)];
          double _di = direction.index * _frameSize * _framesPerDirection2;
          double _fr = _frame * _frameSize;
          src[0] = _humanFiringHandgun.x + _di + _fr;
          src[1] = _humanFiringHandgun.y + shade.index * _frameSize;
          break;

        case Weapon.Shotgun:
          int _frame = _manFramesFiringShotgun[min(frame, _manFramesFiringShotgunLength)];
          double _di = direction.index * _frameSize * _framesPerDirection3;
          double _fr = _frame * _frameSize;
          src[0] = _humanFiringShotgun.x + _di + _fr;
          src[1] = _humanFiringShotgun.y + shade.index * _frameSize;
          break;

        default:
          int _frame = -1;
          if (frame < _manFramesFiringShotgunLength) {
            _frame = _manFramesFiringShotgun[frame];
          } else {
            _frame = _manFramesFiringShotgunLength - 1;
          }
          double _s = direction.index * _frameSize * 3;
          double _f = _frame * _frameSize;
          src[0] = _s + _f + _humanFiringShotgun.x;
          src[1] = shade.index * _frameSize + _humanFiringShotgun.y;
          break;
      }
      break;
    case CharacterState.Striking:
      throw Exception("Not Implemented");
    case CharacterState.Running:
      double _s = direction.index * _frameSize * 4;
      double _f = (frame % 4) * _frameSize;
      src[0] = _s + _f + _humanRunning.x;
      src[1] = shade.index * _frameSize + _humanRunning.y;
      break;

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
      src[0] = _s + _f + _humanChanging.x;
      src[1] = shade.index * _frameSize + _humanChanging.y;
      break;
  }

  src[2] = src[0] + _frameSize;
  src[3] = src[1] + _frameSize;
}
