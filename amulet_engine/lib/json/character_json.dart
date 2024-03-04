import 'package:amulet_engine/common/src.dart';
import 'package:amulet_engine/json/map_json_to_amulet_item_object.dart';
import 'package:lemon_json/src.dart';

import 'amulet_field.dart';

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

  AmuletItemObject? get equippedWeapon =>
    mapJsonToAmuletItemObject(
        tryGetChild(AmuletField.Equipped_Weapon)
    );

  AmuletItemObject? get equippedHelm =>
    mapJsonToAmuletItemObject(
        tryGetChild(AmuletField.Equipped_Helm)
    );

  AmuletItemObject? get equippedArmor =>
    mapJsonToAmuletItemObject(
        tryGetChild(AmuletField.Equipped_Armor)
    );

  AmuletItemObject? get equippedShoes =>
    mapJsonToAmuletItemObject(
        tryGetChild(AmuletField.Equipped_Shoes)
    );

  String get uuid => getString(FIELD_UUID);

  String get name => getString(FIELD_NAME);

  SkillType get skillTypeLeft => SkillType.parse(getString(FIELD_SKILL_TYPE_LEFT));

  SkillType get skillTypeRight => SkillType.parse(getString(FIELD_SKILL_TYPE_RIGHT));

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
