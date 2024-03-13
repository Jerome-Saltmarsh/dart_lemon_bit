

import 'package:amulet_common/src.dart';

class SkillTypeStats {
  final SkillType skillType;
  var unlocked = false;
  var magicCost = 0;
  var damageMin = 0;
  var damageMax = 0;
  var range = 0;
  // var performDuration = 0;
  var amount = 0;
  SkillTypeStats({required this.skillType});
}