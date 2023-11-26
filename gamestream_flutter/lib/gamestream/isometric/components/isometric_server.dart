
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/lemon_websocket_client.dart';
import 'package:gamestream_flutter/types/server_mode.dart';

class IsometricServer with IsometricComponent {

  late final WebsocketClient websocket;

  ServerMode get serverMode => options.serverMode.value;

  bool get connected {
    switch (serverMode) {
      case ServerMode.remote:
        return websocket.connected;
      case ServerMode.local:
        return options.localServer.connected;
    }
  }

  @override
  Future onComponentInit(sharedPreferences) async {
    websocket = WebsocketClient(
      readString: parser.addString,
      readBytes: parser.add,
      onError: options.onWebsocketNetworkError,
      onDone: options.onWebsocketNetworkDone,
    );

    websocket.connectionStatus.onChanged(
        events.onChangedNetworkConnectionStatus
    );
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
    switch (options.serverMode.value){
      case ServerMode.local:
        options.localServer.send(data);
        break;
      case ServerMode.remote:
        websocket.send(data);
        break;
    }
  }

  void disconnect() {
    switch (serverMode){
      case ServerMode.local:
        options.localServer.disconnect();
        break;
      case ServerMode.remote:
        websocket.disconnect();
        break;
    }
  }
}

