import 'package:gamestream_flutter/common.dart';

import 'atlas_src_objects.dart';


class Atlas {

  static const SrcX = 0;
  static const SrcY = 1;
  static const SrcWidth = 2;
  static const SrcHeight = 3;
  static const SrcScale = 4;
  static const SrcAnchorY = 5;

  static const Collection_Nothing = <int, List<double>>{};

  static const Collection_Weapons = <int, List<double>>{};

  static const Collection_Legs = <int, List<double>>{};

  static const Collection_Body = <int, List<double>>{};

  static const Collection_Head = <int, List<double>>{};

  static const Collection_Objects = <int, List<double>>{
    ObjectType.Barrel: AtlasSrcObjects.Barrel,
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
}
