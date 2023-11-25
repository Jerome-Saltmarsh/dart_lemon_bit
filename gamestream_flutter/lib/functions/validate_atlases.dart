import 'package:amulet_engine/packages/isometric_engine/packages/common/src/isometric/item_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_src_icon_type.dart';
import 'package:gamestream_flutter/gamestream/ui/enums/icon_type.dart';

void validateAtlases(){

  for (final iconType in IconType.values){
    if (!atlasSrcIconType.containsKey(iconType)){
      print('validation: "atlasSrcIconType does not contain $iconType"');
    }
  }

  for (final entry in ItemType.collections.entries){
    final type = entry.key;
    final values = entry.value;
    final atlas = Atlas.SrcCollection[type];
    if (atlas == null) {
      print('validation: "missing atlas ${ItemType.getName(type)}"');
      continue;
    }
    for (final value in values){
      if (!atlas.containsKey(value)){
        print('validation: "missing atlas src for ${ItemType.getName(type)} ${ItemType.getNameSubType(type, value)}"');
      }
    }
  }
}
