
import 'package:amulet_common/src.dart';
import 'package:amulet_engine/json/amulet_field.dart';
import 'package:lemon_json/src.dart';


Json mapAmuletItemObjectToJson(AmuletItemObject amuletItemObject) =>
    Json()
      ..[AmuletField.Amulet_Item] = amuletItemObject.amuletItem.name
      ..[AmuletField.Level] = amuletItemObject.level
    ;

Json mapSkillPointsToJson(Map<SkillType, int> skillPoints){
  final json = Json();
  for (final entry in skillPoints.entries) {
    json[entry.key.name] = entry.value;
  }
  return json;
}


