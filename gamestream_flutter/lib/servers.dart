
import 'package:bleed_common/Character_Selection.dart';
import 'package:bleed_common/ClientRequest.dart';
import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/init.dart';
import 'package:gamestream_flutter/web_socket.dart';

void connectToWebSocketServer(Region server, CharacterSelection character) {
  if (server == Region.LocalHost) {
    _connectLocalHost(character: character);
    return;
  }
  final httpsConnectionString = getHttpsConnectionString(server, GameType.RANDOM);
  final wsConnectionString = parseHttpToWebSocket(httpsConnectionString);
  _connectToServer(wsConnectionString, character);
}


void _connectLocalHost({int port = 8080, required CharacterSelection character}) {
  _connectToServer('ws://localhost:$port', character);
}

void _connectToServer(String uri, CharacterSelection characterClass){
  webSocket.connect(uri: uri, message: '${ClientRequest.Join.index} ${characterClass.index}');
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
          return ServerUri.Sydney;
    default:
      return ServerUri.Sydney;
  }
}
