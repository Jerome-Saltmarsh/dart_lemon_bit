
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/library.dart';

import 'inventory_type.dart';

class SurvivalGame extends GameIsometric {
  final hoverTargetType = Watch(InventoryType.Hover_Target_None);
  final dragStart = Watch(-1);
  final dragEnd = Watch(-1);
  final hoverIndex = Watch(-1);
  late final inventoryReads = Watch(0, onChanged: onInventoryReadsChanged);

  SurvivalGame({required super.isometric}) {
    print("SurvivalGame()");
  }

  void sendClientRequestInventoryEquip(int index) =>
    sendSurvivalRequest(SurvivalRequest.Equip, index);

  void sendClientRequestInventoryToggle() =>
      sendSurvivalRequest(SurvivalRequest.Toggle);

  void sendClientRequestInventoryDrop(int index) =>
      sendSurvivalRequest(SurvivalRequest.Drop, index);

  void sendClientRequestInventoryUnequip(int index) =>
      sendSurvivalRequest(SurvivalRequest.Unequip, index);

  void sendClientRequestInventoryBuy(int index) =>
      sendSurvivalRequest(SurvivalRequest.Buy, index);

  void sendClientRequestInventoryDeposit(int index) =>
      sendSurvivalRequest(SurvivalRequest.Deposit, index);

  void sendClientRequestInventorySell(int index) =>
      sendSurvivalRequest(SurvivalRequest.Sell, index);

  void sendClientRequestInventoryMove({
    required int indexFrom,
    required int indexTo,
  }) =>
      sendSurvivalRequest(SurvivalRequest.Move, "$indexFrom $indexTo");

  void sendSurvivalRequest(
      SurvivalRequest survivalRequest, [dynamic message]
      ) =>
      gamestream.network.sendClientRequest(ClientRequest.Survival, message);


  void inventorySwapDragTarget(){
    if (dragStart.value == -1) return;
    if (hoverIndex.value == -1) return;
    sendClientRequestInventoryMove(
      indexFrom: dragStart.value,
      indexTo: hoverIndex.value,
    );
  }

  void clearHoverIndex() =>
      hoverIndex.value = -1;

  void dragStartSetNone(){
    dragStart.value = -1;
  }

  void setDragItemIndex(int index) =>
          () => dragStart.value = index;

  void dropDraggedItem(){
    if (dragStart.value == -1) return;
    sendClientRequestInventoryDrop(dragStart.value);
  }

  void onInventoryReadsChanged(int value){
    clearHoverIndex();
  }

  void redrawInventory() => inventoryReads.value++;


  void onDragStarted(int itemIndex){
    dragStart.value = itemIndex;
    dragEnd.value = -1;
  }

  void onItemIndexPrimary(int itemIndex) {
    if (gamestream.isometric.ui.hoverDialogDialogIsTrade){
      sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    sendClientRequestInventoryEquip(itemIndex);
  }

  void onItemIndexSecondary(int itemIndex){
    if (gamestream.isometric.ui.hoverDialogDialogIsTrade){
      sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    gamestream.isometric.player.interactModeTrading
        ? sendClientRequestInventorySell(itemIndex)
        : sendClientRequestInventoryDrop(itemIndex);
  }

  void onDragAcceptEquippedItemContainer(int? i){
    if (i == null) return;
    sendClientRequestInventoryEquip(i);
  }

  void onDragCancelled(Velocity velocity, Offset offset){
    if (hoverIndex.value == -1){
      dropDraggedItem();
    } else {
      inventorySwapDragTarget();
    }
    dragStart.value = -1;
    dragEnd.value = -1;
  }

  void onDragAcceptWatchBelt(Watch<int> watchBelt, int index) =>
      inventoryMoveToWatchBelt(index, watchBelt);

  void onButtonPressedWatchBelt(Watch<int> watchBeltType) =>
      equipWatchBeltType(watchBeltType);

  void onRightClickedWatchBelt(Watch<int> watchBelt){
    inventoryUnequip(
        gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBelt)
    );
  }

  void onAcceptDragInventoryIcon(){
    if (dragStart.value == -1) return;
    sendClientRequestInventoryDeposit(dragStart.value);
  }


  void onDragCompleted(){
    // print("onDragCompleted()");
  }

  void onDragEnd(DraggableDetails details){
    // print("onDragEnd()");
  }

  void dropEquippedWeapon() =>
      sendClientRequestInventoryDrop(ItemType.Equipped_Weapon);

  void equipWatchBeltType(Watch<int> watchBeltType) =>
      sendClientRequestInventoryEquip(
          gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBeltType)
      );

  void inventoryUnequip(int index) =>
      sendClientRequestInventoryUnequip(index);

  void inventoryMoveToWatchBelt(int index, Watch<int> watchBelt)=>
      sendClientRequestInventoryMove(
        indexFrom: index,
        indexTo: gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBelt),
      );
}