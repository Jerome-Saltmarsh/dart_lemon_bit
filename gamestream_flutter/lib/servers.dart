
import 'package:bleed_common/client_request.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

import 'network/instance/websocket.dart';

void connectToRegion(Region server, String message) {
  if (server == Region.LocalHost) {
    connectToServer('ws://localhost:8080', message);
    return;
  }
  if (server == Region.Custom){
    print("connecting to custom server");
    print(website.state.customConnectionStrongController.text);
    connectToServer(website.state.customConnectionStrongController.text, message);
    return;
  }
  final httpsConnectionString = getRegionConnectionString(server);
  final wsConnectionString = parseHttpToWebSocket(httpsConnectionString);
  connectToServer(wsConnectionString, message);
}

void connectLocalHost({int port = 8080, required String message}) {
  connectToServer('ws://localhost:$port', message);
}

void connectToServer(String uri, String message){
    webSocket.connect(
        uri: uri, message: '${ClientRequest.Join.index} $message');
}

final List<Region> selectableServerTypes =
    regions.where((type) => (Engine.isLocalHost || type != Region.LocalHost)
    ).toList();

class ServerUri {
  static const Sydney = "https://gamestream-ws-australia-osbmaezptq-ts.a.run.app";
  static const Singapore = "https://gamestream-ws-singapore-osbmaezptq-as.a.run.app";
}

String parseHttpToWebSocket(String url, {String port = '8080'}) =>
  url.replaceAll("https", "wss") + "/:$port";

String getRegionConnectionString(Region region) {
  switch (region) {
    case Region.Australia:
      return ServerUri.Sydney;
    case Region.Singapore:
      return ServerUri.Singapore;
    default:
      return ServerUri.Sydney;
  }
}
