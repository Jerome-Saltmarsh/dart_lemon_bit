import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/images.dart';

Image mapCharacterToImageMan(
    CharacterState state, Weapon weapon, Shade shade) {
  switch (state) {
    case CharacterState.Idle:
      if (weapon == Weapon.HandGun) {
        switch (shade) {
          case Shade.Bright:
            return images.manIdleHandgun1;
          case Shade.Medium:
            return images.manIdleHandgun2;
          case Shade.Dark:
            return images.manIdleHandgun3;
          case Shade.VeryDark:
            return images.manIdleHandgun3;
        }
      }
      if (weapon == Weapon.Shotgun) {
        switch (shade) {
          case Shade.Bright:
            return images.manIdleShotgun01;
          case Shade.Medium:
            return images.manIdleShotgun02;
          case Shade.Dark:
            return images.manIdleShotgun03;
          case Shade.VeryDark:
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
      if (shade == Shade.Bright) {
        return images.manIdleBright;
      }
      return images.manIdle;
    case CharacterState.Aiming:
      switch (weapon) {
        case Weapon.HandGun:
          switch (shade) {
            case Shade.Bright:
              return images.manFiringHandgun1;
            case Shade.Medium:
              return images.manFiringHandgun2;
            case Shade.Dark:
              return images.manFiringHandgun3;
            case Shade.VeryDark:
              return images.manFiringHandgun3;
          }
          throw Exception();
        default:
          switch (shade) {
            case Shade.Bright:
              return images.manFiringShotgun1;
            case Shade.Medium:
              return images.manFiringShotgun2;
            case Shade.Dark:
              return images.manFiringShotgun3;
            case Shade.VeryDark:
              return images.manFiringShotgun3;
          }
      }
      throw Exception();
    case CharacterState.Dead:
      switch (shade) {
        case Shade.Bright:
          return images.manDying1;
        case Shade.Medium:
          return images.manDying2;
        case Shade.Dark:
          return images.manDying3;
        case Shade.VeryDark:
          return images.manDying3;
      }
      throw Exception();
    case CharacterState.Striking:
      return images.manStriking;
    case CharacterState.ChangingWeapon:
      switch (shade) {
        case Shade.Bright:
          return images.manChanging1;
        case Shade.Medium:
          return images.manChanging2;
        case Shade.Dark:
          return images.manChanging3;
        case Shade.VeryDark:
          return images.manChanging3;
      }
      throw Exception();
    case CharacterState.Running:
      switch (shade) {
        case Shade.Bright:
          return images.manUnarmedRunning1;
        case Shade.Medium:
          return images.manUnarmedRunning2;
        case Shade.Dark:
          return images.manUnarmedRunning3;
        case Shade.VeryDark:
          return images.manUnarmedRunning3;
      }
      throw Exception();
    case CharacterState.Walking:
      if (weapon == Weapon.HandGun) {
        switch (shade) {
          case Shade.Bright:
            return images.manWalkingHandgun1;
          case Shade.Medium:
            return images.manWalkingHandgun2;
          case Shade.Dark:
            return images.manWalkingHandgun3;
          case Shade.VeryDark:
            return images.manWalkingHandgun3;
        }
        throw Exception();
      }
      if (weapon == Weapon.Shotgun) {
        switch (shade) {
          case Shade.Bright:
            return images.manWalkingShotgunShade1;
          case Shade.Medium:
            return images.manWalkingShotgunShade2;
          case Shade.Dark:
            return images.manWalkingShotgunShade3;
          case Shade.VeryDark:
            return images.manWalkingShotgunShade3;
        }
        throw Exception();
      }
      if (shade == Shade.Bright) {
        return images.manWalkingBright;
      }
      return images.manWalking;
    case CharacterState.Firing:
      switch (weapon) {
        case Weapon.HandGun:
          switch (shade) {
            case Shade.Bright:
              return images.manFiringHandgun1;
            case Shade.Medium:
              return images.manFiringHandgun2;
            case Shade.Dark:
              return images.manFiringHandgun3;
            case Shade.VeryDark:
              return images.manFiringHandgun3;
          }
          throw Exception();
        default:
          switch (shade) {
            case Shade.Bright:
              return images.manFiringShotgun1;
            case Shade.Medium:
              return images.manFiringShotgun2;
            case Shade.Dark:
              return images.manFiringShotgun3;
            case Shade.VeryDark:
              return images.manFiringShotgun3;
          }
      }
      throw Exception();
    default:
      throw Exception();
  }
}
