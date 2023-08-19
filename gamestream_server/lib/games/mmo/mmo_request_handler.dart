import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/games/mmo/mmo_player.dart';
import 'package:gamestream_server/utils/src.dart';
import 'package:gamestream_server/websocket/websocket_connection.dart';

extension MMORequestHandler on WebSocketConnection {

  void handleClientRequestMMORequest(List<String> arguments){

    final player = this.player;
    if (player is! AmuletPlayer) {
      errorInvalidPlayerType();
      return;
    }

    final requestIndex = parseArg1(arguments);
    if (requestIndex == null) return;
    if (!isValidIndex(requestIndex, MMORequest.values)){
      errorInvalidClientRequest();
      return;
    }
    final mmoRequest = MMORequest.values[requestIndex];

    switch (mmoRequest){
      case MMORequest.End_Interaction:
        player.endInteraction();
        break;
      case MMORequest.Select_Item:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectItem(index);
        break;
      case MMORequest.Select_Treasure:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectTreasure(index);
        break;
      case MMORequest.Select_Weapon:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectWeapon(index);
        break;
      case MMORequest.Select_Talk_Option:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.selectNpcTalkOption(index);
        break;
      case MMORequest.Toggle_Skills_Dialog:
        player.toggleSkillsDialog();
        break;
      case MMORequest.Toggle_Inventory_Open:
        player.toggleInventoryOpen();
        break;
      case MMORequest.Upgrade_Talent:
        final index = parseArg2(arguments);
        if (index == null) return;
        if (!isValidIndex(index, MMOTalentType.values)){
          errorInvalidClientRequest();
          return;
        }
        final mmoTalentType = MMOTalentType.values[index];
        player.upgradeTalent(mmoTalentType);
        break;
    }
  }
}