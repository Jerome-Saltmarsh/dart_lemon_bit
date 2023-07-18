
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_actions.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/library.dart';

class MmoGame extends IsometricGame {

  IsometricPlayer get player => gamestream.isometric.player;

  final itemHover = Watch<MMOItem?>(null);

  late final weaponsChangedNotifier = Watch(0, onChanged: onAnyChanged);
  late final itemsChangedNotifier = Watch(0, onChanged: onAnyChanged);
  late final treasuresChangedNotifier = Watch(0, onChanged: onAnyChanged);


  final weapons = List<MMOItem?>.generate(4, (index) => null);
  final treasures = List<MMOItem?>.generate(4, (index) => null);
  var items = <MMOItem?>[];

  final playerInteracting = Watch(false);
  final npcText = Watch('');
  final npcOptions = <String>[];
  final npcOptionsReads = Watch(0);
  final equippedWeaponIndex = Watch(-1);

  final equippedHead = Watch<MMOItem?>(null);
  final equippedBody = Watch<MMOItem?>(null);
  final equippedLegs = Watch<MMOItem?>(null);

  final playerLevel = Watch(0);
  final playerExperience = Watch(0);
  final playerExperienceRequired = Watch(0);
  final playerSkillPoints = Watch(0);
  final playerSkillsDialogOpen = Watch(false);

  MmoGame({required super.isometric});

  void setWeapon({required int index, required MMOItem? item}){
    weapons[index] = item;
    notifyWeaponsChanged();
  }

  void setTreasure({required int index, required MMOItem? item}){
    treasures[index] = item;
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

  void notifyWeaponsChanged() {
    weaponsChangedNotifier.value++;
  }

  void notifyTreasuresChanged() {
    treasuresChangedNotifier.value++;
  }

  @override
  void onKeyPressed(int key) {
    super.onKeyPressed(key);

    if (key == KeyCode.Q){
      selectWeapon(0);
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
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);
    renderPlayerHoverItemRange();

    if (!player.arrivedAtDestination.value) {
      gamestream.isometric.renderer.renderLine(
          player.x,
          player.y,
          player.z,
          player.runX,
          player.runY,
          player.runZ,
      );
    }
  }

  void renderPlayerHoverItemRange() {
    final item = itemHover.value;
    if (item == null) return;
    renderPlayerItemRange(item);
  }

  void renderPlayerItemRange(MMOItem item) {
    if (item.range <= 0) return;
    gamestream.isometric.renderer.renderCircle(
      player.x,
      player.y,
      player.z,
      item.range,
      sections: 20
    );
  }

  @override
  void onMouseExit() {

  }

  @override
  void onMouseEnter() => clearItemHover();

  void onAnyChanged(int value) => clearItemHover();

  void clearItemHover() => itemHover.value = null;
}