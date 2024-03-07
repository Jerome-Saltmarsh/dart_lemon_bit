
import '../amulet/amulet_item.dart';
import '../amulet/skill_type.dart';

class AmuletItemObject {
  final AmuletItem amuletItem;
  final int level;

  AmuletItemObject({
    required this.amuletItem,
    required this.level,
  });

  double? get damageMax => (amuletItem.damage ?? 0) * level;

  int getSkillLevel(SkillType skillType) =>
      amuletItem.getSkillTypeValue(
          skillType: skillType,
          level: level,
      );

}