
import '../amulet/amulet_item.dart';
import '../amulet/skill_type.dart';

class AmuletItemObject {
  final AmuletItem amuletItem;
  final Map<SkillType, int> skillPoints;
  final double? damage;
  final int? level;
  final ItemQuality? itemQuality;

  AmuletItemObject({
    required this.amuletItem,
    required this.skillPoints,
    this.itemQuality,
    this.damage,
    this.level,
  }) {
    assert(amuletItem.isConsumable || level != null);
  }

  int get quantify {
    return skillPoints.length;
  }
}