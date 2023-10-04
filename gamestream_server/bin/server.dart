
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/user_service/user_service_http.dart';

void main() => GamestreamServer(
    userService: UserServiceHttp(
        url: 'https://gamestream-http-osbmaezptq-uc.a.run.app',
    ),
);

