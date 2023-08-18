
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_item_slot.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/library.dart';

import 'mmo_actions.dart';
import 'mmo_render.dart';
import 'mmo_ui.dart';
import 'ui/src.dart';

class MmoGame extends IsometricGame {

  final emptyMMOItemImage = MMOItemImage(item: null, size: 64);

  var errorTimer = 0;
  var items = <MMOItemSlot>[];

  final talentHover = Watch<MMOTalentType?>(null);
  final itemHover = Watch<MMOItem?>(null);
  final activePowerPosition = Position();
  final weapons = List<MMOItemSlot>.generate(4, (index) => MMOItemSlot(index: index, slotType: SlotType.Weapons));
  final treasures = List<MMOItemSlot>.generate(4, (index) => MMOItemSlot(index: index, slotType: SlotType.Treasures));
  final error = Watch('');
  final playerInteracting = Watch(false);
  final npcText = Watch('');
  final npcOptions = <String>[];
  final npcOptionsReads = Watch(0);
  final equippedWeaponIndex = Watch(-1);
  final activatedPowerIndex = Watch(-1);
  final equippedHead = MMOItemSlot(slotType: SlotType.Equipped_Head, index: 0);
  final equippedBody = MMOItemSlot(slotType: SlotType.Equipped_Body, index: 0);
  final equippedLegs = MMOItemSlot(slotType: SlotType.Equipped_Legs, index: 0);
  final equippedHandLeft = MMOItemSlot(slotType: SlotType.Equipped_Hand_Left, index: 0);
  final equippedHandRight = MMOItemSlot(slotType: SlotType.Equipped_Hand_Right, index: 0);
  final playerLevel = Watch(0);
  final playerExperience = Watch(0);
  final playerExperienceRequired = Watch(0);
  final playerTalentPoints = Watch(0);
  final playerTalentDialogOpen = Watch(false);
  final playerInventoryOpen = Watch(false);
  final playerTalents = List.generate(MMOTalentType.values.length, (index) => 0, growable: false);
  final playerTalentsChangedNotifier = Watch(0);

  MmoGame(){
    print('MmoGame()');
    playerInventoryOpen.onChanged(onChangedPlayerInventoryOpen);
    playerTalentDialogOpen.onChanged(onChangedPlayerTalentsDialogOpen);
    error.onChanged(onChangedError);
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
    items = List.generate(length, (index) => MMOItemSlot(
        index: index,
        slotType: SlotType.Items,
    ));
  }

  @override
  Widget customBuildUI(BuildContext context) => buildMMOUI();

  @override
  void onKeyPressed(int key) {
    super.onKeyPressed(key);

    if (key == KeyCode.Q){
      toggleInventoryOpen();
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
      toggleTalentsDialog();
      return;
    }
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);
    renderMMO(canvas, size);
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


  void handleDragRequest({
    required MMOItemSlot src,
    required MMOItemSlot target,
  }){

  }

  void handleItemSlotLeftClicked(MMOItemSlot slot){

  }

  void handleItemSlotRightClicked(MMOItemSlot slot){

  }
}