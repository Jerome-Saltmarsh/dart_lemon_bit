import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/amulet/extensions.dart';

String? getSkillTypeLevelDescription(SkillType skillType, int level) {
  switch (skillType) {
    case SkillType.Heal:
      return '+${SkillType.getHealAmount(level)} health';
    case SkillType.Agility:
      return 'attack speed +${(SkillType.getAttackSpeedPercentage(level) * 100).toInt()}%';
    case SkillType.Vampire:
      return '${SkillType.getHealthSteal(level).toStringPercentage} of damage';
    case SkillType.Warlock:
      return '${SkillType.getMagicSteal(level).toStringPercentage} of damage';
    case SkillType.Critical_Hit:
      return '${SkillType.getPercentageCriticalHit(level).toStringPercentage} chance';
    case SkillType.Mighty_Strike:
      return 'damage +${SkillType.getPercentageMightySwing(level).toStringPercentage}';
    case SkillType.Shield:
      return '${SkillType.getPercentageDamageResistanceMelee(level).toStringPercentage} damage reduced';
    case SkillType.Magic_Regen:
      return '+$level magic regen';
    case SkillType.Health_Regen:
      return '+$level health regen';
    case SkillType.None:
      return '';
    case SkillType.Strike:
      return '-';
    case SkillType.Frostball:
      return 'ice damage: ${SkillType.getDamageFrostBall(level)}';
    case SkillType.Fireball:
      return 'fire damage: ${SkillType.getDamageFireball(level)}';
    case SkillType.Explode:
      return 'damage: ${SkillType.getDamageExplode(level)}';
    case SkillType.Shoot_Arrow:
      return '';
    case SkillType.Split_Shot:
      return 'total arrows: ${SkillType.getSplitShotTotalArrows(level)}';
    case SkillType.Ice_Arrow:
      return 'ice damage: ${SkillType.getDamageIceArrow(level)}';
    case SkillType.Fire_Arrow:
      return 'fire damage: ${SkillType.getDamageFireArrow(level)}';
    case SkillType.Area_Damage:
      return '${SkillType.getAreaDamage(level).toStringPercentage} area damage';
    case SkillType.Run_Speed:
      return '${SkillType.getRunSpeed(level).toStringPercentage} faster';
    case SkillType.Wind_Cut:
      return 'range +${SkillType.getRangeWindCut(level).toInt()}';
  }
}
