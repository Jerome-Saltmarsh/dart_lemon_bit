import '../packages/isometric_engine/packages/type_def/json.dart';

typedef CharacterJson = Json;

extension CharacterJsonExtension on CharacterJson {

  static const FIELD_UUID = 'uuid';
  static const FIELD_NAME = 'name';
  static const FIELD_WEAPON = 'weapon';
  static const FIELD_HELM = 'helm';
  static const FIELD_BODY = 'body';
  static const FIELD_SHOES = 'shoes';

  String get weapon => tryGetString(FIELD_WEAPON) ?? '-';

  String get helm => tryGetString(FIELD_HELM) ?? '-';

  String get body => tryGetString(FIELD_BODY) ?? '-';

  String get shoes => tryGetString(FIELD_SHOES) ?? '-';

  String get uuid => getString(FIELD_UUID);

  String get name => getString(FIELD_NAME);

  set weapon(String value) => setString(FIELD_WEAPON, value);

  set helm(String value) => setString(FIELD_HELM, value);

  set body(String value) => setString(FIELD_BODY, value);

  set shoes(String value) => setString(FIELD_SHOES, value);

  set uuid(String value) => setString(FIELD_UUID, value);

  set name(String value) => setString(FIELD_NAME, value);

  void setString(String key, String value){
    this[key] = value;
  }

  void setInt(String key, int value){
    this[key] = value;
  }
}
