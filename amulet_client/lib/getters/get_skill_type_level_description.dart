import 'package:amulet_client/extensions/double_extension.dart';
import 'package:amulet_common/src.dart';

String? getSkillTypeLevelDescription(SkillType skillType, int level) {
  switch (skillType) {
    case SkillType.Heal:
      return '+${SkillType.getHealAmount(level)} health';
    case SkillType.Attack_Speed:
      return 'attack speed +${SkillType.getAttackSpeed(level).toStringPercentage}';
    case SkillType.Health_Steal:
      return '${SkillType.getHealthSteal(level).toStringPercentage} of damage';
    case SkillType.Magic_Steal:
      return '${SkillType.getMagicSteal(level).toStringPercentage} of damage';
    case SkillType.Critical_Hit:
      return '${SkillType.getPercentageCriticalHit(level).toStringPercentage} chance';
    case SkillType.Mighty_Strike:
      return 'damage +${SkillType.getPercentageMightySwing(level).toStringPercentage}';
    case SkillType.Resist_Fire:
      return '${SkillType.getResistFire(level).toStringPercentage} damage reduced';
    case SkillType.Resist_Ice:
      return '${SkillType.getResistIce(level).toStringPercentage} damage reduced';
    case SkillType.Resist_Pierce:
      return '${SkillType.getResistPierce(level).toStringPercentage} damage reduced';
    case SkillType.Resist_Bludgeon:
      return '${SkillType.getResistBludgeon(level).toStringPercentage} damage reduced';
    case SkillType.Resist_Slash:
      return '${SkillType.getResistSlash(level).toStringPercentage} damage reduced';
    case SkillType.Magic_Regen:
      return '+$level magic regen';
    case SkillType.Health_Regen:
      return '+$level health regen';
    case SkillType.None:
      return '';
    case SkillType.Slash:
      return formatDamage('Slash Damage', SkillType.Slash, level);
    case SkillType.Bludgeon:
      return formatDamage('Bludgeon Damage', SkillType.Bludgeon, level);
    case SkillType.Shoot_Arrow:
      return formatDamage('Pierce Damage', SkillType.Shoot_Arrow, level);
    case SkillType.Ice_Ball:
      return formatIceDamage(
        damage: SkillType.getDamageIceBall(level),
        duration: SkillType.getAilmentDurationIceBall(level),
        durationDamage: SkillType.getAilmentDamageIceBall(level),
      );
    case SkillType.Fire_Ball:
      return formatFireDamage(
        damage: SkillType.getDamageFireBall(level),
        duration: SkillType.getAilmentDurationFireball(level),
        durationDamage: SkillType.getAilmentDamageFireball(level),
      );
    case SkillType.Explode:
      return 'damage: ${SkillType.getDamageExplode(level)}';
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
    case SkillType.Max_Health:
      return 'health +${SkillType.getMaxHealth(level).toInt()}';
    case SkillType.Max_Magic:
      return 'magic +${SkillType.getMaxMagic(level).toInt()}';
  }
}

String formatDamage(String text, SkillType skillType, int level) =>
    '$text ${skillType.getDamageMin(level)?.toStringAsFixed(1)}'
        '-${skillType.getDamageMax(level)?.toStringAsFixed(1)}';

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
