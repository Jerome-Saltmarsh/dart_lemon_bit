
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

import 'library.dart';

class GameInventoryUI {
  static const Slot_Size = 32.0;
  static const ColumnsPerRow = 10;

  static int convertIndexToRow(int index){
    return index ~/ ColumnsPerRow;
  }

  static int convertIndexToColumn(int index){
    return index % ColumnsPerRow;
  }

  static int convertToIndex({required int row, required int column}){
    return row * ColumnsPerRow + column;
  }

  static Widget buildInventoryUI() =>
      MouseRegion(
        onEnter: (event){
          GameCanvas.cursorVisible = false;
        },
        onExit: (event){
          GameCanvas.cursorVisible = true;
        },
        child: Column(
          children: [
            buildRowEquippedItems(),
            buildContainerInventory(),
          ],
        ),
      );

  static Row buildRowEquippedItems() => Row(
        children: [
          buildDragTargetWeapon(),
          buildDragTargetBody(),
          buildDragTargetHead(),
        ],
      );

  static DragTarget<int> buildDragTargetWeapon() =>
    DragTarget<int>(
      builder: (context, i, a) {
        return watch(GamePlayer.weapon.type, buildPanelPlayerEquippedAttackType);
      },
      onWillAccept: onDragWillAccept,
      onAccept: onDragAccept,
    );

  static Widget buildDragTargetBody() =>
    DragTarget<int>(
      builder: (context, i, a) {
        return watch(GamePlayer.bodyType, buildPanelPlayerEquippedBodyType);
      },
      onWillAccept: onDragWillAccept,
      onAccept: onDragAccept,
    );

  static Widget buildDragTargetHead() =>
    DragTarget<int>(
      builder: (context, i, a) {
        return watch(GamePlayer.headType, buildPanelPlayerEquippedHeadType);
      },
      onWillAccept: onDragWillAccept,
      onAccept: onDragAccept,
    );


  static Widget buildContainerInventory() =>
      Container(
        color: brownLight,
        width: 400,
        height: 400,
        padding: const EdgeInsets.all(6),
        child: Stack(
          children: [
            buildInventorySlotGrid(),
            watch(GameInventory.reads, buildInventoryItemGrid),
          ],
        ),
      );

  static Widget buildPanelPlayerEquippedAttackType(int bodyType) =>
      Container(
        color: brownLight,
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(6),
        child: GameUI.buildIconAttackType(bodyType),
      );

  static Widget buildPanelPlayerEquippedBodyType(int bodyType) =>
      Container(
        color: brownLight,
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(6),
        child: buildIconItemType(bodyType),
      );


  static Widget buildPanelPlayerEquippedHeadType(int headType) =>
      Container(
        color: brownLight,
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(6),
        child: buildIconItemType(headType),
      );

  static bool onDragWillAccept(int? i) => i != null;

  static void onDragAccept(int? i){
    if (i == null) return;
    GameNetwork.sendClientRequestInventoryEquip(i);
  }

  static Widget buildInventoryItemGrid(int reads){
    final children = <Widget>[];
    for (var i = 0; i < GameInventory.items.length; i++){
      children.add(buildInventoryItem(i));
    }
    return Stack(
      children: children,
    );
  }

  static Widget buildInventoryItem(int i){
    const size = 32.0;
    return Positioned(
      left: convertIndexToColumn(i) * Slot_Size,
      top: convertIndexToRow(i) * Slot_Size,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Draggable<int>(
          hitTestBehavior: HitTestBehavior.opaque,
          data: i,
          feedback: buildAtlasImage(
            image: GameImages.atlasIcons,
            srcX: AtlasItems.getSrcX(i),
            srcY: AtlasItems.getSrcY(i),
            srcWidth: size,
            srcHeight: size,
          ),
          child: buildAtlasImage(
            image: GameImages.atlasIcons,
            srcX: AtlasItems.getSrcX(i),
            srcY: AtlasItems.getSrcY(i),
            srcWidth: size,
            srcHeight: size,
          ),
          childWhenDragging: buildAtlasImage(
            image: GameImages.atlasIcons,
            srcX: AtlasItems.getSrcX(i),
            srcY: AtlasItems.getSrcY(i),
            srcWidth: size,
            srcHeight: size,
          ),
        ),
      ),
    );
  }

  // static double getInventoryItemSrcX(int index){
  //   switch (GameInventory.itemType[index]) {
  //     case ItemType.Body:
  //       return AtlasIconsX.getBodyType(GameInventory.itemSubType[index]);
  //     case ItemType.Weapon:
  //       return AtlasIconsX.getWeaponType(GameInventory.itemSubType[index]);
  //     case ItemType.Head:
  //       return AtlasIconsX.getHeadType(GameInventory.itemSubType[index]);
  //     default:
  //       throw Exception('GameUI.getInventoryItemSrcX($index)');
  //   }
  // }

  // static double getInventoryItemSrcY(int index){
  //   switch (GameInventory.itemType[index]) {
  //     case ItemType.Body:
  //       return AtlasIconsY.getBodyType(GameInventory.itemSubType[index]);
  //     case ItemType.Weapon:
  //       return AtlasIconsY.getWeaponType(GameInventory.itemSubType[index]);
  //     case ItemType.Head:
  //       return AtlasIconsY.getHeadType(GameInventory.itemSubType[index]);
  //     default:
  //       throw Exception('GameUI.getInventoryItemSrcY($index)');
  //   }
  // }
  

  static int getIndexRow(int index) =>
    index ~/ ColumnsPerRow;

  static int getIndexColumn(int index) =>
      index % ColumnsPerRow;

  static Widget buildInventorySlotGrid() =>
    Stack(
      children: GameInventory.items.map(buildPositionedGridSlot).toList(),
    );

  static Widget buildPositionedGridSlot(int i) =>
    Positioned(
        top: getIndexRow(i) * 32.0,
        left: getIndexColumn(i) * 32.0,
        child: DragTarget<int>(
          onWillAccept: (int? index) => index != null,
          onAccept: (int? toIndex){
            if (toIndex == null) return;
            GameNetwork.sendClientRequestInventoryMove(
              indexFrom: i,
              indexTo: toIndex,
            );
          },
          builder: (context, candidate, index){
            return buildAtlasImage(
              image: GameImages.atlasItems,
              srcX: 0,
              srcY: 64,
              srcWidth: 32,
              srcHeight: 32,
            );
          },
        )
    );

  static Widget buildColumnPlayerWeapons(List<Weapon> weapons) =>
      Container(
        color: brownLight,
        width: 300,
        height: 400,
        padding: const EdgeInsets.all(6),
        child: text("weapons"),
      );


  static Widget buildIconItemType(int itemType) =>
      buildAtlasImage(
        image: GameImages.atlasItems,
        srcX: AtlasItems.getSrcX(itemType),
        srcY: AtlasItems.getSrcY(itemType),
        srcWidth: AtlasItems.getSrcX(itemType),
        srcHeight: AtlasItems.getSrcY(itemType),
        scale: 3.0,
      );
}