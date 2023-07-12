
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/library.dart';

class MmoGame extends IsometricGame {

  final itemHover = Watch<MMOItem?>(null);

  final weaponsChangedNotifier = Watch(0);
  final itemsChangedNotifier = Watch(0);

  final weapons = List<MMOItem?>.generate(4, (index) => null);
  var items = <MMOItem?>[];

  final npcText = Watch('');
  final npcOptions = <String>[];
  final npcOptionsReads = Watch(0);
  final equippedWeaponIndex = Watch(-1);

  final equippedHead = Watch<MMOItem?>(null);
  final equippedBody = Watch<MMOItem?>(null);
  final equippedLegs = Watch<MMOItem?>(null);

  MmoGame({required super.isometric});

  void setWeapon({required int index, required MMOItem? item}){
    weapons[index] = item;
    notifyWeaponsChanged();
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

  void selectWeapon(int index) =>
      sendMMORequest(MMORequest.Select_Weapon, index);

  void selectItem(int index) =>
      sendMMORequest(MMORequest.Select_Item, index);

  void notifyItemsChanged() {
    itemsChangedNotifier.value++;
  }

  void notifyWeaponsChanged() {
    weaponsChangedNotifier.value++;
  }

  void dropWeapon(int index) =>
      sendMMORequest(MMORequest.Drop_Weapon, index);

  void dropItem(int index) =>
      sendMMORequest(MMORequest.Drop_Item, index);

  void selectTalkOption(int index) =>
      sendMMORequest(MMORequest.Select_Talk_Option, index);

  void endInteraction() =>
      sendMMORequest(MMORequest.End_Interaction);

  void sendMMORequest(MMORequest request, [dynamic message]) =>
      gamestream.network.sendClientRequest(
        ClientRequest.MMO,
        '${request.index} $message'
      );

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
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    super.drawCanvas(canvas, size);
    renderPlayerHoverItemRange();
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
}