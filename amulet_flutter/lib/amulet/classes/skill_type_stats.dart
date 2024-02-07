import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/amulet_item.dart';

class SkillTypeStats {
  final SkillType skillType;
  var unlocked = false;
  var magicCost = 0;
  var damageMin = 0;
  var damageMax = 0;
  var range = 0;
  var performDuration = 0;
  var amount = 0;
  SkillTypeStats({required this.skillType});
}