import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/enums/region.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/io/touchscreen.dart';
import 'package:gamestream_flutter/isometric_web/read_player_input.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';

import 'network/classes/websocket.dart';

class GameNetwork {
  static const Url_Sydney = "https://gamestream-ws-australia-osbmaezptq-ts.a.run.app";
  static const Url_Singapore = "https://gamestream-ws-singapore-osbmaezptq-as.a.run.app";
  static final webSocket = WebSocket();

  static final updateBuffer = Uint8List(17);

  static void connectToRegion(Region region, String message) {
    if (region == Region.LocalHost) {
      connectToServer('ws://localhost:8080', message);
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
    webSocket.connect(
        uri: uri, message: '${ClientRequest.Join.index} $message');
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
      updateBuffer[4] = !Game.edit.value && keyPressedSpace ? 1 : 0;
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
    webSocket.sink.add(updateBuffer);
  }
}

