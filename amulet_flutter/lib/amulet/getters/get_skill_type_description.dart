import 'package:amulet_engine/common.dart';

String getSkillTypeDescription(SkillType skillType) => switch (skillType) {
      SkillType.None => 'None',
      SkillType.Strike => 'perform a melee attack',
      SkillType.Mighty_Strike => 'add extra damage to melee attacks',
      SkillType.Frostball => 'shoot a frozen ball of ice',
      SkillType.Fireball => 'shoot a blazing ball of fire',
      SkillType.Explode => 'caste a mighty explosion',
      SkillType.Shoot_Arrow => 'shoot an arrow',
      SkillType.Split_Shot => 'shoot multiple arrows at once',
      SkillType.Ice_Arrow => 'shoot a frozen arrow',
      SkillType.Fire_Arrow => 'shoot a fire arrow',
      SkillType.Heal => 'recover health',
      SkillType.Attack_Speed => 'increase speed of attacks and spells',
      SkillType.Health_Steal => 'convert damage to health',
      SkillType.Magic_Steal => 'convert damage to magic',
      SkillType.Critical_Hit => 'chance of doing double damage',
      SkillType.Magic_Regen => 'increase magic recovered over time',
      SkillType.Health_Regen => 'increase health recovered over time',
      SkillType.Area_Damage => 'melee damage applied in an area',
      SkillType.Run_Speed => 'increase movement speed',
      SkillType.Shield => 'reduces non magical damage received',
      SkillType.Wind_Cut => 'cuts the air in front',
    };
