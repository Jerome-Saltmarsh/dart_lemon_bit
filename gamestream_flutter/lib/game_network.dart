import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/enums/region.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/instance/websocket.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';

class GameNetwork {

  static void connectToRegion(Region server, String message) {
    if (server == Region.LocalHost) {
      connectToServer('ws://localhost:8080', message);
      return;
    }
    if (server == Region.Custom) {
      print("connecting to custom server");
      print(website.state.customConnectionStrongController.text);
      connectToServer(
          website.state.customConnectionStrongController.text,
          message,
      );
      return;
    }
    final httpsConnectionString = getRegionConnectionString(server);
    final wsConnectionString = parseHttpToWS(httpsConnectionString);
    connectToServer(wsConnectionString, message);
  }

  static void connectLocalHost({int port = 8080, required String message}) {
    connectToServer('ws://localhost:$port', message);
  }

  static void connectToServer(String uri, String message) {
    webSocket.connect(
        uri: uri, message: '${ClientRequest.Join.index} $message');
  }

  final List<Region> selectableServerTypes = regions
      .where((type) => (Engine.isLocalHost || type != Region.LocalHost))
      .toList();

  static String parseHttpToWS(String url, {String port = '8080'}) =>
      url.replaceAll("https", "wss") + "/:$port";

  static String getRegionConnectionString(Region region) {
    switch (region) {
      case Region.Australia:
        return ServerUri.Sydney;
      case Region.Singapore:
        return ServerUri.Singapore;
      default:
        return ServerUri.Sydney;
    }
  }

  static void connectToGameDarkAge() => connectToGame(GameType.Dark_Age);

  static void connectToGameEditor() => connectToGame(GameType.Editor);

  static void connectToGameWaves() => connectToGame(GameType.Waves);

  static void connectToGameSkirmish() => connectToGame(GameType.Skirmish);

  static void connectToGame(int gameType, [String message = ""]) =>
      connectToRegion(Website.region.value, '${gameType} $message');
}

class ServerUri {
  static const Sydney =
      "https://gamestream-ws-australia-osbmaezptq-ts.a.run.app";
  static const Singapore =
      "https://gamestream-ws-singapore-osbmaezptq-as.a.run.app";
}
