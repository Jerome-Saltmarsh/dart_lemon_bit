import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/games/mmo/mmo_player.dart';
import 'package:gamestream_server/utils/src.dart';
import 'package:gamestream_server/websocket/websocket_connection.dart';

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
      case MMORequest.Select_Item:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectItem(index);
        break;
      case MMORequest.Select_Weapon:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectWeapon(index);
        break;
      case MMORequest.Drop_Item:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.dropItem(index);
        break;
      case MMORequest.Drop_Weapon:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.dropWeapon(index);
        break;
      case MMORequest.Select_Talk_Option:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectNpcTalkOption(index);
        break;
      case MMORequest.Drop_Equipped_Head:
        player.dropEquippedHead();
        break;
      case MMORequest.Drop_Equipped_Body:
        player.dropEquippedBody();
        break;
      case MMORequest.Select_Equipped_Head:
        player.dropEquippedHead();
        break;
      case MMORequest.Select_Equipped_Body:
        player.dropEquippedBody();
        break;
      case MMORequest.Drop_Equipped_Legs:
        player.dropEquippedLegs();
        break;
      case MMORequest.Select_Equipped_Legs:
        player.dropEquippedLegs();
        break;
    }
  }
}