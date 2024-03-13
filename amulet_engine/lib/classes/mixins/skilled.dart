
import 'package:amulet_common/src.dart';

mixin Skilled {
  var skillTypeLeft = SkillType.Slash;
  var skillTypeRight = SkillType.Fireball;
  var skillActiveLeft = true;

  SkillType get activeSkillType => skillActiveLeft ? skillTypeLeft : skillTypeRight;

  void activeSkillActiveLeft() => setSkillActiveLeft(true);

  void activeSkillActiveRight() => setSkillActiveLeft(false);

  void setSkillActiveLeft(bool value) => skillActiveLeft = value;
}