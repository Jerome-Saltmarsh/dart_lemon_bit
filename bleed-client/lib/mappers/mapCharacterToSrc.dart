import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:lemon_engine/classes/vector2.dart';

const _frameSize = 48.0;

const List<int> _manFramesFiringHandgun = [1, 0];
const List<int> _manFramesFiringShotgun = [0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0];

final _manFramesFiringHandgunLength = _manFramesFiringHandgun.length;
final _manFramesFiringShotgunLength = _manFramesFiringShotgun.length;

final Vector2 _humanIdle = Vector2(2102, 1998);
final Vector2 _humanWalking = Vector2(1, 2213);
final Vector2 _humanRunning  = Vector2(1, 2013);
final Vector2 _humanChanging   = Vector2(1, 1479);
final Vector2 _dying = Vector2(1, 1736);
final Vector2 _firingHandgun  = Vector2(1, 258);
final Vector2 _firingShotgun  = Vector2(1, 1);

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
      src[0] = direction.index * _frameSize + _humanIdle.x;
      src[1] = shade.index * _frameSize + _humanIdle.y;
      src[2] = src[0] + _frameSize;
      src[3] = src[1] + _frameSize;
      return;
    case CharacterState.Walking:
      double _s = direction.index * _frameSize * 4;
      double _f = (frame % 4) * _frameSize;
      src[0] = _s + _f + _humanWalking.x;
      src[1] = shade.index * _frameSize + _humanWalking.y;
      src[2] = src[0] + _frameSize;
      src[3] = src[1] + _frameSize;
      return;
    case CharacterState.Dead:
      int _frame = min(2, frame);
      double _s = direction.index * _frameSize * 2;
      double _f = _frame * _frameSize;
      src[0] = _s + _f + _dying.x;
      src[1] = shade.index * _frameSize + _dying.y;
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
          src[0] = _s + _f + _firingHandgun.x;
          src[1] = shade.index * _frameSize + _firingHandgun.y;
          src[2] = src[0] + _frameSize;
          src[3] = src[1] + _frameSize;
          return;
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
      src[0] = _s + _f + _humanRunning.x;
      src[1] = shade.index * _frameSize + _humanRunning.y;
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
      src[0] = _s + _f + _humanChanging.x;
      src[1] = shade.index * _frameSize + _humanChanging.y;
      src[2] = src[0] + _frameSize;
      src[3] = src[1] + _frameSize;
      return;
  }
}
