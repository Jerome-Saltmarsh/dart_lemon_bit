import 'package:amulet_common/src.dart';

const _srcX = 400.0;
const iconSizeSkillType = 16.0;

List<double> getSrcSkillType(SkillType skillType) =>
    switch (skillType) {
      SkillType.None => const [_srcX, 0],
      SkillType.Fire_Ball => const [416, 32, 32 ,32],
      SkillType.Ice_Ball => const [416, 64, 32 ,32],
      SkillType.Slash => const [416, 928, 32, 32],
      SkillType.Bludgeon => const [416, 896, 32, 32],
      SkillType.Shoot_Arrow => const [416, 960, 32, 32],
      SkillType.Heal => const [416, 480, 32, 32],
      SkillType.Mighty_Strike => const [416, 544, 32, 32],
      SkillType.Explode => const [416, 96, 32 ,32],
      SkillType.Split_Shot => const [416, 512, 32, 32],
      SkillType.Ice_Arrow => const [416, 732, 32, 32],
      SkillType.Fire_Arrow => const [_srcX, 272],
      SkillType.Attack_Speed => const [768, 64],
      SkillType.Health_Steal => const [416, 576, 32, 32],
      SkillType.Magic_Steal => const [416, 768, 32, 32],
      SkillType.Critical_Hit =>  const [416, 448, 32, 32],
      SkillType.Magic_Regen =>  const [416, 704, 32, 32],
      SkillType.Health_Regen =>  const [416, 384, 32, 32],
      SkillType.Area_Damage =>  const [416, 288, 32, 32],
      SkillType.Run_Speed =>  const [416, 640, 32, 32],
      SkillType.Wind_Cut => const [416, 800, 32 ,32],
      SkillType.Max_Health => const [416, 832, 32 ,32],
      SkillType.Max_Magic => const [416, 864, 32 ,32],
      SkillType.Resist_Ice => const [416, 352, 32 ,32],
      SkillType.Resist_Fire => const [416, 352, 32 ,32],
      SkillType.Resist_Pierce => const [416, 352, 32 ,32],
      SkillType.Resist_Slash => const [416, 352, 32 ,32],
      SkillType.Resist_Bludgeon => const [416, 352, 32 ,32],
    };
