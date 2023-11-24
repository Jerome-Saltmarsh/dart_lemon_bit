

import 'package:gamestream_ws/packages/amulet_engine/packages/isometric_engine/packages/type_def/json.dart';
import 'package:gamestream_ws/packages/gamestream_firestore/classes/gamestream_firestore.dart';
import 'package:gamestream_ws/user_service/user_service.dart';

class UserServiceFirestore implements UserService {

  final gamestreamFirestore = GamestreamFirestore();

  UserServiceFirestore(){
    print("UserServiceFirestore()");
  }

  @override
  Future<Json> getUser(String userId) =>
      gamestreamFirestore.getUser(userId);

  @override
  Future saveUserCharacter({
    required String userId,
    required Json character,
  }) =>
      gamestreamFirestore.saveCharacter(userId, character);
}