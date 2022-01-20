import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/render/constants/animations.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/mappers/animate.dart';
import 'package:lemon_math/Vector2.dart';

import 'loop.dart';

const _size = 64.0;

final _manFramesFiringHandgunMax = animations.man.firingHandgun.length - 1;
final _manFramesFiringShotgunMax = animations.man.firingShotgun.length - 1;

const _framesPerDirection2 = 2;
const _framesPerDirection3 = 3;

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
      switch (weaponType) {
        case WeaponType.Unarmed:
          return loop(
              atlas: atlas.human.unarmed.walking,
              direction: direction,
              frame: frame
          );
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
          return loop(atlas: atlas.human.unarmed.walking, direction: direction, frame: frame);
      }

    case CharacterState.Dead:
      return single(atlas: atlas.human.dying, direction: direction);

    case CharacterState.Aiming:
      switch (weaponType) {
        case WeaponType.HandGun:
          return single(atlas: atlas.human.handgun.firing, direction: direction);

        case WeaponType.Shotgun:
          return single(atlas: atlas.human.shotgun.firing, direction: direction);

        default:
          throw Exception("Cannot aim unarmed");
      }
    case CharacterState.Firing:
      switch (weaponType) {
        case WeaponType.HandGun:
          return animate(
              atlas: atlas.human.handgun.firing,
              animation: animations.man.firingHandgun,
              direction: direction,
              frame: frame,
              framesPerDirection: 2,
          );

        case WeaponType.Shotgun:
          int _frame = animations
              .man.firingShotgun[min(frame, _manFramesFiringShotgunMax)];
          double _di = direction.index * _size * _framesPerDirection3;
          double _fr = _frame * _size;
          _src[0] = atlas.human.shotgun.firing.x + _di + _fr;
          _src[1] = atlas.human.shotgun.firing.y;
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
          _src[0] = _s + _f + atlas.human.shotgun.firing.x;
          _src[1] = atlas.human.shotgun.firing.y;
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
        case WeaponType.SniperRifle:
          return loop(
              atlas: atlas.human.shotgun.walking,
              direction: direction,
              frame: frame
          );
        case WeaponType.AssaultRifle:
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
      _src[0] = _s + _f + atlas.human.changing.x;
      _src[1] = atlas.human.changing.y;
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