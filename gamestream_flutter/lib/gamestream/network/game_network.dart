import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'enums/connection_region.dart';
import 'enums/connection_status.dart';


class GameNetwork {

  static var portLocalhost = '8080';
  static String get wsLocalHost => 'ws://localhost:${portLocalhost}';
  
  late WebSocketChannel webSocketChannel;
  late WebSocketSink sink;
  late final connectionStatus = Watch(ConnectionStatus.None);
  String connectionUri = "";
  DateTime? connectionEstablished;
  late final region = Watch<ConnectionRegion?>(null);

  final Gamestream gamestream;

  GameNetwork(this.gamestream);

  // GETTERS
  bool get connected => connectionStatus.value == ConnectionStatus.Connected;
  bool get connecting => connectionStatus.value == ConnectionStatus.Connecting;

  // FUNCTIONS
  void connectToRegion(ConnectionRegion region, String message) {
    print("connectToRegion(${region.name}");
    if (region == ConnectionRegion.LocalHost) {
      connectToServer(wsLocalHost, message);
      return;
    }
    if (region == ConnectionRegion.Custom) {
      print("connecting to custom server");
      print(gamestream.games.website.customConnectionStrongController.text);
      connectToServer(
        gamestream.games.website.customConnectionStrongController.text,
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

  void connectToGame(GameType gameType, [String message = ""]) {
    final regionValue = region.value;
    if (regionValue == null) {
      throw Exception('region is null');
    }
    connectToRegion(regionValue, '${gameType.index} $message');
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

  void _onEvent(dynamic response) {
    if (connecting) {
      connectionStatus.value = ConnectionStatus.Connected;
    }

    if (response is Uint8List) {
      return gamestream.serverResponseReader.read(response);
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

  void sendClientRequestInventoryEquip(int index) {
    sendClientRequest(
      ClientRequest.Inventory, "${InventoryRequest.Equip} $index",
    );
  }

  void sendClientRequestInventoryToggle() =>
      sendClientRequest(
        ClientRequest.Inventory, "${InventoryRequest.Toggle}",
      );

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

  void sendClientRequestSelectWeaponPrimary(int value) =>
      sendClientRequest(ClientRequest.Select_Weapon_Primary, value);

  void sendClientRequestSelectWeaponSecondary(int value) =>
      sendClientRequest(ClientRequest.Select_Weapon_Secondary, value);

  void sendClientRequest(int value, [dynamic message]) =>
      message != null ? send('${value} $message') : send(value);

  void send(dynamic message) {
    if (!connected) {
      print("warning cannot send because not connected");
      return;
    }
    sink.add(message);
  }

}

