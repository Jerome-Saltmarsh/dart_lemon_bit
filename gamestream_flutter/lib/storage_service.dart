
import 'package:gamestream_flutter/data/data_authentication.dart';
import 'package:gamestream_flutter/enums/region.dart';
import 'package:lemon_engine/Engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storage = StorageService();
final _keys = _Keys();

class StorageService {

  bool get serverSaved => Engine.sharedPreferences.containsKey(_keys.server);

  void saveRegion(Region value){
    SharedPreferences.getInstance().then((instance){
      instance.setInt('server', value.index);
    });
  }

  void rememberAuthorization(DataAuthentication authorization){
    print("storage.rememberAuthorization()");
    put(_keys.userId, authorization.userId);
    put(_keys.userEmail, authorization.email);
    put(_keys.userName, authorization.name);
  }

  void forgetAuthorization(){
    Engine.sharedPreferences.remove(_keys.userId);
    Engine.sharedPreferences.remove(_keys.userEmail);
    Engine.sharedPreferences.remove(_keys.userName);
  }

  DataAuthentication recallAuthorization() {
    final userId = get<String>(_keys.userId);
    final email = get<String>(_keys.userEmail);
    final displayName = get<String>(_keys.userName);
    return DataAuthentication(
      userId: userId,
      email: email,
      name: displayName,
    );
  }

  bool get authorizationRemembered => Engine.sharedPreferences.containsKey(_keys.userId);

  String get userId => get(_keys.userId);

  void remove(String key){
    Engine.sharedPreferences.remove(key);
  }

  void put(String key, dynamic value){
    if (key.isEmpty) throw Exception("key is empty");

    if (value == null){
      print('cannot store key $key because value is null');
      return;
    }

    if (value is String){
      Engine.sharedPreferences.setString(key, value);
      return;
    }

    if (value is int){
      Engine.sharedPreferences.setInt(key, value);
      return;
    }

    if (value is double){
      Engine.sharedPreferences.setDouble(key, value);
      return;
    }

    if (value is bool){
      Engine.sharedPreferences.setBool(key, value);
      return;
    }

    if (value is DateTime){
      Engine.sharedPreferences.setString(key, value.toIso8601String());
      return;
    }

    throw Exception('cannot store value');
  }

  bool contains(String key){
    return Engine.sharedPreferences.containsKey(key);
  }

  T get<T>(String key){
    if (!Engine.sharedPreferences.containsKey(key)){
      throw Exception('shared preference does not contain key $key');
    }
    if (T == int){
      return Engine.sharedPreferences.getInt(key) as T;
    }
    if (T == double){
      return Engine.sharedPreferences.getDouble(key) as T;
    }
    if (T == String){
      return Engine.sharedPreferences.getString(key) as T;
    }
    if (T == bool){
      return Engine.sharedPreferences.getBool(key) as T;
    }
    if (T.toString().startsWith('DateTime')){
      return DateTime.parse(Engine.sharedPreferences.getString(key)!) as T;
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