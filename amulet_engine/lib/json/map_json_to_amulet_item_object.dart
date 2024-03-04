import 'package:amulet_engine/common.dart';
import 'package:lemon_json/src.dart';

import 'amulet_field.dart';

AmuletItemObject? mapJsonToAmuletItemObject(Json? json) {

  if (json == null) {
    return null;
  }

  final amuletItemName = json.getString(AmuletField.Amulet_Item);
  final amuletItem = AmuletItem.findByName(amuletItemName);

  if (amuletItem == null) {
    return null;
  }

  final skillPointsText = json.getMapStringInt(AmuletField.Skill_Points);
  final skillPoints = <SkillType, int> {};

  for (final entry in skillPointsText.entries) {
    final skillType = SkillType.tryParse(entry.key);
    if (skillType == null) continue;
    skillPoints[skillType] = entry.value;
  }

  return AmuletItemObject(
      amuletItem: amuletItem,
      skillPoints: skillPoints,
  );
}
