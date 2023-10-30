
import 'package:gamestream_flutter/amulet/amulet_ui.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/lemon_websocket_client/connection_status.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/classes/item_slot.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'amulet_render.dart';


class Game {

}

class Amulet extends IsometricGame {

  final games = Watch(<Game>[]);
  final amuletScene = Watch<AmuletScene?>(null);
  final cameraTargetSet = Watch(false);
  final cameraTarget = Position();

  final elementPoints = Watch(0);
  final elementFire = Watch(0);
  final elementWater = Watch(0);
  final elementWind = Watch(0);
  final elementEarth = Watch(0);
  final elementElectricity = Watch(0);

  late final AmuletUI amuletUI;

  final dragging = Watch<ItemSlot?>(null);
  final emptyItemSlot = buildText('-');

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

  final messages = <String>[];
  final messageIndex = Watch(-1);
  final talentHover = Watch<AmuletTalentType?>(null);
  final itemHover = Watch<AmuletItem?>(null);
  final activePowerPosition = Position();
  final weapons = List<ItemSlot>.generate(4, (index) => ItemSlot(index: index, slotType: SlotType.Weapons));
  final treasures = List<ItemSlot>.generate(4, (index) => ItemSlot(index: index, slotType: SlotType.Treasures));
  final error = Watch('');
  final playerInteracting = Watch(false);
  final npcTextIndex = Watch(-1);
  final npcText = <String>[];
  final npcName = Watch('');
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
  final playerTalents = List.generate(AmuletTalentType.values.length, (index) => 0, growable: false);
  final playerTalentsChangedNotifier = Watch(0);

  Amulet(){
    print('MmoGame()');
    playerInventoryOpen.onChanged(onChangedPlayerInventoryOpen);
    playerTalentDialogOpen.onChanged(onChangedPlayerTalentsDialogOpen);
    playerInteracting.onChanged(onChangedPlayerInteracting);
    npcTextIndex.onChanged(onChangedNpcTextIndex);
    error.onChanged(onChangedError);
    cameraTargetSet.onChanged(onChangedCameraTargetSet);
  }

  @override
  void onComponentReady() {
    amuletUI = AmuletUI(this);
  }

  void onChangedError(String value){
    if (value.isEmpty)
      return;

    audio.errorSound15();
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

    if (options.playMode) {
      if (cameraTargetSet.value){
        camera.target = cameraTarget;
      } else {
        camera.target = player.position;
      }
    }
  }

  void clearError() {
    error.value = '';
  }

  void setWeapon({
    required int index,
    required AmuletItem? item,
    required double cooldownPercentage,
    required int charges,
    required int max,
  }){
    final slot = weapons[index];
    slot.amuletItem.value = item;
    slot.cooldownPercentage.value = cooldownPercentage;
    slot.charges.value = charges;
    slot.max.value = max;
  }

  void setTreasure({required int index, required AmuletItem? item}){
    treasures[index].amuletItem.value = item;
  }

  void setItem({required int index, required AmuletItem? item}){
    items[index].amuletItem.value = item;
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

  int getTalentLevel(AmuletTalentType talent) =>
      playerTalents[talent.index];

  bool maxLevelReached(AmuletTalentType talent) =>
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

  void useItemSlot(ItemSlot itemSlot) =>
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

  Watch<int> getAmuletElementWatch(AmuletElement amuletElement) =>
      switch (amuletElement) {
        AmuletElement.fire => elementFire,
        AmuletElement.water => elementWater,
        AmuletElement.wind => elementWind,
        AmuletElement.earth => elementEarth,
        AmuletElement.electricity => elementElectricity,
      };

  void upgradeAmuletElement(AmuletElement amuletElement) =>
      network.sendNetworkRequestAmulet(
        NetworkRequestAmulet.Upgrade_Element,
        amuletElement.index,
      );

  void requestAcquireAmuletItem(AmuletItem amuletItem) {
    network.sendNetworkRequestAmulet(
      NetworkRequestAmulet.Acquire_Amulet_Item,
      '--index ${amuletItem.index}',
    );
  }

  int getAmuletPlayerItemLevel(AmuletItem amuletItem) =>
      amuletItem.getLevel(
        fire: elementFire.value,
        water: elementWater.value,
        wind: elementWind.value,
        earth: elementEarth.value,
        electricity: elementElectricity.value,
    );

  void toggleInventoryOpen() =>
      network.sendNetworkRequest(
          NetworkRequest.Amulet,
          NetworkRequestAmulet.Toggle_Inventory_Open.index,
      );

  void setInventoryOpen(bool value) =>
      network.sendNetworkRequest(
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
    network.sendNetworkRequest(
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

  void onChangedCameraTargetSet(bool cameraTargetSet) {
    print('amulet.onChangedCameraTargetSet("$cameraTargetSet")');
    options.setCameraPlay(cameraTargetSet ? cameraTarget : player.position);
  }

  void onChangedNetworkConnectionStatus(ConnectionStatus connection) {
     switch (connection){
       case ConnectionStatus.Connected:
         options.edit.value = false;
         cameraTargetSet.value = false;
         break;
       default:
         break;
     }
  }

  void onNetworkDone() {
      clearAmuletScene();
      clearEquippedWeapon();
      clearDragging();
      clearActivatedPowerIndex();
  }

  void clearAmuletScene() => amuletScene.value = null;

  void clearActivatedPowerIndex() => activatedPowerIndex.value = -1;

  void clearDragging() => dragging.value = null;

  void clearEquippedWeapon() => equippedWeaponIndex.value = -1;
}