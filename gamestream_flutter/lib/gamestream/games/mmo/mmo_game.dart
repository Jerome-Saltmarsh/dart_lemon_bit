
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_game.dart';
import 'package:gamestream_flutter/library.dart';

class MmoGame extends IsometricGame {

  final itemHover = Watch<MMOItem?>(null);

  final weaponsChangedNotifier = Watch(0);
  final itemsChangedNotifier = Watch(0);

  final weapons = List<MMOItem?>.generate(4, (index) => null);
  late List<MMOItem?> items;

  final npcText = Watch('');
  final npcOptions = <String>[];
  final npcOptionsReads = Watch(0);
  final equippedWeaponIndex = Watch(-1);

  MmoGame({required super.isometric});

  void setWeapon({required int index, required MMOItem? item}){
    weapons[index] = item;
    notifyWeaponsChanged();
  }

  void setItemLength(int length){
    items = List.generate(length, (index) => null);
    notifyItemsChanged();
  }

  @override
  Widget customBuildUI(BuildContext context) => buildMMOUI();

  void selectItem(int index) =>
      sendMMORequest(MMORequest.Select_Item, index);

  void notifyItemsChanged() {
    itemsChangedNotifier.value++;
  }

  void notifyWeaponsChanged() {
    weaponsChangedNotifier.value++;
  }

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

}