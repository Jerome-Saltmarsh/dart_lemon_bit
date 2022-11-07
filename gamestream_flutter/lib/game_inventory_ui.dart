
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
  static const ColumnsPerRow = 7;
  static final itemTypeHover = Watch(ItemType.Empty);
  static const Inventory_Width = Slot_Size * Slot_Scale * ColumnsPerRow;

  static Widget buildInventoryUI() =>
      GameUI.buildDialog(
        dialogType: DialogType.Inventory,
        child: Column(
          children: [
            buildContainerEquippedItems(),
            buildContainerInventory(),
          ],
        ),
      );

  static Widget buildContainerEquippedItems() => Container(
        width: Inventory_Width,
        height: 80.0,
        color: brownDark,
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
        itemTypeHover.value = itemType;
      },
      onExit: (_){
        if (itemTypeHover.value == itemType){
          itemTypeHover.value = ItemType.Empty;
        }
      },
      child: buildItemTypeAtlasImage(itemType: itemType, scale: scale),
    );
  }

  static Widget buildContainerInventory() =>
      Container(
        color: brownLight,
        width: Inventory_Width,
        height: 400,
        // padding: const EdgeInsets.all(6),
        child: Stack(
          children: [
            buildStackSlotGrid(),
            watch(GameInventory.reads, buildStackInventoryItems),
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
     for (var i = 0; i < GameInventory.items.length; i++){
         if (GameInventory.items[i] == ItemType.Empty) continue;
         positioned.add(
           buildPositionInventoryItem(i)
         );
     }
     return Stack(
       children: positioned,
     );
  }

  static Widget buildPositionInventoryItem(int index){
    final itemType = GameInventory.items[index];
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
            itemTypeHover.value = itemType;
          },
          onExit: (_){
            if (itemTypeHover.value == itemType){
               itemTypeHover.value = ItemType.Empty;
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
                child: buildItemTypeAtlasImage(itemType: itemType, scale: Slot_Item_Scale),
            ),
            childWhenDragging: buildItemTypeAtlasImage(itemType: itemType, scale: Slot_Item_Scale),
          ),
        ),
      ),
    );
  }

  static Widget buildStackSlotGrid() {
    final children = <Widget>[];
    for (var i = 0; i < GameInventory.items.length; i++) {
       children.add(buildPositionedGridSlot(i));
    }
    return Stack(
      children: children,
    );
  }

  static Widget buildPositionedGridSlot(int i) =>
    buildPositionGridItem(
        index: i,
        child: buildAtlasIconSlotEmpty()
    );

  static double getIndexX(int index) => getIndexColumn(index) * Scaled_Slot_Size;

  static double getIndexY(int index) => getIndexRow(index) * Scaled_Slot_Size;

  static int getIndexRow(int index) => index ~/ ColumnsPerRow;

  static int getIndexColumn(int index) =>  index % ColumnsPerRow;

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
    return Positioned(
      top:  Engine.mousePosition.y + 10,
      left: max(10, min(Engine.mousePosition.x - 170, Engine.screen.width - 300)),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: brownDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text(ItemType.getGroupTypeName(itemType), color: Colors.blue),
            text(ItemType.getName(itemType)),
            text('Damage: ${ItemType.getDamage(itemType)}'),
            text('Range: ${ItemType.getRange(itemType).toInt()}'),
            text('Cooldown: ${ItemType.getCooldown(itemType).toInt()}'),

            if (ItemType.isTypeRecipe(itemType))
              buildContainerRecipe(itemType),

            height16,
            text("left click to ${GameUI.mouseOverDialogInventory ? 'equip' : 'buy'}", color: GameColors.inventoryHint),
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
