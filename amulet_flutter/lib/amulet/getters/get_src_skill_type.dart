import 'package:amulet_engine/common.dart';

const _srcX = 400.0;
const iconSizeSkillType = 16.0;

List<double> getSrcSkillType(SkillType skillType) =>
    switch (skillType) {
      SkillType.None => const [_srcX, iconSizeSkillType * 0],
      SkillType.Fireball => const [416, 32, 32 ,32],
      SkillType.Frostball => const [416, 64, 32 ,32],
      SkillType.Strike => const [_srcX, iconSizeSkillType * 4],
      SkillType.Shoot_Arrow => const [_srcX, iconSizeSkillType * 5],
      SkillType.Heal => const [416, 192, 32, 32],
      SkillType.Mighty_Strike => const [416, 0, 32, 32],
      SkillType.Explode => const [416, 96, 32 ,32],
      SkillType.Split_Shot => const [_srcX, 288],
      SkillType.Freeze_Target => const [416, 128, 32, 32],
      SkillType.Freeze_Area => const [416, 160, 32, 32],
      SkillType.Ice_Arrow => const [_srcX, 256],
      SkillType.Fire_Arrow => const [_srcX, 272],
      SkillType.Exploding_Arrow => const [_srcX, 240],
      SkillType.Blind => const [_srcX, 336],
      SkillType.Agile => const [768, 64],
      SkillType.Health_Steal => const [768, 256],
      SkillType.Magic_Steal => const [768, 272],
      SkillType.Critical_Hit =>  const [768, 336],
      SkillType.Magic_Regen =>  const [416, 224, 32, 32],
      SkillType.Health_Regen =>  const [416, 256, 32, 32],
      SkillType.Area_Damage =>  const [416, 288, 32, 32],
    };
