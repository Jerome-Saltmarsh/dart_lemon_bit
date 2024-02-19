import 'package:amulet_engine/common/src.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/src.dart';


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

  static List<double> getSrc(int type, int subType) {

    if (type == ItemType.Amulet_Item){
      return atlasSrcAmuletItem[AmuletItem.values[subType]] ?? (throw Exception(
          'Atlas.getSrc(type: ${ItemType.getName(type)}, subType: ${ItemType.getNameSubType(type, subType)})'
      ));
    }

    if (type == ItemType.Object){
      return Collection_Objects[subType] ?? (throw Exception(
          'Atlas.getSrc(type: ${ItemType.getName(type)}, subType: ${ItemType.getNameSubType(type, subType)})'
      ));
    }

    throw Exception(
        'Atlas.getSrc(type: ${ItemType.getName(type)}, subType: ${ItemType.getNameSubType(type, subType)})'
    );
  }
}
