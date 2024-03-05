
import 'dart:typed_data';

import 'package:amulet_engine/src.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_parser.dart';
import 'package:lemon_byte/src.dart';
import 'package:lemon_lang/src.dart';

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
       case NetworkResponseAmulet.Player_Skill_Slots:
         readPlayerSkillSlots();
         break;
       case NetworkResponseAmulet.Player_Skill_Slot_Index:
         readPlayerSkillSlotIndex();
         break;
       case NetworkResponseAmulet.Player_Skill_Types:
         readPlayerSkillTypes();
         break;
       // case NetworkResponseAmulet.Player_Active_Slot_Type:
       //   readPlayerActiveSlotType();
       //   break;
       case NetworkResponseAmulet.Player_Skills_Left_Right:
         readPlayerSkillsLeftRight();
         break;
       case NetworkResponseAmulet.Player_Equipped:
         readPlayerEquipped();
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
       case NetworkResponseAmulet.Player_Skill_Active_Left:
         readPlayerSkillActiveLeft();
         break;
       case NetworkResponseAmulet.Player_Debug_Enabled:
         readPlayerDebugEnabled();
         break;
       case NetworkResponseAmulet.World_Map_Locations:
         readWorldMapLocations();
         break;
       case NetworkResponseAmulet.Quest_Main:
         readQuestMain();
         break;
       case NetworkResponseAmulet.Debug:
         readNetworkResponseAmuletDebug();
         break;
       case NetworkResponseAmulet.Collectable_Amulet_Item_Object:
         readCollectableAmuletItemObject();
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
       case NetworkResponseAmulet.Player_Consumable_Slots:
         readPlayerConsumableSlots();
         break;
       case NetworkResponseAmulet.Perform_Frame_Velocity:
         readPlayerPerformFrameVelocity();
         break;
       case NetworkResponseAmulet.Amulet_Item_Consumed:
         readAmuletItemConsumed();
         break;
       case NetworkResponseAmulet.Amulet_Item_Dropped:
         readAmuletItemDropped();
         break;
       case NetworkResponseAmulet.Amulet_Item_Equipped:
         readAmuletItemEquipped();
         break;
       case NetworkResponseAmulet.Player_Weapon_Range:
         readPlayerWeaponRange();
         break;
       case NetworkResponseAmulet.Player_Weapon_Attack_Speed:
         readPlayerWeaponAttackSpeed();
         break;
       case NetworkResponseAmulet.Player_Critical_Hit_Points:
         readPlayerCriticalHitPoints();
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
     }
  }

  void readPlayerEquipped() {
    amulet.equippedWeapon.value = tryReadAmuletItemObject();
    amulet.equippedHelm.value = tryReadAmuletItemObject();
    amulet.equippedArmor.value = tryReadAmuletItemObject();
    amulet.equippedShoes.value = tryReadAmuletItemObject();
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

  void readCollectableAmuletItemObject() =>
      amulet.aimTargetAmuletItemObject.value = tryReadAmuletItemObject();

  AmuletItem? tryReadAmuletItem() => AmuletItem.values.tryGet(readInt16());

  AmuletItemObject? tryReadAmuletItemObject() {

    if (!readBool()){
      return null;
    }

    final amuletItem = readAmuletItem();

    final totalEntries = readByte();
    final skillTypePoints = <SkillType, int> {

    };

    for (var i = 0; i < totalEntries; i++){
      final skillType = readSkillType();
      final skillPoints = readUInt16();
      skillTypePoints[skillType] = skillPoints;
    }

    double? damage;

    if (readBool()){
      damage = readDecimal();
    }

    final level = tryReadUInt16();
    final itemQualityIndex = tryReadByte();

    return AmuletItemObject(
        amuletItem: amuletItem,
        skillPoints: skillTypePoints,
        damage: damage,
        level: level,
        itemQuality: ItemQuality.values.tryGet(itemQualityIndex),
    );
  }

  AmuletItem readAmuletItem() => AmuletItem.values[readUInt16()];

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

    for (var i = 0; i < SkillType.values.length; i++) {
      final skillType = readSkillType();
       amulet.playerSkillTypeLevels[skillType] = readUInt16();
    }
    amulet.playerSkillTypeLevelNotifier.value++;
  }

  void readFiendCount() {
    amulet.fiendCountAlive.value = readUInt16();
    amulet.fiendCountDead.value = readUInt16();
  }

  void readPlayerPerformFrameVelocity() =>
      amulet.playerPerformFrameVelocity.value = readUInt16() / 1000;

  void readPlayerWeaponRange() =>
      amulet.playerWeaponRange.value = tryReadByte();

  void readPlayerWeaponAttackSpeed() =>
      amulet.playerWeaponAttackSpeed.value = readBool() ? readByte() : null;

  void readPlayerCriticalHitPoints() =>
      amulet.playerCriticalHitPoints.value = readByte();

  void readPlayerSkillActiveLeft() =>
      amulet.playerSkillActiveLeft.value = readBool();

  void readNetworkResponseAmuletDebug() {
     final debugLines = amulet.debugLines;
     var i = 0;
     while (readBool()) {
       debugLines[i++] = readInt16();
       debugLines[i++] = readInt16();
       debugLines[i++] = readInt16();
       debugLines[i++] = readInt16();
       debugLines[i++] = readInt16();
       debugLines[i++] = readInt16();
     }
     amulet.debugLinesTotal = i ~/ 6;
  }

  void readPlayerDebugEnabled() =>
      amulet.playerDebugEnabled.value = readBool();

  void readPlayerSkillSlots() {
     amulet.skillSlot0.value = readSkillType();
     amulet.skillSlot1.value = readSkillType();
     amulet.skillSlot2.value = readSkillType();
     amulet.skillSlot3.value = readSkillType();
     amulet.skillSlotsChangedNotifier.value++;
  }

  void readPlayerSkillSlotIndex() =>
      amulet.playerSkillSlotIndex.value = readByte();

  void readPlayerConsumableSlots() {
      for (var i = 0; i < 4; i++){
        final amuletItemIndex = readInt16();
        amulet.consumableSlots[i].value = AmuletItem.values.tryGet(amuletItemIndex);
      }
  }

  void readAmuletItemConsumed() {
    final amuletItem = tryReadAmuletItem();
    if (amuletItem == null){
      return;
    }
    amulet.onAmuletItemConsumed(amuletItem);
  }

  void readAmuletItemDropped() {
    final amuletItem = tryReadAmuletItem();

    if (amuletItem != null){
      amulet.onAmuletItemDropped(amuletItem);
    }
  }

  void readAmuletItemEquipped() {
    final amuletItem = tryReadAmuletItem();

    if (amuletItem != null){
      amulet.onAmuletItemEquipped(amuletItem);
    }
  }

  double readDecimal() => readUInt16() / 10;

  int? tryReadByte() => tryRead(readByte);

  int? tryReadUInt16() => tryRead(readUInt16);

  T? tryRead<T>(T Function() read) => readBool() ? read() : null;
}
