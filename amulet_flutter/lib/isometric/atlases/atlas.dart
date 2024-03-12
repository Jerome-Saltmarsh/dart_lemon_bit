import 'package:amulet_engine/common/src.dart';

import 'atlas_src_objects.dart';


class Atlas {
  static const SrcX = 0;
  static const SrcY = 1;
  static const SrcWidth = 2;
  static const SrcHeight = 3;
  static const SrcScale = 4;
  static const SrcAnchorY = 5;

  static const Collection_Nothing = <int, List<double>>{};

  static const Collection_Objects = <int, List<double>>{
    GameObjectType.Barrel: AtlasSrcObjects.Barrel,
    GameObjectType.Crate_Wooden: AtlasSrcObjects.Crate_Wooden,
    GameObjectType.Candle: AtlasSrcObjects.Candle,
    GameObjectType.Cup: AtlasSrcObjects.Cup,
    GameObjectType.Bed: AtlasSrcObjects.Bed,
    GameObjectType.Bottle: AtlasSrcObjects.Bottle,
  };
}
