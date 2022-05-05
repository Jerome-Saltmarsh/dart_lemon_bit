
import 'package:bleed_common/ClientRequest.dart';
import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/init.dart';
import 'package:gamestream_flutter/web_socket.dart';

void connectToWebSocketServer(Region server, GameType gameType) {
  if (server == Region.LocalHost) {
    _connectLocalHost(gameType: gameType);
    return;
  }
  final httpsConnectionString = getHttpsConnectionString(server, gameType);
  final wsConnectionString = parseHttpToWebSocket(httpsConnectionString);
  _connectToServer(wsConnectionString, gameType);
}

void _connectLocalHost({int port = 8080, required GameType gameType}) {
  _connectToServer('ws://localhost:$port', gameType);
}

void _connectToServer(String uri, GameType gameType){
  webSocket.connect(uri: uri, message: '${ClientRequest.Join} ${gameType.index}');
}

final List<Region> selectableServerTypes =
    regions.where((type) => (isLocalHost || type != Region.LocalHost)
    ).toList();

class ServerUri {
  static const Sydney = "https://gamestream-ws-osbmaezptq-ts.a.run.app";
}

String parseHttpToWebSocket(String url) {
  return url.replaceAll("https", "wss") + "/:8080";
}

String getHttpsConnectionString(Region server, GameType gameType) {
  switch (server) {
    case Region.Australia:
      switch (gameType) {
        case GameType.MMO:
          return ServerUri.Sydney;
        case GameType.Moba:
          return ServerUri.Sydney;
        default:
          return ServerUri.Sydney;
      }
    default:
      throw Exception();
  }
}
