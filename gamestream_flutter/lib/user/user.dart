import 'package:lemon_watch/src.dart';
import 'package:typedef/json.dart';

import 'get_user_characters.dart';

class User {
  var scheme = 'http';
  var host = 'localhost';
  var port = 8082;

  final characters = Watch<List<Json>>([]);

  User(){
    refreshCharacterNames();
  }

  void refreshCharacterNames() async =>
      characters.value = await getUserCharacters(
        scheme: scheme,
        host: host,
        port: port,
      );


}