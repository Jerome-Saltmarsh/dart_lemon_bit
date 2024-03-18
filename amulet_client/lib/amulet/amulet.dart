
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:amulet_common/src.dart';
import 'package:amulet_client/amulet/amulet_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../isometric/src.dart';
import 'amulet_render.dart';
import 'classes/map_location.dart';


class Amulet extends IsometricGame {

  SkillType? mouseOverSkillType;
  final screenColor = Watch(Colors.transparent);
  final screenColorI = Watch(0.0);
  final fiendCountAlive = Watch(0);
  final fiendCountDead = Watch(0);
  final fiendCountTotal = Watch(0);
  final fiendCountPercentage = Watch(0.0);
  final playerDebugEnabled = WatchBool(false);
  final playerPerformFrameVelocity = Watch(0.0);

  final equippableSlotTypes = const [
    SlotType.Weapon,
    SlotType.Helm,
    SlotType.Armor,
    SlotType.Shoes,
  ];

  final playerSkillSlotIndex = Watch(-1);

  var worldMapClrs = Int32List(0);
  var worldMapDsts = Float32List(0);
  var worldMapSrcs = Float32List(0);

  var debugLinesTotal = 0;
  final debugLines = Int16List(10000);

  var worldRow = 0;
  var worldColumn = 0;

  var worldRows = 0;
  var worldColumns = 0;
  var worldFlatMaps = <Uint8List>[];
  final worldLocations = <MapLocation>[];
  ui.Image? worldMapPicture;

  var playerWorldX = 0.0;
  var playerWorldY = 0.0;

  var playerMagic = 0;
  var playerMagicMax = 0;
  final playerMagicNotifier = Watch(0);
  final playerMagicPercentage = Watch(0.0);

  final playerRegenMagic = Watch(0);
  final playerRegenHealth = Watch(0);
  final playerCriticalHitPoints = Watch(0);
  final playerSkillActiveLeft = Watch(true);

  final playerWeaponDamageMin = Watch(0);
  final playerWeaponDamageMax = Watch(0);

  final playerSkillTypeLevels = Map.fromEntries(
      SkillType.values.map((skillType) => MapEntry(skillType, 0)));
  final playerSkillsNotifier = Watch(0);
  var playerSkillLeft = SkillType.None;
  var playerSkillRight = SkillType.None;
  final windowVisibleSkillLeft = WatchBool(false);
  final windowVisibleSkillRight = WatchBool(false);
  final windowVisibleQuantify = WatchBool(false);
  final playerRunSpeed = Watch(0);
  final playerAgility = Watch(0);
  final playerGold = Watch(0);

  final aimTargetAmuletItemObject = Watch<AmuletItemObject?>(null);

  final worldMapLarge = WatchBool(false);
  final amuletScene = Watch<AmuletScene?>(null);
  final questMain = Watch(QuestMain.values.first);
  final windowVisibleQuests = WatchBool(true);
  final windowVisibleInventory = WatchBool(true);
  final windowVisibleHelp = WatchBool(false);
  final amuletKeys = AmuletKeys();


  final emptyItemSlot = buildText('-');

  final aimTargetItemTypeCurrent = Watch<AmuletItem?>(null);
  final highlightedAmuletItem = Watch<AmuletItem?>(null);

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
  AmuletItemObject? equippedWeapon;
  AmuletItemObject? equippedHelm;
  AmuletItemObject? equippedArmor;
  AmuletItemObject? equippedShoes;
  final equippedChangedNotifier = Watch(0);

  ItemQuality? aimTargetItemQuality;
  var aimTargetText = '';
  String? aimTargetSubtitles;
  var aimTargetHealthPercentage = 0.0;
  int? aimTargetLevel;
  final aimTargetSet = Watch(false);
  final aimTargetNotifier = Watch(0);
  var playerCanUpgrade = false;
  final potionsHealth = Watch(0);
  final potionsMagic = Watch(0);

  Amulet() {
    print('Amulet()');

    screenColorI.onChanged((t) {
      screenColor.value = Colors.black.withOpacity((1.0 - t).clamp(0, 1.0));
    });

    playerMagicNotifier.onChanged((t) => updatePlayerMagicPercentage());

    questMain.onChanged(onChangedQuestMain);

    fiendCountAlive.onChanged((t) {
      updateFiendCountTotal();
      updateFiendCountPercentage();
    });
    fiendCountDead.onChanged((t) {
      updateFiendCountTotal();
      updateFiendCountPercentage();
    });

    windowVisibleQuests.onChanged(onWindowVisibilityChanged);
    windowVisibleHelp.onChanged(onWindowVisibilityChanged);
    windowVisibleQuantify.onChanged(onWindowVisibilityChanged);
    playerInteracting.onChanged(onChangedPlayerInteracting);
    npcTextIndex.onChanged(onChangedNpcTextIndex);
    error.onChanged(onChangedError);

    aimTargetAmuletItemObject.onChanged((t) {
      if (t != null) {
        audio.click_sounds_35();
      }
    });
  }

  void updatePlayerMagicPercentage() {
    playerMagicPercentage.value = playerMagic.percentageOf(playerMagicMax);
  }

  void onChangedQuestMain(QuestMain questMain) {
    windowVisibleQuests.setTrue();
  }

  void onWindowVisibilityChanged(bool value) {
    audio.click_sounds_35.play();
  }

  void updateFiendCountTotal() {
    fiendCountTotal.value = fiendCountAlive.value + fiendCountDead.value;
  }

  void updateFiendCountPercentage() {
    final total = fiendCountTotal.value;
    if (total == 0) {
      fiendCountPercentage.value = 1.0;
    } else {
      fiendCountPercentage.value = (fiendCountAlive.value / total).clamp(0, 1);
    }
  }

  // @override
  // void onComponentReady() {
  //   amuletUI = AmuletUI(this);
  // }

  void onChangedError(String value) {
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

    // updateCursor();
    if (errorTimer > 0) {
      errorTimer--;
      if (errorTimer <= 0) {
        clearError();
      }
    }

    if (screenColorI.value < 1) {
      screenColorI.value += 0.15;
    }
  }

  void clearError() {
    error.value = '';
  }

  // @override
  // Widget customBuildUI(BuildContext context) =>
  //     buildWatch(options.mode, (mode) => buildMode(mode, context));
  //
  // Widget buildMode(Mode mode, BuildContext context) =>
  //     switch (mode){
  //       Mode.play => amuletUI.buildUI(context),
  //       Mode.edit => editor.buildEditor(),
  //       Mode.debug => debugger.buildUI()
  //     };

  @override
  void onKeyPressed(PhysicalKeyboardKey key) {
    super.onKeyPressed(key);

    if (options.editing)
      return;

    if (key == amuletKeys.toggleWindowQuest) {
      windowVisibleQuests.toggle();
      return;
    }

    if (key == amuletKeys.toggleWindowInventory) {
      windowVisibleInventory.toggle();
      return;
    }

    if (key == amuletKeys.toggleWindowHelp) {
      windowVisibleHelp.toggle();
      return;
    }

    if (key == amuletKeys.usePotionHealth) {
      amulet.usePotionHealth();
      return;
    }

    if (key == amuletKeys.usePotionMagic) {
      amulet.usePotionMagic();
      return;
    }

    if (options.developMode) {
      if (key == amuletKeys.refillHealthAndMagic) {
        amulet.sendAmuletRequest(
            NetworkRequestAmulet.Refill_Player_Health_Magic);
        return;
      }
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

  void clearItemHover() => aimTargetItemTypeCurrent.value = null;

  void onChangedPlayerInventoryOpen(bool value) {
    audio.click_sound_8.play();
    if (!value) {
      clearItemHover();
    }
  }

  void dropItemTypeWeapon() =>
      dropItemType(SlotType.Weapon);

  void dropAmuletItem(AmuletItem amuletItem) =>
      dropItemType(amuletItem.slotType);

  void dropItemType(SlotType slotType) =>
      server.sendNetworkRequestAmulet(
        NetworkRequestAmulet.Drop_Item_Type,
        slotType.index,
      );

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

  void messageNext() {
    if (messageIndex.value + 1 >= messages.length) {
      clearMessage();
    } else {
      messageIndex.value++;
    }
  }

  void clearMessage() {
    messageIndex.value = -1;
    messages.clear();
  }

  void nextNpcText() {
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
    scene.nodeVisibility.fillRange(
        0, scene.nodeVisibility.length, NodeVisibility.opaque);
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
    engine.cursorType.value = SystemMouseCursors.basic;
  }

  void clearHighlightAmuletItem() {
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

  void buildWorldMapSrcAndDst() {
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
    NodeType.Empty: Palette.Black,
    NodeType.Water: colors.blue_2,
    NodeType.Grass: colors.sage_2,
    NodeType.Brick: colors.grey_2,
    NodeType.Cobblestone: colors.brown_3,
    NodeType.Tree_Top: colors.sage_3,
    NodeType.Wood: colors.brown_3,
    NodeType.Soil: colors.brown_2,
  };

  Color mapNodeTypeToColor(int nodeType) {
    return colorMap[nodeType] ?? Colors.black;
  }

  void recordWorldMapPicture() {
    print('amulet.recordWorldMapPicture()');
    final paint = Paint()
      ..color = Colors.white;
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

  void sendAmuletRequest(NetworkRequestAmulet request,
      [dynamic arg1, dynamic arg2]) =>
      server.sendNetworkRequest(
        NetworkRequest.Amulet,
        request.index,
        arg1,
        arg2,
      );

  void onAmuletEvent({
    required double x,
    required double y,
    required double z,
    required int amuletEvent,
  }) {

  }

  AmuletItemObject? getEquipped(SlotType slotType) =>
      switch (slotType) {
        SlotType.Weapon => equippedWeapon,
        SlotType.Helm => equippedHelm,
        SlotType.Armor => equippedArmor,
        SlotType.Shoes => equippedShoes,
        SlotType.Consumable => null,
      };

  void toggleDebugEnabled() =>
      server.sendNetworkRequestAmulet(
          NetworkRequestAmulet.Toggle_Debug_Enabled
      );

  @override
  List<Widget> buildMenuItems() {
    return [
      onPressed(
        action: amulet.windowVisibleHelp.toggle,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('HELP', size: 20, color: Colors.white70),
              buildWatch(amulet.windowVisibleHelp, amulet.ui.buildIconCheckbox),
            ],
          ),
        ),
      )
    ];
  }

  // SkillTypeStats getSkillTypeStats(SkillType skillType){
  //    for (final skillTypeStats in playerSkillTypeStats){
  //      if (skillTypeStats.skillType == skillType){
  //        return skillTypeStats;
  //      }
  //    }
  //    throw Exception();
  // }

  // Watch<SkillType> getSkillSlotAt(int index) {
  //   switch (index) {
  //     case 0:
  //       return skillSlot0;
  //     case 1:
  //       return skillSlot1;
  //     case 2:
  //       return skillSlot2;
  //     case 3:
  //       return skillSlot3;
  //     default:
  //       throw Exception('amulet.getSkillSlotAt($index)');
  //   }
  // }

  void onNewCharacterCreated() {
    windowVisibleQuests.setTrue();
  }

  void onAmuletItemConsumed(AmuletItem amuletItem) {
    audio.drink.play();
  }

  void onAmuletItemDropped(AmuletItem amuletItem) {
    if (amuletItem.isConsumable) {
      audio.material_struck_glass.play();
    }
  }

  void onAmuletItemEquipped(AmuletItem amuletItem) {
    if (amuletItem.isConsumable) {
      audio.material_struck_glass.play();
    }
  }

  void toggleSkillType(SkillType skillType) =>
      sendAmuletRequest(
          NetworkRequestAmulet.Toggle_Skill_Type, skillType.index);

  int getSkillTypeLevel(SkillType skillType) =>
      playerSkillTypeLevels[skillType] ?? (throw Exception());

  void spawnRandomAmuletItem() =>
      sendAmuletRequest(NetworkRequestAmulet.Spawn_Random_Amulet_Item);

  void pickupAmuletItem() =>
      sendAmuletRequest(NetworkRequestAmulet.Pickup_Amulet_Item);

  void sellAmuletItem() =>
      sendAmuletRequest(NetworkRequestAmulet.Sell_Amulet_Item);

  void spawnAmuletItem({
    required AmuletItem amuletItem,
    required int level,
  }) =>
      sendAmuletRequest(
          NetworkRequestAmulet.Spawn_Amulet_Item,
          '${AmuletRequestField.Level} $level '
          '${AmuletRequestField.Amulet_Item} ${amuletItem.index}'
      );

  void upgradeSlotType(SlotType slotType) {
    sendAmuletRequest(
        NetworkRequestAmulet.Upgrade_Slot_Type,
        '${AmuletRequestField.Slot_Type} ${slotType.index}'
    );
  }

  void notifySkillsChanged() => playerSkillsNotifier.value++;

  void notifyEquipmentChanged() => equippedChangedNotifier.value++;

  void cheatAcquireGold() =>
      sendAmuletRequest(
          NetworkRequestAmulet.Cheat_Acquire_Gold,
      );

  void usePotionHealth() =>
      sendAmuletRequest(
        NetworkRequestAmulet.Use_Potion_Health,
      );

  void usePotionMagic() =>
      sendAmuletRequest(
        NetworkRequestAmulet.Use_Potion_Magic,
      );

  void onPotionConsumed() => audio.playSoundDrink();

  void disconnect() {
    server.disconnect();
    clearAllState();
  }
}

