import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'library.dart';

class GameNetwork {
  static final updateBuffer = Uint8List(18);
  static late WebSocketChannel webSocketChannel;
  static final connectionStatus = Watch(ConnectionStatus.None, onChanged: onChangedConnectionStatus);
  static bool get connected => connectionStatus.value == ConnectionStatus.Connected;
  static bool get connecting => connectionStatus.value == ConnectionStatus.Connecting;
  static String connectionUri = "";
  static late WebSocketSink sink;
  static DateTime? connectionEstablished;

  static void connectToRegion(ConnectionRegion region, String message) {
    if (region == ConnectionRegion.LocalHost) {
      connectToServer(GameNetworkConfig.wsLocalHost, message);
      return;
    }
    if (region == ConnectionRegion.Custom) {
      print("connecting to custom server");
      print(website.state.customConnectionStrongController.text);
      connectToServer(
          website.state.customConnectionStrongController.text,
          message,
      );
      return;
    }
    final httpsConnectionString = getRegionConnectionString(region);
    final wsConnectionString = parseUrlHttpToWS(httpsConnectionString);
    connectToServer(wsConnectionString, message);
  }

  static void connectLocalHost({int port = 8080, required String message}) {
    connectToServer('ws://localhost:$port', message);
  }

  static void connectToServer(String uri, String message) {
    connect(uri: uri, message: '${ClientRequest.Join} $message');
  }

  static String parseUrlHttpToWS(String url, {String port = '8080'}) =>
      url.replaceAll("https", "wss") + "/:$port";

  static String getRegionConnectionString(ConnectionRegion region) {
    switch (region) {
      case ConnectionRegion.Australia:
        return GameNetworkConfig.Url_Sydney;
      case ConnectionRegion.Singapore:
        return GameNetworkConfig.Url_Singapore;
      default:
        throw Exception('GameNetwork.getRegionConnectionString($region)');
    }
  }

  static void connectToGameDarkAge() => connectToGame(GameType.Dark_Age);

  static void connectToGameEditor() => connectToGame(GameType.Editor);

  static void connectToGameWaves() => connectToGame(GameType.Waves);

  static void connectToGameSkirmish() => connectToGame(GameType.Skirmish);

  static void connectToGame(int gameType, [String message = ""]) =>
      connectToRegion(GameWebsite.region.value, '${gameType} $message');

  static Future sendClientRequestUpdate() async {
    applyUpdateBuffer(
      direction: GameIO.getDirection(),
      actionPrimary: GameIO.getActionPrimary(),
      actionSecondary: GameIO.getActionSecondary(),
      actionTertiary: GameIO.getActionTertiary(),
    );
    writeNumberToByteArray(number: GameIO.getMouseX(), list: updateBuffer, index: 5);
    writeNumberToByteArray(number: GameIO.getMouseY(), list: updateBuffer, index: 7);
    writeNumberToByteArray(number: Engine.screen.left, list: updateBuffer, index: 9);
    writeNumberToByteArray(number: Engine.screen.top, list: updateBuffer, index: 11);
    writeNumberToByteArray(number: Engine.screen.right, list: updateBuffer, index: 13);
    writeNumberToByteArray(number: Engine.screen.bottom, list: updateBuffer, index: 15);
    sink.add(updateBuffer);
    updateBuffer[17] = 0;
  }

  static applyUpdateBuffer({
    required int direction,
    required bool actionPrimary,
    required bool actionSecondary,
    required bool actionTertiary,
  }){
    updateBuffer[1] = direction;
    updateBuffer[2] = actionPrimary ? 1 : 0;
    updateBuffer[3] = actionSecondary ? 1 : 0;
    updateBuffer[4] = actionTertiary ? 1 : 0;
  }

  static void connect({required String uri, required dynamic message}) {
    print("webSocket.connect($uri)");
    connectionStatus.value = ConnectionStatus.Connecting;
    try {
      webSocketChannel = WebSocketChannel.connect(
          Uri.parse(uri), protocols: ['gamestream.online']);

      webSocketChannel.stream.listen(_onEvent, onError: _onError, onDone: _onDone);
      sink = webSocketChannel.sink;
      connectionEstablished = DateTime.now();
      sink.done.then((value){
        print("Connection Finished");
        print("webSocketChannel.closeCode: ${webSocketChannel.closeCode}");
        print("webSocketChannel.closeReason: ${webSocketChannel.closeReason}");
        if (connectionEstablished != null){
          final duration = DateTime.now().difference(connectionEstablished!);
          print("Connection Duration ${duration.inSeconds} seconds");
        }
      });
      connectionUri = uri;
      sink.add(message);
    } catch(e) {
      connectionStatus.value = ConnectionStatus.Failed_To_Connect;
    }
  }

  static void disconnect() {
    print('network.disconnect()');
    if (connected){
      sink.close();
    }
    connectionStatus.value = ConnectionStatus.None;
  }

  static void send(dynamic message) {
    if (!connected) {
      print("warning cannot send because not connected");
      return;
    }
    sink.add(message);
  }

  static void _onEvent(dynamic response) {
    if (connecting) {
      connectionStatus.value = ConnectionStatus.Connected;
    }

    if (response is Uint8List) {
      return serverResponseReader.readBytes(response);
    }
    if (response is String){
      if (response.startsWith("scene:")){
        final contents = response.substring(6, response.length);
        Engine.downloadString(contents: contents, filename: "hello.json");
      }
      GameWebsite.error.value = response;
      return;
    }
    throw Exception("cannot parse response: $response");
  }

  static void _onError(Object error, StackTrace stackTrace) {
    print("network.onError()");
    // core.actions.setError(error.toString());
  }

  static void _onDone() {
    print("network.onDone()");
    connectionUri = "";
    if (connecting) {
      connectionStatus.value = ConnectionStatus.Failed_To_Connect;
    } else {
      connectionStatus.value = ConnectionStatus.Done;
    }
    sink.close();
  }

  static void onChangedConnectionStatus(ConnectionStatus connection) {
    GameIO.removeListeners();
    Engine.onDrawForeground = null;
    switch (connection) {
      case ConnectionStatus.Connected:
        Engine.cursorType.value = CursorType.None;
        GameIO.addListeners();
        Engine.onDrawCanvas = GameState.renderCanvas;
        Engine.onDrawForeground = GameState.renderForeground;
        Engine.onUpdate = GameState.update;
        Engine.drawCanvasAfterUpdate = true;
        Engine.zoomOnScroll = true;
        if (!Engine.isLocalHost) {
          Engine.fullScreenEnter();
        }
        break;

      case ConnectionStatus.Done:
        Engine.onUpdate = null;
        Engine.drawCanvasAfterUpdate = true;
        Engine.cursorType.value = CursorType.Basic;
        Engine.drawCanvasAfterUpdate = true;
        Engine.onDrawCanvas = GameWebsite.renderCanvas;
        Engine.onUpdate = GameWebsite.update;
        Engine.fullScreenExit();
        GameState.clear();
        GameState.gameType.value = null;
        GameState.sceneEditable.value = false;
        break;
      case ConnectionStatus.Failed_To_Connect:
        GameWebsite.error.value = "Failed to connect";
        break;
      case ConnectionStatus.Invalid_Connection:
        GameWebsite.error.value = "Invalid Connection";
        break;
      case ConnectionStatus.Error:
        GameWebsite.error.value = "Connection Error";
        break;
      default:
        break;
    }
  }


  static void sendRequestSpeak(String message){
    if (message.trim().isEmpty) return;
    sendClientRequest(ClientRequest.Speak, message);
  }

  static void sendClientRequestTeleport(){
    sendClientRequest(ClientRequest.Teleport);
  }

  static void sendClientRequestTeleportScene(TeleportScenes scene){
    sendClientRequest(ClientRequest.Teleport_Scene, scene.index);
  }

  static void sendClientRequestSpawnNodeData(int z, int row, int column){
    sendClientRequest(ClientRequest.Spawn_Node_Data, '$z $row $column');
  }

  static void sendClientRequestStoreClose(){
    sendClientRequest(ClientRequest.Store_Close);
  }

  static void sendClientRequestSetWeapon(int type){
    sendClientRequest(ClientRequest.Set_Weapon, type);
  }

  static void sendClientRequestPurchaseWeapon(int type){
    sendClientRequest(ClientRequest.Purchase_Weapon, type);
  }

  static void sendClientRequestSetArmour(int type){
    sendClientRequest(ClientRequest.Set_Armour, type);
  }

  static void sendClientRequestSetHeadType(int type){
    sendClientRequest(ClientRequest.Set_Head_Type, type);
  }

  static void sendClientRequestSetPantsType(int type){
    sendClientRequest(ClientRequest.Set_Pants_Type, type);
  }

  static void sendClientRequestUpgradeWeaponDamage(){
    sendClientRequest(ClientRequest.Upgrade_Weapon_Damage);
  }

  static void sendClientRequestEquipWeapon(int index){
    assert (index >= 0);
    sendClientRequest(ClientRequest.Equip_Weapon, index);
  }

  static void sendClientRequestWeatherSetRain(Rain value){
    sendClientRequest(ClientRequest.Weather_Set_Rain, value.index);
  }

  static void sendClientRequestWeatherToggleBreeze(){
    sendClientRequest(ClientRequest.Weather_Toggle_Breeze);
  }

  static void sendClientRequestWeatherSetWind(Wind wind){
    sendClientRequest(ClientRequest.Weather_Set_Wind, wind.index);
  }

  static void sendClientRequestWeatherSetLightning(Lightning value){
    sendClientRequest(ClientRequest.Weather_Set_Lightning, value.index);
  }

  static void sendClientRequestWeatherToggleTimePassing([bool? value]){
    sendClientRequest(ClientRequest.Weather_Toggle_Time_Passing, value);
  }

  static void sendClientRequestEditorLoadGame(String name){
    sendClientRequest(ClientRequest.Editor_Load_Game, name);
  }

  static void sendClientRequestEditorSetSceneName(String name){
    sendClientRequest(ClientRequest.Editor_Set_Scene_Name, name);
  }

  static void sendClientRequestSubmitPlayerDesign(){
    sendClientRequest(ClientRequest.Submit_Player_Design);
  }

  static void sendClientRequestNpcSelectTopic(int index) =>
      sendClientRequest(ClientRequest.Npc_Talk_Select_Option, index);

  static void sendClientRequestTimeSetHour(int hour){
    assert(hour >= 0);
    assert(hour <= 24);
    sendClientRequest(ClientRequest.Time_Set_Hour, hour);
  }

  static void sendClientRequestRespawn(){
    sendClientRequest(ClientRequest.Revive);
  }

  static void sendClientRequestSetBlock({
    required int index,
    required int type,
    required int orientation,
  }) =>
      sendClientRequest(
        ClientRequest.Node,
        '$index $type $orientation',
      );

  static void sendClientRequestAddGameObject({
    required int index,
    required int type,
  }) {
    sendClientRequest(
      ClientRequest.GameObject,
      "${GameObjectRequest.Add.index} $index $type",
    );
  }

  static void sendClientRequestAddGameObjectXYZ({
    required double x,
    required double y,
    required double z,
    required int type,
  }) {
    sendClientRequest(
      ClientRequest.GameObject,
      "${GameObjectRequest.Add.index} $x $y $z $type",
    );
  }

  static void sendClientRequestGameObjectTranslate({
    required double tx,
    required double ty,
    required double tz,
  }) {
    sendClientRequest(
      ClientRequest.GameObject,
      "${GameObjectRequest.Translate.index} $tx $ty $tz",
    );
  }

  static void sendGameObjectRequestSelect() {
    sendGameObjectRequest(GameObjectRequest.Select);
  }

  static void sendGameObjectRequestDeselect() {
    sendGameObjectRequest(GameObjectRequest.Deselect);
  }

  static void sendGameObjectRequestDelete() {
    sendGameObjectRequest(GameObjectRequest.Delete);
  }

  static void sendClientRequestModifyCanvasSize(RequestModifyCanvasSize request) =>
      sendClientRequestEdit(EditRequest.Modify_Canvas_Size, request.index);

  static void sendClientRequestEdit(EditRequest request, [dynamic message = null]) =>
      sendClientRequest(ClientRequest.Edit, '${request.index} $message');

  static void sendClientRequestSpawnNodeDataModify({
    required int z,
    required int row,
    required int column,
    required int spawnType,
    required int spawnAmount,
    required int spawnRadius,
  }) =>
      sendClientRequest(
          ClientRequest.Spawn_Node_Data_Modify,
          '$z $row $column $spawnType $spawnAmount $spawnRadius'
      );

  static void sendGameObjectRequestMoveToMouse() {
    sendGameObjectRequest(GameObjectRequest.Move_To_Mouse);
  }

  static void sendGameObjectRequest(GameObjectRequest request, [dynamic message]) {
    if (message != null){
      sendClientRequest(ClientRequest.GameObject, '${request.index} $message');
    }
    sendClientRequest(ClientRequest.GameObject, request.index);
  }

  static void sendClientRequestTogglePaths() {
    sendClientRequest(ClientRequest.Toggle_Debug);
  }


  static void sendClientRequest(int value, [dynamic message]){
    if (message != null){
      return GameNetwork.send('${value} $message');
    }
    GameNetwork.send(value);
  }
}

