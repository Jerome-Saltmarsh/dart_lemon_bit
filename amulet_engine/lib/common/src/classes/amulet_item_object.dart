
import '../amulet/amulet_item.dart';
import '../amulet/skill_type.dart';

class AmuletItemObject {
  final AmuletItem amuletItem;
  final Map<SkillType, int> skillPoints;
  final double? damage;

  AmuletItemObject({
    required this.amuletItem,
    required this.skillPoints,
    this.damage,
  });

  int getSkillPoints(SkillType skillType) => skillPoints[skillType] ?? 0;
}