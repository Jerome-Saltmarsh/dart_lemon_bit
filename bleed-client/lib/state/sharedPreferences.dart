
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

final _Storage storage = _Storage();

class _Storage {

  final _Keys _keys = _Keys();

  bool get serverSaved => sharedPreferences.containsKey(_keys.server);
  int? get _serverIndex => sharedPreferences.getInt(_keys.server);
  Region get serverType => serverTypes[_serverIndex ?? Region.None.index];

  void saveServerType(Region value){
    print("storage.saveServerType($value)");
    sharedPreferences.setInt('server', value.index);
  }

  void put(String key, dynamic value){
    print("storage.put({key: $key, value: $value})");
    if (value is String){
      sharedPreferences.setString(key, value);
      return;
    }

    if (value is int){
      sharedPreferences.setInt(key, value);
      return;
    }

    if (value is double){
      sharedPreferences.setDouble(key, value);
      return;
    }

    if (value is bool){
      sharedPreferences.setBool(key, value);
      return;
    }

    throw Exception('cannot store value');
  }

  T get<T>(String key){
    if (T == int){
      return sharedPreferences.getInt(key) as T;
    }
    if (T == double){
      return sharedPreferences.getDouble(key) as T;
    }
    if (T == String){
      return sharedPreferences.getString(key) as T;
    }
    if (T == bool){
      return sharedPreferences.getBool(key) as T;
    }
    throw Exception("cannot get value");


  }
}

class _Keys {
  final String server = 'server';
  final String audio = 'audio';
}