import 'package:amulet_engine/common/src.dart';
import 'package:lemon_json/src.dart';

typedef CharacterJson = Json;

extension CharacterJsonExtension on CharacterJson {

  static const FIELD_UUID = 'uuid';
  static const FIELD_NAME = 'name';
  static const FIELD_WEAPON = 'weapon';
  static const FIELD_HELM = 'helm';
  static const FIELD_ARMOR = 'body';
  static const FIELD_SHOES = 'shoes';
  static const FIELD_SKILL_TYPE_LEFT = 'skill_type_left';
  static const FIELD_SKILL_TYPE_RIGHT = 'skill_type_right';

  String get weapon => tryGetString(FIELD_WEAPON) ?? '-';

  String get helm => tryGetString(FIELD_HELM) ?? '-';

  String get armor => tryGetString(FIELD_ARMOR) ?? '-';

  String get shoes => tryGetString(FIELD_SHOES) ?? '-';

  String get uuid => getString(FIELD_UUID);

  String get name => getString(FIELD_NAME);

  SkillType get skillTypeLeft => SkillType.parse(getString(FIELD_SKILL_TYPE_LEFT));

  SkillType get skillTypeRight => SkillType.parse(getString(FIELD_SKILL_TYPE_RIGHT));

  set weapon(String value) => setString(FIELD_WEAPON, value);

  set helm(String value) => setString(FIELD_HELM, value);

  set armor(String value) => setString(FIELD_ARMOR, value);

  set shoes(String value) => setString(FIELD_SHOES, value);

  set uuid(String value) => setString(FIELD_UUID, value);

  set name(String value) => setString(FIELD_NAME, value);

  set skillTypeLeft(SkillType skillType) => setString(FIELD_SKILL_TYPE_LEFT, skillType.name);

  set skillTypeRight(SkillType skillType) => setString(FIELD_SKILL_TYPE_RIGHT, skillType.name);

  void setString(String key, String value){
    this[key] = value;
  }

  void setInt(String key, int value){
    this[key] = value;
  }
}
