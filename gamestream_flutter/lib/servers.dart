
import 'package:bleed_common/ClientRequest.dart';
import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/init.dart';
import 'package:gamestream_flutter/network/web_socket.dart';

void connectToWebSocketServer(Region server, String message) {
  if (server == Region.LocalHost) {
    _connectLocalHost(message: message);
    return;
  }
  final httpsConnectionString = getHttpsConnectionString(server, GameType.Dark_Age);
  final wsConnectionString = parseHttpToWebSocket(httpsConnectionString);
  _connectToServer(wsConnectionString, message);
}

void _connectLocalHost({int port = 8080, required String message}) {
  _connectToServer('ws://localhost:$port', message);
}

void _connectToServer(String uri, String message){
  webSocket.connect(uri: uri, message: '${ClientRequest.Join.index} $message');
}

final List<Region> selectableServerTypes =
    regions.where((type) => (isLocalHost || type != Region.LocalHost)
    ).toList();

class ServerUri {
  static const Sydney = "https://gamestream-ws-australia-osbmaezptq-ts.a.run.app";
  static const Singapore = "https://gamestream-ws-singapore-osbmaezptq-as.a.run.app";
}

String parseHttpToWebSocket(String url) {
  return url.replaceAll("https", "wss") + "/:8080";
}

String getHttpsConnectionString(Region server, GameType gameType) {
  switch (server) {
    case Region.Australia:
          return ServerUri.Sydney;
    case Region.Singapore:
      return ServerUri.Singapore;
    default:
      return ServerUri.Sydney;
  }
}
