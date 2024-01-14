
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';
import 'package:amulet_flutter/amulet/amulet_ui.dart';
import 'package:amulet_flutter/amulet/classes/item_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../gamestream/isometric/src.dart';
import 'amulet_render.dart';
import 'classes/map_location.dart';


class Amulet extends IsometricGame {

  final screenColor = Watch(Colors.transparent);
  final screenColorI = Watch(0.0);
  final cursor = Watch(SystemMouseCursors.basic);
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

  final activeSlotType = Watch<SlotType?>(null);
  final worldMapLarge = WatchBool(false);
  final amuletScene = Watch<AmuletScene?>(null);
  final questMain = Watch(QuestMain.Speak_With_Warren);
  final windowVisibleQuests = WatchBool(true);
  final elementPoints = Watch(0);
  late final elementFire = Watch(0, onChanged: elementsChangedNotifier);
  late final elementWater = Watch(0, onChanged: elementsChangedNotifier);
  late final elementElectricity = Watch(0, onChanged: elementsChangedNotifier);
  late final elementStone = Watch(0, onChanged: elementsChangedNotifier);
  final elementsChangedNotifier = Watch(0);

  final elementPointsAvailable = Watch(false);

  late final AmuletUI amuletUI;

  final dragging = Watch<ItemSlot?>(null);
  final emptyItemSlot = buildText('-');

  final highlightedAmuletItem = Watch<AmuletItem?>(null);

  ItemSlot? get activeAmuletItemSlot {
    switch (activeSlotType.value){
      case SlotType.Helm:
        return equippedHelm;
      case SlotType.Body:
        return equippedBody;
      case SlotType.Shoes:
        return equippedShoes;
      case SlotType.Legs:
        return equippedLegs;
      case SlotType.Hand_Left:
        return equippedHandLeft;
      case SlotType.Hand_Right:
        return equippedHandRight;
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
  var items = Watch(<ItemSlot>[]);

  final messages = <String>[];
  final messageIndex = Watch(-1);
  final itemHover = Watch<AmuletItem?>(null);
  final activePowerPosition = Position();
  // final weapons = List<ItemSlot>.generate(4, (index) => ItemSlot(index: index, slotType: SlotType.Weapons));
  final treasures = List<ItemSlot>.generate(4, (index) => ItemSlot(index: index, slotType: SlotType.Treasure));
  final error = Watch('');
  final playerInteracting = Watch(false);
  final npcTextIndex = Watch(-1);
  final npcText = <String>[];
  final npcName = Watch('');
  final npcOptions = <String>[];
  final npcOptionsReads = Watch(0);
  final equippedWeaponIndex = Watch(-1);
  final equippedWeapon = ItemSlot(slotType: SlotType.Weapon);
  final equippedHelm = ItemSlot(slotType: SlotType.Helm);
  final equippedBody = ItemSlot(slotType: SlotType.Body);
  final equippedLegs = ItemSlot(slotType: SlotType.Legs);
  final equippedHandLeft = ItemSlot(slotType: SlotType.Hand_Left);
  final equippedHandRight = ItemSlot(slotType: SlotType.Hand_Right);
  final equippedShoes = ItemSlot(slotType: SlotType.Shoes);
  final playerLevel = Watch(0);
  final playerExperience = Watch(0);
  final playerExperienceRequired = Watch(0);
  final playerInventoryOpen = Watch(false);

  late final aimTargetElementWater = Watch(0);
  late final aimTargetElementFire = Watch(0);
  late final aimTargetElementAir = Watch(0);
  late final aimTargetElementStone = Watch(0);
  late final aimTargetElement = Watch(AmuletElement.stone);
  late final aimTargetFiendType = Watch<FiendType?>(null);

  Amulet(){
    print('MmoGame()');
    playerInventoryOpen.onChanged(onChangedPlayerInventoryOpen);
    playerInteracting.onChanged(onChangedPlayerInteracting);
    npcTextIndex.onChanged(onChangedNpcTextIndex);
    error.onChanged(onChangedError);
    elementPoints.onChanged(onChangedElementPoints);

    screenColorI.onChanged((t) {
      screenColor.value = Colors.black.withOpacity((1.0 - t).clamp(0, 1.0));
    });

  }

  void onChangedElementPoints(int elementPoints) =>
      elementPointsAvailable.value = elementPoints > 0;

  @override
  void onComponentReady() {
    amuletUI = AmuletUI(this);
  }

  void onChangedError(String value){
    if (value.isEmpty)
      return;

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

  // void setWeapon({
  //   required int index,
  //   required AmuletItem? item,
  //   required double cooldownPercentage,
  //   required int charges,
  //   required int max,
  // }){
  //   final slot = weapons[index];
  //   slot.amuletItem.value = item;
  //   slot.cooldownPercentage.value = cooldownPercentage;
  //   slot.charges.value = charges;
  //   slot.max.value = max;
  // }

  void setTreasure({required int index, required AmuletItem? item}){
    treasures[index].amuletItem.value = item;
  }

  void setItem({required int index, required AmuletItem? item}){
    items.value[index].amuletItem.value = item;
  }

  void setItemLength(int length){
    items.value = List.generate(length, (index) => ItemSlot(
        index: index,
        slotType: SlotType.Item,
    ));
  }

  @override
  Widget customBuildUI(BuildContext context) => amuletUI.buildAmuletUI();

  @override
  void onKeyPressed(PhysicalKeyboardKey key) {
    super.onKeyPressed(key);

    if (options.editing)
      return;

    // if (key == PhysicalKeyboardKey.keyQ){
    //   amulet.toggleInventoryOpen();
    //   return;
    // }

    if (key == PhysicalKeyboardKey.keyA) {
      selectSlotType(SlotType.Weapon);
      return;
    }
    if (key == PhysicalKeyboardKey.keyS) {
      selectSlotType(SlotType.Helm);
      return;
    }
    if (key == PhysicalKeyboardKey.keyD) {
      selectSlotType(SlotType.Body);
      return;
    }
    if (key == PhysicalKeyboardKey.keyF) {
      selectSlotType(SlotType.Shoes);
      return;
    }
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

  void clearItemHover() => itemHover.value = null;

  void onChangedPlayerInventoryOpen(bool value) {
    audio.click_sound_8.play();
    if (!value){
      clearItemHover();
    }
  }

  void reportItemSlotDragged({
    required ItemSlot src,
    required ItemSlot target,
  }) =>
    server.sendNetworkRequest(
      NetworkRequest.Inventory_Request,
      '${NetworkRequestInventory.Move.index} '
      '${src.slotType.index} '
      '${src.index} '
      '${target.slotType.index} '
      '${target.index}'
    );

  void useItemSlot(ItemSlot itemSlot) =>
    server.sendNetworkRequest(
      NetworkRequest.Inventory_Request,
      '${NetworkRequestInventory.Use.index} '
      '${itemSlot.slotType.index} '
      '${itemSlot.index}'
    );

  void dropItemSlot(ItemSlot itemSlot) =>
    server.sendNetworkRequest(
      NetworkRequest.Inventory_Request,
      '${NetworkRequestInventory.Drop.index} '
      '${itemSlot.slotType.index} '
      '${itemSlot.index}'
    );

  void selectSlotType(SlotType slotType) =>
      sendAmuletRequest(NetworkRequestAmulet.Select_Item_Type, slotType.index);

  void selectItem(int index) =>
      sendAmuletRequest(NetworkRequestAmulet.Select_Item, index);

  void selectTreasure(int index) =>
      sendAmuletRequest(NetworkRequestAmulet.Select_Treasure, index);

  void spawnRandomEnemy() =>
      server.sendNetworkRequestAmulet(
        NetworkRequestAmulet.Spawn_Random_Enemy,
      );

  Watch<int> getAmuletElementWatch(AmuletElement amuletElement) =>
      switch (amuletElement) {
        AmuletElement.fire => elementFire,
        AmuletElement.water => elementWater,
        AmuletElement.air => elementElectricity,
        AmuletElement.stone => elementStone,
      };

  void upgradeAmuletElement(AmuletElement amuletElement) =>
      server.sendNetworkRequestAmulet(
        NetworkRequestAmulet.Upgrade_Element,
        amuletElement.index,
      );

  void requestAcquireAmuletItem(AmuletItem amuletItem) {
    server.sendNetworkRequestAmulet(
      NetworkRequestAmulet.Acquire_Amulet_Item,
      '--index ${amuletItem.index}',
    );
  }

  // int getAmuletPlayerItemLevel(AmuletItem amuletItem) =>
  //     amuletItem.getLevel(
  //       fire: elementFire.value,
  //       water: elementWater.value,
  //       electricity: elementElectricity.value,
  //   );

  void toggleInventoryOpen() =>
      server.sendNetworkRequest(
          NetworkRequest.Amulet,
          NetworkRequestAmulet.Toggle_Inventory_Open.index,
      );

  void setInventoryOpen(bool value) =>
      server.sendNetworkRequest(
          NetworkRequest.Amulet,
          '--inventory',
          value
      );

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
    clearEquippedWeapon();
    clearDragging();
    // clearActivatedPowerIndex();
  }

  void clearDragging() => dragging.value = null;

  void clearEquippedWeapon() => equippedWeaponIndex.value = -1;

  void clearHighlightAmuletItem(){
    highlightedAmuletItem.value = null;
  }

  void requestGainLevel() =>
      server.sendNetworkRequest(
          NetworkRequest.Amulet,
          NetworkRequestAmulet.Gain_Level.index,
      );

  void requestGainExperience() =>
      server.sendNetworkRequest(
          NetworkRequest.Amulet,
          NetworkRequestAmulet.Gain_Experience.index,
      );

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

  void onPlayerLevelGained() {
    audio.buff_10.play();
  }

  void onPlayerElementUpgraded() {
    audio.buff_1.play();
  }

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

  void sendAmuletRequest(NetworkRequestAmulet request, [dynamic message]) =>
      server.sendNetworkRequest(
          NetworkRequest.Amulet,
          '${request.index} $message'
      );
}