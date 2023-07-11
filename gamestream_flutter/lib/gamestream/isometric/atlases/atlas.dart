import 'dart:ui';

import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_src_head.dart';
import 'package:gamestream_flutter/images.dart';

import 'atlas_src_objects.dart';
import 'atlas_src_weapons.dart';


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
  };

  static const Collection_Legs = <int, List<double>>{};

  static const Collection_Body = <int, List<double>>{};

  static const Collection_Head = <int, List<double>>{
    HeadType.Plain: AtlasSrcHead.Plain,
    HeadType.Blonde: AtlasSrcHead.Blond,
    HeadType.Rogue_Hood: AtlasSrcHead.Rogue_Hood,
    HeadType.Steel_Helm: AtlasSrcHead.Steel_Helm,
    HeadType.Swat: AtlasSrcHead.Swat,
    HeadType.Wizards_Hat: AtlasSrcHead.Wizards_Hat,
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
  };

  static const Collection = <Map<int, List<double>>>[
    Collection_Nothing,
    Collection_Weapons,
    Collection_Legs,
    Collection_Body,
    Collection_Head,
    Collection_Objects
  ];

  static List<double> getSrc(int type, int subType) =>
      Collection[type][subType] ??
      (throw Exception(
          'Atlas.getSrc(type: ${GameObjectType.getName(type)}, subType: ${GameObjectType.getNameSubType(type, subType)})'
      ));

  static Image getImage(int type) =>
      switch (type) {
          GameObjectType.Weapon => Images.atlas_weapons,
          GameObjectType.Object => Images.atlas_gameobjects,
          GameObjectType.Head => Images.atlas_head,
          GameObjectType.Body => Images.atlas_body,
          GameObjectType.Legs => Images.atlas_legs,
          _ => (throw Exception('Atlas.getImage(type: ${GameObjectType.getName(type)}})'))
      }
;
}
