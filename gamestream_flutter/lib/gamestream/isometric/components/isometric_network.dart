
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/lemon_websocket_client.dart';

import 'classes/send_amulet_request.dart';

class IsometricNetwork with IsometricComponent {

  late final WebsocketClient websocket;
  late final SendAmuletRequest sendAmuletRequest;

  IsometricNetwork(){
    sendAmuletRequest = SendAmuletRequest(this);
  }

  @override
  Future onComponentInit(sharedPreferences) async {
    websocket = WebsocketClient(
      readString: parser.readServerResponseString,
      readBytes: parser.parseBytes,
      onError: onNetworkError,
      onDone: () {
        print('onDone()');
        player.position.x = 0;
        player.position.y = 0;
        player.position.z = 0;
        scene.totalCharacters = 0;
        scene.totalProjectiles = 0;
        scene.characters.clear();
        scene.gameObjects.clear();
        scene.projectiles.clear();
        particles.children.clear();
      }
    );
  }

  void onNetworkError(Object error, StackTrace stack) {
    if (error.toString().contains('NotAllowedError')){
      // https://developer.chrome.com/blog/autoplay/
      // This error appears when the game attempts to fullscreen
      // without the user having interacted first
      // TODO dispatch event on fullscreen failed
      // onErrorFullscreenAuto();
      return;
    }
    print(error.toString());
    print(stack);
    ui.error.value = error.toString();
  }

  void sendIsometricRequestRevive() =>
      sendIsometricRequest(NetworkRequestIsometric.Revive);

  void sendIsometricRequestWeatherSetRain(int value) =>
      sendIsometricRequest(NetworkRequestIsometric.Weather_Set_Rain, value);

  void sendIsometricRequestWeatherSetWind(int value) =>
      sendIsometricRequest(NetworkRequestIsometric.Weather_Set_Wind, value);

  void sendIsometricRequestWeatherSetLightning(int value) =>
      sendIsometricRequest(NetworkRequestIsometric.Weather_Set_Lightning, value);

  void sendIsometricRequestWeatherToggleBreeze() =>
      sendIsometricRequest(NetworkRequestIsometric.Weather_Toggle_Breeze);

  void sendIsometricRequestTimeSetHour(int value) =>
      sendIsometricRequest(NetworkRequestIsometric.Time_Set_Hour, value);

  void sendIsometricRequestEditorLoadGame(String name) =>
      sendIsometricRequest(NetworkRequestIsometric.Editor_Load_Game, name);

  void sendIsometricRequestSelectGameObject(GameObject gameObject) =>
      sendIsometricRequest(NetworkRequestIsometric.Select_GameObject, '${gameObject.id}');

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

  void sendIsometricRequest(NetworkRequestIsometric request, [dynamic message]) =>
      sendNetworkRequest(NetworkRequest.Isometric, '${request.index} $message');

  void sendRequest(int requestType, [dynamic a, dynamic b, dynamic c, dynamic d]) =>
    websocket.send('$requestType $a $b $c $d'.trim());


  void sendArgs2(int clientRequest, dynamic a, dynamic b) =>
      websocket.send('$clientRequest $a $b');


  // FUNCTIONS
  void connectToRegion(ConnectionRegion region, String message) {
    print('isometric.connectToRegion(${region.name})');
    if (region == ConnectionRegion.LocalHost) {
      const portLocalhost = '8080';
      final wsLocalHost = 'ws://localhost:${portLocalhost}';
      connectToServer(wsLocalHost, message);
      return;
    }
    if (region == ConnectionRegion.Custom) {
      print('connecting to custom server');
      return;
    }
    connectToServer(convertHttpToWSS(region.url), message);
  }

  void connectLocalHost({int port = 8080, required String message}) {
    connectToServer('ws://localhost:$port', message);
  }

  void connectToServer(String uri, String message) {
    websocket.connect(uri: uri, message: '${NetworkRequest.Join} $message');
  }

  void connectToGame(GameType gameType, [String message = '']) {
    final regionValue = options.region.value;
    if (regionValue == null) {
      throw Exception('region is null');
    }
    try {
      connectToRegion(regionValue, '--gameType ${gameType.index} $message');
    } catch(error) {
      print(error);
    }
  }

  @override
  void onComponentDispose() {
    print('isometricNetwork.onComponentDispose()');
    websocket.disconnect();
  }

  void sendNetworkRequestAmulet(NetworkRequestAmulet request, [dynamic message]) =>
      sendNetworkRequest(NetworkRequest.Amulet, '${request.index} $message');

  void sendNetworkRequest(int networkRequest, [dynamic arg1, dynamic arg2]) =>
      websocket.send('${networkRequest} ${arg1 ?? ""} ${arg2 ?? ""}'.trim());

}

