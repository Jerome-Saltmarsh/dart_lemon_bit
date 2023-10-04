
import 'package:gamestream_server/packages/user_service_http_client/src/user_service_client.dart';
import 'package:gamestream_server/user_service/user_service.dart';
import 'package:typedef/json.dart';

class UserServiceHttp implements UserService {

  final String url;

  UserServiceHttp({required this.url}) {
    print('UserServiceHttp("$url"');
  }

  @override
  Future<Json> getUser(String userId) =>
      UserServiceHttpClient.getUser(url: url, userId: userId);

  @override
  Future saveUserCharacter({
    required String userId,
    required Json character,
  }) => UserServiceHttpClient.patchCharacter(
      url: url,
      userId: userId,
      character: character,
    );

}