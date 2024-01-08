import '../packages/src.dart';
import 'package:amulet_ws/user_service/user_service.dart';


class UserServiceHttp implements UserService {

  final String url;

  UserServiceHttp({required this.url}) {
    print('UserServiceHttp("$url"');
  }

  @override
  Future<Json> getUser(String userId) =>
      GameStreamHttpClient.getUser(url: url, userId: userId);

  @override
  Future saveUserCharacter({
    required String userId,
    required Json character,
  }) => GameStreamHttpClient.patchCharacter(
      url: url,
      userId: userId,
      character: character,
    );

}