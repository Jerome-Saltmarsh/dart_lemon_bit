import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';
import 'package:gamestream_flutter/packages/common/src/game_type.dart';
import 'package:lemon_watch/src.dart';
import 'package:typedef/json.dart';
import 'package:user_service_client/src.dart';


class User with IsometricComponent {
  final id = Watch('cef8dda2-5533-42be-bca3-1770314fdba3');
  final username = Watch('');
  final password = Watch('');
  final userServiceUrl = Watch('https://gamestream-http-osbmaezptq-uc.a.run.app');
  final connected = Watch(false);
  final error = Watch('');
  final characters = Watch<List<Json>>([]);

  User(){
    testConnection().then((value) {
      if (value){
        refreshCharacterNames();
      }
    });
  }

  Future<bool> testConnection() {
    return UserServiceClient.ping(url: userServiceUrl.value).then((value) {
      connected.value = value;
      return value;
    });
  }

  void refreshCharacterNames() async =>
      characters.value = await UserServiceClient.getUserCharacters(
        url: userServiceUrl.value,
        userId: id.value,
      );

  void playCharacter(String characterId) {
    network.connectToGame(GameType.Amulet, '--userId ${id.value} --characterId $characterId');
  }
}
