import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/amulet/amulet_ui.dart';

String? getSkillTypeLevelDescription(SkillType skillType, int level) {
  switch (skillType) {
    case SkillType.Heal:
      return '+${SkillType.getHealAmount(level)} health';
    case SkillType.Attack_Speed:
      return 'Attack Speed +${(SkillType.getAttackSpeedPercentage(level) * 100).toInt()}%';
    case SkillType.Health_Steal:
      return SkillType.getHealthSteal(level).toStringPercentage;
    case SkillType.Magic_Steal:
      return SkillType.getMagicSteal(level).toStringPercentage;
    case SkillType.Critical_Hit:
      return SkillType.getPercentageCriticalHit(level).toStringPercentage;
    case SkillType.Mighty_Strike:
      return 'damage +${SkillType.getPercentageMightySwing(level).toStringPercentage}';
    default:
      return '';
  }
}
