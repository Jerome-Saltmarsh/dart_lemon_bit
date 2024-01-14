import '../packages/isometric_engine/packages/type_def/json.dart';

typedef CharacterJson = Json;

extension CharacterJsonExtension on CharacterJson {

  static const FIELD_ELEMENT_FIRE = 'elementFire';
  static const FIELD_ELEMENT_WATER = 'elementWater';
  static const FIELD_ELEMENT_ELECTRICITY = 'elementElectricity';
  static const FIELD_ELEMENT_POINTS = 'elementPoints';
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

  int get elementFire => getInt(FIELD_ELEMENT_FIRE);
  
  int get elementWater => getInt(FIELD_ELEMENT_WATER);
  
  int get elementElectricity => getInt(FIELD_ELEMENT_ELECTRICITY);

  int get elementPoints => getInt(FIELD_ELEMENT_POINTS);

  String get uuid => getString(FIELD_UUID);

  String get name => getString(FIELD_NAME);

  set weapon(String value) => setString(FIELD_WEAPON, value);

  set helm(String value) => setString(FIELD_HELM, value);

  set body(String value) => setString(FIELD_BODY, value);

  set shoes(String value) => setString(FIELD_SHOES, value);

  set elementPoints(int value) => setInt(FIELD_ELEMENT_POINTS, value);

  set elementFire(int value) => setInt(FIELD_ELEMENT_FIRE, value);

  set elementWater(int value) => setInt(FIELD_ELEMENT_WATER, value);

  set elementElectricity(int value) => setInt(FIELD_ELEMENT_ELECTRICITY, value);

  set uuid(String value) => setString(FIELD_UUID, value);

  set name(String value) => setString(FIELD_NAME, value);

  void setString(String key, String value){
    this[key] = value;
  }

  void setInt(String key, int value){
    this[key] = value;
  }
}
