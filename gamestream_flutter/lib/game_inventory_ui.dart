
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

import 'library.dart';

class GameInventoryUI {
  static const Slot_Size = 32.0;
  static const Slot_Scale = 1.5;
  static const Scaled_Slot_Size = Slot_Size * Slot_Scale;
  static const Slot_Item_Scale = Slot_Scale * 0.9;
  static const Columns_Per_Row = 7;
  static const Inventory_Width = Slot_Size * Slot_Scale * Columns_Per_Row;
  static final atlasIconSlotEmpty = GameUI.buildIconSlotEmpty();

  static Widget buildInventoryUI() =>
      GameUI.buildDialog(
        dialogType: DialogType.Inventory,
        child: Container(
          width: Inventory_Width,
          color: GameColors.brownDark,
          child: Column(
            children: [
              buildContainerInventory(),
              buildContainerPlayerGold(),
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: watch(ServerState.playerMaxHealth, (int maxHealth){
                          return watch(ServerState.playerHealth, (int currentHealth){
                             return text("health: $currentHealth / $maxHealth");
                          });
                      }) ,
                    ),
                    buildContainerEquippedItems(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  static Container buildContainerPlayerGold() =>
      Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        child: watch(ServerState.playerGold, (int gold) => text("Gold $gold")),
      );

  static Widget buildContainerEquippedItems() =>
      DragTarget<int>(
        onWillAccept: onDragWillAccept,
        onAccept: ClientEvents.onDragAcceptEquippedItemContainer,
        builder: (context, i, a) => Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // buildContainerEquippedWeapon(),
                buildContainerEquippedHead(),
                height2,
                buildContainerEquippedBody(),
                height2,
                buildContainerEquippedLegs(),
                height6,
              ],
            ),
          ));

  static Widget buildContainerEquippedWeapon() =>
      buildWatchEquippedItemType(GamePlayer.weapon, ItemType.Equipped_Weapon);

  static Widget buildContainerEquippedBody() =>
      buildWatchEquippedItemType(GamePlayer.body, ItemType.Equipped_Body);

  static Widget buildContainerEquippedHead() =>
      buildWatchEquippedItemType(GamePlayer.head, ItemType.Equipped_Head);

  static Widget buildContainerEquippedLegs() =>
      buildWatchEquippedItemType(GamePlayer.legs, ItemType.Equipped_Legs);

  static Widget buildWatchEquippedItemType(Watch<int> watchInt, int index) =>
   Container(
     alignment: Alignment.center,
     width: 32 * Slot_Scale, height: 32 * Slot_Scale, color: GameColors.brown02,
      child: watch(watchInt, (int itemType) => buildDraggableItemIndex(itemIndex: index)),
   );

  static Widget buildDraggableItemIndex({required int itemIndex, double scale = Slot_Item_Scale}) =>
      Draggable(
        onDragStarted: () => ClientEvents.onDragStarted(itemIndex),
        onDragEnd: ClientEvents.onDragEnd,
        onDraggableCanceled: ClientEvents.onDragCancelled,
        onDragCompleted: ClientEvents.onDragCompleted,
        data: itemIndex,
        hitTestBehavior: HitTestBehavior.opaque,
        feedback: buildPressableItemIndex(
            itemIndex: itemIndex,
            scale: scale,
        ),
        child: buildPressableItemIndex(
          itemIndex: itemIndex,
          scale: scale,
        ),
      );

  static Widget buildPressableItemIndex({
    required int itemIndex,
    double scale = Slot_Item_Scale,
    int? itemType,
  }) =>
      onPressed(
        action: () => ClientEvents.onItemIndexPrimary(itemIndex),
        onRightClick: () => ClientEvents.onItemIndexSecondary(itemIndex),
        child: MouseRegion(
          onEnter: (event) {
            Engine.mousePosition.x = event.position.dx;
            Engine.mousePosition.y = event.position.dy;
            ClientState.hoverIndex.value = itemIndex;
          },
          onExit: (_) {
            if (ClientState.hoverIndex.value == itemIndex) {
              ClientActions.clearHoverIndex();
            }
          },
          child: Container(
            child: buildItemTypeAtlasImage(
              itemType: itemType ?? ServerQuery.getItemTypeAtInventoryIndex(itemIndex),
              scale: scale,
            ),
          ),
        ),
      );

  static Widget buildContainerInventory() =>
      Container(
        height: 300,
        child: Stack(
          children: [
            buildStackSlotGrid(),
            watch(ClientState.inventoryReads, buildStackInventoryItems),
          ],
        ),
      );

  static bool onDragWillAccept(int? i) => i != null;

  static Widget buildStackInventoryItems(int reads) {
     final positioned = <Widget>[];
     for (var i = 0; i < ServerState.inventory.length; i++){
         if (ServerState.inventory[i] == ItemType.Empty) continue;
         positioned.add(
           buildPositionInventoryItem(i)
         );
     }
     return Stack(
       children: positioned,
     );
  }

  static Widget buildPositionInventoryItem(int index) =>
      buildPositionGridItem(
        index: index,
        child: buildDraggableItemIndex(itemIndex: index),
      );

  static Widget buildStackSlotGrid() {
    final children = <Widget>[];
    for (var i = 0; i < ServerState.inventory.length; i++) {
       children.add(buildPositionedGridSlot(i));
    }
    return Stack(
      children: children,
    );
  }

  static Widget buildPositionedGridSlot(int i) =>
    buildPositionGridItem(
        index: i,
        child: atlasIconSlotEmpty,
    );

  static double getIndexX(int index) => getIndexColumn(index) * Scaled_Slot_Size;

  static double getIndexY(int index) => getIndexRow(index) * Scaled_Slot_Size;

  static int getIndexRow(int index) => index ~/ Columns_Per_Row;

  static int getIndexColumn(int index) =>  index % Columns_Per_Row;

  static Widget buildPositionGridElement({
    required int index,
    required Widget child,
  }) =>
      Positioned(
        left: getIndexX(index),
        top: getIndexY(index),
        child: child,
      );

  static Widget buildPositionGridItem({required int index, required Widget child}) =>
      buildPositionGridElement(
        index: index,
        child: DragTarget<int>(
          onWillAccept: (int? index) => index != null,
          onAccept: (int? indexFrom){
            if (indexFrom == null) return;
            GameNetwork.sendClientRequestInventoryMove(
              indexFrom: indexFrom,
              indexTo: index,
            );
          },
          builder: (context, candidate, i){
            return child;
          },
        ),
      );

  static Widget buildItemTypeAtlasImage({required int itemType, double scale = 1.0}) =>
      Engine.buildAtlasImage(
        image: GameImages.atlasItems,
        srcX: AtlasItems.getSrcX(itemType),
        srcY: AtlasItems.getSrcY(itemType),
        srcWidth: Slot_Size,
        srcHeight: Slot_Size,
        scale: scale,
      );

  static Widget buildPositionedContainerItemTypeInformation(int itemIndex){
    if (itemIndex == -1) return const SizedBox();

    final itemType = ClientState.hoverDialogType.value == DialogType.Trade ? GamePlayer.storeItems.value[itemIndex] : ServerQuery.getItemTypeAtInventoryIndex(itemIndex);
    final consumeType = ItemType.getConsumeType(itemType);
    return Positioned(
      top: Engine.mousePosition.y < (Engine.screen.height * 0.5) ?  Engine.mousePosition.y + 60 : null,
      bottom: Engine.mousePosition.y >= (Engine.screen.height * 0.5) ?  Engine.screen.height - Engine.mousePosition.y + 50 : null,
      left:  Engine.mousePosition.x < (Engine.screen.width * 0.5) ? max(Engine.mousePosition.x - 100, 50) : null,
      right: Engine.mousePosition.x >= (Engine.screen.width * 0.5) ? max((Engine.screen.width - Engine.mousePosition.x) - 100, 50) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: brownDark,
        constraints: BoxConstraints(
          minWidth: 450,
          maxWidth: 550,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text(ItemType.getName(itemType), color: GameColors.blue),
            height8,
            text('type: ${ItemType.getGroupTypeName(itemType)}'),
            text('Damage: ${ItemType.getDamage(itemType)}'),
            text('Range: ${ItemType.getRange(itemType).toInt()}'),
            text('Cooldown: ${ItemType.getCooldown(itemType).toInt()}'),
            if (consumeType != ItemType.Empty)
               text("Uses: ${ItemType.getConsumeAmount(itemType)}x ${ItemType.getName(consumeType)}"),

            height16,
            if (ClientState.hoverDialogDialogIsTrade)
              buildItemTypeRecipe(itemType),

            height16,

            if (ClientState.hoverDialogDialogIsTrade)
              text("left click to buy", color: GameColors.inventoryHint),
            if (ClientState.hoverDialogIsInventory && ItemType.isTypeEquippable(itemType))
              text("left click to equip", color: GameColors.inventoryHint),
            if (ClientState.hoverDialogIsInventory && ItemType.isFood(itemType))
              text("left click to eat", color: GameColors.inventoryHint),
            if (GamePlayer.interactModeTrading && ClientState.hoverDialogIsInventory)
              text("right click to sell", color: GameColors.inventoryHint),
            if (!GamePlayer.interactModeTrading && ClientState.hoverDialogIsInventory)
              text("right click to drop", color: GameColors.inventoryHint),
          ],
        ),
      ),
    );
  }

  static Widget buildItemTypeRecipe(int itemType){
    final recipe = ItemType.Recipes[itemType];
    if (recipe == null) return text("(FREE)");
    final children = <Widget>[];
    for (var i = 0; i < recipe.length; i += 2){
      final recipeItemQuantityRequired = recipe[i];
      final recipeItemType = recipe[i + 1];
      final recipeItemQuantityPossessed = ServerQuery.countItemTypeQuantityInPlayerPossession(recipeItemType);
      final sufficientQuantity = recipeItemQuantityPossessed >= recipeItemQuantityRequired;
      final textColor = sufficientQuantity ? GameColors.green : GameColors.red;
       children.add(Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Expanded(
             child: Row(
               children: [
                 buildItemTypeAtlasImage(itemType: recipeItemType, scale: 0.75),
                 width6,
                 text(ItemType.getName(recipeItemType), color: textColor),
                 width32,
               ],
             ),
           ),
           Row(
             children: [
               Container(width: 65, child: text(recipeItemQuantityRequired, color: textColor), alignment: Alignment.centerRight),
               Container(width: 65, child: text('$recipeItemQuantityPossessed', color: textColor.withOpacity(0.85)), alignment: Alignment.centerRight),
             ],
           ),
         ],
       ));
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: GameColors.brownLight,
      constraints: BoxConstraints(
        minWidth: 450,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text("COST"),
          height6,
          ...children
        ],
      ),
    );
  }

  static Widget buildContainerRecipe(int itemTypeRecipe) {
     final recipe = ItemType.Recipes[itemTypeRecipe];
     if (recipe == null) {
       return text("recipe not found");
     }
     final children = <Widget>[];
     for (var i = 0; i < recipe.length; i += 2){
        final itemType = recipe[i];
        final quantity = recipe[i + 1];
        children.add(
           text('${ItemType.getName(itemType)}: x$quantity', color: Colors.yellow)
        );
     }
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: children,
     );
  }

}
