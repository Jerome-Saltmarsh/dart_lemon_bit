import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'library.dart';

class GameNetwork {
  static late WebSocketChannel webSocketChannel;
  static late WebSocketSink sink;
  static final updateBuffer = Uint8List(18);
  static final connectionStatus = Watch(ConnectionStatus.None, onChanged: onChangedConnectionStatus);
  static String connectionUri = "";
  static DateTime? connectionEstablished;

  // GETTERS
  static bool get connected => connectionStatus.value == ConnectionStatus.Connected;
  static bool get connecting => connectionStatus.value == ConnectionStatus.Connecting;

  // FUNCTIONS
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

  static void connectToGameSurvival() => connectToGame(GameType.Survival);

  static void connectToGame5v5() => connectToGame(GameType.FiveVFive);

  static void connectToGamePractice() => connectToGame(GameType.Practice);

  static void connectToGame(int gameType, [String message = ""]) =>
      connectToRegion(GameWebsite.region.value, '${gameType} $message');

  static Future sendClientRequestUpdate() async {
    applyUpdateBuffer(
      actionPrimary: GameIO.getCursorAction(),
      direction: GameIO.getDirection(),
      actionSecondary: false,
      actionTertiary: false,
    );

    writeNumberToByteArray(number: GameIO.getCursorWorldX(), list: updateBuffer, index: 5);
    writeNumberToByteArray(number: GameIO.getCursorWorldY(), list: updateBuffer, index: 7);
    writeNumberToByteArray(number: Engine.Screen_Left, list: updateBuffer, index: 9);
    writeNumberToByteArray(number: Engine.Screen_Top, list: updateBuffer, index: 11);
    writeNumberToByteArray(number: Engine.Screen_Right, list: updateBuffer, index: 13);
    writeNumberToByteArray(number: Engine.Screen_Bottom, list: updateBuffer, index: 15);
    sink.add(updateBuffer);
    GameIO.setCursorAction(CursorAction.None);
  }

  static applyUpdateBuffer({
    required int direction,
    required int actionPrimary,
    required bool actionSecondary,
    required bool actionTertiary,
  }){
    updateBuffer[1] = direction;
    updateBuffer[2] = actionPrimary;
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

        if (webSocketChannel.closeCode != null){
           WebsiteState.error.value = "Lost Connection";
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
      return serverResponseReader.read(response);
    }
    if (response is String){
      // if (response.startsWith("scene:")){
      //   final contents = response.substring(6, response.length);
      //   Engine.downloadString(contents: contents, filename: "hello.json");
      // }
      WebsiteState.error.value = response;
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
        Engine.onDrawCanvas = GameCanvas.renderCanvas;
        Engine.onDrawForeground = GameCanvas.renderForeground;
        Engine.onUpdate = GameState.update;
        Engine.drawCanvasAfterUpdate = true;
        Engine.zoomOnScroll = true;
        Engine.zoom = GameConfig.Zoom_Spawn;
        Engine.targetZoom = GameConfig.Zoom_Default;
        ClientState.hoverDialogType.value = DialogType.None;
        if (!Engine.isLocalHost) {
          Engine.fullScreenEnter();
        }
        GameAudio.muted.value = false;
        break;

      case ConnectionStatus.Done:
        Engine.camera.x = 0;
        Engine.camera.y = 0;
        Engine.zoom = 1.0;
        Engine.onUpdate = null;
        Engine.drawCanvasAfterUpdate = true;
        Engine.cursorType.value = CursorType.Basic;
        Engine.drawCanvasAfterUpdate = true;
        // Engine.onDrawCanvas = GameWebsite.renderCanvas;
        Engine.onDrawCanvas = null;
        Engine.onUpdate = GameWebsite.update;
        Engine.fullScreenExit();
        GameState.clear();
        ServerState.clean();
        // TODO illegal server state assignment
        ServerState.gameType.value = null;
        ServerState.sceneEditable.value = false;
        GameAudio.muted.value = true;
        break;
      case ConnectionStatus.Failed_To_Connect:
        WebsiteState.error.value = "Failed to connect";
        break;
      case ConnectionStatus.Invalid_Connection:
        WebsiteState.error.value = "Invalid Connection";
        break;
      case ConnectionStatus.Error:
        WebsiteState.error.value = "Connection Error";
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

  static void sendClientRequestReload(){
    sendClientRequest(ClientRequest.Reload);
  }

  static void sendClientRequestTeleportScene(TeleportScenes scene){
    sendClientRequest(ClientRequest.Teleport_Scene, scene.index);
  }

  static void sendClientRequestWeatherSetRain(int value){
    sendClientRequest(ClientRequest.Weather_Set_Rain, value);
  }

  static void sendClientRequestWeatherToggleBreeze(){
    sendClientRequest(ClientRequest.Weather_Toggle_Breeze);
  }

  static void sendClientRequestWeatherSetWind(int windType){
    sendClientRequest(ClientRequest.Weather_Set_Wind, windType);
  }

  static void sendClientRequestWeatherSetLightning(int value){
    sendClientRequest(ClientRequest.Weather_Set_Lightning, value);
  }

  static void sendClientRequestEditorLoadGame(String name){
    sendClientRequest(ClientRequest.Editor_Load_Game, name);
  }

  static void uploadScene(List<int> bytes) {
    final package = Uint8List(bytes.length + 1);
    package[0] = ClientRequest.Editor_Load_Scene;
    for (var i = 0; i < bytes.length; i++){
      package[i + 1] = bytes[i];
    }
    GameNetwork.sink.add(package);
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
  }) =>
    sendClientRequest(
      ClientRequest.GameObject, "${GameObjectRequest.Add.index} $index $type",
    );

  static void sendClientRequestInventoryEquip(int index) {
    sendClientRequest(
      ClientRequest.Inventory, "${InventoryRequest.Equip} $index",
    );
  }

  static void sendClientRequestInventoryToggle() =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Toggle}",
      );


  static final unequipRequest = (){
     final list = Uint8List(1);
     list[0] = ClientRequest.Unequip;
     return list;
  }();

  static void sendClientRequestUnequip() =>
      GameNetwork.send(unequipRequest);

  static void sendClientRequestInventoryDrop(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Drop} $index",
      );

  static void sendClientRequestInventoryUnequip(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Unequip} $index",
      );

  static void sendClientRequestInventoryBuy(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Buy} $index",
      );

  static void sendClientRequestInventoryDeposit(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Deposit} $index",
      );

  static void sendClientRequestInventorySell(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Sell} $index",
      );

  static void sendClientRequestInventoryMove({
    required int indexFrom,
    required int indexTo,
  }) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Move} $indexFrom $indexTo",
      );

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

  static void sendClientRequestEditSceneToggleUnderground() =>
      sendClientRequestEdit(EditRequest.Scene_Toggle_Underground);

  static void sendClientRequestEditGenerateScene({
    required int rows,
    required int columns,
    required int height,
    required int octaves,
    required int frequency,
  }) => sendClientRequestEdit(
      EditRequest.Generate_Scene, '$rows $columns $height $octaves $frequency'
  );

  static void sendClientRequestEditSceneSetFloorTypeStone() =>
      sendClientRequestEditSceneSetFloorType(NodeType.Concrete);

  static void sendClientRequestEditSceneSetFloorType(int nodeType) =>
      sendClientRequestEdit(EditRequest.Scene_Set_Floor_Type, nodeType);

  static void sendClientRequestEdit(EditRequest request, [dynamic message = null]) =>
      sendClientRequest(ClientRequest.Edit, '${request.index} $message');

  static void sendGameObjectRequestMoveToMouse() {
    sendGameObjectRequest(GameObjectRequest.Move_To_Mouse);
  }

  static void sendGameObjectRequest(GameObjectRequest request, [dynamic message]) {
    if (message != null){
      sendClientRequest(ClientRequest.GameObject, '${request.index} $message');
    }
    sendClientRequest(ClientRequest.GameObject, request.index);
  }

  static void sendClientRequestSelectPerkType(int perk){
    sendClientRequest(ClientRequest.Select_Perk, perk);
  }

  static void sendClientRequest(int value, [dynamic message]){
    if (message != null){
      return GameNetwork.send('${value} $message');
    }
    GameNetwork.send(value);
  }
}

