
import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_parser.dart';

extension MMOResponseReader on IsometricParser {

  void readMMOResponse(){
     switch (readByte()){
       case MMOResponse.Player_Interacting:
         amulet.playerInteracting.value = readBool();
         break;
       case MMOResponse.Npc_Talk:
         amulet.npcText.value = readString();
         final length = readByte();
         final options = amulet.npcOptions;
         options.clear();
         for (var i = 0; i < length; i++){
           options.add(readString());
         }
         amulet.npcOptionsReads.value++;
         break;
       case MMOResponse.Player_Item_Length:
         amulet.setItemLength(readUInt16());
         break;
       case MMOResponse.Player_Item:
         final index = readUInt16();
         final type = readInt16();
         final item = type != -1 ? MMOItem.values[type] : null;
         amulet.setItem(index: index, item: item);
         break;
       case MMOResponse.Player_Weapon:
         final index = readUInt16();
         final type = readInt16();
         final cooldown = type != -1 ? readUInt16() : 0;
         final item = type != -1 ? MMOItem.values[type] : null;
         amulet.setWeapon(index: index, item: item, cooldown: cooldown);
         break;
       case MMOResponse.Player_Treasure:
         final index = readUInt16();
         final type = readInt16();
         final item = type != -1 ? MMOItem.values[type] : null;
         amulet.setTreasure(index: index, item: item);
         break;
       case MMOResponse.Player_Equipped_Weapon_Index:
         amulet.equippedWeaponIndex.value = readInt16();
         break;
       case MMOResponse.Player_Equipped:
         amulet.equippedHead.item.value = readMMOItem();
         amulet.equippedBody.item.value = readMMOItem();
         amulet.equippedLegs.item.value = readMMOItem();
         amulet.equippedHandLeft.item.value = readMMOItem();
         amulet.equippedHandRight.item.value = readMMOItem();
         break;
       case MMOResponse.Player_Experience:
         amulet.playerExperience.value = readUInt24();
         break;
       case MMOResponse.Player_Experience_Required:
         amulet.playerExperienceRequired.value = readUInt24();
         break;
       case MMOResponse.Player_Level:
         amulet.playerLevel.value = readByte();
         break;
       case MMOResponse.Player_Talent_Points:
         amulet.playerTalentPoints.value = readByte();
         amulet.playerTalentsChangedNotifier.value++;
         break;
       case MMOResponse.Player_Talent_Dialog_Open:
         amulet.playerTalentDialogOpen.value = readBool();
         break;
       case MMOResponse.Player_Inventory_Open:
         amulet.playerInventoryOpen.value = readBool();
         break;
       case MMOResponse.Player_Talents:
         final playerTalents = amulet.playerTalents;
         for (var i = 0; i < playerTalents.length; i++){
          playerTalents[i] = readByte();
         }
         amulet.playerTalentsChangedNotifier.value++;
         break;
       case MMOResponse.Activated_Power_Index:
         amulet.activatedPowerIndex.value = readInt8();
         break;
       case MMOResponse.Active_Power_Position:
         readIsometricPosition(amulet.activePowerPosition);
         break;
       case MMOResponse.Error:
         amulet.clearError();
         amulet.error.value = readString();
         break;
     }
  }

  MMOItem? readMMOItem(){
    final mmoItemIndex = readInt16();
    return mmoItemIndex == -1 ? null : MMOItem.values[mmoItemIndex];
  }
}