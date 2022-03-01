import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/core/init.dart';
import 'package:bleed_client/webSocket.dart';

void connectToWebSocketServer(Region server, GameType gameType) {
  if (server == Region.LocalHost) {
    _connectLocalHost();
    return;
  }
  final httpsConnectionString = getHttpsConnectionString(server, gameType);
  final wsConnectionString = parseHttpToWebSocket(httpsConnectionString);
  _connectToServer(wsConnectionString);
}

void _connectLocalHost({int port = 8080}) {
  _connectToServer('ws://localhost:$port');
}

void _connectToServer(String uri){
  webSocket.connect(uri: uri, message: ClientRequest.Ping.index.toString());
}

final List<Region> selectableServerTypes =
    regions.where((type) => (isLocalHost || type != Region.LocalHost)
    ).toList();

class _Servers {
  static const sydney = "https://gamestream-ws-sydney-6-osbmaezptq-ts.a.run.app";
}

String parseHttpToWebSocket(String url) {
  return url.replaceAll("https", "wss") + "/:8080";
}

String getHttpsConnectionString(Region server, GameType gameType) {
  print("HttpsConnectionString(server: $server)");
  switch (server) {
    case Region.Australia:
      switch (gameType) {
        case GameType.MMO:
          return _Servers.sydney;
        case GameType.Moba:
          return _Servers.sydney;
        default:
          return _Servers.sydney;
      }
    default:
      throw Exception();
  }
}
