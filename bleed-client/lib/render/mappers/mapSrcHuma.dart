import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/render/constants/animations.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:lemon_engine/classes/vector2.dart';

import 'loop.dart';

const _size = 64.0;

final _manFramesFiringHandgunMax = animations.man.firingHandgun.length - 1;
final _manFramesFiringShotgunMax = animations.man.firingShotgun.length - 1;

const _framesPerDirection2 = 2;
const _framesPerDirection3 = 3;
const _framesPerDirection4 = 4;

// final Vector2 _humanWalkingHandgun = Vector2(1, 708);
// final Vector2 _humanWalkingShotgun = Vector2(1, 965);
final Vector2 _humanChanging = Vector2(1, 1479);
final Vector2 _humanDying = Vector2(1, 1736);
final Vector2 _humanFiringHandgun = Vector2(1, 258);
final Vector2 _humanFiringShotgun = Vector2(1, 1);

final Float32List _src = Float32List(4);


Float32List mapSrcHuman({
    required WeaponType weaponType,
    required CharacterState characterState,
    required Direction direction,
    required int frame
}) {
  switch (characterState) {
    case CharacterState.Idle:
      return single(
        atlas: _idleWeaponTypeVector2[weaponType] ?? _idleWeaponTypeVector2[WeaponType.Unarmed]!,
        direction: direction,
      );
    case CharacterState.Walking:
      double _s = direction.index * _size * _framesPerDirection4;
      double _f = (frame % 4) * _size;

      switch (weaponType) {
        case WeaponType.HandGun:
          return loop(
            atlas: atlas.human.handgun.walking,
            direction: direction,
            frame: frame
          );
        case WeaponType.Shotgun:
          return loop(
              atlas: atlas.human.shotgun.walking,
              direction: direction,
              frame: frame
          );
        default:
          _src[0] = _s + _f + atlas.human.unarmed.walking.x;
          _src[1] = atlas.human.unarmed.walking.y;
          break;
      }
      break;

    case CharacterState.Dead:
      double _s = direction.index * _size * 2;
      double _f = min(2, frame) * _size;
      _src[0] = _humanDying.x + _s + _f;
      _src[1] = _humanDying.y + _size;
      break;

    case CharacterState.Aiming:
      switch (weaponType) {
        case WeaponType.HandGun:
          int _frame = 0;
          double _di = direction.index * _size * _framesPerDirection2;
          double _fr = _frame * _size;
          _src[0] = _humanFiringHandgun.x + _di + _fr;
          _src[1] = _humanFiringHandgun.y + _size;
          break;

        case WeaponType.Shotgun:
          int _frame = 0;
          double _di = direction.index * _size * _framesPerDirection3;
          double _fr = _frame * _size;
          _src[0] = _humanFiringShotgun.x + _di + _fr;
          _src[1] = _humanFiringShotgun.y + _size;
          break;

        default:
          throw Exception("Cannot aim unarmed");
      }
      break;
    case CharacterState.Firing:
      switch (weaponType) {
        case WeaponType.HandGun:
          int _frame = animations
              .man.firingHandgun[min(frame, _manFramesFiringHandgunMax)];
          double _di = direction.index * _size * _framesPerDirection2;
          double _fr = _frame * _size;
          _src[0] = _humanFiringHandgun.x + _di + _fr;
          _src[1] = _humanFiringHandgun.y + _size;
          break;

        case WeaponType.Shotgun:
          int _frame = animations
              .man.firingShotgun[min(frame, _manFramesFiringShotgunMax)];
          double _di = direction.index * _size * _framesPerDirection3;
          double _fr = _frame * _size;
          _src[0] = _humanFiringShotgun.x + _di + _fr;
          _src[1] = _humanFiringShotgun.y + _size;
          break;

        case WeaponType.Bow:
          double size = 96;
          double _di = direction.index * size;
          _src[0] = atlas.human.firingBow.x + _di;
          _src[1] = atlas.human.firingBow.y + size;
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
          double _s = direction.index * _size * 3;
          double _f = _frame * _size;
          _src[0] = _s + _f + _humanFiringShotgun.x;
          _src[1] = _size + _humanFiringShotgun.y;
          break;
      }
      break;
    case CharacterState.Striking:
      int _frame = animations.man.strikingSword[min(frame, 3)];
      double _di = direction.index * 96.0 * 2;
      double _fr = _frame * 96.0;
      _src[0] = atlas.human.striking.x + _di + _fr;
      _src[1] = atlas.human.striking.y + 96.0;
      _src[2] = _src[0] + 96;
      _src[3] = _src[1] + 96;
      return _src;
    case CharacterState.Running:
      switch (weaponType) {
        case WeaponType.HandGun:
          return loop(
              atlas: atlas.human.handgun.walking,
              direction: direction,
              frame: frame
          );
        case WeaponType.Shotgun:
          return loop(
              atlas: atlas.human.shotgun.walking,
              direction: direction,
              frame: frame
          );
        default:
          return loop(
            atlas: atlas.human.unarmed.running,
            direction: direction,
            frame: frame,
          );
      }
    case CharacterState.Reloading:
      throw Exception("Not Implemented");
    case CharacterState.ChangingWeapon:
      int _frame = -1;
      if (frame < 2) {
        _frame = frame;
      } else {
        _frame = 1;
      }
      double _s = direction.index * _size * 2;
      double _f = _frame * _size;
      _src[0] = _s + _f + _humanChanging.x;
      _src[1] = _size + _humanChanging.y;
      break;
  }
  _src[2] = _src[0] + _size;
  _src[3] = _src[1] + _size;
  return _src;
}

final Map<WeaponType, Vector2> _idleWeaponTypeVector2 = {
  WeaponType.HandGun: atlas.human.handgun.idle,
  WeaponType.Shotgun: atlas.human.shotgun.idle,
  WeaponType.SniperRifle: atlas.human.shotgun.idle,
  WeaponType.AssaultRifle: atlas.human.shotgun.idle,
  WeaponType.Unarmed: atlas.human.unarmed.idle,
};