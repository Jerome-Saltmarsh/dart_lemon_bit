
import 'package:amulet_common/src.dart';
import 'package:amulet_client/interfaces/connection.dart';
import 'package:amulet_client/isometric/components/isometric_component.dart';
import 'package:amulet_client/isometric/enums/mode.dart';
import 'package:amulet_client/classes/gameobject.dart';

class IsometricServer with IsometricComponent {

  Connection? connection;

  bool get connected => connection?.connected ?? false;

  void sendIsometricRequestRevive() =>
      sendIsometricRequest(NetworkRequestIsometric.Revive);

  void sendIsometricRequestWeatherSetRain(int value) =>
      sendIsometricRequest(NetworkRequestIsometric.Weather_Set_Rain, value);

  void sendIsometricRequestWeatherSetWind(int value) =>
      sendIsometricRequest(NetworkRequestIsometric.Weather_Set_Wind, value);

  void sendIsometricRequestWeatherSetLightning(int value) =>
      sendIsometricRequest(
          NetworkRequestIsometric.Weather_Set_Lightning, value);

  void sendIsometricRequestWeatherToggleBreeze() =>
      sendIsometricRequest(NetworkRequestIsometric.Weather_Toggle_Breeze);

  void sendIsometricRequestTimeSetHour(int value) =>
      sendIsometricRequest(NetworkRequestIsometric.Time_Set_Hour, value);

  void sendIsometricRequestEditorLoadGame(String name) =>
      sendIsometricRequest(NetworkRequestIsometric.Editor_Load_Game, name);

  void sendIsometricRequestSelectGameObject(GameObject gameObject) =>
      sendIsometricRequest(
          NetworkRequestIsometric.Select_GameObject, '${gameObject.id}');

  void sendIsometricRequestDebugCharacterSetCharacterType(int characterType) =>
      sendIsometricRequest(
        NetworkRequestIsometric.Debug_Character_Set_Character_Type,
        characterType,
      );

  void sendIsometricRequestDebugCharacterSetWeaponType(int weaponType) =>
      sendIsometricRequest(
        NetworkRequestIsometric.Debug_Character_Set_Weapon_Type,
        weaponType,
      );

  void sendIsometricRequestDebugSelect() =>
      sendIsometricRequest(NetworkRequestIsometric.Debug_Select);

  void sendIsometricRequestDebugCommand() =>
      sendIsometricRequest(NetworkRequestIsometric.Debug_Command);

  void sendIsometricRequestDebugAttack() =>
      sendIsometricRequest(NetworkRequestIsometric.Debug_Attack);

  void sendIsometricRequestToggleDebugging() =>
      sendIsometricRequest(NetworkRequestIsometric.Toggle_Debugging);

  void sendIsometricRequest(NetworkRequestIsometric request,
      [dynamic message]) =>
      sendNetworkRequest(NetworkRequest.Isometric, '${request.index} $message');

  void sendRequest(int requestType,
      [dynamic a, dynamic b, dynamic c, dynamic d]) =>
      send('$requestType $a $b $c $d'.trim());

  void sendArgs2(int clientRequest, dynamic a, dynamic b) =>
      send('$clientRequest $a $b');

  @override
  void onComponentDispose() {
    print('isometricNetwork.onComponentDispose()');
    disconnect();
  }

  void sendNetworkRequestAmulet(NetworkRequestAmulet request,
      [dynamic message]) =>
      sendNetworkRequest(NetworkRequest.Amulet, '${request.index} $message');

  void sendNetworkRequest(int networkRequest,
      [dynamic arg1, dynamic arg2, dynamic arg3]) =>
      send(
          '${networkRequest} ${arg1 ?? ""} ${arg2 ?? ""} ${arg3 ?? ""}'.trim());

  void send(dynamic data) => connection?.send(data);

  Future disconnect() async => connection?.disconnect();

  void onServerConnectionEstablished() {
    options.mode.value = Mode.play;
    options.setModePlay();
    options.activateCameraPlay();
    engine.zoomOnScroll = true;
    engine.zoom = 1.0;
    engine.targetZoom = 1.6;
    audio.enabledSound.value = true;
    camera.target = options.cameraPlay;
  }

  void playCharacter(String characterUuid) =>
      connection?.playCharacter(characterUuid);

  Future deleteCharacter(String uuid) async =>
      connection?.deleteCharacter(uuid);

  // Connection get activeServer =>
  //     switch (serverMode) {
  //       ServerMode.local => local,
  //       ServerMode.remote => remote,
  //       _ => throw Exception('server mode is null')
  //     };
}

