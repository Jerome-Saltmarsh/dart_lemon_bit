import 'package:amulet_common/src.dart';
import 'package:amulet_server/json/map_json_to_amulet_item_object.dart';
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

  set uuid(String value) => setString(FIELD_UUID, value);

  set name(String value) => setString(FIELD_NAME, value);

  void setString(String key, String value){
    this[key] = value;
  }

  void setInt(String key, int value){
    this[key] = value;
  }
}
