
import 'package:gamestream_ws/packages.dart';
import 'package:gamestream_ws/user_service/user_service.dart';
import 'package:typedef/json.dart';


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