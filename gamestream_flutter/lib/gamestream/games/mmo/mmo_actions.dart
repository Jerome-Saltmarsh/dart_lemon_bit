import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';

extension MMOActions on MmoGame {

  void toggleInventoryOpen() =>
      sendMMORequest(MMORequest.Toggle_Inventory_Open);

  void selectTalkOption(int index) =>
      sendMMORequest(MMORequest.Select_Talk_Option, index);

  void endInteraction() =>
      sendMMORequest(MMORequest.End_Interaction);

  void toggleTalentsDialog() =>
      sendMMORequest(MMORequest.Toggle_Skills_Dialog);

  void upgradeTalent(MMOTalentType talentType) =>
      sendMMORequest(MMORequest.Upgrade_Talent, talentType.index);

  void sendMMORequest(MMORequest request, [dynamic message]) =>
      network.send(
          NetworkRequest.MMO,
          '${request.index} $message'
      );


}