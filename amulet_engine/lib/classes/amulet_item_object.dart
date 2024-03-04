import 'package:amulet_engine/common/src/amulet/amulet_item.dart';
import 'package:amulet_engine/common/src/amulet/skill_type.dart';

class AmuletItemObject {
  final AmuletItem amuletItem;
  final Map<SkillType, int> skillPoints;

  AmuletItemObject({
    required this.amuletItem,
    required this.skillPoints,
  });

  int getSkillPoints(SkillType skillType) => skillPoints[skillType] ?? 0;
}