
import 'package:amulet_engine/packages/isometric_engine/packages/common/src/network/network_request.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_parser.dart';
import 'package:amulet_flutter/packages/lemon_cache/cache.dart';
import 'package:amulet_flutter/server/server.dart';
import 'package:amulet_flutter/website/enums/website_page.dart';
import 'package:gamestream_http_client/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:typedef/json.dart';
import 'package:amulet_engine/packages/isometric_engine/packages/common/src/game_type.dart';
import 'package:amulet_flutter/gamestream/network/enums/connection_region.dart';
import 'package:amulet_flutter/packages/lemon_websocket_client.dart';

import '../gamestream/operation_status.dart';

class ServerRemote implements Server {

  late final WebsocketClient websocket;

  final operationStatus = Watch(OperationStatus.None);
  final region = Watch(ConnectionRegion.LocalHost);
  final userJson = Watch<Json>({});
  final userId = Cache(key: 'userId', value: '');
  final username = Watch('');
  final password = Watch('');
  final userServiceUrl = Watch('https://gamestream-http-osbmaezptq-uc.a.run.app');
  final characters = Watch<List<Json>>([]);

  final IsometricParser parser;

  @override
  bool get connected => websocket.connected;

  ServerRemote({required this.parser}){
    userId.onChanged(onChangedUserId);
    userJson.onChanged(onChangedUserJson);

    websocket = WebsocketClient(
      readString: parser.addString,
      readBytes: parser.add,
      onError: onWebsocketNetworkError,
      onDone: onWebsocketConnectionDone,
    );

    websocket.connectionStatus.onChanged(onChangedWebsocketConnectionStatus);
  }

  void onChangedUserId(String value) {
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
    setOperationStatus(OperationStatus.Loading_User);
    userJson.value = userId.value.isEmpty
        ? const {}
        : await GameStreamHttpClient.getUser(
      url: userServiceUrl.value,
      userId: userId.value,
    );
    setOperationStatusDone();
  }

  Future register({
    required String username,
    required String password,
  }) async {
    setOperationStatus(OperationStatus.Creating_Account);
    final response = await GameStreamHttpClient.createUser(
      url: userServiceUrl.value,
      username: username,
      password: password,
    );
    setOperationStatusDone();
    if (response.statusCode == 200){
      userId.value = response.body;
    } else {
      parser.ui.error.value = response.body;
    }
  }

  void login({
    required String username,
    required String password,
  }) async {
    setOperationStatus(OperationStatus.Authenticating);
    final response = await GameStreamHttpClient.login(
      url: userServiceUrl.value,
      username: username,
      password: password,
    );
    setOperationStatusDone();
    if (response.statusCode == 200){
      userId.value = response.body.replaceAll('\"', '');
    } else {
      parser.ui.error.value = response.body;
    }
  }

  void logout() => userId.value = '';

  Future deleteCharacter(String characterId) async {
    setOperationStatus(OperationStatus.Deleting_Character);
    try {
      final response = await GameStreamHttpClient.deleteCharacter(
        url: userServiceUrl.value,
        userId: userId.value,
        characterId: characterId,
      );

      if (response.statusCode != 200) {
        parser.ui.error.value = response.body;
      }

    } catch (error) {
      parser.ui.handleException(error);
    }
    await refreshUser();
    setOperationStatusDone();
  }

  @override
  void disconnect() => websocket.disconnect();

  void playCharacter(String characterUuid) {
    connectToGame(
        GameType.Amulet,
        '--userId ${userId.value} --characterId $characterUuid'
    );
  }

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
    connectToServer(convertUrlHttpToWSS(region.url), message);
  }

  void connectLocalHost({int port = 8080, required String message}) {
    connectToServer('ws://localhost:$port', message);
  }

  void connectToServer(String uri, String message) {
    websocket.connect(uri: uri, message: '${NetworkRequest.Join} $message');
  }

  void connectToGame(GameType gameType, [String message = '']) {
    try {
      connectToRegion(region.value, '--gameType ${gameType.index} $message');
    } catch (error) {
      print(error);
    }
  }

  void onChangedWebsocketConnectionStatus(ConnectionStatus connection) {
    print('isometricServer.onChangedWebsocketConnectionStatus($connection)');

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
    parser.ui.error.value = 'Connection Error';
    parser.options.game.value = parser.options.website;
  }

  void onWebsocketInvalidConnection() {
    parser.ui.error.value = 'Invalid Connection';
  }

  void onWebsocketFailedToConnect() {
    parser.ui.error.value = 'Failed to connect';
  }

  void onWebsocketConnected() {
    parser.server.onServerConnectionEstablished();
  }

  void onWebsocketConnectionDone() {
    parser.amulet.clearAllState();
  }

  Future createNewCharacter({
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
      parser.website.websitePage.value = WebsitePage.Select_Character;
      return;
    }

    setOperationStatus(OperationStatus.Creating_Character);
    parser.website.websitePage.value = WebsitePage.Select_Character;
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
      setOperationStatusDone();
      refreshUser();
      if (response.statusCode == 200) {
        playCharacter(response.body);
      } else {
        parser.ui.error.value = response.body;
      }
    } catch (error){
      setOperationStatusDone();
      parser.ui.handleException(error);
    }
  }

  void playCharacterCustom({
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }) {
    connectToGame(GameType.Amulet,
        '--name $name '
        '--complexion $complexion '
        '--hairType $hairType '
        '--hairColor $hairColor '
        '--gender $gender '
        '--headType $headType'
    );
  }

  @override
  void send(data) => websocket.send(data);

  void onWebsocketNetworkError(Object error, StackTrace stack) {
    if (error.toString().contains('NotAllowedError')){
      return;
    }
    print(error.toString());
    print(stack);
    parser.ui.error.value = error.toString();
  }

  void setOperationStatusDone(){
    setOperationStatus(OperationStatus.None);
  }

  void setOperationStatus(OperationStatus status){
    operationStatus.value = status;
  }

}