
import 'package:gamestream_flutter/common/src/client_request.dart';
import 'package:gamestream_flutter/common/src/game_type.dart';
import 'package:gamestream_flutter/common/src/isometric/isometric_request.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/lemon_websocket_client/convert_http_to_wss.dart';
import 'package:gamestream_flutter/lemon_websocket_client/websocket_client.dart';

class IsometricNetwork with IsometricComponent {

  late final WebsocketClient websocket;

  @override
  Future onComponentInit(sharedPreferences) async {
    websocket = WebsocketClient(
      readString: responseReader.readServerResponseString,
      readBytes: responseReader.readNetworkBytes,
      onError: onNetworkError,
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
    website.error.value = error.toString();
  }

  void sendIsometricRequestRevive() =>
      sendIsometricRequest(IsometricRequest.Revive);

  void sendIsometricRequestWeatherSetRain(int value) =>
      sendIsometricRequest(IsometricRequest.Weather_Set_Rain, value);

  void sendIsometricRequestWeatherSetWind(int value) =>
      sendIsometricRequest(IsometricRequest.Weather_Set_Wind, value);

  void sendIsometricRequestWeatherSetLightning(int value) =>
      sendIsometricRequest(IsometricRequest.Weather_Set_Lightning, value);

  void sendIsometricRequestWeatherToggleBreeze() =>
      sendIsometricRequest(IsometricRequest.Weather_Toggle_Breeze);

  void sendIsometricRequestTimeSetHour(int value) =>
      sendIsometricRequest(IsometricRequest.Time_Set_Hour, value);

  void sendIsometricRequestEditorLoadGame(String name) =>
      sendIsometricRequest(IsometricRequest.Editor_Load_Game, name);

  void sendIsometricRequestMoveSelectedColliderToMouse() =>
      sendIsometricRequest(IsometricRequest.Move_Selected_Collider_To_Mouse);

  void sendIsometricRequestDebugCharacterWalkToMouse() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Walk_To_Mouse);

  void sendIsometricRequestDebugCharacterToggleAutoAttackNearbyEnemies() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Toggle_Auto_Attack_Nearby_Enemies);

  void sendIsometricRequestDebugCharacterTogglePathFindingEnabled() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Toggle_Path_Finding_Enabled);

  void sendIsometricRequestDebugCharacterToggleRunToDestination() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Toggle_Run_To_Destination);

  void sendIsometricRequestDebugCharacterDebugUpdate() =>
      sendIsometricRequest(IsometricRequest.Debug_Character_Debug_Update);

  void sendIsometricRequestSelectGameObject(GameObject gameObject) =>
      sendIsometricRequest(IsometricRequest.Select_GameObject, '${gameObject.id}');

  void sendIsometricRequestDebugCharacterSetCharacterType(int characterType) =>
      sendIsometricRequest(
        IsometricRequest.Debug_Character_Set_Character_Type,
        characterType,
      );

  void sendIsometricRequestDebugCharacterSetWeaponType(int weaponType) =>
      sendIsometricRequest(
        IsometricRequest.Debug_Character_Set_Weapon_Type,
        weaponType,
      );

  void sendIsometricRequestDebugSelect() =>
      sendIsometricRequest(IsometricRequest.Debug_Select);

  void sendIsometricRequestDebugCommand() =>
      sendIsometricRequest(IsometricRequest.Debug_Command);

  void sendIsometricRequestDebugAttack() =>
      sendIsometricRequest(IsometricRequest.Debug_Attack);

  void sendIsometricRequestToggleDebugging() =>
      sendIsometricRequest(IsometricRequest.Toggle_Debugging);

  void sendIsometricRequest(IsometricRequest request, [dynamic message]) =>
      send(ClientRequest.Isometric, '${request.index} $message');

  void send(int clientRequest, [dynamic message]) =>
      message != null
          ? websocket.send('${clientRequest} $message')
          : websocket.send(clientRequest);


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
    websocket.connect(uri: uri, message: '${ClientRequest.Join} $message');
  }

  void connectToGame(GameType gameType, [String message = '']) {
    final regionValue = options.region.value;
    if (regionValue == null) {
      throw Exception('region is null');
    }
    try {
      connectToRegion(regionValue, '${gameType.index} $message');
    } catch(error) {
      print(error);
    }
  }

  @override
  void onComponentDispose() {
    print('isometricNetwork.onComponentDispose()');
  }
}