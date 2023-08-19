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
      case MMORequest.Drop_Treasure:
        final index = parseArg2(arguments);
        if (index == null) return;
        player.dropTreasure(index);
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
      case MMORequest.Drop_Equipped_Legs:
        player.dropEquippedLegs();
        break;
      case MMORequest.Drop_Equipped_Hand_Left:
        player.dropEquippedHandLeft();
        break;
      case MMORequest.Drop_Equipped_Hand_Right:
        player.dropEquippedHandRight();
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
      case MMORequest.Unequip_Head:
        player.unequipHead();
        break;
      case MMORequest.Unequip_Body:
        player.unequipBody();
        break;
      case MMORequest.Unequip_Legs:
        player.unequipLegs();
        break;
      case MMORequest.Unequip_Hand_Left:
        player.unequipHandLeft();
        break;
      case MMORequest.Unequip_Hand_Right:
        player.unequipHandRight();
        break;
      case MMORequest.Inventory_Move:
        final srcSlotTypeIndex = parseArg2(arguments);
        final srcIndex = parseArg3(arguments);
        final targetSlotTypeIndex = parseArg4(arguments);
        final targetIndex = parseArg5(arguments);

        if (srcSlotTypeIndex == null ||
            srcIndex == null ||
            targetSlotTypeIndex == null ||
            targetIndex == null
        ) return;

        const slotTypes = SlotType.values;

        if (!isValidIndex(srcSlotTypeIndex, slotTypes) ||
            !isValidIndex(targetSlotTypeIndex, slotTypes))
          return;

        final srcSlotType = slotTypes[srcSlotTypeIndex];
        final targetSlotType = slotTypes[targetSlotTypeIndex];

        final srcItemObject = player.getItemObjectAtSlotType(srcSlotType, srcIndex);
        final targetItemObject = player.getItemObjectAtSlotType(targetSlotType, targetIndex);

        final srcItem = srcItemObject.item;

        if (srcItem == null)
          throw Exception('srcItem is null');

        if (!slotTypeSupportsType(targetSlotType, srcItem.type)){
          return;
        }

        targetItemObject.item = srcItemObject.item;
        srcItemObject.item = null;
        player.notifyEquipmentDirty();
        break;
    }
  }

  bool slotTypeSupportsType(SlotType slotType, int type) =>
      switch (slotType){
        SlotType.Equipped_Helm => type == GameObjectType.Helm,
        SlotType.Equipped_Legs => type == GameObjectType.Legs,
        SlotType.Equipped_Body => type == GameObjectType.Body,
        SlotType.Equipped_Hand_Left => type == GameObjectType.Hand,
        SlotType.Equipped_Hand_Right => type == GameObjectType.Hand,
        SlotType.Treasures => type == GameObjectType.Treasure,
        SlotType.Weapons => type == GameObjectType.Weapon,
        SlotType.Items => true
      };
}