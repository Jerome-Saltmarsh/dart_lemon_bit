import 'modules/modules.dart';

class GameStream {
  static onError(Object error, StackTrace stack){
    print(error.toString());
    print(stack);
    core.state.error.value = error.toString();
  }
}