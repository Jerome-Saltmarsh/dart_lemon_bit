
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/users/user_service_http.dart';

void main() => GamestreamServer(
  userService: UserServiceHttp(
    scheme: 'http',
    host: 'localhost',
    port: 8082,
  ),
);

