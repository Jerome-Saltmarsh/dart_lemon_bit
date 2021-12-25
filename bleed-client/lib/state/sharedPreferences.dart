
import 'package:bleed_client/constants/servers.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

final _Storage storage = _Storage();

class _Storage {

  final _Keys _keys = _Keys();

  bool get serverSaved => sharedPreferences.containsKey(_keys.server);
  int? get _serverIndex => sharedPreferences.getInt(_keys.server);
  ServerType get serverType => serverTypes[_serverIndex ?? ServerType.None.index];

  void saveServerType(ServerType value){
    print("storage.saveServerType($value)");
    sharedPreferences.setInt('server', value.index);
  }
}

class _Keys {
  final String server = 'server';
  final String audio = 'audio';
}