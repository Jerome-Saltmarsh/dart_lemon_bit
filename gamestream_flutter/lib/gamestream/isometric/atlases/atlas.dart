import 'package:gamestream_flutter/gamestream/isometric/atlases/src.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'atlas_src_hands.dart';

class Atlas {

  static const SrcX = 0;
  static const SrcY = 1;
  static const SrcWidth = 2;
  static const SrcHeight = 3;
  static const SrcScale = 4;
  static const SrcAnchorY = 5;

  static const Collection_Nothing = <int, List<double>>{};

  static const Collection_Weapons = <int, List<double>>{
    WeaponType.Handgun : AtlasSrcWeapons.Handgun,
    WeaponType.Shotgun : AtlasSrcWeapons.Shotgun,
    WeaponType.Sniper_Rifle : AtlasSrcWeapons.Sniper_Rifle,
    WeaponType.Unarmed : AtlasSrcWeapons.Unarmed,
    WeaponType.Smg : AtlasSrcWeapons.Smg,
    WeaponType.Machine_Gun : AtlasSrcWeapons.Machine_Gun,
    WeaponType.Sword : AtlasSrcWeapons.Sword,
    WeaponType.Bow : AtlasSrcWeapons.Bow,
    WeaponType.Plasma_Pistol : AtlasSrcWeapons.Plasma_Pistol,
    WeaponType.Crowbar : AtlasSrcWeapons.Crowbar,
    WeaponType.Grenade : AtlasSrcWeapons.Grenade,
    WeaponType.Flame_Thrower : AtlasSrcWeapons.Flame_Thrower,
    WeaponType.Bazooka : AtlasSrcWeapons.Bazooka,
    WeaponType.Minigun : AtlasSrcWeapons.Minigun,
    WeaponType.Crossbow : AtlasSrcWeapons.Crossbow,
    WeaponType.Staff : AtlasSrcWeapons.Staff,
    WeaponType.Musket : AtlasSrcWeapons.Musket,
    WeaponType.Revolver : AtlasSrcWeapons.Revolver,
    WeaponType.Pistol : AtlasSrcWeapons.Pistol,
    WeaponType.Plasma_Rifle : AtlasSrcWeapons.Plasma_Rifle,
    WeaponType.Hammer : AtlasSrcWeapons.Hammer,
    WeaponType.Pickaxe : AtlasSrcWeapons.Pickaxe,
    WeaponType.Knife : AtlasSrcWeapons.Knife,
    WeaponType.Axe : AtlasSrcWeapons.Axe,
    WeaponType.Rifle : AtlasSrcWeapons.Rifle,
  };

  static const Collection_Legs = <int, List<double>> {
    LegType.None: AtlasSrcLegs.None,
    LegType.Swat: AtlasSrcLegs.Swat,
    LegType.Blue: AtlasSrcLegs.Blue,
    LegType.Red: AtlasSrcLegs.Red,
    LegType.Brown: AtlasSrcLegs.Brown,
    LegType.Green: AtlasSrcLegs.Green,
    LegType.White: AtlasSrcLegs.Green,
  };

  static const Collection_Helm = <int, List<double>>{
    HelmType.None: AtlasSrcHelm.None,
    HelmType.Steel: AtlasSrcHelm.Steel,
    HelmType.Wizard_Hat: AtlasSrcHelm.Wizards_Hat,
  };

  static const Collection_Hands = <int, List<double>>{
    HandType.None: AtlasSrcHands.None,
    HandType.Gauntlets: AtlasSrcHands.Gauntlet,
  };

  static const Collection_Objects = <int, List<double>>{
    ObjectType.Barrel: AtlasSrcObjects.Barrel,
    ObjectType.Barrel_Explosive: AtlasSrcObjects.Barrel_Explosive,
    ObjectType.Barrel_Flaming: AtlasSrcObjects.Barrel_Flaming,
    ObjectType.Crate_Wooden: AtlasSrcObjects.Crate_Wooden,
    ObjectType.Flag_Red: AtlasSrcObjects.Flag_Red,
    ObjectType.Flag_Blue: AtlasSrcObjects.Flag_Blue,
    ObjectType.Base_Red: AtlasSrcObjects.Base_Red,
    ObjectType.Base_Blue: AtlasSrcObjects.Base_Blue,
    ObjectType.Spawn_Red: AtlasSrcObjects.Spawn_Red,
    ObjectType.Spawn_Blue: AtlasSrcObjects.Spawn_Blue,
    ObjectType.Credits: AtlasSrcObjects.Credits,
    ObjectType.Car: AtlasSrcObjects.Car,
    ObjectType.Crystal: AtlasSrcObjects.Crystal,
    ObjectType.Candle: AtlasSrcObjects.Candle,
    ObjectType.Barrel_Purple: AtlasSrcObjects.Barrel_Purple,
    ObjectType.Cup: AtlasSrcObjects.Cup,
    ObjectType.Crystal_Small_Red: AtlasSrcObjects.Crystal_Small_Red,
    ObjectType.Crystal_Small_Blue: AtlasSrcObjects.Crystal_Small_Blue,
    ObjectType.Aircon_South: AtlasSrcObjects.Aircon_South,
    ObjectType.Toilet: AtlasSrcObjects.Toilet,
    ObjectType.Desk: AtlasSrcObjects.Desk,
    ObjectType.Vending_Machine: AtlasSrcObjects.Vending_Machine,
    ObjectType.Bed: AtlasSrcObjects.Bed,
    ObjectType.Sink: AtlasSrcObjects.Sink,
    ObjectType.Firehydrant: AtlasSrcObjects.Firehydrant,
    ObjectType.Chair: AtlasSrcObjects.Chair,
    ObjectType.Car_Tire: AtlasSrcObjects.Car_Tire,
    ObjectType.Bottle: AtlasSrcObjects.Bottle,
    ObjectType.Van: AtlasSrcObjects.Van,
    ObjectType.Computer: AtlasSrcObjects.Computer,
    ObjectType.Neon_Sign_01: AtlasSrcObjects.Neon_Sign_01,
    ObjectType.Neon_Sign_02: AtlasSrcObjects.Neon_Sign_02,
    ObjectType.Flag_Spawn_Red: AtlasSrcObjects.Flag_Spawn_Red,
    ObjectType.Flag_Spawn_Blue: AtlasSrcObjects.Flag_Spawn_Blue,
    ObjectType.Grenade: AtlasSrcObjects.Grenade,
  };

  static const SrcCollection = <int, Map<int, List<double>>>{
    ItemType.Weapon: Collection_Weapons,
    ItemType.Legs: Collection_Legs,
    ItemType.Body: atlasSrcBodyType,
    ItemType.Helm: Collection_Helm,
    ItemType.Object: Collection_Objects,
    ItemType.Hand: Collection_Hands,
    ItemType.Consumable: atlasSrcConsumables,
    ItemType.Treasure: atlasSrcTreasures,
  };

  static List<double> getSrc(int type, int subType) =>
      SrcCollection[type]?[subType] ??
      (throw Exception(
          'Atlas.getSrc(type: ${ItemType.getName(type)}, subType: ${ItemType.getNameSubType(type, subType)})'
      ));
}
