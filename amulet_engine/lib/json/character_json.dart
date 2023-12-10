import '../packages/isometric_engine/packages/type_def/json.dart';

typedef CharacterJson = Json;

extension CharacterJsonExtension on CharacterJson {

  String get uuid => getString('uuid');

  String get name => getString('name');

  set uuid(String value){
    setString('uuid', value);
  }

  set name(String value){
    setString('name', value);
  }

  void setString(String key, String value){
    this[key] = value;
  }
}
