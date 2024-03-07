
import '../amulet/amulet_item.dart';
import '../amulet/skill_type.dart';

class AmuletItemObject {
  final AmuletItem amuletItem;
  final Map<SkillType, int> skillPoints;
  final int level;

  AmuletItemObject({
    required this.amuletItem,
    required this.skillPoints,
    required this.level,
  });

  int get quantify {
    return skillPoints.length;
  }

  double? get damageMax {
    return (amuletItem.damage ?? 0) * (level ?? 0);
  }
}