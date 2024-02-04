
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
  SkillType.Mighty_Swing: [_srcX, iconSizeSkillType * 7],
  SkillType.Explode: [_srcX, iconSizeSkillType * 8],
  SkillType.Split_Shot: [_srcX, iconSizeSkillType * 9],
  SkillType.Entangle: [_srcX, iconSizeSkillType * 10],
  SkillType.Freeze_Target: [_srcX, iconSizeSkillType * 11],
  SkillType.Freeze_Area: [_srcX, iconSizeSkillType * 12],
};