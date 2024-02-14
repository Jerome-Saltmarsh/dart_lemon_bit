
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';
import 'package:amulet_flutter/amulet/amulet_ui.dart';
import 'package:amulet_flutter/amulet/classes/item_slot.dart';
import 'package:amulet_flutter/amulet/ui/enums/quantify_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../gamestream/isometric/src.dart';
import 'amulet_render.dart';
import 'classes/map_location.dart';
import 'classes/skill_type_stats.dart';

class Characteristics {
  final sword = Watch(0);
  final staff = Watch(0);
  final bow = Watch(0);
  final caste = Watch(0);
}

class Amulet extends IsometricGame {

  final screenColor = Watch(Colors.transparent);
  final screenColorI = Watch(0.0);
  final cursor = Watch(SystemMouseCursors.basic);
  final fiendCountAlive = Watch(0);
  final fiendCountDead = Watch(0);
  final fiendCountTotal = Watch(0);
  final fiendCountPercentage = Watch(0.0);
  final flaskPercentage = Watch(0.0);
  final playerPerformFrameVelocity = Watch(0.0);

  var worldMapClrs = Int32List(0);
  var worldMapDsts = Float32List(0);
  var worldMapSrcs = Float32List(0);

  var worldRow = 0;
  var worldColumn = 0;

  var worldRows = 0;
  var worldColumns = 0;
  var worldFlatMaps = <Uint8List>[];
  final worldLocations = <MapLocation>[];
  ui.Image? worldMapPicture;

  var playerWorldX = 0.0;
  var playerWorldY = 0.0;

  final playerMastery = Characteristics();
  final playerMagic = Watch(0);
  final playerMagicMax = Watch(0);
  final playerMagicPercentage = Watch(0.0);
  final playerHealthSteal = Watch(0);
  final playerMagicSteal = Watch(0);
  final playerAreaOfEffectDamage = Watch(0);

  final playerRegenMagic = Watch(0);
  final playerRegenHealth = Watch(0);

  final playerWeaponDamageMin = Watch(0);
  final playerWeaponDamageMax = Watch(0);
  final playerWeaponRange = Watch<int?>(0);
  final playerWeaponAttackSpeed = Watch<int?>(0);

  final playerSkillLeft = Watch(SkillType.Strike);
  final playerSkillRight = Watch(SkillType.Strike);
  final windowVisibleSkillLeft = WatchBool(false);
  final windowVisibleSkillRight = WatchBool(false);
  final windowVisibleQuantify = WatchBool(false);
  final windowQuantifyTab = Watch(QuantifyTab.values.first);
  // final windowVisibleQuantifyAmuletItems = WatchBool(false);
  // final windowVisibleQuantifyFiendTypes = WatchBool(false);

  final playerRunSpeed = Watch(0);
  final playerAgility = Watch(0);

  final activeSlotType = Watch<SlotType?>(null);
  final worldMapLarge = WatchBool(false);
  final amuletScene = Watch<AmuletScene?>(null);
  final questMain = Watch(QuestMain.values.first);
  final windowVisibleQuests = WatchBool(true);
  final windowVisiblePlayerStats = WatchBool(true);
  final windowVisibleHelp = WatchBool(false);

  late final AmuletUI amuletUI;

  final dragging = Watch<ItemSlot?>(null);
  final emptyItemSlot = buildText('-');

  final aimTargetItemType = Watch<AmuletItem?>(null);
  final aimTargetItemTypeCurrent = Watch<AmuletItem?>(null);
  final highlightedAmuletItem = Watch<AmuletItem?>(null);
  final playerSkillTypeStatsNotifier = Watch(0);
  final playerSkillTypeStats = SkillType.values.map((skillType) =>
      SkillTypeStats(skillType: skillType)
  ).toList(growable: false);

  void onChangedPlayerSkillType(SkillType skillType){
    audio.click_sounds_35.play();
  }

  Watch<AmuletItem?>? get activeAmuletItemSlot {
    switch (activeSlotType.value){
      case SlotType.Helm:
        return equippedHelm;
      case SlotType.Armor:
        return equippedArmor;
      case SlotType.Shoes:
        return equippedShoes;
      default:
        return null;
    }
  }

  final slotContainerDefault = Container(
    color: Colors.black12,
    alignment: Alignment.center,
    margin: const EdgeInsets.all(2),
    width: 64,
    height: 64,
  );

  final slotContainerDragTarget = Container(
    color: Colors.green.withOpacity(0.5),
    alignment: Alignment.center,
    margin: const EdgeInsets.all(2),
    width: 64,
    height: 64,
  );

  var errorTimer = 0;
  final messages = <String>[];
  final messageIndex = Watch(-1);
  final activePowerPosition = Position();
  final error = Watch('');
  final playerInteracting = Watch(false);
  final npcTextIndex = Watch(-1);
  final npcText = <String>[];
  final npcName = Watch('');
  final npcOptions = <String>[];
  final npcOptionsReads = Watch(0);
  final equippedWeapon = Watch<AmuletItem?>(null);
  final equippedHelm = Watch<AmuletItem?>(null);
  final equippedArmor = Watch<AmuletItem?>(null);
  final equippedShoes =  Watch<AmuletItem?>(null);

  late final aimTargetFiendType = Watch<FiendType?>(null);

  Amulet(){
    print('Amulet()');

    screenColorI.onChanged((t) {
      screenColor.value = Colors.black.withOpacity((1.0 - t).clamp(0, 1.0));
    });

    aimTargetItemType.onChanged((itemType) {
      // aimTargetItemTypeCurrent.value = getEquippedItemSlot(itemType?.type)?.amuletItem.value;
    });

    fiendCountAlive.onChanged((t) {
      updateFiendCountTotal();
      updateFiendCountPercentage();
    });
    fiendCountDead.onChanged((t) {
      updateFiendCountTotal();
      updateFiendCountPercentage();
    });

    playerInteracting.onChanged(onChangedPlayerInteracting);
    npcTextIndex.onChanged(onChangedNpcTextIndex);
    error.onChanged(onChangedError);
    playerMagic.onChanged(refreshPlayerMagicPercentage);
    playerMagicMax.onChanged(refreshPlayerMagicPercentage);
    playerSkillLeft.onChanged(onChangedPlayerSkillType);
    playerSkillRight.onChanged(onChangedPlayerSkillType);

    verifySrcs();
  }

  void verifySrcs(){
     for (final amuletItem in AmuletItem.values){
       if (atlasSrcAmuletItem.containsKey(amuletItem)) continue;
       print('verification_warning: atlasSrcAmuletItem[${amuletItem.name}]');
     }
  }

  void updateFiendCountTotal(){
    fiendCountTotal.value = fiendCountAlive.value + fiendCountDead.value;
  }

  void updateFiendCountPercentage() {
    final total = fiendCountTotal.value;
    if (total == 0){
      fiendCountPercentage.value = 1.0;
    } else {
      fiendCountPercentage.value = (fiendCountAlive.value / total).clamp(0, 1);
    }
  }

  void refreshPlayerMagicPercentage(int _){
    final value = playerMagic.value;
    final max = playerMagicMax.value;
    if (max <= 0){
      playerMagicPercentage.value = 0;
    }
    if (value >= max){
      playerMagicPercentage.value = 1;
    }
    playerMagicPercentage.value = value / max;
  }

  @override
  void onComponentReady() {
    amuletUI = AmuletUI(this);
  }

  void onChangedError(String value){
    if (value.isEmpty)
      return;

    print(value);
    audio.errorSound15.play();
    errorTimer = 70;
  }

  var cameraZoom = 0;

  @override
  void update() {
    super.update();

    if (errorTimer > 0) {
      errorTimer--;
      if (errorTimer <= 0){
        clearError();
      }
    }

    if (screenColorI.value < 1){
      screenColorI.value += 0.15;
    }
  }

  void clearError() {
    error.value = '';
  }

  @override
  Widget customBuildUI(BuildContext context) => amuletUI.buildAmuletUI();

  @override
  void onKeyPressed(PhysicalKeyboardKey key) {
    super.onKeyPressed(key);

    if (options.editing)
      return;

    if (key == PhysicalKeyboardKey.keyQ) {
      amulet.windowVisiblePlayerStats.toggle();
      return;
    }

    if (key == PhysicalKeyboardKey.keyW) {
      amulet.windowVisibleQuests.toggle();
      return;
    }

    if (key == PhysicalKeyboardKey.keyH) {
      amulet.windowVisibleHelp.toggle();
      return;
    }

    if (key == PhysicalKeyboardKey.space) {
      amulet.useFlask();
      return;
    }

    if (key == PhysicalKeyboardKey.keyA) {
      selectSlotType(SlotType.Weapon);
      return;
    }
    if (key == PhysicalKeyboardKey.keyS) {
      selectSlotType(SlotType.Helm);
      return;
    }
    if (key == PhysicalKeyboardKey.keyD) {
      selectSlotType(SlotType.Armor);
      return;
    }
    if (key == PhysicalKeyboardKey.keyF) {
      selectSlotType(SlotType.Shoes);
      return;
    }

    if (options.developMode){
      if (key == PhysicalKeyboardKey.digit9) {
        amulet.sendAmuletRequest(NetworkRequestAmulet.Refill_Player_Health_Magic);
        return;
      }
    }

    // if (key == PhysicalKeyboardKey.space) {
    //   options.toggleRenderHealthBars();
    //   return;
    // }
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);
    renderAmulet(canvas, size);
  }

  @override
  void onMouseExit() {

  }

  @override
  void onMouseEnter() => clearItemHover();

  void onAnyChanged(int value) => clearItemHover();

  void clearItemHover() => aimTargetItemTypeCurrent.value = null;

  void onChangedPlayerInventoryOpen(bool value) {
    audio.click_sound_8.play();
    if (!value){
      clearItemHover();
    }
  }

  void dropItemTypeWeapon() =>
      dropItemType(ItemType.Weapon);

  void dropAmuletItem(AmuletItem amuletItem) =>
      dropItemType(amuletItem.type);

  void dropItemType(int value) =>
      server.sendNetworkRequestAmulet(
        NetworkRequestAmulet.Drop_Item_Type,
        value,
      );

  void selectSlotType(SlotType slotType) =>
      sendAmuletRequest(NetworkRequestAmulet.Select_Slot_Type, slotType.index);

  void spawnRandomEnemy() =>
      server.sendNetworkRequestAmulet(
        NetworkRequestAmulet.Spawn_Random_Enemy,
      );

  void requestAcquireAmuletItem(AmuletItem amuletItem) {
    server.sendNetworkRequestAmulet(
      NetworkRequestAmulet.Acquire_Amulet_Item,
      '--index ${amuletItem.index}',
    );
  }

  void messageNext(){
    if (messageIndex.value + 1 >= messages.length){
      clearMessage();
    } else {
      messageIndex.value++;
    }
  }

  void clearMessage() {
    messageIndex.value = -1;
    messages.clear();
  }

  void nextNpcText(){
    npcTextIndex.value++;
  }

  void endInteraction() {
    server.sendNetworkRequest(
        NetworkRequest.Amulet,
        NetworkRequestAmulet.End_Interaction.index,
    );
  }

  void onChangedPlayerInteracting(bool interacting) {
    if (interacting) return;
    npcOptions.clear();
    npcText.clear();
    npcTextIndex.value = -1;
    npcOptionsReads.value++;
  }

  void onChangedNpcTextIndex(int value) {
    if (value >= npcText.length) {
      endInteraction();
    } else {
      audio.click_sounds_35.play();
    }
  }

  void clearAllState() {
    print('amulet.clearAllState()');
    scene.clearVisited();
    scene.totalNodes = 0;
    scene.totalCharacters = 0;
    scene.totalProjectiles = 0;
    scene.characters.clear();
    scene.gameObjects.clear();
    scene.projectiles.clear();
    scene.colorStackIndex = -1;
    scene.ambientStackIndex = -1;
    scene.editEnabled.value = false;
    scene.nodeVisibility.fillRange(0, scene.nodeVisibility.length, NodeVisibility.opaque);
    particles.activated.clear();
    particles.deactivated.clear();
    amuletScene.value = null;
    io.reset();
    audio.enabledSound.value = false;
    player.active.value = false;
    player.position.x = 0;
    player.position.y = 0;
    player.position.z = 0;
    player.gameDialog.value = null;
    engine.cameraX = 0.0;
    engine.cameraY = 0.0;
    engine.zoom = 1.0;
    engine.drawCanvasAfterUpdate = true;
    engine.cursorType.value = CursorType.Basic;
    clearDragging();
  }

  void clearDragging() => dragging.value = null;

  void clearHighlightAmuletItem(){
    highlightedAmuletItem.value = null;
  }

  void requestSkipTutorial() =>
      server.sendNetworkRequest(
          NetworkRequest.Amulet,
          NetworkRequestAmulet.Skip_Tutorial.index,
      );

  void requestReset() =>
      server.sendNetworkRequest(
          NetworkRequest.Amulet,
          NetworkRequestAmulet.Reset.index,
      );

  void buildWorldMapSrcAndDst(){
    print('amulet.buildWorldMapSrcAndDst()');
    var index = 0;
    final size = 100;
    final area = size * size;
    final worldRows = this.worldRows;
    final worldColumns = this.worldColumns;
    final worldFlatMaps = this.worldFlatMaps;
    final total = worldFlatMaps.length * area;

    final clrs = Int32List(total);
    final dsts = Float32List(total * 4);
    final srcs = Float32List(total * 4);

    worldMapClrs = clrs;
    worldMapDsts = dsts;
    worldMapSrcs = srcs;

    var i = 0;
    for (var worldRow = 0; worldRow < worldRows; worldRow++) {
      for (var worldColumn = 0; worldColumn < worldColumns; worldColumn++) {
        final worldFlatMap = worldFlatMaps[index];

        for (var nodeIndex = 0; nodeIndex < area; nodeIndex++) {
          final nodeType = worldFlatMap[nodeIndex];
          final nodeRow = nodeIndex ~/ size;
          final nodeColumn = nodeIndex % size;
          final x = (worldRow * size) + nodeRow;
          final y = (worldColumn * size) + nodeColumn;
          final f = i * 4;

          clrs[i] = mapNodeTypeToColor(nodeType).value;

          srcs[f + 0] = 96; // left
          srcs[f + 1] = 0; // top
          srcs[f + 2] = 97; // right
          srcs[f + 3] = 1; // bottom

          dsts[f + 0] = 1.0; // scale
          dsts[f + 1] = 0; // rotation
          dsts[f + 2] = x.toDouble();
          dsts[f + 3] = y.toDouble();

          i++;
        }

        index++;
      }
    }

    onWorldMapChanged();
  }

  late final colorMap = {
    NodeType.Water: colors.blue_2,
    NodeType.Grass: colors.sage_2,
    NodeType.Brick: colors.grey_2,
    NodeType.Cobblestone: colors.brown_3,
    NodeType.Tree_Top: colors.sage_3,
    NodeType.Wood: colors.brown_3,
    NodeType.Soil: colors.brown_2,
  };

  Color mapNodeTypeToColor(int nodeType){
    return colorMap[nodeType] ?? Colors.black;
  }

  void recordWorldMapPicture(){
    print('amulet.recordWorldMapPicture()');
    final paint = Paint()..color = Colors.white;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRawAtlas(
      images.shades,
      worldMapDsts,
      worldMapSrcs,
      worldMapClrs,
      BlendMode.modulate,
      null,
      paint,
    );

     final picture = recorder.endRecording();
     picture
         .toImage(
            (300).toInt(),
            (300).toInt(),
          )
         .then((value) {
            worldMapPicture = value;
         });
  }

  void onWorldMapChanged() {
    print('amulet.onWorldMapChanged()');
    recordWorldMapPicture();
  }

  void selectTalkOption(int index) =>
      sendAmuletRequest(NetworkRequestAmulet.Select_Talk_Option, index);

  void selectSkillTypeLeft(SkillType value) =>
      sendAmuletRequest(
          NetworkRequestAmulet.Select_Skill_Type_Left,
          value.index,
      );

  void selectSkillTypeRight(SkillType value) =>
      sendAmuletRequest(
          NetworkRequestAmulet.Select_Skill_Type_Right,
          value.index,
      );

  void sendAmuletRequest(NetworkRequestAmulet request, [dynamic message]) =>
      server.sendNetworkRequest(
          NetworkRequest.Amulet,
          '${request.index} $message'
      );

  void onAmuletEvent({
    required double x,
    required double y,
    required double z,
    required int amuletEvent,
  }) {

  }

  AmuletItem? getEquippedItemType(int itemType) =>
      switch (itemType) {
          ItemType.Weapon => equippedWeapon.value,
          ItemType.Helm => equippedHelm.value,
          ItemType.Armor => equippedArmor.value,
          ItemType.Shoes => equippedShoes.value,
          _ => throw Exception('amulet.getEquippedItemType(itemType: $itemType)')
      };

  void useFlask() =>
      server.sendNetworkRequestAmulet(
        NetworkRequestAmulet.Use_Flask
      );
}


