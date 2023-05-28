import 'package:gamestream_flutter/modules/modules.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'library.dart';

class GameNetwork {
  late WebSocketChannel webSocketChannel;
  late WebSocketSink sink;
  final updateBuffer = Uint8List(15);
  late final connectionStatus = Watch(ConnectionStatus.None, onChanged: gamestream.network.onChangedConnectionStatus);
  String connectionUri = "";
  DateTime? connectionEstablished;

  final Gamestream gsEngine;

  GameNetwork(this.gsEngine);

  // GETTERS
  bool get connected => connectionStatus.value == ConnectionStatus.Connected;
  bool get connecting => connectionStatus.value == ConnectionStatus.Connecting;

  // FUNCTIONS
  void connectToRegion(ConnectionRegion region, String message) {
    print("connectToRegion(${region.name}");
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
    connectToServer(convertHttpToWSS(region.url), message);
  }

  void connectLocalHost({int port = 8080, required String message}) {
    connectToServer('ws://localhost:$port', message);
  }

  void connectToServer(String uri, String message) {
    connect(uri: uri, message: '${ClientRequest.Join} $message');
  }

  static String convertHttpToWSS(String url, {String port = '8080'}) =>
      url.replaceAll("https", "wss") + "/:$port";

  void connectToGameEditor() => connectToGame(GameType.Editor);

  void connectToGameCombat() => connectToGame(GameType.Combat);

  void connectToGameRockPaperScissors() => connectToGame(GameType.Rock_Paper_Scissors);

  void connectToGameAeon() => connectToGame(GameType.Mobile_Aeon);

  void connectToGame(GameType gameType, [String message = ""]) =>
      connectToRegion(GameWebsite.region.value, '${gameType.index} $message');

  Future sendClientRequestUpdate() async {
    applyKeyboardInputToUpdateBuffer();
    gamestream.io.setCursorAction(CursorAction.None);
  }

  /// [0] Direction
  /// [1] Direction
  /// [2] Direction
  /// [3] Direction
  /// [4] Mouse_Left
  /// [5] Mouse_Right
  /// [6] Shift
  /// [7] Space
  applyKeyboardInputToUpdateBuffer() {
    updateBuffer[1] = gamestream.io.getInputAsByte();
    writeNumberToByteArray(number: gamestream.io.getCursorWorldX(), list: updateBuffer, index: 2);
    writeNumberToByteArray(number: gamestream.io.getCursorWorldY(), list: updateBuffer, index: 4);
    writeNumberToByteArray(number: engine.Screen_Left, list: updateBuffer, index: 6);
    writeNumberToByteArray(number: engine.Screen_Top, list: updateBuffer, index: 8);
    writeNumberToByteArray(number: engine.Screen_Right, list: updateBuffer, index: 10);
    writeNumberToByteArray(number: engine.Screen_Bottom, list: updateBuffer, index: 12);
    sink.add(updateBuffer);
  }

  void connect({required String uri, required dynamic message}) {
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

  void disconnect() {
    print('network.disconnect()');
    if (connected){
      sink.close();
    }
    connectionStatus.value = ConnectionStatus.None;
  }

  void sendIntList(List<int> values) => send(Uint8List.fromList(values));

  void send(dynamic message) {
    if (!connected) {
      print("warning cannot send because not connected");
      return;
    }
    sink.add(message);
  }

  void _onEvent(dynamic response) {
    if (connecting) {
      connectionStatus.value = ConnectionStatus.Connected;
    }

    if (response is Uint8List) {
      return gamestream.serverResponseReader.read(response, gamestream.games.gameFight2D);
    }
    if (response is String) {
      if (response.toLowerCase() == 'ping'){
        print("ping request received");
        sink.add('pong');
        return;
      }
      WebsiteState.error.value = response;
      return;
    }
    throw Exception("cannot parse response: $response");
  }

  void _onError(Object error, StackTrace stackTrace) {
    print("network.onError()");
    // core.actions.setError(error.toString());
  }

  void _onDone() {
    print("network.onDone()");

    connectionUri = "";
    if (connecting) {
      connectionStatus.value = ConnectionStatus.Failed_To_Connect;
    } else {
      connectionStatus.value = ConnectionStatus.Done;
    }
    sink.close();
  }

  void onChangedConnectionStatus(ConnectionStatus connection) {
    gamestream.io.removeListeners();
    engine.onDrawForeground = null;
    gamestream.serverResponseReader.bufferSizeTotal.value = 0;
    ClientState.clearParticles();
    ClientState.window_visible_menu.setFalse();
    ClientState.control_visible_player_weapons.value = false;
    ClientState.window_visible_player_creation.value = false;
    ClientState.control_visible_respawn_timer.value = false;

    switch (connection) {
      case ConnectionStatus.Connected:
        gamestream.io.addListeners();
        engine.cursorType.value = CursorType.None;
        engine.drawCanvasAfterUpdate = true;
        engine.zoomOnScroll = true;
        engine.zoom = GameConfig.Zoom_Spawn;
        engine.targetZoom = GameConfig.Zoom_Default;
        ClientState.hoverDialogType.value = DialogType.None;
        ClientState.timeConnectionEstablished = DateTime.now();
        gamestream.audio.enabledSound.value = true;
        if (!engine.isLocalHost) {
          engine.fullScreenEnter();
        }
        break;

      case ConnectionStatus.Done:
        GamePlayer.active.value = false;
        ClientState.timeConnectionEstablished = null;
        engine.cameraX = 0;
        engine.cameraY = 0;
        engine.zoom = 1.0;
        engine.drawCanvasAfterUpdate = true;
        engine.cursorType.value = CursorType.Basic;
        engine.drawCanvasAfterUpdate = true;
        engine.fullScreenExit();
        gamestream.games.isometric.clientState.clear();
        ServerState.clean();
        gamestream.gameType.value = GameType.Website;
        ServerState.sceneEditable.value = false;
        gamestream.audio.enabledSound.value = false;
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


  void sendRequestSpeak(String message){
    if (message.trim().isEmpty) return;
    sendClientRequest(ClientRequest.Speak, message);
  }

  void sendClientRequestTeleport(){
    sendClientRequest(ClientRequest.Teleport);
  }

  void sendClientRequestReload(){
    sendClientRequest(ClientRequest.Reload);
  }

  void sendClientRequestTeleportScene(TeleportScenes scene){
    sendClientRequest(ClientRequest.Teleport_Scene, scene.index);
  }

  void sendClientRequestWeatherSetRain(int value){
    sendClientRequest(ClientRequest.Weather_Set_Rain, value);
  }

  void sendClientRequestWeatherToggleBreeze(){
    sendClientRequest(ClientRequest.Weather_Toggle_Breeze);
  }

  void sendClientRequestWeatherSetWind(int windType){
    sendClientRequest(ClientRequest.Weather_Set_Wind, windType);
  }

  void sendClientRequestWeatherSetLightning(int value){
    sendClientRequest(ClientRequest.Weather_Set_Lightning, value);
  }

  void sendClientRequestEditorLoadGame(String name){
    sendClientRequest(ClientRequest.Editor_Load_Game, name);
  }

  void uploadScene(List<int> bytes) {
    final package = Uint8List(bytes.length + 1);
    package[0] = ClientRequest.Editor_Load_Scene;
    for (var i = 0; i < bytes.length; i++){
      package[i + 1] = bytes[i];
    }
    gamestream.network.sink.add(package);
  }

  void sendClientRequestNpcSelectTopic(int index) =>
      sendClientRequest(ClientRequest.Npc_Talk_Select_Option, index);

  void sendClientRequestTimeSetHour(int hour){
    assert(hour >= 0);
    assert(hour <= 24);
    sendClientRequest(ClientRequest.Time_Set_Hour, hour);
  }

  void sendClientRequestRevive(){
    sendClientRequest(ClientRequest.Revive);
  }

  void sendClientRequestSetBlock({
    required int index,
    required int type,
    required int orientation,
  }) =>
      sendClientRequest(
        ClientRequest.Node,
        '$index $type $orientation',
      );

  void sendClientRequestAddGameObject({
    required int index,
    required int type,
  }) =>
    sendClientRequest(
      ClientRequest.GameObject, "${GameObjectRequest.Add.index} $index $type",
    );

  void sendClientRequestInventoryEquip(int index) {
    sendClientRequest(
      ClientRequest.Inventory, "${InventoryRequest.Equip} $index",
    );
  }

  void sendClientRequestInventoryToggle() =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Toggle}",
      );


  final unequipRequest = (){
     final list = Uint8List(1);
     list[0] = ClientRequest.Unequip;
     return list;
  }();

  void sendClientRequestUnequip() =>
      gamestream.network.send(unequipRequest);

  void sendClientRequestInventoryDrop(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Drop} $index",
      );

  void sendClientRequestInventoryUnequip(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Unequip} $index",
      );

  void sendClientRequestInventoryBuy(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Buy} $index",
      );

  void sendClientRequestInventoryDeposit(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Deposit} $index",
      );

  void sendClientRequestInventorySell(int index) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Sell} $index",
      );

  void sendClientRequestInventoryMove({
    required int indexFrom,
    required int indexTo,
  }) =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Move} $indexFrom $indexTo",
      );

  void sendClientRequestGameObjectTranslate({
    required double tx,
    required double ty,
    required double tz,
  }) {
    sendClientRequest(
      ClientRequest.GameObject,
      "${GameObjectRequest.Translate.index} $tx $ty $tz",
    );
  }

  void sendGameObjectRequestDuplicate() {
    sendClientRequest(
      ClientRequest.GameObject,
      "${GameObjectRequest.Duplicate.index}",
    );
  }

  void sendGameObjectRequestSelect() {
    sendGameObjectRequest(GameObjectRequest.Select);
  }

  void sendGameObjectRequestDeselect() {
    sendGameObjectRequest(GameObjectRequest.Deselect);
  }

  void sendGameObjectRequestDelete() {
    sendGameObjectRequest(GameObjectRequest.Delete);
  }

  void sendRequestThrowGrenade() => sendClientRequest(ClientRequest.Player_Throw_Grenade);

  void sendClientRequestModifyCanvasSize(RequestModifyCanvasSize request) =>
      sendClientRequestEdit(EditRequest.Modify_Canvas_Size, request.index);

  void sendClientRequestEditSceneToggleUnderground() =>
      sendClientRequestEdit(EditRequest.Scene_Toggle_Underground);

  void sendClientRequestEditGenerateScene({
    required int rows,
    required int columns,
    required int height,
    required int octaves,
    required int frequency,
  }) => sendClientRequestEdit(
      EditRequest.Generate_Scene, '$rows $columns $height $octaves $frequency'
  );

  void sendClientRequestEditSceneSetFloorTypeStone() =>
      sendClientRequestEditSceneSetFloorType(NodeType.Concrete);

  void sendClientRequestEditSceneSetFloorType(int nodeType) =>
      sendClientRequestEdit(EditRequest.Scene_Set_Floor_Type, nodeType);

  void sendClientRequestEdit(EditRequest request, [dynamic message = null]) =>
      sendClientRequest(ClientRequest.Edit, '${request.index} $message');

  void sendGameObjectRequestMoveToMouse() {
    sendGameObjectRequest(GameObjectRequest.Move_To_Mouse);
  }

  void sendClientRequestSelectWeaponPrimary(int value) =>
      sendClientRequest(ClientRequest.Select_Weapon_Primary, value);

  void sendClientRequestSelectWeaponSecondary(int value) =>
      sendClientRequest(ClientRequest.Select_Weapon_Secondary, value);

  void sendGameObjectRequest(GameObjectRequest request, [dynamic message]) {
    if (message != null){
      sendClientRequest(ClientRequest.GameObject, '${request.index} $message');
    }
    sendClientRequest(ClientRequest.GameObject, request.index);
  }

  void sendClientRequest(int value, [dynamic message]){
    if (message != null){
      return gamestream.network.send('${value} $message');
    }
    gamestream.network.send(value);
  }
}

