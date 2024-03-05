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
      return formatIceDamage(
        damage: SkillType.getDamageFrostBall(level),
        duration: SkillType.getAilmentDurationFrostBall(level),
        durationDamage: SkillType.getAilmentDamageFrostBall(level),
      );
    case SkillType.Fireball:
      return formatFireDamage(
        damage: SkillType.getDamageFireball(level),
        duration: SkillType.getAilmentDurationFireball(level),
        durationDamage: SkillType.getAilmentDamageFireball(level),
      );
    case SkillType.Explode:
      return 'damage: ${SkillType.getDamageExplode(level)}';
    case SkillType.Shoot_Arrow:
      return '';
    case SkillType.Split_Shot:
      return 'total arrows: ${SkillType.getSplitShotTotalArrows(level)}';
    case SkillType.Ice_Arrow:
      return formatIceDamage(
        damage: SkillType.getDamageIceArrow(level),
        duration: SkillType.getAilmentDurationIceArrow(level),
        durationDamage: SkillType.getAilmentDamageIceArrow(level),
      );
    case SkillType.Fire_Arrow:
      return formatFireDamage(
        damage: SkillType.getDamageFireArrow(level),
        duration: SkillType.getAilmentDurationFireArrow(level),
        durationDamage: SkillType.getAilmentDamageFireArrow(level),
      );
    case SkillType.Area_Damage:
      return '${SkillType.getAreaDamage(level).toStringPercentage} area damage';
    case SkillType.Run_Speed:
      return '${SkillType.getRunSpeed(level).toStringPercentage} faster';
    case SkillType.Wind_Cut:
      return 'range +${SkillType.getRangeWindCut(level).toInt()}';
  }
}

String formatFireDamage({
  required double damage,
  required double duration,
  required double durationDamage,
}) =>
    formatAilment(
      damageType: 'fire',
      ailmentType: 'burn',
      damage: damage,
      duration: duration,
      durationDamage: durationDamage
    );

String formatIceDamage({
  required double damage,
  required double duration,
  required double durationDamage,
}) =>
    formatAilment(
      damageType: 'ice',
      ailmentType: 'freeze',
      damage: damage,
      duration: duration,
      durationDamage: durationDamage
    );

String formatAilment({
  required String damageType,
  required String ailmentType,
  required double damage,
  required double duration,
  required double durationDamage,
}) =>
    '$damageType damage: ${damage.toStringAsFixed(1)}\n'
    '$ailmentType damage: ${duration.toStringAsFixed(1)}/s\n'
    '$ailmentType duration: ${duration.toStringAsFixed(1)}s';
