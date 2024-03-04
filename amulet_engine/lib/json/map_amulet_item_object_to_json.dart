
import 'package:amulet_engine/json/amulet_field.dart';
import 'package:lemon_json/src.dart';

import '../common/src/classes/amulet_item_object.dart';

Json mapAmuletItemObjectToJson(AmuletItemObject amuletItemObject){
  final data = Json();
  final skillPoints = Json();

  for (final entry in amuletItemObject.skillPoints.entries) {
    skillPoints[entry.key.name] = entry.value;
  }

  data[AmuletField.Skill_Points] = skillPoints;
  data[AmuletField.Amulet_Item] = amuletItemObject.amuletItem.name;
  return data;
}


