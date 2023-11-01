
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_parser.dart';

extension AmuletParser on IsometricParser {

  static final _regex = RegExp(r'[.!]');

  void readNetworkResponseAmulet(){
     final amulet = this.amulet;
     switch (readByte()){
       case NetworkResponseAmulet.Player_Interacting:
         amulet.playerInteracting.value = readBool();
         break;
       case NetworkResponseAmulet.Npc_Talk:
         amulet.npcText.clear();
         amulet.npcName.value = readString();
         final texts = readString().split(_regex).map((e) => e.trim()).toList(growable: true);
         texts.removeWhere((element) => element.isEmpty);
         amulet.npcText.addAll(texts);
         amulet.npcTextIndex.value = -1;
         amulet.npcTextIndex.value = 0;
         final length = readByte();
         final options = amulet.npcOptions;
         options.clear();
         for (var i = 0; i < length; i++){
           options.add(readString());
         }
         amulet.npcOptionsReads.value++;
         break;
       case NetworkResponseAmulet.Player_Item_Length:
         amulet.setItemLength(readUInt16());
         break;
       case NetworkResponseAmulet.Player_Item:
         final index = readUInt16();
         final type = readInt16();
         final item = type != -1 ? AmuletItem.values[type] : null;
         amulet.setItem(index: index, item: item);
         break;
       case NetworkResponseAmulet.Player_Weapon:
         readPlayerWeapon();
         break;
       case NetworkResponseAmulet.Player_Treasure:
         final index = readUInt16();
         final type = readInt16();
         final item = type != -1 ? AmuletItem.values[type] : null;
         amulet.setTreasure(index: index, item: item);
         break;
       case NetworkResponseAmulet.Player_Equipped_Weapon_Index:
         amulet.equippedWeaponIndex.value = readInt16();
         break;
       case NetworkResponseAmulet.Player_Equipped:
         amulet.equippedHelm.amuletItem.value = readMMOItem();
         amulet.equippedBody.amuletItem.value = readMMOItem();
         amulet.equippedLegs.amuletItem.value = readMMOItem();
         amulet.equippedHandLeft.amuletItem.value = readMMOItem();
         amulet.equippedHandRight.amuletItem.value = readMMOItem();
         amulet.equippedShoes.amuletItem.value = readMMOItem();
         break;
       case NetworkResponseAmulet.Player_Experience:
         amulet.playerExperience.value = readUInt24();
         break;
       case NetworkResponseAmulet.Player_Experience_Required:
         amulet.playerExperienceRequired.value = readUInt24();
         break;
       case NetworkResponseAmulet.Player_Level:
         amulet.playerLevel.value = readByte();
         break;
       case NetworkResponseAmulet.Player_Inventory_Open:
         amulet.playerInventoryOpen.value = readBool();
         break;
       case NetworkResponseAmulet.Activated_Power_Index:
         amulet.activatedPowerIndex.value = readInt8();
         break;
       case NetworkResponseAmulet.Active_Power_Position:
         readIsometricPosition(amulet.activePowerPosition);
         break;
       case NetworkResponseAmulet.Error:
         amulet.clearError();
         amulet.error.value = readString();
         break;
       case NetworkResponseAmulet.Amulet_Scene:
         final index = readByte();
         final amuletScene = AmuletScene.values[index];
         amulet.amuletScene.value = amuletScene;
         break;
       case NetworkResponseAmulet.Play_AudioType:
         final audioTypeIndex = readByte();
         final audioType = AudioType.values[audioTypeIndex];
         onPlayAudioType(audioType);
         break;
       case NetworkResponseAmulet.Highlight_Amulet_Item:
         final amuletItemIndex = readByte();
         final amuletItem = AmuletItem.values[amuletItemIndex];
         amulet.highlightedAmuletItem.value = amuletItem;
         break;
       case NetworkResponseAmulet.Highlight_Amulet_Item_Clear:
         amulet.clearHighlightAmuletItem();
         break;
       case NetworkResponseAmulet.Player_Level_Gained:
         amulet.onPlayerLevelGained();
         break;
       case NetworkResponseAmulet.Spawn_Confetti:
         final x = readDouble();
         final y = readDouble();
         final z = readDouble();
         for (var i = 0; i < 10; i++){
           particles.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_White);
         }
         break;
     }
  }

  AmuletItem? readMMOItem(){
    final mmoItemIndex = readInt16();
    return mmoItemIndex == -1 ? null : AmuletItem.values[mmoItemIndex];
  }

  void readPlayerWeapon() {
    final index = readUInt16();
    final type = readInt16();

    if (type == -1){
      amulet.setWeapon(
        index: index,
        item: null,
        cooldownPercentage: 0,
        charges: 0,
        max: 0,
      );
      return;
    }

    final cooldownPercentage = readPercentage();
    final charges = readUInt16();
    final max = readUInt16();
    final item = AmuletItem.values[type];
    amulet.setWeapon(
      index: index,
      item: item,
      cooldownPercentage: cooldownPercentage,
      charges: charges,
      max: max,
    );
  }

  void onPlayAudioType(AudioType audioType) {
     switch (audioType){
       case AudioType.unlock_2:
         audio.unlock_2.play();
         break;
       case AudioType.magical_swoosh_18:
         audio.magical_swoosh_18.play();
         break;
     }
  }
}

