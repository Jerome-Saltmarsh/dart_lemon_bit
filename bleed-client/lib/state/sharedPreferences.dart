
import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

final _Storage storage = _Storage();
final _Keys _keys = _Keys();

class _Storage {
  bool get serverSaved => sharedPreferences.containsKey(_keys.server);
  int? get _serverIndex => sharedPreferences.getInt(_keys.server);
  Region get serverType => serverTypes[_serverIndex ?? Region.None.index];

  void saveServerType(Region value){
    print("storage.saveServerType($value)");
    sharedPreferences.setInt('server', value.index);
  }

  void rememberAuthorization(Authorization authorization){
    print("storage.rememberAuthorization()");
    put(_keys.userId, authorization.userId);
    put(_keys.userEmail, authorization.email);
    put(_keys.userName, authorization.displayName);
  }

  void forgetAuthorization(){
    sharedPreferences.remove(_keys.userId);
    sharedPreferences.remove(_keys.userEmail);
    sharedPreferences.remove(_keys.userName);
  }

  Authorization recallAuthorization() {
    print("recallAuthorization()");
    final userId = get<String>(_keys.userId);
    final email = get<String>(_keys.userEmail);
    final displayName = get<String>(_keys.userName);
    return Authorization(
      userId: userId,
      email: email,
      displayName: displayName,
    );
  }

  bool get authorizationRemembered => sharedPreferences.containsKey(_keys.userId);

  String get userId => get(_keys.userId);

  void put(String key, dynamic value){
    print("storage.put({key: '$key', value: '$value'})");

    if (value == null){
      print('cannot store key $key because value is null');
      return;
    }

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
    throw Exception("cannot get value for key $key");
  }
}

class _Keys {
  final String server = 'server';
  final String audio = 'audio';
  final String userId = 'userId';
  final String userName = 'userName';
  final String userEmail = 'userEmail';
}