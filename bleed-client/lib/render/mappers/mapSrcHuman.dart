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

final _manFramesFiringShotgunMax = animations.human.firingShotgun.length - 1;
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
              animation: animations.human.firingHandgun,
              direction: direction,
              frame: frame,
              framesPerDirection: 2,
          );

        case WeaponType.Shotgun:
          return animate(
            atlas: atlas.human.shotgun.firing,
            animation: animations.human.firingShotgun,
            direction: direction,
            frame: frame,
            framesPerDirection: 3,
          );

        default:
          return animate(
            atlas: atlas.human.shotgun.firing,
            animation: animations.human.firingShotgun,
            direction: direction,
            frame: frame,
            framesPerDirection: 3,
          );
      }
    case CharacterState.Striking:
      return animate(
        atlas: atlas.human.striking,
        animation: animations.human.strikingSword,
        direction: direction,
        frame: frame,
        framesPerDirection: 3,
        size: 96
      );
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