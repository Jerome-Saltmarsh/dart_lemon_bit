
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_item_slot.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/library.dart';

import 'mmo_actions.dart';
import 'mmo_render.dart';
import 'mmo_ui.dart';

class MmoGame extends IsometricGame {

  IsometricPlayer get player => gamestream.isometric.player;

  final itemHover = Watch<MMOItem?>(null);

  final activePowerPosition = IsometricPosition();
  var items = <MMOItem?>[];

  late final itemsChangedNotifier = Watch(0, onChanged: onAnyChanged);
  late final treasuresChangedNotifier = Watch(0, onChanged: onAnyChanged);

  final weapons = List<MMOItemSlot>.generate(4, (index) => MMOItemSlot());
  final treasures = List<MMOItemSlot>.generate(4, (index) => MMOItemSlot());

  final playerInteracting = Watch(false);
  final npcText = Watch('');
  final npcOptions = <String>[];
  final npcOptionsReads = Watch(0);
  final equippedWeaponIndex = Watch(-1);
  final activatedPowerIndex = Watch(-1);

  final equippedHead = Watch<MMOItem?>(null);
  final equippedBody = Watch<MMOItem?>(null);
  final equippedLegs = Watch<MMOItem?>(null);

  final playerLevel = Watch(0);
  final playerExperience = Watch(0);
  final playerExperienceRequired = Watch(0);
  final playerTalentPoints = Watch(0);
  final playerTalentDialogOpen = Watch(false);
  final playerInventoryOpen = Watch(false);
  final playerTalents = List.generate(MMOTalentType.values.length, (index) => 0, growable: false);

  final playerTalentsChangedNotifier = Watch(0);

  MmoGame({required super.isometric}){
    print('MmoGame()');
    playerInventoryOpen.onChanged(onChangedPlayerInventoryOpen);
    playerTalentDialogOpen.onChanged(onChangedPlayerSkillsDialogOpen);
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
    notifyTreasuresChanged();
  }

  void setItem({required int index, required MMOItem? item}){
    items[index] = item;
    notifyItemsChanged();
  }

  void setItemLength(int length){
    items = List.generate(length, (index) => null);
    notifyItemsChanged();
  }

  @override
  Widget customBuildUI(BuildContext context) => buildMMOUI();

  void notifyItemsChanged() {
    itemsChangedNotifier.value++;
  }

  void notifyTreasuresChanged() {
    treasuresChangedNotifier.value++;
  }

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
    render(canvas, size);
  }

  @override
  void onMouseExit() {

  }

  @override
  void onMouseEnter() => clearItemHover();

  void onAnyChanged(int value) => clearItemHover();

  void clearItemHover() => itemHover.value = null;

  void onChangedPlayerInventoryOpen(bool value) {
    gamestream.audio.click_sound_8();
  }

  void onChangedPlayerSkillsDialogOpen(bool value) {
    gamestream.audio.click_sound_8();
  }

  int getTalentLevel(MMOTalentType talent) =>
      playerTalents[talent.index];

  bool maxLevelReached(MMOTalentType talent) =>
      getTalentLevel(talent) >= talent.maxLevel;
}