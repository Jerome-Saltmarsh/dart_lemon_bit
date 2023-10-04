
import 'package:gamestream_ws/user_service/user_service.dart';
import 'package:typedef/json.dart';

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