
import '../amulet/amulet_item.dart';
import '../amulet/skill_type.dart';
import 'package:lemon_lang/src.dart';

class AmuletItemObject {
  final AmuletItem amuletItem;
  final int level;

  AmuletItemObject({
    required this.amuletItem,
    required this.level,
  });

  double get levelPercentage => level.percentageOf(amuletItem.maxLevel);

  double? get maxHealth => amuletItem.getMaxHealth(level);

  double? get maxMagic => amuletItem.getMaxMagic(level);

  int get sellValue => (amuletItem.getUpgradeCost(level) * 0.25).floor().atLeast(1);

  int getSkillLevel(SkillType skillType) =>
      amuletItem.getSkillTypeLevel(
          skillType: skillType,
          level: level,
      );



}