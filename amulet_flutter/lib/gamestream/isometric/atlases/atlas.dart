import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_src_spells.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/src.dart';
import 'package:amulet_engine/packages/common.dart';
import 'atlas_src_hands.dart';
import 'atlas_src_shoes.dart';


class Atlas {

  static const SrcX = 0;
  static const SrcY = 1;
  static const SrcWidth = 2;
  static const SrcHeight = 3;
  static const SrcScale = 4;
  static const SrcAnchorY = 5;

  static const Collection_Nothing = <int, List<double>>{};

  static const Collection_Legs = <int, List<double>> {
    LegType.None: AtlasSrcLegs.None,
    LegType.Leather: AtlasSrcLegs.Red,
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
    GameObjectType.Barrel: AtlasSrcObjects.Barrel,
    GameObjectType.Barrel_Explosive: AtlasSrcObjects.Barrel_Explosive,
    GameObjectType.Barrel_Flaming: AtlasSrcObjects.Barrel_Flaming,
    GameObjectType.Crate_Wooden: AtlasSrcObjects.Crate_Wooden,
    GameObjectType.Flag_Red: AtlasSrcObjects.Flag_Red,
    GameObjectType.Flag_Blue: AtlasSrcObjects.Flag_Blue,
    GameObjectType.Base_Red: AtlasSrcObjects.Base_Red,
    GameObjectType.Base_Blue: AtlasSrcObjects.Base_Blue,
    GameObjectType.Spawn_Red: AtlasSrcObjects.Spawn_Red,
    GameObjectType.Spawn_Blue: AtlasSrcObjects.Spawn_Blue,
    GameObjectType.Credits: AtlasSrcObjects.Credits,
    GameObjectType.Car: AtlasSrcObjects.Car,
    GameObjectType.Candle: AtlasSrcObjects.Candle,
    GameObjectType.Barrel_Purple: AtlasSrcObjects.Barrel_Purple,
    GameObjectType.Cup: AtlasSrcObjects.Cup,
    GameObjectType.Crystal_Small_Red: AtlasSrcObjects.Crystal_Small_Red,
    GameObjectType.Crystal_Small_Blue: AtlasSrcObjects.Crystal_Small_Blue,
    GameObjectType.Aircon_South: AtlasSrcObjects.Aircon_South,
    GameObjectType.Toilet: AtlasSrcObjects.Toilet,
    GameObjectType.Desk: AtlasSrcObjects.Desk,
    GameObjectType.Vending_Machine: AtlasSrcObjects.Vending_Machine,
    GameObjectType.Bed: AtlasSrcObjects.Bed,
    GameObjectType.Sink: AtlasSrcObjects.Sink,
    GameObjectType.Firehydrant: AtlasSrcObjects.Firehydrant,
    GameObjectType.Chair: AtlasSrcObjects.Chair,
    GameObjectType.Car_Tire: AtlasSrcObjects.Car_Tire,
    GameObjectType.Bottle: AtlasSrcObjects.Bottle,
    GameObjectType.Van: AtlasSrcObjects.Van,
    GameObjectType.Computer: AtlasSrcObjects.Computer,
    GameObjectType.Neon_Sign_01: AtlasSrcObjects.Neon_Sign_01,
    GameObjectType.Neon_Sign_02: AtlasSrcObjects.Neon_Sign_02,
    GameObjectType.Flag_Spawn_Red: AtlasSrcObjects.Flag_Spawn_Red,
    GameObjectType.Flag_Spawn_Blue: AtlasSrcObjects.Flag_Spawn_Blue,
    GameObjectType.Grenade: AtlasSrcObjects.Grenade,
  };

  static const SrcCollection = <int, Map<int, List<double>>>{
    ItemType.Weapon: atlasSrcWeapons,
    ItemType.Legs: Collection_Legs,
    ItemType.Body: atlasSrcBodyType,
    ItemType.Helm: Collection_Helm,
    ItemType.Object: Collection_Objects,
    ItemType.Hand: Collection_Hands,
    ItemType.Consumable: atlasSrcConsumables,
    ItemType.Treasure: atlasSrcTreasures,
    ItemType.Shoes: atlasSrcShoes,
    ItemType.Spell: atlasSrcSpells,
  };

  static List<double> getSrc(int type, int subType) =>
      SrcCollection[type]?[subType] ??
      (throw Exception(
          'Atlas.getSrc(type: ${ItemType.getName(type)}, subType: ${ItemType.getNameSubType(type, subType)})'
      ));
}
