
import 'package:amulet_engine/classes/amulet_item_object.dart';
import 'package:amulet_engine/json/amulet_field.dart';
import 'package:lemon_json/src.dart';

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


