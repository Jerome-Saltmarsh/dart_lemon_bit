import 'package:amulet_engine/common/src.dart';

mixin Skilled {
  var skillTypeLeft = SkillType.Slash;
  var skillTypeRight = SkillType.Fireball;
  var skillActiveLeft = true;

  SkillType get skillActive => skillActiveLeft ? skillTypeLeft : skillTypeRight;

  void activeSkillActiveLeft() => setSkillActiveLeft(true);

  void activeSkillActiveRight() => setSkillActiveLeft(false);

  void setSkillActiveLeft(bool value) => skillActiveLeft = value;
}