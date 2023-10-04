
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/user_service/user_service.dart';
import 'package:gamestream_server/user_service/user_service_firebase.dart';
import 'package:gamestream_server/user_service/user_service_http.dart';
import 'package:gamestream_server/user_service/user_service_local.dart';

void main(List<String> arguments) {
  GamestreamServer(
    userService: getUserService(arguments),
  );
}

UserService getUserService(List<String> arguments) {
  switch (arguments.getArg('--database')){
      case 'firestore':
          return UserServiceFirestore();
      case 'local':
          return UserServiceLocal();
      case 'http':
          final url = arguments.getArg('--url');
          return UserServiceHttp(
              url: url ?? 'https://gamestream-http-osbmaezptq-uc.a.run.app',
          );
      default:
        return UserServiceFirestore();
  }
}

