
import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:amulet_flutter/gamestream/isometric/enums/mode.dart';
import 'package:amulet_flutter/gamestream/network/enums/connection_region.dart';
import 'package:amulet_flutter/isometric/classes/gameobject.dart';
import 'package:amulet_flutter/packages/common.dart';
import 'package:amulet_flutter/packages/lemon_websocket_client.dart';
import 'package:amulet_flutter/types/server_mode.dart';
import 'package:amulet_flutter/user_service/src.dart';

class IsometricServer with IsometricComponent {

  late final WebsocketClient websocket;
  late final UserServiceLocal userServiceLocal;

  ServerMode? get serverMode => options.serverMode.value;

  bool get connected {
    switch (serverMode) {
      case ServerMode.remote:
        return websocket.connected;
      case ServerMode.local:
        return userServiceLocal.connected;
      default:
        return false;
    }
  }

  @override
  Future onComponentInit(sharedPreferences) async {

    userServiceLocal = UserServiceLocal(
        parser: parser,
        playerClient: player,
    );

    websocket = WebsocketClient(
      readString: parser.addString,
      readBytes: parser.add,
      onError: options.onWebsocketNetworkError,
      onDone: onWebsocketConnectionDone,
    );

    websocket.connectionStatus.onChanged(onChangedWebsocketConnectionStatus);
    userServiceLocal.initialize(sharedPreferences);
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
      send('$requestType $a $b $c $d'.trim());

  void sendArgs2(int clientRequest, dynamic a, dynamic b) =>
      send('$clientRequest $a $b');

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
    disconnect();
  }

  void sendNetworkRequestAmulet(NetworkRequestAmulet request, [dynamic message]) =>
      sendNetworkRequest(NetworkRequest.Amulet, '${request.index} $message');

  void sendNetworkRequest(int networkRequest, [dynamic arg1, dynamic arg2, dynamic arg3]) =>
      send('${networkRequest} ${arg1 ?? ""} ${arg2 ?? ""} ${arg3 ?? ""}'.trim());

  void send(dynamic data) {
    switch (serverMode){
      case ServerMode.local:
        userServiceLocal.send(data);
        break;
      case ServerMode.remote:
        websocket.send(data);
        break;
      default:
        throw Exception('isometricServer.send() - serverMode is null');
    }
  }

  void disconnect() {
    options.game.value = options.website;
    switch (serverMode) {
      case ServerMode.local:
        parser.amulet.clearAllState();
        userServiceLocal.disconnect();
        break;
      case ServerMode.remote:
        websocket.disconnect();
        break;
      default:
        print('no server connected');
        return;
    }
  }

  void onChangedWebsocketConnectionStatus(ConnectionStatus connection) {
    print('isometricServer.onChangedWebsocketConnectionStatus($connection)');
    // server.parser.bufferSize.value = 0;

    switch (connection) {
      case ConnectionStatus.Connected:
        onWebsocketConnected();
        break;
      case ConnectionStatus.Done:
        onWebsocketConnectionDone();
        break;
      case ConnectionStatus.Failed_To_Connect:
        onWebsocketFailedToConnect();
        break;
      case ConnectionStatus.Invalid_Connection:
        onWebsocketInvalidConnection();
        break;
      case ConnectionStatus.Error:
        onWebsocketConnectionError();
        break;
      default:
        break;
    }
  }

  void onWebsocketConnectionError() {
    ui.error.value = 'Connection Error';
    options.game.value = options.website;
  }

  void onWebsocketInvalidConnection() {
    ui.error.value = 'Invalid Connection';
  }

  void onWebsocketFailedToConnect() {
    ui.error.value = 'Failed to connect';
  }

  void onWebsocketConnected() {
    onServerConnectionEstablished();
  }

  void onServerConnectionEstablished() {
    options.mode.value = Mode.Play;
    options.game.value = options.amulet;
    options.setModePlay();
    options.activateCameraPlay();
    engine.zoomOnScroll = true;
    engine.zoom = 1.0;
    engine.targetZoom = 1.0;
    audio.enabledSound.value = true;
    camera.target = options.cameraPlay;
    if (!engine.isLocalHost) {
      engine.fullScreenEnter();
    }
  }

  void onWebsocketConnectionDone() {
     amulet.clearAllState();
  }

  UserService? get userService => switch (serverMode){
    ServerMode.remote => userServiceHttp,
    ServerMode.local => userServiceLocal,
    _ => null
  };

  void createCharacter({
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }){
    userService?.createNewCharacter(
        name: name,
        complexion: complexion,
        hairType: hairType,
        hairColor: hairColor,
        gender: gender,
        headType: headType,
    );
  }

  void playCharacter(CharacterJson character) {
    switch (serverMode){
      case ServerMode.local:
        userServiceLocal.playCharacter(character.uuid);
        break;
      case ServerMode.remote:
        userServiceHttp.playCharacter(character.uuid);
        break;
      default:
        throw Exception('no server mode selected');
    }
  }

}

