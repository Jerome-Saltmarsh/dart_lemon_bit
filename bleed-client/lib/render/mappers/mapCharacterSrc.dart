import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/constants/animations.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/enums/CharacterType.dart';
import 'package:lemon_engine/classes/vector2.dart';

const _frameSize = 64.0;

final _manFramesFiringHandgunMax = animations.man.firingHandgun.length - 1;
final _manFramesFiringShotgunMax = animations.man.firingShotgun.length - 1;

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

final Vector2 _zombieWalking = Vector2(1, 2720);

Float32List _src = Float32List(4);

Float32List mapCharacterSrc({
  CharacterType type,
  CharacterState state,
  WeaponType weapon,
  Direction direction,
  int frame,
  Shade shade,
}) {

  bool zombie = type == CharacterType.Zombie;

  switch (state) {
    case CharacterState.Idle:

      if (zombie){
        _src[0] = atlas.zombie.idle.x + (direction.index * _frameSize);
        _src[1] = atlas.zombie.idle.y + (shade.index * _frameSize);
        break;
      }

      switch(weapon){
        case WeaponType.HandGun:
          _src[0] = _humanIdleHandgun.x + (direction.index * _frameSize);
          _src[1] = _humanIdleHandgun.y + (shade.index * _frameSize);
          break;
        case WeaponType.Unarmed:
          _src[0] = _humanIdleUnarmed.x + (direction.index * _frameSize);
          _src[1] = _humanIdleUnarmed.y + (shade.index * _frameSize);
          break;
        default:
          _src[0] = _humanIdleShotgun.x + (direction.index * _frameSize);
          _src[1] = _humanIdleShotgun.y + (shade.index * _frameSize);
          break;
      }
      break;

    case CharacterState.Walking:
      double _s = direction.index * _frameSize * _framesPerDirection4;
      double _f = (frame % 4) * _frameSize;

      if (type == CharacterType.Zombie){
        _src[0] = _s + _f + _zombieWalking.x;
        _src[1] = shade.index * _frameSize + _zombieWalking.y;
        break;
      }

      switch(weapon){
        case WeaponType.HandGun:
          _src[0] = _s + _f + _humanWalkingHandgun.x;
          _src[1] = shade.index * _frameSize + _humanWalkingHandgun.y;
          break;
        case WeaponType.Shotgun:
          _src[0] = _s + _f + _humanWalkingShotgun.x;
          _src[1] = shade.index * _frameSize + _humanWalkingShotgun.y;
          break;
        default:
          _src[0] = _s + _f + _humanWalkingUnarmed.x;
          _src[1] = shade.index * _frameSize + _humanWalkingUnarmed.y;
          break;
      }
      break;

    case CharacterState.Dead:
      double _s = direction.index * _frameSize * 2;
      double _f = min(2, frame) * _frameSize;
      _src[0] = _humanDying.x + _s + _f;
      _src[1] = _humanDying.y + shade.index * _frameSize;
      break;

    case CharacterState.Aiming:
      switch (weapon) {
        case WeaponType.HandGun:
          int _frame = 0;
          double _di = direction.index * _frameSize * _framesPerDirection2;
          double _fr = _frame * _frameSize;
          _src[0] = _humanFiringHandgun.x + _di + _fr;
          _src[1] = _humanFiringHandgun.y + shade.index * _frameSize;
          break;

        case WeaponType.Shotgun:
          int _frame = 0;
          double _di = direction.index * _frameSize * _framesPerDirection3;
          double _fr = _frame * _frameSize;
          _src[0] = _humanFiringShotgun.x + _di + _fr;
          _src[1] = _humanFiringShotgun.y + shade.index * _frameSize;
          break;

        default:
          throw Exception("Cannot aim unarmed");
      }
      break;
    case CharacterState.Firing:
      switch (weapon) {
        case WeaponType.HandGun:
          int _frame = animations.man.firingHandgun[min(frame, _manFramesFiringHandgunMax)];
          double _di = direction.index * _frameSize * _framesPerDirection2;
          double _fr = _frame * _frameSize;
          _src[0] = _humanFiringHandgun.x + _di + _fr;
          _src[1] = _humanFiringHandgun.y + shade.index * _frameSize;
          break;

        case WeaponType.Shotgun:
          int _frame = animations.man.firingShotgun[min(frame, _manFramesFiringShotgunMax)];
          double _di = direction.index * _frameSize * _framesPerDirection3;
          double _fr = _frame * _frameSize;
          _src[0] = _humanFiringShotgun.x + _di + _fr;
          _src[1] = _humanFiringShotgun.y + shade.index * _frameSize;
          break;

        case WeaponType.Bow:
          double size = 96;
          double _di = direction.index * size;
          _src[0] = atlas.human.firingBow.x + _di;
          _src[1] = atlas.human.firingBow.y + shade.index * size;
          _src[2] = _src[0] + size;
          _src[3] = _src[1] + size;
          break;

        default:
          int _frame = -1;
          if (frame < _manFramesFiringShotgunMax) {
            _frame = animations.man.firingShotgun[frame];
          } else {
            _frame = _manFramesFiringShotgunMax - 1;
          }
          double _s = direction.index * _frameSize * 3;
          double _f = _frame * _frameSize;
          _src[0] = _s + _f + _humanFiringShotgun.x;
          _src[1] = shade.index * _frameSize + _humanFiringShotgun.y;
          break;
      }
      break;
    case CharacterState.Striking:

      if (type == CharacterType.Human){
        int _frame = animations.man.strikingSword[min(frame, 3)];
        double _di = direction.index * 96.0 * 2;
        double _fr = _frame * 96.0;
        _src[0] = atlas.human.striking.x + _di + _fr;
        _src[1] = atlas.human.striking.y + shade.index * 96.0;
        _src[2] = _src[0] + 96;
        _src[3] = _src[1] + 96;
        return _src;
      } else

      if (type == CharacterType.Zombie){
        double _s = direction.index * _frameSize * 2;
        double _f = (frame % 4) * _frameSize;
        _src[0] = _s + _f + atlas.zombie.striking.x;
        _src[1] = shade.index * _frameSize + atlas.zombie.striking.y;
      }
      break;
    case CharacterState.Running:

      double _s = direction.index * _frameSize * _framesPerDirection4;
      double _f = (frame % 4) * _frameSize;

      if (type == CharacterType.Zombie){
        _src[0] = _s + _f + _zombieWalking.x;
        _src[1] = shade.index * _frameSize + _zombieWalking.y;
        break;
      }

      switch(weapon){
        case WeaponType.HandGun:
          _src[0] = _s + _f + _humanWalkingHandgun.x;
          _src[1] = shade.index * _frameSize + _humanWalkingHandgun.y;
          break;
        case WeaponType.Shotgun:
          _src[0] = _s + _f + _humanWalkingShotgun.x;
          _src[1] = shade.index * _frameSize + _humanWalkingShotgun.y;
          break;
        default:
          _s = direction.index * _frameSize * 4;
          _f = (frame % 4) * _frameSize;
          _src[0] = _s + _f + _humanRunning.x;
          _src[1] = shade.index * _frameSize + _humanRunning.y;
          break;
      }
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
      _src[0] = _s + _f + _humanChanging.x;
      _src[1] = shade.index * _frameSize + _humanChanging.y;
      break;
  }

  _src[2] = _src[0] + _frameSize;
  _src[3] = _src[1] + _frameSize;
  return _src;
}
