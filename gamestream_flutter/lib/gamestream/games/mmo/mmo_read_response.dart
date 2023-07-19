
import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';

extension MMOResponseReader on Gamestream {

  void readMMOResponse(){
    final game = games.mmo;
     switch (readByte()){
       case MMOResponse.Player_Interacting:
         game.playerInteracting.value = readBool();
         break;
       case MMOResponse.Npc_Talk:
         game.npcText.value = readString();
         final length = readByte();
         final options = game.npcOptions;
         options.clear();
         for (var i = 0; i < length; i++){
           options.add(readString());
         }
         game.npcOptionsReads.value++;
         break;
       case MMOResponse.Player_Item_Length:
         game.setItemLength(readUInt16());
         break;
       case MMOResponse.Player_Item:
         final index = readUInt16();
         final type = readInt16();
         final item = type != -1 ? MMOItem.values[type] : null;
         game.setItem(index: index, item: item);
         break;
       case MMOResponse.Player_Weapon:
         final index = readUInt16();
         final type = readInt16();
         final item = type != -1 ? MMOItem.values[type] : null;
         game.setWeapon(index: index, item: item);
         break;
       case MMOResponse.Player_Treasure:
         final index = readUInt16();
         final type = readInt16();
         final item = type != -1 ? MMOItem.values[type] : null;
         game.setTreasure(index: index, item: item);
         break;
       case MMOResponse.Player_Equipped_Weapon_Index:
         game.equippedWeaponIndex.value = readInt16();
         break;
       case MMOResponse.Player_Equipped:
         game.equippedHead.value = readMMOItem();
         game.equippedBody.value = readMMOItem();
         game.equippedLegs.value = readMMOItem();
         break;
       case MMOResponse.Player_Experience:
         game.playerExperience.value = readUInt24();
         break;
       case MMOResponse.Player_Experience_Required:
         game.playerExperienceRequired.value = readUInt24();
         break;
       case MMOResponse.Player_Level:
         game.playerLevel.value = readByte();
         break;
       case MMOResponse.Player_SkillPoints:
         game.playerSkillPoints.value = readByte();
         break;
       case MMOResponse.Player_Skills_Dialog_Open:
         game.playerSkillsDialogOpen.value = readBool();
         break;
       case MMOResponse.Player_Inventory_Open:
         game.playerInventoryOpen.value = readBool();
         break;
       case MMOResponse.Player_Talents:
         final playerTalents = game.playerTalents;
         for (var i = 0; i < playerTalents.length; i++){
          playerTalents[i] = readBool();
         }
         game.playerTalentsChangedNotifier.value++;
         break;
       case MMOResponse.Activated_Power_Index:
         game.activatedPowerIndex.value = readInt8();
         break;
     }
  }

  MMOItem? readMMOItem(){
    final mmoItemIndex = readInt16();
    return mmoItemIndex == -1 ? null : MMOItem.values[mmoItemIndex];
  }
}