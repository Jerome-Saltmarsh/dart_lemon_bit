import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

extension MMOActions on MmoGame {

  void selectWeapon(int index) =>
      sendMMORequest(MMORequest.Select_Weapon, index);

  void selectItem(int index) =>
      sendMMORequest(MMORequest.Select_Item, index);

  void selectTreasure(int index) =>
      sendMMORequest(MMORequest.Select_Treasure, index);

  void dropWeapon(int index) =>
      sendMMORequest(MMORequest.Drop_Weapon, index);

  void dropItem(int index) =>
      sendMMORequest(MMORequest.Drop_Item, index);

  void dropTreasure(int index) =>
      sendMMORequest(MMORequest.Drop_Treasure, index);

  void dropEquippedHead() =>
      sendMMORequest(MMORequest.Drop_Equipped_Head);

  void dropEquippedBody() =>
      sendMMORequest(MMORequest.Drop_Equipped_Body);

  void dropEquippedLegs() =>
      sendMMORequest(MMORequest.Drop_Equipped_Legs);

  void selectTalkOption(int index) =>
      sendMMORequest(MMORequest.Select_Talk_Option, index);

  void endInteraction() =>
      sendMMORequest(MMORequest.End_Interaction);

  void toggleTalentsDialog() =>
      sendMMORequest(MMORequest.Toggle_Skills_Dialog);

  void unlockTalent(MMOTalentType talentType) =>
      sendMMORequest(MMORequest.Unlock_Talent, talentType.index);

  void sendMMORequest(MMORequest request, [dynamic message]) =>
      gamestream.network.sendClientRequest(
          ClientRequest.MMO,
          '${request.index} $message'
      );

}