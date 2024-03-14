
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
    final amuletItemDamageMin = amuletItem.damageMin;
    if (amuletItemDamageMin == null){
      return null;
    }
    return damageMax * amuletItemDamageMin;
  }

  int getSkillLevel(SkillType skillType) =>
      amuletItem.getSkillTypeLevel(
          skillType: skillType,
          level: level,
      );



}