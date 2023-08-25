
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_network.dart';
import 'package:gamestream_flutter/packages/common.dart';

class SendAmuletRequest {

  final IsometricNetwork network;

  SendAmuletRequest(this.network);

  void toggleInventoryOpen() =>
      sendAmuletRequest(MMORequest.Toggle_Inventory_Open);

  void selectTalkOption(int index) =>
      sendAmuletRequest(MMORequest.Select_Talk_Option, index);

  void endInteraction() =>
      sendAmuletRequest(MMORequest.End_Interaction);

  void toggleTalentsDialog() =>
      sendAmuletRequest(MMORequest.Toggle_Skills_Dialog);

  void upgradeTalent(MMOTalentType talentType) =>
      sendAmuletRequest(MMORequest.Upgrade_Talent, talentType.index);

  void sendAmuletRequest(MMORequest request, [dynamic message]) =>
      network.send(
          NetworkRequest.MMO,
          '${request.index} $message'
      );

}