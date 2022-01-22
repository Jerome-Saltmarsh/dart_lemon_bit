import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/debug.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/webSocket.dart';

// Build upgrade orbs
// Each weapon has 3 orb slots

// Fire Orb
// Water Orb
// Leaf orb
// Energy Orb

// Ring of Healing
// 1 Fire Orb
// 1 Leaf Orb
// 1 Water Orb
// 1 Energy Orb

// Ring of Greater Healing

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
    serverTypes.where((type) => (debug || type != Region.LocalHost)
    ).toList();

const String _default = "https://gamestream-99-osbmaezptq-ts.a.run.app";
const String sydneyMoba = "https://gamestream-99-osbmaezptq-ts.a.run.app";
const String sydneyMMO = "https://gamestream-99-osbmaezptq-ts.a.run.app";

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
