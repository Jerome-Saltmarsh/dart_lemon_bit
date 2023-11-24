
import 'package:gamestream_ws/gamestream.dart';
import 'package:gamestream_ws/packages/utils/args.dart';
import 'package:gamestream_ws/user_service/user_service.dart';
import 'package:gamestream_ws/user_service/user_service_firebase.dart';
import 'package:gamestream_ws/user_service/user_service_http.dart';
import 'package:gamestream_ws/user_service/user_service_local.dart';

void main(List<String> arguments) {
  Root(
    userService: getUserService(arguments),
    admin: arguments.contains('--admin'),
    port: arguments.tryGetArgInt('--port') ?? 8080
  );
}

UserService getUserService(List<String> arguments) {
  switch (arguments.tryGetArgString('--database')){
      case 'firestore':
          return UserServiceFirestore();
      case 'local':
          return UserServiceLocal();
      case 'http':
          final url = arguments.tryGetArgString('--url');
          return UserServiceHttp(
              url: url ?? 'https://gamestream-http-osbmaezptq-uc.a.run.app',
          );
      default:
        return UserServiceFirestore();
  }
}

