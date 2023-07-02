import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

class AtlasItems {
  static const size = 32.0;

  static double getSrcX(int type, int subType) {
    const function = 'getSrcX';
    switch (type) {
      case GameObjectType.Weapon:
        return const <int, double> {
          WeaponType.Sword: 0,
          WeaponType.Knife: 1,
          WeaponType.Staff: 32,
          WeaponType.Axe: 128,
          WeaponType.Pickaxe: 160,
          WeaponType.Hammer: 224,
          WeaponType.Crowbar: 256,
          WeaponType.Bow: 64,
          WeaponType.Grenade: 7,
          WeaponType.Shotgun: 177,
          WeaponType.Pistol: 288,
          WeaponType.Handgun: 32,
          WeaponType.Desert_Eagle: 32,
          WeaponType.Revolver: 224,
          WeaponType.Rifle: 595,
          WeaponType.Musket: 64,
          WeaponType.Plasma_Rifle: 577,
          WeaponType.Machine_Gun: 704,
          WeaponType.Sniper_Rifle: 406,
          WeaponType.Smg: 783,
          WeaponType.Flame_Thrower: 177,
          WeaponType.Bazooka: 298,
          WeaponType.Minigun: 1,
          WeaponType.Plasma_Pistol: 417,
          WeaponType.Portal: 673,
        }[subType] ?? (throw buildException(function, type, subType));

      case GameObjectType.Head:
        return const <int, double> {
          HeadType.Steel_Helm: 128,
          HeadType.Rogue_Hood: 160,
          HeadType.Wizards_Hat: 192,
          HeadType.Swat: 288,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Body:
        return const <int, double> {
          BodyType.Shirt_Blue: 64,
          BodyType.Shirt_Cyan: 96,
          BodyType.Tunic_Padded: 128,
          BodyType.Swat: 256,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Legs:
        return const <int, double> {
          LegType.Blue: 224,
          LegType.Brown: 384,
          LegType.Swat: 320,
          LegType.Red: 352,
          LegType.Green: 384,
          LegType.White: 384,
        }[subType] ?? (throw buildException(function, type, subType));

      case GameObjectType.Object:
        return subType == ObjectType.Barrel_Explosive ? 34.0 * gamestream.animation.animationFrame6 :
        const <int, double> {
          ObjectType.Car: 384,
          ObjectType.Crystal: 75,
          ObjectType.Candle: 23,
          ObjectType.Barrel: 11,
          ObjectType.Barrel_Explosive: 128,
          ObjectType.Barrel_Purple: 128,
          ObjectType.Cup: 0,
          ObjectType.Tavern_Sign: 40,
          ObjectType.Crystal_Small_Red: 35,
          ObjectType.Crystal_Small_Blue: 35,
          ObjectType.Aircon_South: 224,
          ObjectType.Toilet: 309,
          ObjectType.Crate_Wooden: 361,
          ObjectType.Desk: 410,
          ObjectType.Vending_Machine: 0,
          ObjectType.Bed: 447,
          ObjectType.Sink: 273,
          ObjectType.Firehydrant: 162,
          ObjectType.Chair: 273,
          ObjectType.Washing_Machine: 304,
          ObjectType.Car_Tire: 208,
          ObjectType.Bottle: 83,
          ObjectType.Van: 102,
          ObjectType.Computer: 204,
          ObjectType.Neon_Sign_01: 254,
          ObjectType.Neon_Sign_02: 304,
          ObjectType.Vending_Upgrades: 1,
          ObjectType.Pipe_Vertical: 181,
          ObjectType.Flag_Red: 368,
          ObjectType.Flag_Blue: 416,
          ObjectType.Base_Red: 368,
          ObjectType.Base_Blue: 368,
          ObjectType.Flag_Spawn_Red: 368,
          ObjectType.Flag_Spawn_Blue: 368,
          ObjectType.Credits: 448,
        }[subType] ?? (throw buildException(function, type, subType));
    }

    switch (type){
      case GameObjectType.Weapon:
        throw buildException(function, type, subType);
    }

    throw buildException(function, type, subType);
  }

  static double getSrcY(int type, int subType) {
    const function = 'getSrcY';

    switch (type) {
      case GameObjectType.Weapon:
        return const <int, double> {
          WeaponType.Shotgun: 243,
          WeaponType.Grenade: 176,
          WeaponType.Knife: 224,
          WeaponType.Staff: 0,
          WeaponType.Axe: 128,
          WeaponType.Pickaxe: 128,
          WeaponType.Hammer: 128,
          WeaponType.Crowbar: 128,
          WeaponType.Handgun: 96,
          WeaponType.Revolver: 96,
          WeaponType.Desert_Eagle: 32,
          WeaponType.Rifle: 0,
          WeaponType.Musket: 96,
          WeaponType.Plasma_Rifle: 1,
          WeaponType.Machine_Gun: 236,
          WeaponType.Sniper_Rifle: 161,
          WeaponType.Smg: 85,
          WeaponType.Flame_Thrower: 161,
          WeaponType.Bazooka: 219,
          WeaponType.Minigun: 130,
          WeaponType.Plasma_Pistol: 208,
          WeaponType.Portal: 42,
        }[subType] ?? (throw buildException(function, type, subType));

      case GameObjectType.Head:
        return const <int, double> {
          HeadType.Swat: 96,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Body:
        return const <int, double> {
          BodyType.Shirt_Blue: 32,
          BodyType.Shirt_Cyan: 32,
          BodyType.Tunic_Padded: 32,
          BodyType.Swat: 96,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Legs:
        return const <int, double> {
          LegType.Blue: 32,
          LegType.Swat: 96,
          LegType.Red: 96,
          LegType.Green: 96,
          LegType.White: 64,
          LegType.Brown: 128,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Object:
        return subType == ObjectType.Barrel_Explosive ? 34.0 * gamestream.animation.animationFrame6 :

        const <int, double> {
         ObjectType.Car: 80,
         ObjectType.Crystal: 0,
         ObjectType.Candle: 131,
         ObjectType.Barrel: 0,
         ObjectType.Barrel_Explosive: 39,
         ObjectType.Barrel_Purple: 103,
         ObjectType.Barrel_Flaming: 176,
         ObjectType.Cup: 0,
         ObjectType.Tavern_Sign: 0,
         ObjectType.Crystal_Small_Blue: 119,
         ObjectType.Crystal_Small_Red: 151,
         ObjectType.Toilet: 0,
         ObjectType.Crate_Wooden: 0,
         ObjectType.Desk: 0,
         ObjectType.Vending_Machine: 256,
         ObjectType.Bed: 0,
         ObjectType.Firehydrant: 49,
         ObjectType.Aircon_South: 64,
         ObjectType.Sink: 48,
         ObjectType.Chair: 83,
         ObjectType.Washing_Machine: 96,
         ObjectType.Car_Tire: 146,
         ObjectType.Bottle: 81,
         ObjectType.Van: 248,
         ObjectType.Computer: 206,
         ObjectType.Neon_Sign_01: 210,
         ObjectType.Neon_Sign_02: 179,
         ObjectType.Vending_Upgrades: 329,
         ObjectType.Pipe_Vertical: 247,
         ObjectType.Flag_Red: 224,
         ObjectType.Flag_Blue: 224,
         ObjectType.Base_Red: 272,
         ObjectType.Base_Blue: 401,
         ObjectType.Flag_Spawn_Red: 272,
         ObjectType.Flag_Spawn_Blue: 401,
        }[subType] ?? (throw buildException(function, type, subType));
    }

    throw buildException(function, type, subType);
  }

  static double getSrcWidth(int type, int subType) {
    const function = 'getSrcWidth';

    switch (type) {
      case GameObjectType.Weapon:
        return const <int, double> {
          WeaponType.Sniper_Rifle: 121,
          WeaponType.Flame_Thrower: 114,
          WeaponType.Bazooka: 117,
          WeaponType.Minigun: 35,
          WeaponType.Rifle: 429,
          WeaponType.Smg: 240,
          WeaponType.Plasma_Rifle: 83,
          WeaponType.Machine_Gun: 319,
          WeaponType.Shotgun: 117,
          WeaponType.Plasma_Pistol: 46,
          WeaponType.Portal: 80,
          WeaponType.Grenade: 38,
          WeaponType.Knife: 44,
        }[subType] ?? (throw buildException(function, type, subType));

      case GameObjectType.Head:
        return const <int, double> {
          HeadType.Swat: 96,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Body:
        return const <int, double> {
          BodyType.Shirt_Blue: 32,
          BodyType.Shirt_Cyan: 32,
          BodyType.Tunic_Padded: 32,
          BodyType.Swat: 96,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Legs:
        return const <int, double> {
          LegType.Blue: 32,
          LegType.Swat: 96,
          LegType.Red: 96,
          LegType.Green: 96,
          LegType.White: 64,
          LegType.Brown: 128,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Object:
        return const <int, double> {
          ObjectType.Car: 115,
          ObjectType.Crystal: 22,
          ObjectType.Barrel: 28,
          ObjectType.Barrel_Explosive: 33,
          ObjectType.Barrel_Purple: 33,
          ObjectType.Barrel_Flaming: 33,
          ObjectType.Crystal_Small_Blue: 10,
          ObjectType.Crystal_Small_Red: 10,
          ObjectType.Cup: 6,
          ObjectType.Tavern_Sign: 19,
          ObjectType.Candle: 3,
          ObjectType.Toilet: 51,
          ObjectType.Crate_Wooden: 48,
          ObjectType.Desk: 36,
          ObjectType.Vending_Machine: 48,
          ObjectType.Bed: 56,
          ObjectType.Firehydrant: 53,
          ObjectType.Aircon_South: 48,
          ObjectType.Sink: 27,
          ObjectType.Chair: 24,
          ObjectType.Washing_Machine: 48,
          ObjectType.Car_Tire: 56,
          ObjectType.Bottle: 18,
          ObjectType.Van: 78,
          ObjectType.Computer: 40,
          ObjectType.Neon_Sign_01: 43,
          ObjectType.Neon_Sign_02: 21,
          ObjectType.Vending_Upgrades: 39,
          ObjectType.Pipe_Vertical: 8,
          ObjectType.Flag_Red: 32,
          ObjectType.Flag_Blue: 32,
          ObjectType.Base_Red: 128,
          ObjectType.Base_Blue: 128,
          ObjectType.Flag_Spawn_Red: 128,
          ObjectType.Flag_Spawn_Blue: 128,
        }[subType] ?? (throw buildException(function, type, subType));
    }

    throw buildException(function, type, subType);
  }

  static double getSrcHeight(int type, int subType) {
    const function = 'getSrcHeight';

    switch (type) {
      case GameObjectType.Weapon:
        return const <int, double> {
          WeaponType.Sniper_Rifle: 37,
          WeaponType.Bazooka: 52,
          WeaponType.Minigun: 12,
          WeaponType.Rifle: 83,
          WeaponType.Smg: 150,
          WeaponType.Machine_Gun: 93,
          WeaponType.Plasma_Rifle: 53,
          WeaponType.Shotgun: 28,
          WeaponType.Plasma_Pistol: 37,
          WeaponType.Portal: 42,
          WeaponType.Flame_Thrower: 66,
          WeaponType.Grenade: 45,
          WeaponType.Knife: 10,
        }[subType] ?? (throw buildException(function, type, subType));

      case GameObjectType.Head:
        return const <int, double> {
          HeadType.Swat: 96,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Body:
        return const <int, double> {
          BodyType.Shirt_Blue: 32,
          BodyType.Shirt_Cyan: 32,
          BodyType.Tunic_Padded: 32,
          BodyType.Swat: 96,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Legs:
        return const <int, double> {
          LegType.Blue: 32,
          LegType.Swat: 96,
          LegType.Red: 96,
          LegType.Green: 96,
          LegType.White: 64,
          LegType.Brown: 128,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Object:
        return const <int, double> {
          ObjectType.Car: 133,
          ObjectType.Crystal: 45,
          ObjectType.Barrel: 40,
          ObjectType.Barrel_Explosive: 63,
          ObjectType.Barrel_Purple: 63,
          ObjectType.Barrel_Flaming: 70,
          ObjectType.Crate_Wooden: 80,
          ObjectType.Desk: 59,
          ObjectType.Candle: 10,
          ObjectType.Cup: 11,
          ObjectType.Tavern_Sign: 39,
          ObjectType.Firehydrant: 104,
          ObjectType.Washing_Machine: 81,
          ObjectType.Crystal_Small_Blue: 18,
          ObjectType.Crystal_Small_Red: 18,
          ObjectType.Toilet: 92,
          ObjectType.Vending_Machine: 72,
          ObjectType.Car_Tire: 57,
          ObjectType.Bottle: 58,
          ObjectType.Bed: 78,
          ObjectType.Aircon_South: 81,
          ObjectType.Sink: 33,
          ObjectType.Van: 129,
          ObjectType.Chair: 49,
          ObjectType.Computer: 68,
          ObjectType.Neon_Sign_01: 144,
          ObjectType.Neon_Sign_02: 33,
          ObjectType.Vending_Upgrades: 94,
          ObjectType.Pipe_Vertical: 40,
          ObjectType.Flag_Red: 32,
          ObjectType.Flag_Blue: 32,
          ObjectType.Base_Red: 128,
          ObjectType.Base_Blue: 128,
          ObjectType.Flag_Spawn_Red: 128,
          ObjectType.Flag_Spawn_Blue: 128,
        }[subType] ?? (throw buildException(function, type, subType));
    }

    throw buildException(function, type, subType);
  }

  static double getSrcScale(int type, int subType) {

    const function = 'getSrcScale';

    switch (type) {
      case GameObjectType.Weapon:
        return const <int, double> {
          WeaponType.Sniper_Rifle: 37,
          WeaponType.Bazooka: 52,
          WeaponType.Minigun: 12,
          WeaponType.Rifle: 83,
          WeaponType.Smg: 150,
          WeaponType.Machine_Gun: 93,
          WeaponType.Plasma_Rifle: 53,
          WeaponType.Shotgun: 28,
          WeaponType.Plasma_Pistol: 37,
          WeaponType.Portal: 42,
          WeaponType.Flame_Thrower: 66,
          WeaponType.Grenade: 45,
          WeaponType.Knife: 10,
        }[subType] ?? (throw buildException(function, type, subType));

      case GameObjectType.Head:
        return const <int, double> {
          HeadType.Swat: 96,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Body:
        return const <int, double> {
          BodyType.Shirt_Blue: 32,
          BodyType.Shirt_Cyan: 32,
          BodyType.Tunic_Padded: 32,
          BodyType.Swat: 96,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Legs:
        return const <int, double> {
          LegType.Blue: 32,
          LegType.Swat: 96,
          LegType.Red: 96,
          LegType.Green: 96,
          LegType.White: 64,
          LegType.Brown: 128,
        }[subType] ?? (
            throw buildException(function, type, subType)
        );

      case GameObjectType.Object:
        return const <int, double> {
          ObjectType.Barrel_Explosive: 0.75,
          ObjectType.Barrel_Purple: 0.75,
          ObjectType.Barrel_Flaming: 0.75,
          ObjectType.Toilet: 0.5,
          ObjectType.Crate_Wooden: 0.75,
          ObjectType.Firehydrant: 0.4,
          ObjectType.Car: 0.66,
          ObjectType.Aircon_South: 0.6,
          ObjectType.Sink: 0.75,
          ObjectType.Washing_Machine: 0.75,
          ObjectType.Car_Tire: 0.5,
          ObjectType.Bottle: 0.4,
          ObjectType.Computer: 0.61,
          ObjectType.Flag_Spawn_Red: 0.5,
          ObjectType.Flag_Spawn_Blue: 0.5,
        }[subType] ?? (throw buildException(function, type, subType));
    }

    throw buildException(function, type, subType);
  }

  static double getAnchorY(int type, int subType) {

    if (type != GameObjectType.Object) return 0.5;

    return const <int, double>{
          ObjectType.Barrel_Explosive: 0.65,
          ObjectType.Barrel_Purple: 0.65,
          ObjectType.Barrel_Flaming: 0.65,
          ObjectType.Crate_Wooden: 0.61,
          ObjectType.Vending_Machine: 0.6,
          ObjectType.Vending_Upgrades: 0.7,
          ObjectType.Firehydrant: 0.66,
          ObjectType.Bottle: 0.6,
          ObjectType.Van: 0.6,
          ObjectType.Pipe_Vertical: 0.9,
        }[subType] ??
        0.5;
  }

  static Exception buildException(String function, int type, int subType) =>
      Exception('$function(type: ${GameObjectType.getName(type)}, subType: ${GameObjectType.getNameSubType(type, subType)})');

}
