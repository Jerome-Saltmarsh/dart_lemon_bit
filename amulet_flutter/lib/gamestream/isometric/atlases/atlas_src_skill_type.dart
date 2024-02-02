
import 'package:amulet_engine/packages/common.dart';

const _srcX = 400.0;
const iconSizeSkillType = 16.0;

const atlasSrcSkillType = <SkillType, List<double>> {
  SkillType.None: [_srcX, iconSizeSkillType * 0],
  SkillType.Fireball: [_srcX, iconSizeSkillType * 1],
  SkillType.Frostball: [_srcX, iconSizeSkillType * 2],
  SkillType.Teleport: [_srcX, iconSizeSkillType * 3],
  SkillType.Strike: [_srcX, iconSizeSkillType * 4],
  SkillType.Shoot_Arrow: [_srcX, iconSizeSkillType * 5],
  SkillType.Heal: [_srcX, iconSizeSkillType * 6],
};