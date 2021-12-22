import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/network.dart';


// interface
String getServerName(ServerType server) {
  return _names[server];
}

void connectToWebSocketServer(ServerType server, GameType gameType) {
  if (server == ServerType.LocalHost) {
    connectLocalHost();
    return;
  }

  String httpsConnectionString = getHttpsConnectionString(server, gameType);
  String wsConnectionString = parseHttpToWebSocket(httpsConnectionString);
  connectWebSocket(wsConnectionString);
}

void connectLocalHost({int port = 8080}) {
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

Map<ServerType, String> _names = {
  ServerType.Australia: "Australia",
  ServerType.Brazil: "Brazil",
  ServerType.Germany: "Germany",
  ServerType.South_Korea: "South Korea",
  ServerType.USA_East: "USA East",
  ServerType.USA_West: "USA West",
  ServerType.LocalHost: "Localhost",
  ServerType.None: "None",
};

Map<ServerType, String> _uris = {
  ServerType.Australia: 'https://bleed-osbmaezptq-ts.a.run.app',
  ServerType.Brazil: "https://bleed-2-sao-paulo-osbmaezptq-rj.a.run.app",
  ServerType.Germany: 'https://bleed-frankfurt-15-osbmaezptq-ey.a.run.app',
  ServerType.South_Korea: 'https://bleed-2-seoul-osbmaezptq-du.a.run.app',
  ServerType.USA_East: 'https://bleed-usa-east-2-osbmaezptq-ue.a.run.app',
  ServerType.USA_West: 'https://bleed-usa-west-2-osbmaezptq-uw.a.run.app',
  ServerType.LocalHost: 'https://localhost'
};

final String sydneyMoba = "https://sydney-moba-1-osbmaezptq-ts.a.run.app";
final String sydneyMMO = "https://sydney-mmo-1-osbmaezptq-ts.a.run.app";

String parseHttpToWebSocket(String url) {
  return url.replaceAll("https", "wss") + "/:8080";
}

String _getUri(ServerType server) {
  return _uris[server];
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
