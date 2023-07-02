import 'package:gamestream_flutter/common.dart';

import 'atlas_src_objects.dart';


class AtlasSrc {

  static const SrcX = 0;
  static const SrcY = 1;
  static const SrcWidth = 2;
  static const SrcHeight = 3;
  static const SrcScale = 4;
  static const SrcAnchorY = 5;

  static const Collection_Nothing = {};

  static const Collection_Weapons = {};

  static const Collection_Legs = {};

  static const Collection_Body = {};

  static const Collection_Head = {};

  static const Collection_Objects = {
    ObjectType.Barrel: AtlasSrcObjects.Barrel,
  };

  static const Collection = [
    Collection_Nothing,
    Collection_Weapons,
    Collection_Legs,
    Collection_Body,
    Collection_Head,
    Collection_Objects
  ];

  static List<double> getSrc(int type, int subType) => Collection[type][subType];
}
