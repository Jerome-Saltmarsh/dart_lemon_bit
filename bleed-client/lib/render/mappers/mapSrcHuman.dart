import 'dart:typed_data';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/render/constants/animations.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/mappers/animate.dart';
import 'package:lemon_math/Vector2.dart';

import 'loop.dart';

Float32List mapSrcHuman({
    required WeaponType weaponType,
    required CharacterState characterState,
    required Direction direction,
    required int frame
}) {

  switch (characterState) {
    case CharacterState.Idle:
      return srcSingle(
        atlas: _idleWeaponTypeVector2[weaponType] ?? _idleWeaponTypeVector2[WeaponType.Unarmed]!,
        direction: direction,
      );
    case CharacterState.Walking:
      switch (weaponType) {
        case WeaponType.Unarmed:
          return srcLoop(
              atlas: atlas.human.unarmed.walking,
              direction: direction,
              frame: frame
          );
        case WeaponType.HandGun:
          return srcLoop(
            atlas: atlas.human.handgun.walking,
            direction: direction,
            frame: frame
          );
        case WeaponType.Shotgun:
          return srcLoop(
              atlas: atlas.human.shotgun.walking,
              direction: direction,
              frame: frame
          );
        default:
          return srcLoop(atlas: atlas.human.unarmed.walking, direction: direction, frame: frame);
      }

    case CharacterState.Dead:
      return srcSingle(atlas: atlas.human.dying, direction: direction);

    case CharacterState.Aiming:
      switch (weaponType) {
        case WeaponType.HandGun:
          return srcSingle(atlas: atlas.human.handgun.firing, direction: direction);

        case WeaponType.Shotgun:
          return srcSingle(atlas: atlas.human.shotgun.firing, direction: direction);

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
        atlas: atlas.human.punching,
        animation: animations.human.strikingSword,
        direction: direction,
        frame: frame,
        framesPerDirection: 2,
      );
    case CharacterState.Running:
      switch (weaponType) {
        case WeaponType.HandGun:
          return srcLoop(
              atlas: atlas.human.handgun.walking,
              direction: direction,
              frame: frame
          );
        case WeaponType.Shotgun:
          return srcLoop(
              atlas: atlas.human.shotgun.walking,
              direction: direction,
              frame: frame
          );
        case WeaponType.SniperRifle:
          return srcLoop(
              atlas: atlas.human.shotgun.walking,
              direction: direction,
              frame: frame
          );
        case WeaponType.AssaultRifle:
          return srcLoop(
              atlas: atlas.human.shotgun.walking,
              direction: direction,
              frame: frame
          );
        default:
          return srcLoop(
            atlas: atlas.human.unarmed.running,
            direction: direction,
            frame: frame,
          );
      }
    case CharacterState.Reloading:
      throw Exception("Not Implemented");
    case CharacterState.ChangingWeapon:
      return animate(
        atlas: atlas.human.changing,
        animation: animations.human.changing,
        direction: direction,
        frame: frame,
        framesPerDirection: 2,
      );
  }

  throw Exception("Could not map src to human");
}

final Map<WeaponType, Vector2> _idleWeaponTypeVector2 = {
  WeaponType.HandGun: atlas.human.handgun.idle,
  WeaponType.Shotgun: atlas.human.shotgun.idle,
  WeaponType.SniperRifle: atlas.human.shotgun.idle,
  WeaponType.AssaultRifle: atlas.human.shotgun.idle,
  WeaponType.Unarmed: atlas.human.unarmed.idle,
};