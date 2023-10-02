import 'dart:convert';

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';
import 'package:gamestream_flutter/packages/common/src/game_type.dart';
import 'package:lemon_watch/src.dart';
import 'package:typedef/json.dart';
import 'package:user_service_client/src.dart';


class User with IsometricComponent {
  final userJson = Watch<Json>({});
  final userId = Watch('cef8dda2-5533-42be-bca3-1770314fdba3');
  final username = Watch('');
  final password = Watch('');
  final userServiceUrl = Watch('https://gamestream-http-osbmaezptq-uc.a.run.app');
  final error = Watch('');
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

  void refreshUser() async {
    if (userId.value.isNotEmpty){
      userJson.value = await UserServiceClient.getUser(
        url: userServiceUrl.value,
        userId: userId.value,
      );
    } else {
      userJson.value = {};
    }
  }

  void playCharacter(String characterId) {
    network.connectToGame(GameType.Amulet, '--userId ${userId.value} --characterId $characterId');
  }

  void register({required String username, required String password}) async {
    final userId = await UserServiceClient.createUser(
      url: userServiceUrl.value,
      username: username,
      password: password,
    );
    this.userId.value = userId;
  }

  void login({required String username, required String password}) async {
    final userId = await UserServiceClient.login(
      url: userServiceUrl.value,
      username: username,
      password: password,
    );
    this.userId.value = userId;
  }

  void logout() => userId.value = '';
}
