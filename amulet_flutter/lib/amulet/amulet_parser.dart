
import 'dart:typed_data';

import 'package:amulet_engine/src.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_parser.dart';

import 'classes/map_location.dart';

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
       case NetworkResponseAmulet.Player_World_Index:
         amulet.worldRow = readByte();
         amulet.worldColumn = readByte();
         break;
       case NetworkResponseAmulet.Player_Weapon:
         readPlayerWeapon();
         break;
       case NetworkResponseAmulet.Amulet_Event:
         readAmuletEvent();
         break;
       case NetworkResponseAmulet.Fiend_Count:
         readFiendCount();
         break;
       case NetworkResponseAmulet.Player_Skill_Types:
         readPlayerSkillTypes();
         break;
       case NetworkResponseAmulet.Player_Characteristics:
         readPlayerCharacteristics();
         break;
       case NetworkResponseAmulet.Player_Active_Slot_Type:
         readPlayerActiveSlotType();
         break;
       case NetworkResponseAmulet.Player_Skills_Left_Right:
         readPlayerSkillsLeftRight();
         break;
       case NetworkResponseAmulet.Player_Equipped:
         amulet.equippedWeapon.value = readAmuletItem();
         amulet.equippedHelm.value = readAmuletItem();
         amulet.equippedArmor.value = readAmuletItem();
         amulet.equippedShoes.value = readAmuletItem();
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
       case NetworkResponseAmulet.Aim_Target_Fiend_Type:
         final isFiend = readBool();

         if (isFiend){
           final fiendTypeIndex = readByte();
           amulet.aimTargetFiendType.value = FiendType.values[fiendTypeIndex];
         } else {
           amulet.aimTargetFiendType.value = null;
         }
         break;
       case NetworkResponseAmulet.Spawn_Confetti:
         final x = readDouble();
         final y = readDouble();
         final z = readDouble();
         final particles = this.particles;
         for (var i = 0; i < 10; i++){
           particles.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti);
         }
         break;
       case NetworkResponseAmulet.World_Map_Bytes:
         readWorldMapBytes();
         break;
       case NetworkResponseAmulet.World_Map_Locations:
         readWorldMapLocations();
         break;
       case NetworkResponseAmulet.Quest_Main:
         readQuestMain();
         break;
       case NetworkResponseAmulet.Aim_Target_Item_Type:
         readAimTargetItemType();
         break;
       case NetworkResponseAmulet.Player_Magic:
         readPlayerMagic();
         break;
       case NetworkResponseAmulet.Player_Regen_Magic:
         readPlayerRegenMagic();
         break;
       case NetworkResponseAmulet.Player_Regen_Health:
         readPlayerRegenHealth();
         break;
       case NetworkResponseAmulet.Player_Run_Speed:
         readPlayerRunSpeed();
         break;
       case NetworkResponseAmulet.Player_Agility:
         readPlayerAgility();
         break;
       case NetworkResponseAmulet.Perform_Frame_Velocity:
         readPlayerPerformFrameVelocity();
         break;
       case NetworkResponseAmulet.Player_Health_Steal:
         readPlayerHealthSteal();
         break;
       case NetworkResponseAmulet.Player_Magic_Steal:
         readPlayerMagicSteal();
         break;
       case NetworkResponseAmulet.Player_Weapon_Range:
         readPlayerWeaponRange();
         break;
       case NetworkResponseAmulet.Message:
         amulet.clearMessage();
         amulet.messages.addAll(readString().split('.').map((e) => e.trim()).toList(growable: false));
         amulet.messages.removeWhere((element) => element.isEmpty);
         amulet.messageIndex.value = 0;
         break;
       case NetworkResponseAmulet.End_Interaction:
         amulet.playerInteracting.value = false;
         break;
       case NetworkResponseAmulet.Camera_Target:
         readCameraTarget();
         break;
       case NetworkResponseAmulet.Flask_Percentage:
         readNetworkResponseAmuletFlashPercentage();
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
      // amulet.setWeapon(
      //   index: index,
      //   item: null,
      //   cooldownPercentage: 0,
      //   charges: 0,
      //   max: 0,
      // );
      return;
    }

    // final cooldownPercentage = readPercentage();
    // final charges = readUInt16();
    // final max = readUInt16();
    // final item = AmuletItem.values[type];
    // amulet.setWeapon(
    //   index: index,
    //   item: item,
    //   cooldownPercentage: cooldownPercentage,
    //   charges: charges,
    //   max: max,
    // );
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

  void readWorldMapBytes() {
    final worldRows = readByte();;
    final worldColumns = readByte();;
    final total = worldRows * worldColumns;
    amulet.worldRows = worldRows;
    amulet.worldColumns = worldColumns;
    final worldFlatMaps = amulet.worldFlatMaps;
    worldFlatMaps.clear();

    final compressedBytesLength = readUInt16();
    final compressedBytes = readBytes(compressedBytesLength);
    final bytesDecompressed = decoder.decodeBytes(compressedBytes);
    final byteReader = ByteReader();
    byteReader.values = bytesDecompressed;

    for (var i = 0; i < total; i++){
      final length = byteReader.readUInt24();
      final bytes = byteReader.readBytes(length);
      worldFlatMaps.add(Uint8List.fromList(bytes));
    }

    amulet.buildWorldMapSrcAndDst();
  }

  void readWorldMapLocations() {
    final locations = amulet.worldLocations;
    locations.clear();
    final compressedBytesLength = readUInt16();
    final compressedBytes = readBytes(compressedBytesLength);
    final bytesDecompressed = decoder.decodeBytes(compressedBytes);
    final byteReader = ByteReader();
    byteReader.values = bytesDecompressed;

    while (byteReader.readBool()) {
      final worldRow = byteReader.readByte();
      final worldColumn = byteReader.readByte();
      final name = byteReader.readString();
      final row = byteReader.readUInt16();
      final column = byteReader.readUInt16();
      locations.add(
          MapLocation(
            x: (worldRow * 100.0) + row,
            y: (worldColumn * 100.0) + column,
            text: name,
          )
      );
    }
  }

  void readQuestMain() =>
      amulet.questMain.value = QuestMain.values[readByte()];

  void readAimTargetItemType() =>
      amulet.aimTargetItemType.value = readBool()
          ? readAmuletItem()
          : null;

  AmuletItem? readAmuletItem() {
     final index = readInt16();
     return AmuletItem.values.tryGet(index);
  }

  void readPlayerMagic() {
    amulet.playerMagicMax.value = readUInt16();
    amulet.playerMagic.value = readUInt16();
  }

  void readPlayerRegenMagic() =>
      amulet.playerRegenMagic.value = readUInt16();

  void readPlayerRegenHealth() =>
      amulet.playerRegenHealth.value = readUInt16();

  void readPlayerRunSpeed() =>
      amulet.playerRunSpeed.value = readUInt16();

  void readPlayerAgility() =>
      amulet.playerAgility.value = readUInt16();

  void readPlayerSkillsLeftRight() {
    amulet.playerSkillLeft.value = readSkillType();
    amulet.playerSkillRight.value = readSkillType();
  }

  SkillType readSkillType() => SkillType.values[readByte()];

  void readAmuletEvent() {
    final x = readDouble();
    final y = readDouble();
    final z = readDouble();
    final amuletEvent = readByte();
    amulet.onAmuletEvent(x: x, y: y, z: z, amuletEvent: amuletEvent);
  }

  void readPlayerSkillTypes() {

    for (final skillTypeStat in amulet.playerSkillTypeStats) {
       skillTypeStat.unlocked = readBool();
       if (!skillTypeStat.unlocked){
         continue;
       }
       skillTypeStat.magicCost = readByte();
       skillTypeStat.damageMin = readUInt16();
       skillTypeStat.damageMax = readUInt16();
       skillTypeStat.range = readUInt16();
       skillTypeStat.performDuration = readUInt16();
       skillTypeStat.amount = readUInt16();
    }
    amulet.playerSkillTypeStatsNotifier.value++;
  }

  void readPlayerCharacteristics() {
     final characteristics = amulet.playerMastery;
     characteristics.sword.value = readUInt16();
     characteristics.staff.value = readUInt16();
     characteristics.bow.value = readUInt16();
  }

  void readPlayerActiveSlotType() {
    final index = readInt8();
    amulet.activeSlotType.value = SlotType.values.tryGet(index);
  }

  void readFiendCount() {
    amulet.fiendCountAlive.value = readUInt16();
    amulet.fiendCountDead.value = readUInt16();
  }

  void readNetworkResponseAmuletFlashPercentage() {
     amulet.flaskPercentage.value = readPercentage();
  }

  void readPlayerPerformFrameVelocity() {
    amulet.playerPerformFrameVelocity.value = readUInt16() / 1000;
  }

  void readPlayerHealthSteal() =>
      amulet.playerHealthSteal.value = readByte();

  void readPlayerMagicSteal() =>
      amulet.playerMagicSteal.value = readByte();

  void readPlayerWeaponRange() {
    amulet.playerWeaponRange.value = readUInt16();
  }
}
