
import 'package:gamestream_flutter/common/src/isometric/gameobject_type.dart';
import 'package:gamestream_flutter/common/src/isometric/weapon_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/classes/template_animation.dart';

void validateAtlases(){
  for (final entry in GameObjectType.Collection.entries){
    final type = entry.key;
    final values = entry.value;
    final atlas = Atlas.SrcCollection[type];
    for (final value in values){
      if (!atlas.containsKey(value)){
        // print('missing atlas src for ${GameObjectType.getName(type)} ${GameObjectType.getNameSubType(type, value)}');
        throw Exception('missing atlas src for ${GameObjectType.getName(type)} ${GameObjectType.getNameSubType(type, value)}');
      }
    }
  }

  for (final weaponType in WeaponType.values){
    try {
      TemplateAnimation.getWeaponPerformAnimation(weaponType);
    } catch (e){
      print('attack animation missing for ${GameObjectType.getNameSubType(GameObjectType.Weapon, weaponType)}');
    }
  }
}
