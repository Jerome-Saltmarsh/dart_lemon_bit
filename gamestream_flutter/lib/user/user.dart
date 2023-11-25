import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/packages/common/src/game_type.dart';
import 'package:gamestream_flutter/packages/lemon_cache.dart';
import 'package:gamestream_flutter/website/enums/website_page.dart';
import 'package:gamestream_http_client/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:typedef/json.dart';


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

  void onChangedUserId(String value) {
    // print('user.onChangedUserId($value)');
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

  Future refreshUser() async {
    options.startOperation(OperationStatus.Loading_User);
    userJson.value = userId.value.isEmpty
          ? const {}
          : await GameStreamHttpClient.getUser(
              url: userServiceUrl.value,
              userId: userId.value,
            );
    options.operationDone();
  }

  void playCharacter(String characterId) {
    server.connectToGame(GameType.Amulet, '--userId ${userId.value} --characterId $characterId');
  }

  void playCharacterCustom({
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }) {
    server.connectToGame(GameType.Amulet,
        '--name $name '
        '--complexion $complexion '
        '--hairType $hairType '
        '--hairColor $hairColor '
        '--gender $gender '
        '--headType $headType'
    );
  }

  Future register({
    required String username,
    required String password,
  }) async {
    options.startOperation(OperationStatus.Creating_Account);
    final response = await GameStreamHttpClient.createUser(
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
    final response = await GameStreamHttpClient.login(
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

  void deleteCharacter(String characterId) async {
    options.startOperation(OperationStatus.Deleting_Character);
    try {
      final response = await GameStreamHttpClient.deleteCharacter(
        url: user.userServiceUrl.value,
        userId: user.userId.value,
        characterId: characterId,
      );

      if (response.statusCode != 200) {
        ui.error.value = response.body;
      }

    } catch (error) {
      ui.handleException(error);
    }
    await refreshUser();
    options.operationDone();
  }

  void createNewCharacter({
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
}) async {

    if (userId.value.isEmpty){
      playCharacterCustom(
        name: name,
        complexion: complexion,
        hairType: hairType,
        hairColor: hairColor,
        gender: gender,
        headType: headType,
      );
      website.websitePage.value = WebsitePage.User;
      return;
    }


    options.startOperation(OperationStatus.Creating_Character);
    website.websitePage.value = WebsitePage.User;
    try {
      final response = await GameStreamHttpClient.createCharacter(
        url: userServiceUrl.value,
        userId: userId.value,
        password: password.value,
        name: name,
        complexion: complexion,
        hairType: hairType,
        hairColor: hairColor,
        gender: gender,
        headType: headType,
      );
      options.operationDone();
      user.refreshUser();
      if (response.statusCode == 200) {
        playCharacter(response.body);
      } else {
        ui.error.value = response.body;
      }
    } catch (error){
      options.operationDone();
      ui.handleException(error);
    }
  }
}
