import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:lemon_engine/classes/vector2.dart';

const _frameSize = 64.0;

const List<int> _manFramesFiringHandgun = [1, 0];
const List<int> _manFramesFiringShotgun = [0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0];

final _manFramesFiringHandgunLength = _manFramesFiringHandgun.length;
final _manFramesFiringShotgunLength = _manFramesFiringShotgun.length;

final Vector2 _humanIdleUnarmed = Vector2(1538, 1);
final Vector2 _humanIdleHandgun = Vector2(1026, 258);
final Vector2 _humanWalkingUnarmed = Vector2(1, 1222);
final Vector2 _humanWalkingHandgun = Vector2(1, 708);
final Vector2 _humanRunning = Vector2(0, 2206);
final Vector2 _humanChanging = Vector2(1, 1479);
final Vector2 _dying = Vector2(1, 1736);
final Vector2 _firingHandgun = Vector2(1, 258);
final Vector2 _firingShotgun = Vector2(1, 1);

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
      if (weapon == Weapon.HandGun){
        src[0] = _humanIdleHandgun.x + (direction.index * _frameSize);
        src[1] = _humanIdleHandgun.y + (shade.index * _frameSize);
      } else {
        src[0] = _humanIdleUnarmed.x + (direction.index * _frameSize);
        src[1] = _humanIdleUnarmed.y + (shade.index * _frameSize);
      }
      break;

    case CharacterState.Walking:
      double _s = direction.index * _frameSize * 4;
      double _f = (frame % 4) * _frameSize;
      if (weapon == Weapon.HandGun){
        src[0] = _s + _f + _humanWalkingHandgun.x;
        src[1] = shade.index * _frameSize + _humanWalkingHandgun.y;
      }else{
        src[0] = _s + _f + _humanWalkingUnarmed.x;
        src[1] = shade.index * _frameSize + _humanWalkingUnarmed.y;
      }
      break;

    case CharacterState.Dead:
      int _frame = min(2, frame);
      double _s = direction.index * _frameSize * 2;
      double _f = _frame * _frameSize;
      src[0] = _s + _f + _dying.x;
      src[1] = shade.index * _frameSize + _dying.y;
      break;

    case CharacterState.Aiming:
      // TODO This is wrong
      int _frame =
          _manFramesFiringHandgun[frame % _manFramesFiringHandgunLength];
      src[0] = direction.index + (_frame * _frameSize);
      src[1] = shade.index * _frameSize;
      break;

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
          src[0] = _s + _f + _firingHandgun.x;
          src[1] = shade.index * _frameSize + _firingHandgun.y;
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
          src[0] = _s + _f + _firingShotgun.x;
          src[1] = shade.index * _frameSize + _firingShotgun.y;
          break;
      }
      return;
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
