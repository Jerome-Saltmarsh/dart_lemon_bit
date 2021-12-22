import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/network.dart';


void connectToWebSocketServer(ServerType server, GameType gameType) {
  if (server == ServerType.LocalHost) {
    _connectLocalHost();
    return;
  }

  String httpsConnectionString = getHttpsConnectionString(server, gameType);
  String wsConnectionString = parseHttpToWebSocket(httpsConnectionString);
  connectWebSocket(wsConnectionString);
}

void _connectLocalHost({int port = 8080}) {
  connectWebSocket('ws://localhost:$port');
}

enum ServerType {
  None,
  Australia,
  Brazil,
  Germany,
  South_Korea,
  USA_East,
  USA_West,
  LocalHost
}

final List<ServerType> serverTypes = ServerType.values;

// implementation

final String sydneyMoba = "https://sydney-moba-1-osbmaezptq-ts.a.run.app";
final String sydneyMMO = "https://sydney-mmo-1-osbmaezptq-ts.a.run.app";

String parseHttpToWebSocket(String url) {
  return url.replaceAll("https", "wss") + "/:8080";
}

String getHttpsConnectionString(ServerType server, GameType gameType) {
  switch(server){
    case ServerType.Australia:
      switch (gameType) {
        case GameType.Open_World:
          return sydneyMMO;
        case GameType.Moba:
          return sydneyMoba;
        default:
          throw Exception();
      }
      break;
    default:
      throw Exception();
  }

}
