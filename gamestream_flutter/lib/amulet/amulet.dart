
import 'package:gamestream_flutter/amulet/amulet_ui.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/classes/item_slot.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'mmo_render.dart';

class Amulet extends IsometricGame {

  late final AmuletUI amuletUI;

  final dragging = Watch<ItemSlot?>(null);
  final emptyItemSlot = buildText('-');
  final characterCreated = WatchBool(false);

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
  var items = <ItemSlot>[];

  final talentHover = Watch<MMOTalentType?>(null);
  final itemHover = Watch<MMOItem?>(null);
  final activePowerPosition = Position();
  final weapons = List<ItemSlot>.generate(4, (index) => ItemSlot(index: index, slotType: SlotType.Weapons));
  final treasures = List<ItemSlot>.generate(4, (index) => ItemSlot(index: index, slotType: SlotType.Treasures));
  final error = Watch('');
  final playerInteracting = Watch(false);
  final npcText = Watch('');
  final npcOptions = <String>[];
  final npcOptionsReads = Watch(0);
  final equippedWeaponIndex = Watch(-1);
  final activatedPowerIndex = Watch(-1);
  final equippedHelm = ItemSlot(slotType: SlotType.Equipped_Helm, index: 0);
  final equippedBody = ItemSlot(slotType: SlotType.Equipped_Body, index: 0);
  final equippedLegs = ItemSlot(slotType: SlotType.Equipped_Legs, index: 0);
  final equippedHandLeft = ItemSlot(slotType: SlotType.Equipped_Hand_Left, index: 0);
  final equippedHandRight = ItemSlot(slotType: SlotType.Equipped_Hand_Right, index: 0);
  final equippedShoes = ItemSlot(slotType: SlotType.Equipped_Shoes, index: 0);
  final playerLevel = Watch(0);
  final playerExperience = Watch(0);
  final playerExperienceRequired = Watch(0);
  final playerTalentPoints = Watch(0);
  final playerTalentDialogOpen = Watch(false);
  final playerInventoryOpen = Watch(false);
  final playerTalents = List.generate(MMOTalentType.values.length, (index) => 0, growable: false);
  final playerTalentsChangedNotifier = Watch(0);

  Amulet(){
    print('MmoGame()');
    playerInventoryOpen.onChanged(onChangedPlayerInventoryOpen);
    playerTalentDialogOpen.onChanged(onChangedPlayerTalentsDialogOpen);
    error.onChanged(onChangedError);
    characterCreated.onChanged((characterCreated) {
      render.drawCanvasEnabled = characterCreated;
    });
  }

  @override
  void onComponentReady() {
    amuletUI = AmuletUI(this);
    render.drawCanvasEnabled = false;
  }

  void onChangedError(String value){
    if (value.isEmpty)
      return;

    audio.errorSound15();
    errorTimer = 70;
  }

  @override
  void update() {
    super.update();

    if (errorTimer > 0) {
      errorTimer--;
      if (errorTimer <= 0){
        clearError();
      }
    }
  }

  void clearError() {
    error.value = '';
  }

  void setWeapon({
    required int index,
    required MMOItem? item,
    required int cooldown,
  }){
    final slot = weapons[index];
    slot.item.value = item;
    slot.cooldown.value = cooldown;
  }

  void setTreasure({required int index, required MMOItem? item}){
    treasures[index].item.value = item;
  }

  void setItem({required int index, required MMOItem? item}){
    items[index].item.value = item;
  }

  void setItemLength(int length){
    items = List.generate(length, (index) => ItemSlot(
        index: index,
        slotType: SlotType.Items,
    ));
  }

  @override
  Widget customBuildUI(BuildContext context) => amuletUI.buildAmuletUI();

  @override
  void onKeyPressed(int key) {
    super.onKeyPressed(key);

    if (editMode)
      return;

    if (key == KeyCode.Q){
      network.sendAmuletRequest.toggleInventoryOpen();
      return;
    }
    if (key == KeyCode.W){
      selectWeapon(1);
      return;
    }
    if (key == KeyCode.E){
      selectWeapon(2);
      return;
    }
    if (key == KeyCode.R){
      selectWeapon(3);
      return;
    }
    if (key == KeyCode.A){
      selectWeapon(0);
      return;
    }
    if (key == KeyCode.S){
      selectWeapon(1);
      return;
    }
    if (key == KeyCode.D){
      selectWeapon(2);
      return;
    }
    if (key == KeyCode.F){
      selectWeapon(3);
      return;
    }
    if (key == KeyCode.T){
      network.sendAmuletRequest.toggleTalentsDialog();
      return;
    }
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    if (characterCreated.value){
      super.drawCanvas(canvas, size);
      renderMMO(canvas, size);
    }
  }

  @override
  void onMouseExit() {

  }

  @override
  void onMouseEnter() => clearItemHover();

  void onAnyChanged(int value) => clearItemHover();

  void clearItemHover() => itemHover.value = null;

  void onChangedPlayerInventoryOpen(bool value) {
    audio.click_sound_8();
    if (!value){
      clearItemHover();
    }
  }

  void onChangedPlayerTalentsDialogOpen(bool talentsDialogOpen) {
    audio.click_sound_8();
    if (!talentsDialogOpen){
      clearTalentHover();
    }
  }

  void clearTalentHover() {
    talentHover.value = null;
  }

  int getTalentLevel(MMOTalentType talent) =>
      playerTalents[talent.index];

  bool maxLevelReached(MMOTalentType talent) =>
      getTalentLevel(talent) >= talent.maxLevel;

  void reportItemSlotDragged({
    required ItemSlot src,
    required ItemSlot target,
  }) =>
    network.sendNetworkRequest(
      NetworkRequest.Inventory_Request,
      '${NetworkRequestInventory.Move.index} '
      '${src.slotType.index} '
      '${src.index} '
      '${target.slotType.index} '
      '${target.index}'
    );

  void reportItemSlotLeftClicked(ItemSlot itemSlot) =>
    network.sendNetworkRequest(
      NetworkRequest.Inventory_Request,
      '${NetworkRequestInventory.Use.index} '
      '${itemSlot.slotType.index} '
      '${itemSlot.index}'
    );

  void dropItemSlot(ItemSlot itemSlot) =>
    network.sendNetworkRequest(
      NetworkRequest.Inventory_Request,
      '${NetworkRequestInventory.Drop.index} '
      '${itemSlot.slotType.index} '
      '${itemSlot.index}'
    );

  void selectWeapon(int index) =>
      network.sendAmuletRequest.sendAmuletRequest(NetworkRequestAmulet.Select_Weapon, index);

  void selectItem(int index) =>
      network.sendAmuletRequest.sendAmuletRequest(NetworkRequestAmulet.Select_Item, index);

  void selectTreasure(int index) =>
      network.sendAmuletRequest.sendAmuletRequest(NetworkRequestAmulet.Select_Treasure, index);

  void spawnRandomEnemy() =>
      network.sendNetworkRequestAmulet(
        NetworkRequestAmulet.Spawn_Random_Enemy,
      );

  void createPlayer({
    required String name,
  }) =>
      network.sendNetworkRequestAmulet(
        NetworkRequestAmulet.Create_Player,
        name,
      );
}