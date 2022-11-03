
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

import 'library.dart';

class GameInventoryUI {
  static const Slot_Size = 32.0;
  static const Slot_Scale = 1.5;
  static const Slot_Item_Scale = Slot_Scale * 0.9;
  static const ColumnsPerRow = 8;

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

  static DragTarget<int> buildDragTargetWeapon() => buildDragTarget(GamePlayer.weapon.type);
  static DragTarget<int> buildDragTargetBody() => buildDragTarget(GamePlayer.bodyType);
  static DragTarget<int> buildDragTargetHead() => buildDragTarget(GamePlayer.headType);

  static DragTarget<int> buildDragTarget(Watch<int> watchInt) =>
      DragTarget<int>(
        builder: (context, i, a) => watch(watchInt, buildContainerItemType),
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
            buildStackSlotGrid(),
            watch(GameInventory.reads, buildStackInventoryItems),
          ],
        ),
      );

  static Widget buildContainerItemType(int itemType) =>
      onPressed(
        action: (){
          print("pressed");
        },
        child: Container(
          color: brownLight,
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(6),
          child: buildAtlasImageItemType(itemType),
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Draggable<int>(
          hitTestBehavior: HitTestBehavior.opaque,
          data: index,
          feedback: buildItemTypeAtlasImage(itemType, scale: Slot_Item_Scale),
          child: onPressed(
              action: () => GameNetwork.sendClientRequestInventoryEquip(index),
              child: buildItemTypeAtlasImage(itemType, scale: Slot_Item_Scale),
          ),
          childWhenDragging: buildItemTypeAtlasImage(itemType, scale: Slot_Item_Scale),
        ),
      ),
    );
  }

  static buildItemTypeAtlasImage(int itemType, {double scale = 1.0}) =>
    buildAtlasImage(
      image: GameImages.atlasItems,
      srcX: AtlasItems.getSrcX(itemType),
      srcY: AtlasItems.getSrcY(itemType),
      srcWidth: Slot_Size,
      srcHeight: Slot_Size,
      scale: scale,
    );

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
              scale: Slot_Scale,
            );
          },
        )
    );

  static double getIndexX(int index) => getIndexColumn(index) * Slot_Size * Slot_Scale;

  static double getIndexY(int index) => getIndexRow(index) * Slot_Size * Slot_Scale;

  static int getIndexRow(int index) => index ~/ ColumnsPerRow;

  static int getIndexColumn(int index) =>  index % ColumnsPerRow;

  static Positioned buildPositionGridItem({required int index, required Widget child}) =>
    Positioned(
      left: getIndexX(index),
      top: getIndexY(index),
      child: child,
    );

  static Widget buildAtlasImageItemType(int itemType) =>
      buildAtlasImage(
        image: GameImages.atlasItems,
        srcX: AtlasItems.getSrcX(itemType),
        srcY: AtlasItems.getSrcY(itemType),
        srcWidth: 32,
        srcHeight: 32,
        scale: 3.0,
      );
}