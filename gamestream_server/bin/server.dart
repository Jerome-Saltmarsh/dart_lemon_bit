
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/users/classes/user_service_http.dart';

void main() => GamestreamServer(
  userService: UserServiceHttp(
    // url: 'http://localhost:8082',
    url: 'https://gamestream-users-osbmaezptq-uc.a.run.app',
  ),
);

