
import 'package:gamestream_flutter/control/classes/authentication.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:lemon_engine/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storage = _Storage();
final _keys = _Keys();

class _Storage {

  bool get serverSaved => engine.sharedPreferences.containsKey(_keys.server);
  int? get _serverIndex => engine.sharedPreferences.getInt(_keys.server);
  Region get serverType => regions[_serverIndex ?? Region.Australia.index];

  void saveServerType(Region value){
    print("storage.saveServerType($value)");
    engine.sharedPreferences.setInt('server', value.index);
  }

  void rememberAuthorization(Authentication authorization){
    print("storage.rememberAuthorization()");
    put(_keys.userId, authorization.userId);
    put(_keys.userEmail, authorization.email);
    put(_keys.userName, authorization.name);
  }

  void forgetAuthorization(){
    engine.sharedPreferences.remove(_keys.userId);
    engine.sharedPreferences.remove(_keys.userEmail);
    engine.sharedPreferences.remove(_keys.userName);
  }

  Authentication recallAuthorization() {
    final userId = get<String>(_keys.userId);
    final email = get<String>(_keys.userEmail);
    final displayName = get<String>(_keys.userName);
    return Authentication(
      userId: userId,
      email: email,
      name: displayName,
    );
  }

  bool get authorizationRemembered => engine.sharedPreferences.containsKey(_keys.userId);

  String get userId => get(_keys.userId);

  void remove(String key){
    engine.sharedPreferences.remove(key);
  }

  void put(String key, dynamic value){
    if (key.isEmpty) throw Exception("key is empty");

    if (value == null){
      print('cannot store key $key because value is null');
      return;
    }

    if (value is String){
      engine.sharedPreferences.setString(key, value);
      return;
    }

    if (value is int){
      engine.sharedPreferences.setInt(key, value);
      return;
    }

    if (value is double){
      engine.sharedPreferences.setDouble(key, value);
      return;
    }

    if (value is bool){
      engine.sharedPreferences.setBool(key, value);
      return;
    }

    if (value is DateTime){
      engine.sharedPreferences.setString(key, value.toIso8601String());
      return;
    }

    throw Exception('cannot store value');
  }

  bool contains(String key){
    return engine.sharedPreferences.containsKey(key);
  }

  T get<T>(String key){
    if (!engine.sharedPreferences.containsKey(key)){
      throw Exception('shared preference does not contain key $key');
    }
    if (T == int){
      return engine.sharedPreferences.getInt(key) as T;
    }
    if (T == double){
      return engine.sharedPreferences.getDouble(key) as T;
    }
    if (T == String){
      return engine.sharedPreferences.getString(key) as T;
    }
    if (T == bool){
      return engine.sharedPreferences.getBool(key) as T;
    }
    if (T.toString().startsWith('DateTime')){
      return DateTime.parse(engine.sharedPreferences.getString(key)!) as T;
    }
    throw Exception("cannot get value for key $key");
  }
}

extension SharedPreferencesExtensions on SharedPreferences {

  void putAny(String key, dynamic value){
    print("storage.put({key: '$key', value: '$value'})");

    if (key.isEmpty) throw Exception("key is empty");

    if (value == null){
      print('cannot store key $key because value is null');
      return;
    }

    if (value is String){
      setString(key, value);
      return;
    }

    if (value is int){
      setInt(key, value);
      return;
    }

    if (value is double){
      setDouble(key, value);
      return;
    }

    if (value is bool){
      setBool(key, value);
      return;
    }

    if (value is DateTime){
      setString(key, value.toIso8601String());
      return;
    }

    if (value is Enum) {
      setInt(key, value.index);
      return;
    }

    throw Exception('cannot store value');
  }

  T getAny<T>(String key){
    if (!containsKey(key)){
      throw Exception('shared preference does not contain key $key');
    }
    if (T == int){
      return getInt(key) as T;
    }
    if (T == double){
      return getDouble(key) as T;
    }
    if (T == String){
      return getString(key) as T;
    }
    if (T == bool){
      return getBool(key) as T;
    }
    if (T.toString().startsWith('DateTime')){
      return DateTime.parse(getString(key)!) as T;
    }
     throw Exception("cannot get value for key $key, type: ${T.toString()}");
  }
}

class _Keys {
  final String server = 'server';
  final String audio = 'audio';
  final String userId = 'userId';
  final String userName = 'userName';
  final String userEmail = 'userEmail';
}