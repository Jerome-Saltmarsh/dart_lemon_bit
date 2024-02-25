import 'package:amulet_engine/common.dart';

const _srcX = 400.0;
const iconSizeSkillType = 16.0;

List<double> getSkillTypeSrc(SkillType skillType) =>
    switch (skillType) {
      SkillType.None => const [_srcX, iconSizeSkillType * 0],
      SkillType.Fireball => const [_srcX, iconSizeSkillType * 1],
      SkillType.Frostball => const [_srcX, iconSizeSkillType * 2],
      SkillType.Strike => const [_srcX, iconSizeSkillType * 4],
      SkillType.Shoot_Arrow => const [_srcX, iconSizeSkillType * 5],
      SkillType.Heal => const [_srcX, iconSizeSkillType * 6],
      SkillType.Mighty_Strike => const [_srcX, iconSizeSkillType * 7],
      SkillType.Explode => const [_srcX, iconSizeSkillType * 8],
      SkillType.Split_Shot => const [_srcX, 288],
      SkillType.Freeze_Target => const [_srcX, iconSizeSkillType * 11],
      SkillType.Freeze_Area => const [_srcX, iconSizeSkillType * 12],
      SkillType.Ice_Arrow => const [_srcX, 256],
      SkillType.Fire_Arrow => const [_srcX, 272],
      SkillType.Exploding_Arrow => const [_srcX, 240],
      SkillType.Blind => const [_srcX, 336],
      SkillType.Passive_Agile => const [768, 64],
      SkillType.Passive_Health_Steal => const [768, 256],
      SkillType.Passive_Magic_Steal => const [768, 272],
      SkillType.Passive_Critical_Hit =>  const [768, 336],
    };
