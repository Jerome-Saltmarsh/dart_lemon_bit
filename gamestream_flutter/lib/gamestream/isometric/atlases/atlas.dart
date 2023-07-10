import 'dart:ui';

import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/images.dart';

import 'atlas_src_objects.dart';


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

  static const Collection_Head = <int, List<double>>{};

  static const Collection_Objects = <int, List<double>>{
    ObjectType.Barrel: AtlasSrcObjects.Barrel,
    ObjectType.Barrel_Explosive: AtlasSrcObjects.Barrel_Explosive,
    ObjectType.Crate_Wooden: AtlasSrcObjects.Crate_Wooden,
    ObjectType.Flag_Red: AtlasSrcObjects.Flag_Red,
    ObjectType.Flag_Blue: AtlasSrcObjects.Flag_Blue,
    ObjectType.Base_Red: AtlasSrcObjects.Base_Red,
    ObjectType.Base_Blue: AtlasSrcObjects.Base_Blue,
    ObjectType.Spawn_Red: AtlasSrcObjects.Spawn_Red,
    ObjectType.Spawn_Blue: AtlasSrcObjects.Spawn_Blue,
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
          _ => (throw Exception('Atlas.getImage(type: ${GameObjectType.getName(type)}})'))
      }
;
}
