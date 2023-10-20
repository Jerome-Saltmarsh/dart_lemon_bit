
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_network.dart';
import 'package:gamestream_flutter/packages/common.dart';

class SendAmuletRequest {

  final IsometricNetwork network;

  SendAmuletRequest(this.network);

  void toggleInventoryOpen() =>
      sendAmuletRequest(NetworkRequestAmulet.Toggle_Inventory_Open);

  void selectTalkOption(int index) =>
      sendAmuletRequest(NetworkRequestAmulet.Select_Talk_Option, index);

  void toggleTalentsDialog() =>
      sendAmuletRequest(NetworkRequestAmulet.Toggle_Skills_Dialog);

  void upgradeTalent(AmuletTalentType talentType) =>
      sendAmuletRequest(NetworkRequestAmulet.Upgrade_Talent, talentType.index);

  void sendAmuletRequest(NetworkRequestAmulet request, [dynamic message]) =>
      network.sendNetworkRequest(
          NetworkRequest.Amulet,
          '${request.index} $message'
      );

}