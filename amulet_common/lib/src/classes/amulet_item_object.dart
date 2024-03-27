
import 'dart:math';

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

  int get sellValue => (upgradeCost * 0.25).floor().atLeast(1);

  int get upgradeCost => amuletItem.getUpgradeCost(level);

  int get maxLevel => amuletItem.maxLevel;

  bool get maxLevelReached => level >= maxLevel;

  int getSkillLevel(SkillType skillType) =>
      amuletItem.getSkillTypeLevel(
          skillType: skillType,
          level: level,
      );

  int getSkillLevelNext(SkillType skillType) =>
      amuletItem.getSkillTypeLevel(
          skillType: skillType,
          level: min(level + 1, maxLevel),
      );
}