import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';

Image mapCharacterToImageMan(
    CharacterState state, Weapon weapon, Shading shade) {
  switch (state) {
    case CharacterState.Idle:
      if (weapon == Weapon.HandGun) {
        switch (shade) {
          case Shading.Bright:
            return images.manIdleHandgun1;
          case Shading.Medium:
            return images.manIdleHandgun2;
          case Shading.Dark:
            return images.manIdleHandgun3;
          case Shading.VeryDark:
            return images.manIdleHandgun3;
        }
      }
      if (weapon == Weapon.Shotgun) {
        switch (shade) {
          case Shading.Bright:
            return images.manIdleShotgun01;
          case Shading.Medium:
            return images.manIdleShotgun02;
          case Shading.Dark:
            return images.manIdleShotgun03;
          case Shading.VeryDark:
            return images.manIdleShotgun03;
        }
        throw Exception();
      }
      if (weapon == Weapon.SniperRifle) {
        return images.manIdleShotgun01;
      }
      if (weapon == Weapon.AssaultRifle) {
        return images.manIdleShotgun01;
      }
      if (shade == Shading.Bright) {
        return images.manIdleBright;
      }
      return images.manIdle;
    case CharacterState.Aiming:
      switch (weapon) {
        case Weapon.HandGun:
          switch (shade) {
            case Shading.Bright:
              return images.manFiringHandgun1;
            case Shading.Medium:
              return images.manFiringHandgun2;
            case Shading.Dark:
              return images.manFiringHandgun3;
            case Shading.VeryDark:
              return images.manFiringHandgun3;
          }
          throw Exception();
        default:
          switch (shade) {
            case Shading.Bright:
              return images.manFiringShotgun1;
            case Shading.Medium:
              return images.manFiringShotgun2;
            case Shading.Dark:
              return images.manFiringShotgun3;
            case Shading.VeryDark:
              return images.manFiringShotgun3;
          }
      }
      throw Exception();
    case CharacterState.Dead:
      return images.manDying;
    case CharacterState.Striking:
      return images.manStriking;
    case CharacterState.ChangingWeapon:
      return images.manChanging;
    case CharacterState.Running:
      switch (shade) {
        case Shading.Bright:
          return images.manUnarmedRunning1;
        case Shading.Medium:
          return images.manUnarmedRunning2;
        case Shading.Dark:
          return images.manUnarmedRunning3;
        case Shading.VeryDark:
          return images.manUnarmedRunning3;
      }
      throw Exception();
    case CharacterState.Walking:
      if (weapon == Weapon.HandGun) {
        switch (shade) {
          case Shading.Bright:
            return images.manWalkingHandgun1;
          case Shading.Medium:
            return images.manWalkingHandgun2;
          case Shading.Dark:
            return images.manWalkingHandgun3;
          case Shading.VeryDark:
            return images.manWalkingHandgun3;
        }
        throw Exception();
      }
      if (weapon == Weapon.Shotgun) {
        switch (shade) {
          case Shading.Bright:
            return images.manWalkingShotgunShade1;
          case Shading.Medium:
            return images.manWalkingShotgunShade2;
          case Shading.Dark:
            return images.manWalkingShotgunShade3;
          case Shading.VeryDark:
            return images.manWalkingShotgunShade3;
        }
        throw Exception();
      }
      if (shade == Shading.Bright) {
        return images.manWalkingBright;
      }
      return images.manWalking;
    case CharacterState.Firing:
      switch (weapon) {
        case Weapon.HandGun:
          switch (shade) {
            case Shading.Bright:
              return images.manFiringHandgun1;
            case Shading.Medium:
              return images.manFiringHandgun2;
            case Shading.Dark:
              return images.manFiringHandgun3;
            case Shading.VeryDark:
              return images.manFiringHandgun3;
          }
          throw Exception();
        default:
          switch (shade) {
            case Shading.Bright:
              return images.manFiringShotgun1;
            case Shading.Medium:
              return images.manFiringShotgun2;
            case Shading.Dark:
              return images.manFiringShotgun3;
            case Shading.VeryDark:
              return images.manFiringShotgun3;
          }
      }
      throw Exception();
    default:
      throw Exception();
  }
}
