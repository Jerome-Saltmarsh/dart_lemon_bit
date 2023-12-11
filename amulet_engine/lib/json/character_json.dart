import '../packages/isometric_engine/packages/type_def/json.dart';

typedef CharacterJson = Json;

extension CharacterJsonExtension on CharacterJson {

  int get elementFire => getInt('elementFire');
  
  int get elementWater => getInt('elementWater');
  
  int get elementElectricity => getInt('elementElectricity');

  int get elementPoints => getInt('elementPoints');

  String get uuid => getString('uuid');

  String get name => getString('name');
  
  set elementPoints(int value){
    setInt('elementPoints', value);
  }

  set elementFire(int value){
    setInt('elementFire', value);
  }

  set elementWater(int value){
    setInt('elementWater', value);
  }

  set elementElectricity(int value){
    setInt('elementElectricity', value);
  }

  set uuid(String value){
    setString('uuid', value);
  }

  set name(String value){
    setString('name', value);
  }

  void setString(String key, String value){
    this[key] = value;
  }

  void setInt(String key, int value){
    this[key] = value;
  }
}
