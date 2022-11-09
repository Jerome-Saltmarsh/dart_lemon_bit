
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

import 'library.dart';

class GameInventoryUI {
  static const Slot_Size = 32.0;
  static const Slot_Scale = 1.5;
  static const Scaled_Slot_Size = Slot_Size * Slot_Scale;
  static const Slot_Item_Scale = Slot_Scale * 0.9;
  static const Equipped_Item_Scale = Slot_Scale * Engine.GoldenRatio_1_618;
  static const Columns_Per_Row = 7;
  static const Inventory_Width = Slot_Size * Slot_Scale * Columns_Per_Row;

  static final atlasIconSlotEmpty = buildAtlasIconSlotEmpty();

  static Widget buildInventoryUI() =>
      GameUI.buildDialog(
        dialogType: DialogType.Inventory,
        child: Container(
          width: Inventory_Width,
          color: GameColors.brownDark,
          child: Column(
            children: [
              buildContainerEquippedItems(),
              buildContainerInventory(),
              buildContainerPlayerGold()
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

  static Widget buildContainerEquippedItems() => Container(
        height: 80.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildContainerEquippedWeapon(),
            buildContainerEquippedBody(),
            buildContainerEquippedHead(),
            buildContainerEquippedLegs(),
          ],
        ),
      );

  static Widget buildContainerEquippedWeapon() => onPressed(
      action: () => GameNetwork.sendClientRequestInventoryEquip(ItemType.Equipped_Weapon),
      onRightClick: () => GamePlayer.interactModeTrading
          ? GameNetwork.sendClientRequestInventorySell(ItemType.Equipped_Weapon)
          : GameNetwork.sendClientRequestInventoryDrop(ItemType.Equipped_Weapon),
      child: buildDragTarget(GamePlayer.weapon, ItemType.Equipped_Weapon)
  );

  static Widget buildContainerEquippedBody() => onPressed(
      action: () => GameNetwork.sendClientRequestInventoryEquip(ItemType.Equipped_Body),
      onRightClick: () => GamePlayer.interactModeTrading
          ? GameNetwork.sendClientRequestInventorySell(ItemType.Equipped_Body)
          : GameNetwork.sendClientRequestInventoryDrop(ItemType.Equipped_Body),
      child: buildDragTarget(GamePlayer.body, ItemType.Equipped_Body)
  );

  static Widget buildContainerEquippedHead() => onPressed(
      action: () => GameNetwork.sendClientRequestInventoryEquip(ItemType.Equipped_Head),
      onRightClick: () => GamePlayer.interactModeTrading
          ? GameNetwork.sendClientRequestInventorySell(ItemType.Equipped_Head)
          : GameNetwork.sendClientRequestInventoryDrop(ItemType.Equipped_Head),
      child: buildDragTarget(GamePlayer.head, ItemType.Equipped_Head)
  );

  static Widget buildContainerEquippedLegs() => onPressed(
      action: () => GameNetwork.sendClientRequestInventoryEquip(ItemType.Equipped_Legs),
      onRightClick: () => GameNetwork.sendClientRequestInventoryDrop(ItemType.Equipped_Legs),
      child: buildDragTarget(GamePlayer.legs, ItemType.Equipped_Legs)
  );

  static Widget buildDragTarget(Watch<int> watchInt, int index) =>
      DragTarget<int>(
        builder: (context, i, a) => watch(watchInt, (int itemType) => buildContainerEquippedItemType(itemType, index)),
        onWillAccept: onDragWillAccept,
        onAccept: onDragAccept,
      );

  static Widget buildContainerEquippedItemType(int itemType, int index) =>
      Draggable(
        data: index,
        feedback: buildItemTypeAtlasImage(itemType: itemType, scale: Slot_Item_Scale),
        hitTestBehavior: HitTestBehavior.opaque,
        child: buildItemType(itemType: itemType, scale: Equipped_Item_Scale),
      );

  static Widget buildItemType({required int itemType, double scale = Slot_Item_Scale}){
    return MouseRegion(
      onEnter: (event){
        Engine.mousePosition.x = event.position.dx;
        Engine.mousePosition.y = event.position.dy;
        ClientState.itemTypeHover.value = itemType;
      },
      onExit: (_){
        if (ClientState.itemTypeHover.value == itemType){
          ClientState.itemTypeHover.value = ItemType.Empty;
        }
      },
      child: buildItemTypeAtlasImage(itemType: itemType, scale: scale),
    );
  }

  static Widget buildContainerInventory() =>
      Container(
        // color: brownLight,
        // width: Inventory_Width,
        height: 400,
        child: Stack(
          children: [
            buildStackSlotGrid(),
            watch(ClientState.inventoryReads, buildStackInventoryItems),
          ],
        ),
      );

  static bool onDragWillAccept(int? i) => i != null;

  static void onDragAccept(int? i){
    if (i == null) return;
    GameNetwork.sendClientRequestInventoryEquip(i);
  }

  static Widget buildStackInventoryItems(int reads) {
     final positioned = <Widget>[];
     for (var i = 0; i < GamePlayer.inventory.length; i++){
         if (GamePlayer.inventory[i] == ItemType.Empty) continue;
         positioned.add(
           buildPositionInventoryItem(i)
         );
     }
     return Stack(
       children: positioned,
     );
  }

  static Widget buildPositionInventoryItem(int index){
    final itemType = GamePlayer.inventory[index];
    return buildPositionGridItem(
      index: index,
      child: GestureDetector(
        onSecondaryTap: () => GamePlayer.interactModeTrading
            ? GameNetwork.sendClientRequestInventorySell(index)
            : GameNetwork.sendClientRequestInventoryDrop(index),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (event){
            Engine.mousePosition.x = event.position.dx;
            Engine.mousePosition.y = event.position.dy;
            ClientState.itemTypeHover.value = itemType;
          },
          onExit: (_){
            if (ClientState.itemTypeHover.value == itemType){
              ClientState.itemTypeHover.value = ItemType.Empty;
            }
          },
          child: Draggable<int>(
            onDraggableCanceled: (velocity, offset){
              if (GameUI.mouseOverDialogType.value != DialogType.None) return;
              GameNetwork.sendClientRequestInventoryDrop(index);
            },
            hitTestBehavior: HitTestBehavior.opaque,
            data: index,
            feedback: buildItemTypeAtlasImage(itemType: itemType, scale: Slot_Item_Scale),
            child: onPressed(
                action: () => GameNetwork.sendClientRequestInventoryEquip(index),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    buildItemTypeAtlasImage(itemType: itemType, scale: Slot_Item_Scale),
                    if (GamePlayer.inventoryQuantity[index] > 1)
                      Positioned(
                          bottom: -5,
                          right: -5,
                          child: text(GamePlayer.inventoryQuantity[index], size: 14),
                      ),
                  ],
                ),
            ),
            childWhenDragging: buildItemTypeAtlasImage(itemType: itemType, scale: Slot_Item_Scale),
          ),
        ),
      ),
    );
  }

  static Widget buildStackSlotGrid() {
    final children = <Widget>[];
    for (var i = 0; i < GamePlayer.inventory.length; i++) {
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
        left: getIndexX(index) + 7,
        top: getIndexY(index) + 7,
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

  static Widget buildAtlasIconSlotEmpty() =>
      Engine.buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: 288,
        srcY: 0,
        srcWidth: Slot_Size,
        srcHeight: Slot_Size,
        scale: Slot_Scale,
      );

  static Widget buildAtlasIconSlotArmour() =>
      Engine.buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: 320,
        srcY: 0,
        srcWidth: Slot_Size,
        srcHeight: Slot_Size,
        scale: 1.0,
      );

  static Widget buildAtlasIconSlotLegs() =>
      Engine.buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: 352,
        srcY: 0,
        srcWidth: Slot_Size,
        srcHeight: Slot_Size,
        scale: 1.0,
      );

  static Widget buildAtlasIconSlotWeapon() =>
      Engine.buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: 384,
        srcY: 0,
        srcWidth: Slot_Size,
        srcHeight: Slot_Size,
        scale: 1.0,
      );

  static Widget buildAtlasIconSlotHead() =>
      Engine.buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: 416,
        srcY: 0,
        srcWidth: Slot_Size,
        srcHeight: Slot_Size,
        scale: 1.0,
      );

  static Widget buildPositionedContainerItemTypeInformation(int itemType){
    if (itemType == ItemType.Empty) return const SizedBox();

    final consumeType = ItemType.getConsumeType(itemType);

    return Positioned(
      top:  Engine.mousePosition.y + 25,
      left:  GameUI.mouseOverDialogTrade ? max(Engine.mousePosition.x - 100, 50) : null,
      right: GameUI.mouseOverDialogInventory ? max((Engine.screen.width - Engine.mousePosition.x) - 100, 50) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: brownDark,
        constraints: BoxConstraints(
          maxWidth: 400,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: text(ItemType.getName(itemType), color: Colors.blue)),
                if (GameUI.mouseOverDialogTrade)
                  text("${ItemType.getBuyPrice(itemType)} Gold", color: GameColors.yellowDark),
                if (GameUI.mouseOverDialogInventory && GamePlayer.interactModeTrading)
                  text("${ItemType.getSellPrice(itemType)} Gold", color: GameColors.yellowDark),
              ],
            ),
            text('type: ${ItemType.getGroupTypeName(itemType)}'),
            text('Damage: ${ItemType.getDamage(itemType)}'),
            text('Range: ${ItemType.getRange(itemType).toInt()}'),
            text('Cooldown: ${ItemType.getCooldown(itemType).toInt()}'),

            if (consumeType != ItemType.Empty)
               text("Uses: ${ItemType.getConsumeAmount(itemType)}x ${ItemType.getName(consumeType)}"),

            if (ItemType.isTypeRecipe(itemType))
              buildContainerRecipe(itemType),

            height16,

            if (GameUI.mouseOverDialogTrade)
              text("left click to buy", color: GameColors.inventoryHint),
            if (GameUI.mouseOverDialogInventory && ItemType.isTypeEquippable(itemType))
              text("left click to equip", color: GameColors.inventoryHint),
            if (GamePlayer.interactModeTrading && GameUI.mouseOverDialogInventory)
              text("right click to sell", color: GameColors.inventoryHint),
            if (!GamePlayer.interactModeTrading && GameUI.mouseOverDialogInventory)
              text("right click to drop", color: GameColors.inventoryHint),
          ],
        ),
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
