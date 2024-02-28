import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/amulet/amulet_ui.dart';

String? getSkillTypeLevelDescription(SkillType skillType, int level) {
  switch (skillType) {
    case SkillType.Heal:
      return '+${SkillType.getHealAmount(level)} health';
    case SkillType.Attack_Speed:
      return 'attack speed +${(SkillType.getAttackSpeedPercentage(level) * 100).toInt()}%';
    case SkillType.Health_Steal:
      return '${SkillType.getHealthSteal(level).toStringPercentage} of damage';
    case SkillType.Magic_Steal:
      return '${SkillType.getMagicSteal(level).toStringPercentage} of damage';
    case SkillType.Critical_Hit:
      return '${SkillType.getPercentageCriticalHit(level).toStringPercentage} chance';
    case SkillType.Mighty_Strike:
      return 'damage +${SkillType.getPercentageMightySwing(level).toStringPercentage}';
    case SkillType.Resist_Melee:
      return '${SkillType.getPercentageDamageResistanceMelee(level).toStringPercentage} reduced';
    case SkillType.Magic_Regen:
      return '+$level magic regen';
    case SkillType.Health_Regen:
      return '+$level health regen';
    default:
      return '';
  }
}
