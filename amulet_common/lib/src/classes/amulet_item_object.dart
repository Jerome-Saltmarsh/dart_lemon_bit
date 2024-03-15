
import '../amulet/amulet_item.dart';
import '../amulet/skill_type.dart';

class AmuletItemObject {
  final AmuletItem amuletItem;
  final int level;

  AmuletItemObject({
    required this.amuletItem,
    required this.level,
  });

  double? get maxHealth => amuletItem.getMaxHealth(level);

  double? get maxMagic => amuletItem.getMaxMagic(level);

  int getSkillLevel(SkillType skillType) =>
      amuletItem.getSkillTypeLevel(
          skillType: skillType,
          level: level,
      );



}