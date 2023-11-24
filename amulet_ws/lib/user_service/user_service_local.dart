
import 'package:gamestream_ws/packages/amulet_engine/packages/isometric_engine/packages/type_def/json.dart';
import 'package:gamestream_ws/user_service/user_service.dart';

class UserServiceLocal implements UserService {

  UserServiceLocal(){
    print('UserServiceLocal()');
  }

  @override
  Future<Json> getUser(String userId) {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future saveUserCharacter({required String userId, required Json character}) {
    // TODO: implement saveUserCharacter
    throw UnimplementedError();
  }

}