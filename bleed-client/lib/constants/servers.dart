import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/debug.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/webSocket.dart';

void connectToWebSocketServer(Region server, GameType gameType) {
  if (server == Region.LocalHost) {
    _connectLocalHost();
    return;
  }
  final String httpsConnectionString = getHttpsConnectionString(server, gameType);
  final String wsConnectionString = parseHttpToWebSocket(httpsConnectionString);
  _connectToServer(wsConnectionString);
}

void _connectLocalHost({int port = 8080}) {
  _connectToServer('ws://localhost:$port');
}

void _connectToServer(String uri){
  webSocket.connect(uri: uri, message: ClientRequest.Ping.index.toString());
}

final List<Region> serverTypes = Region.values;

final List<Region> selectableServerTypes =
    serverTypes.where((type) => type != Region.None
      && (debug || type != Region.LocalHost)
    ).toList();

const String _default = "https://server-ws-sydney-2-osbmaezptq-ts.a.run.app";
const String sydneyMoba = "https://server-ws-sydney-2-osbmaezptq-ts.a.run.app";
const String sydneyMMO = "https://server-ws-sydney-2-osbmaezptq-ts.a.run.app";

String parseHttpToWebSocket(String url) {
  return url.replaceAll("https", "wss") + "/:8080";
}

String getHttpsConnectionString(Region server, GameType gameType) {
  print("etHttpsConnectionString(server: $server)");
  switch (server) {
    case Region.Australia:
      switch (gameType) {
        case GameType.MMO:
          return sydneyMMO;
        case GameType.Moba:
          return sydneyMoba;
        default:
          return _default;
      }
    default:
      throw Exception();
  }
}
