import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/packages/common/src/game_type.dart';
import 'package:gamestream_flutter/packages/lemon_cache.dart';
import 'package:lemon_watch/src.dart';
import 'package:typedef/json.dart';
import 'package:user_service_client/src.dart';


class User with IsometricComponent {
  final userJson = Watch<Json>({});
  final userId = Cache(key: 'userId', value: '');
  final username = Watch('');
  final password = Watch('');
  final userServiceUrl = Watch('https://gamestream-http-osbmaezptq-uc.a.run.app');
  final characters = Watch<List<Json>>([]);

  User(){
    userId.onChanged(onChangedUserId);
    userJson.onChanged(onChangedUserJson);
  }

  void onChangedUserId(String value){
    print('user.onChangedUserId($value)');
    refreshUser();
  }

  void onChangedUserJson(Json userJson) {
    if (userJson.containsKey('characters')){
      characters.value = userJson.getList<Json>('characters');;
    } else {
      characters.value = [];
    }

    username.value = userJson.tryGetString('username') ?? '';
  }

  void refreshUser() async =>
      userJson.value = userId.value.isEmpty
          ? const {}
          : await UserServiceClient.getUser(
              url: userServiceUrl.value,
              userId: userId.value,
            );

  void playCharacter(String characterId) {
    network.connectToGame(GameType.Amulet, '--userId ${userId.value} --characterId $characterId');
  }

  Future register({
    required String username,
    required String password,
  }) async {
    options.startOperation(OperationStatus.Creating_Account);
    final response = await UserServiceClient.createUser(
      url: userServiceUrl.value,
      username: username,
      password: password,
    );
    options.operationDone();
    if (response.statusCode == 200){
      userId.value = response.body;
    } else {
      ui.error.value = response.body;
    }
  }

  void login({required String username, required String password}) async {
    options.startOperation(OperationStatus.Authenticating);
    final response = await UserServiceClient.login(
      url: userServiceUrl.value,
      username: username,
      password: password,
    );
    options.operationDone();
    if (response.statusCode == 200){
      userId.value = response.body.replaceAll('\"', '');
    } else {
      ui.error.value = response.body;
    }
  }

  void logout() => userId.value = '';
}
