

import 'package:typedef/json.dart';

abstract class UserService {

  Future<List<Json>> getCharacters();
}