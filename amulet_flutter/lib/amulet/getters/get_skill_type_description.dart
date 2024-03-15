import 'package:amulet_common/src.dart';

String getSkillTypeDescription(SkillType skillType) => switch (skillType) {
      SkillType.None => 'None',
      SkillType.Slash => 'a sharp melee attack',
      SkillType.Bludgeon => 'a blunt melee attack',
      SkillType.Mighty_Strike => 'add extra damage to melee attacks',
      SkillType.Ice_Ball => 'shoot a frozen ball of ice',
      SkillType.Fire_Ball => 'shoot a blazing ball of fire',
      SkillType.Explode => 'caste a mighty explosion',
      SkillType.Shoot_Arrow => 'shoot an arrow',
      SkillType.Split_Shot => 'shoot multiple arrows at once',
      SkillType.Ice_Arrow => 'shoot a frozen arrow',
      SkillType.Fire_Arrow => 'shoot a fire arrow',
      SkillType.Heal => 'recover health',
      SkillType.Attack_Speed => 'increase speed of attacks and spells',
      SkillType.Health_Steal => 'recover health by damaging enemies',
      SkillType.Magic_Steal => 'recover magic by damaging enemies',
      SkillType.Critical_Hit => 'chance of doing double damage',
      SkillType.Magic_Regen => 'increase magic recovered over time',
      SkillType.Health_Regen => 'increase health recovered over time',
      SkillType.Area_Damage => 'melee damage applied in an area',
      SkillType.Run_Speed => 'increase movement speed',
      SkillType.Resist_Bludgeon => 'reduces bludgeon damage received',
      SkillType.Resist_Slash => 'reduces slash damage received',
      SkillType.Max_Magic => 'increases total magic',
      SkillType.Resist_Pierce => 'reduces piercing damage',
      SkillType.Resist_Ice => 'reduces ice damage received',
      SkillType.Resist_Fire => 'reduces fire damage received',
      SkillType.Wind_Cut => 'cuts the air in front',
      SkillType.Max_Health => 'increases total health',
    };
