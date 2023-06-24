import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/games/mmo/mmo_player.dart';
import 'package:bleed_server/utils/src.dart';
import 'package:bleed_server/websocket/websocket_connection.dart';

extension CaptureTheFlagRequestHandler on WebSocketConnection {

  void handleClientRequestMMORequest(List<String> arguments){

    final player = this.player;
    if (player is! MmoPlayer) {
      errorInvalidPlayerType();
      return;
    }
    final requestIndex = parseArg1(arguments);
    if (requestIndex == null) return;
    if (!isValidIndex(requestIndex, MMORequest.values)){
      errorInvalidClientRequest();
      return;
    }
    final captureTheFlagClientRequest = MMORequest.values[requestIndex];

    switch (captureTheFlagClientRequest){
      case MMORequest.End_Interaction:
        player.endInteraction();
        break;
    }
  }
}