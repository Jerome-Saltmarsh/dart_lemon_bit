import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/enums/connection_status.dart';
import 'package:gamestream_flutter/enums/region.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_io.dart';
import 'package:gamestream_flutter/io/touchscreen.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric_web/read_player_input.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:lemon_watch/watch.dart';
import 'isometric/watches/scene_meta_data.dart';
import 'isometric_web/download_file.dart';
import 'isometric_web/register_isometric_web_controls.dart';

class GameNetwork {
  static const Url_Sydney = "https://gamestream-ws-australia-osbmaezptq-ts.a.run.app";
  static const Url_Singapore = "https://gamestream-ws-singapore-osbmaezptq-as.a.run.app";
  static final updateBuffer = Uint8List(17);
  static late WebSocketChannel webSocketChannel;
  static final connectionStatus = Watch(ConnectionStatus.None, onChanged: onChangedConnectionStatus);
  static bool get connected => connectionStatus.value == ConnectionStatus.Connected;
  static bool get connecting => connectionStatus.value == ConnectionStatus.Connecting;
  static String connectionUri = "";
  static late WebSocketSink sink;
  static DateTime? connectionEstablished;
  static var localhostPort = '8080';

  static void connectToRegion(Region region, String message) {
    if (region == Region.LocalHost) {
      connectToServer('ws://localhost:$localhostPort', message);
      return;
    }
    if (region == Region.Custom) {
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
    connect(uri: uri, message: '${ClientRequest.Join.index} $message');
  }

  static String parseUrlHttpToWS(String url, {String port = '8080'}) =>
      url.replaceAll("https", "wss") + "/:$port";

  static String getRegionConnectionString(Region region) {
    switch (region) {
      case Region.Australia:
        return Url_Sydney;
      case Region.Singapore:
        return Url_Singapore;
      default:
        throw Exception('GameNetwork.getRegionConnectionString($region)');
    }
  }

  static void connectToGameDarkAge() => connectToGame(GameType.Dark_Age);

  static void connectToGameEditor() => connectToGame(GameType.Editor);

  static void connectToGameWaves() => connectToGame(GameType.Waves);

  static void connectToGameSkirmish() => connectToGame(GameType.Skirmish);

  static void connectToGame(int gameType, [String message = ""]) =>
      connectToRegion(Website.region.value, '${gameType} $message');

  static Future sendClientRequestUpdate() async {
    const updateIndex = 0;
    updateBuffer[0] = updateIndex;

    if (Engine.deviceIsComputer){
      updateBuffer[1] = getKeyDirection();
      updateBuffer[2] = !Game.edit.value && Engine.watchMouseLeftDown.value ? 1 : 0;
      updateBuffer[3] = !Game.edit.value && Engine.mouseRightDown.value ? 1 : 0;
      updateBuffer[4] = !Game.edit.value && GameIO.keyPressedSpace ? 1 : 0;
    } else {
      updateBuffer[1] = Touchscreen.direction;
      updateBuffer[2] = 0;
      updateBuffer[3] = 0;
      updateBuffer[4] = 0;
    }
    writeNumberToByteArray(number: Engine.mouseWorldX, list: updateBuffer, index: 5);
    writeNumberToByteArray(number: Engine.mouseWorldY, list: updateBuffer, index: 7);
    writeNumberToByteArray(number: Engine.screen.left, list: updateBuffer, index: 9);
    writeNumberToByteArray(number: Engine.screen.top, list: updateBuffer, index: 11);
    writeNumberToByteArray(number: Engine.screen.right, list: updateBuffer, index: 13);
    writeNumberToByteArray(number: Engine.screen.bottom, list: updateBuffer, index: 15);
    sink.add(updateBuffer);
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
      sinkMessage(message);
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
    sinkMessage(message);
  }

  static void sinkMessage(dynamic message) {
    sink.add(message);
  }

  static void _onEvent(dynamic _response) {
    if (connecting) {
      connectionStatus.value = ConnectionStatus.Connected;
    }

    if (_response is Uint8List) {
      return serverResponseReader.readBytes(_response);
    }
    if (_response is String){
      if (_response.startsWith("scene:")){
        final contents = _response.substring(6, _response.length);
        downloadString(contents: contents, filename: "hello.json");
      }
      Website.error.value = _response;
      return;
    }
    throw Exception("cannot parse response: $_response");
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
    switch (connection) {
      case ConnectionStatus.Connected:
        Engine.onDrawCanvas = Game.renderCanvas;
        Engine.onDrawForeground = modules.game.render.renderForeground;
        Engine.onUpdate = Game.update;
        Engine.drawCanvasAfterUpdate = true;
        Engine.zoomOnScroll = true;
        if (!Engine.isLocalHost) {
          Engine.fullScreenEnter();
        }
        isometricWebControlsRegister();
        break;

      case ConnectionStatus.Done:
        Engine.onUpdate = null;
        Engine.drawCanvasAfterUpdate = true;
        Engine.cursorType.value = CursorType.Basic;
        Engine.drawCanvasAfterUpdate = true;
        Engine.onDrawCanvas = Website.renderCanvas;
        Engine.onUpdate = Website.update;
        Engine.fullScreenExit();
        Game.clear();
        Game.gameType.value = null;
        sceneEditable.value = false;
        isometricWebControlsDeregister();
        break;
      case ConnectionStatus.Failed_To_Connect:
        Website.error.value = "Failed to connect";
        break;
      case ConnectionStatus.Invalid_Connection:
        Website.error.value = "Invalid Connection";
        break;
      case ConnectionStatus.Error:
        Website.error.value = "Connection Error";
        break;
      default:
        break;
    }
  }
}

