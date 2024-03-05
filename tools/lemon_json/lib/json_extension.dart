import 'dart:typed_data';

import 'type_def_json.dart';

extension JsonExtension on Json {

  double? tryGetDouble(String key){
    final value = this[key];
    
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.parse(value);
    }
    if (value is bool) {
      return value ? 0.0 : 1.0;
    }
    return null;
  }

  Json? tryGetChild(String key){
    if (!containsKey(key)) {
      return null;
    }
    return getChild(key);
  }

  List<String>? tryGetListString(String key) => tryGetList<String>(key);

  List<T>? tryGetList<T>(String key) {
    if (!containsKey(key)){
      return null;
    }
    return (this[key] as List).cast<T>();
  }

  Json getChild(String key){
    if (!containsKey(key)) {
      throw Exception("json.getChild($key). No key");
    }
    final value = this[key];
    if (value is Json) return value;
    throw Exception("value $key is not a json object");
  }

  List<Json> getObjects(String key) => getList<Json>(key);

  Uint8List getUint8List(String key) => Uint8List.fromList(getListInt(key));

  Map<String, int> getMapStringInt(String key) =>
      getMap<String, int>(key);

  Map<T, J> getMap<T, J>(String key) =>
      getChild(key).cast<T, J>();

  List<int> getListInt(String key) => getList<int>(key);

  List<T> getList<T>(String key){
    if (!containsKey(key)) {
      throw Exception("json.getList($key). No key");
    }
    final value = this[key];
    if (value is! List){
      throw Exception('value is not list');
    }
    return value.cast<T>();
    // if (value is List<Json>) return value;
    // throw Exception("value $key is not a json object");
  }

  List<J> mapList<T, J>(String key, J Function(T t) mapper){
    return getList<T>(key).map<J>(mapper).toList();
  }

  double getDouble(String key) {
    if (!containsKey(key)) {
      throw Exception("json.getDouble($key). No key");
    }
    return tryGetDouble(key) ??
        (throw Exception("could not parse ${this[key]} to double"));
  }

  int getInt(String key){
    if (!containsKey(key)) {
      throw Exception("json.getInt($key). No key");
    }
    return 
        tryGetInt(key) ?? 
        (throw Exception("could not parse ${this[key]} to int"));
  }

  String? tryGetString(String key) =>
      containsKey(key) ? getString(key) : null;

  int? tryGetInt(String key) {
    final value = this[key];
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.parse(value);
    }
    if (value is bool){
      return value ? 1 : 0;
    }
    return null;
  }

  bool? tryGetBool(String key) =>
      containsKey(key) ? getBool(key) : null;

  String getString(String key){
    if (!containsKey(key)) {
      throw Exception("json.getString($key). No key");
    }
    final value = this[key];
    if (value is String){
      return value;
    }
    return value.toString();
  }

  bool getBool(String key){
    if (!containsKey(key)) {
      throw Exception("json.getBool($key). No key");
    }
    final value = this[key];
    if (value is bool){
      return value;
    }
    if (value is int){
      if (value == 0) return false;
      if (value == 1) return true;
      throw Exception("could not parse int $value to bool (1 or 0 only)");
    }
    if (value is double){
      if (value == 0) return false;
      if (value == 1.0) return true;
      throw Exception("could not parse double $value to bool (1 or 0 only)");
    }
    if (value is String){
      if (value.trim().toLowerCase() == 'true') return true;
      if (value.trim().toLowerCase() == 'false') return false;
      throw Exception("could not parse string $value to bool ('true' or 'false' only)");
    }

    throw Exception("could not parse value $value to bool");
  }

  Float32List getFloat32List(String key) =>
      tryGetFloat32List(key) ?? (throw Exception('$this.getFloat32List($key)'));

  Float32List? tryGetFloat32List(String name){
    final doubles = tryGetListDouble(name);
    if (doubles == null){
      return null;
    }
    return Float32List.fromList(doubles);
  }

  List<double>? tryGetListDouble(String key) =>
      tryGetListNum(key)?.map((e) => e.toDouble()).toList();

  List<num>? tryGetListNum(String key){
     final value = this[key];
     if (value == null){
       return null;
     }
     if (value is! List){
       return null;
     }
     try {
       return value.cast<num>();
     } catch (e){
       return null;
     }
  }
}
