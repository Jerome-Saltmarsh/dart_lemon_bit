
import '../amulet/amulet_item.dart';
import '../amulet/skill_type.dart';

class AmuletItemObject {
  final AmuletItem amuletItem;
  final int level;

  AmuletItemObject({
    required this.amuletItem,
    required this.level,
  });

  double? get damageMax {
    final damage = amuletItem.damage;
    if (damage == null){
      return null;
    }
    return damage * level;
  }

  double? get damageMin {
    final damageMax = this.damageMax;
    if (damageMax == null){
      return null;
    }
    return damageMax * level;
  }

  int getSkillLevel(SkillType skillType) =>
      amuletItem.getSkillTypeValue(
          skillType: skillType,
          level: level,
      );

}