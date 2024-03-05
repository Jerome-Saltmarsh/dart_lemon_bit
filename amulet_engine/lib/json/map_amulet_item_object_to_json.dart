
import 'package:amulet_engine/common/src/amulet/skill_type.dart';
import 'package:amulet_engine/json/amulet_field.dart';
import 'package:lemon_json/src.dart';

import '../common/src/classes/amulet_item_object.dart';

Json mapAmuletItemObjectToJson(AmuletItemObject amuletItemObject){
  final data = Json();
  data[AmuletField.Skill_Points] = mapSkillPointsToJson(amuletItemObject.skillPoints);
  data[AmuletField.Amulet_Item] = amuletItemObject.amuletItem.name;
  data[AmuletField.Damage] = amuletItemObject.damage;
  data[AmuletField.Level] = amuletItemObject.level;
  data[AmuletField.Item_Quality] = amuletItemObject.itemQuality;
  return data;
}

Json mapSkillPointsToJson(Map<SkillType, int> skillPoints){
  final json = Json();
  for (final entry in skillPoints.entries) {
    json[entry.key.name] = entry.value;
  }
  return json;
}


