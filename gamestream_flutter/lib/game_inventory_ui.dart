
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

import 'library.dart';

class GameInventoryUI {

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
            Row(
              children: [
                buildContainerWeapon(),
                watch(GamePlayer.bodyType, buildPanelPlayerEquippedBodyType),
                watch(GamePlayer.headType, buildPanelPlayerEquippedHeadType),
              ],
            ),
            buildInventory(),
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
        child: buildIconBodyType(bodyType),
      );

  static Widget buildPanelPlayerEquippedHeadType(int headType) =>
      Container(
        color: brownLight,
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(6),
        child: buildIconHeadType(headType),
      );

  static DragTarget<int> buildContainerWeapon() {
    return DragTarget<int>(
      builder: (context, i, a) {
        return watch(GamePlayer.weapon.type, buildPanelPlayerEquippedAttackType);
      },
      onWillAccept: (int? i){
        if (i == null) return false;
        if (GameInventory.itemType[i] != ItemType.Weapon) return false;
        return true;
      },
      onAccept: (int? i){
        if (i == null) return;
        GameNetwork.sendClientInventoryRequest(
          inventoryRequest: InventoryRequest.Equip_Weapon,
          message: GameInventory.index[i],
        );
      },
    );
  }

  static Widget buildInventory() =>
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

  static Widget buildInventoryItemGrid(int reads){
    final children = <Widget>[];
    for (var i = 0; i < GameInventory.total; i++){
      children.add(buildInventoryItem(i));
    }
    return Stack(
      children: children,
    );
  }

  static Widget buildInventoryItem(int i){
    final index = GameInventory.index[i];
    return Positioned(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Draggable<int>(
          hitTestBehavior: HitTestBehavior.opaque,
          data: i,
          feedback: buildAtlasImage(
            image: GameImages.atlasIcons,
            srcX: getInventoryItemSrcX(i),
            srcY: getInventoryItemSrcY(i),
            srcWidth: getInventoryItemSrcSize(i),
            srcHeight: getInventoryItemSrcSize(i),
          ),
          child: buildAtlasImage(
            image: GameImages.atlasIcons,
            srcX: getInventoryItemSrcX(i),
            srcY: getInventoryItemSrcY(i),
            srcWidth: getInventoryItemSrcSize(i),
            srcHeight: getInventoryItemSrcSize(i),
          ),
          childWhenDragging: buildAtlasImage(
            image: GameImages.atlasIcons,
            srcX: getInventoryItemSrcX(i),
            srcY: getInventoryItemSrcY(i),
            srcWidth: getInventoryItemSrcSize(i),
            srcHeight: getInventoryItemSrcSize(i),
          ),
        ),
      ),
      left: InventoryDimensions.convertIndexToColumn(index) * GameInventory.Size,
      top: InventoryDimensions.convertIndexToRow(index) * GameInventory.Size,
    );
  }

  static double getInventoryItemSrcX(int index){
    switch (GameInventory.itemType[index]) {
      case ItemType.Body:
        return AtlasIconsX.getBodyType(GameInventory.itemSubType[index]);
      case ItemType.Weapon:
        return AtlasIconsX.getWeaponType(GameInventory.itemSubType[index]);
      case ItemType.Head:
        return AtlasIconsX.getHeadType(GameInventory.itemSubType[index]);
      default:
        throw Exception('GameUI.getInventoryItemSrcX($index)');
    }
  }

  static double getInventoryItemSrcY(int index){
    switch (GameInventory.itemType[index]) {
      case ItemType.Body:
        return AtlasIconsY.getBodyType(GameInventory.itemSubType[index]);
      case ItemType.Weapon:
        return AtlasIconsY.getWeaponType(GameInventory.itemSubType[index]);
      case ItemType.Head:
        return AtlasIconsY.getHeadType(GameInventory.itemSubType[index]);
      default:
        throw Exception('GameUI.getInventoryItemSrcY($index)');
    }
  }

  static double getInventoryItemSrcSize(int index){
    switch (GameInventory.itemType[index]) {
      case ItemType.Body:
        return AtlasIconSize.getBodyType(GameInventory.itemSubType[index]);
      case ItemType.Weapon:
        return AtlasIconSize.getWeaponType(GameInventory.itemSubType[index]);
      case ItemType.Head:
        return AtlasIconSize.getHeadType(GameInventory.itemSubType[index]);
      default:
        throw Exception('GameUI.getInventoryItemSrcSize($index)');
    }
  }

  static Widget buildInventorySlotGrid(){
    final rows = <Widget>[];

    for (var row = 0; row < InventoryDimensions.Rows; row++){
      final columns = <Widget>[];
      for (var column = 0; column < InventoryDimensions.Columns; column++){
        columns.add(
            DragTarget<int>(
              onWillAccept: (int? index){
                return true;
              },
              onAccept: (int? i){
                if (i == null) return;
                GameNetwork.sendClientRequestInventoryMove(
                  indexFrom: GameInventory.index[i],
                  indexTo: InventoryDimensions.convertToIndex(row: row, column: column),
                );
              },
              builder: (context, candidate, index){
                return buildAtlasImage(
                  image: GameImages.atlasIcons,
                  srcX: AtlasIconsX.Slot,
                  srcY: AtlasIconsY.Slot,
                  srcWidth: AtlasIconSize.Slot,
                  srcHeight: AtlasIconSize.Slot,
                );
              },
            )
        );
      }
      rows.add(
          Row(
            children: columns,
          )
      );
    }
    return Column(
      children: rows,
    );
  }

  static Widget buildColumnPlayerWeapons(List<Weapon> weapons) =>
      Container(
        color: brownLight,
        width: 300,
        height: 400,
        padding: const EdgeInsets.all(6),
        child: text("weapons"),
      );

  static Widget buildIconBodyType(int bodyType) =>
      buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: AtlasIconsX.getBodyType(bodyType),
        srcY: AtlasIconsY.getBodyType(bodyType),
        srcWidth: AtlasIconSize.getBodyType(bodyType),
        srcHeight: AtlasIconSize.getBodyType(bodyType),
        scale: 3.0,
      );

  static Widget buildIconHeadType(int headType) =>
      buildAtlasImage(
        image: GameImages.atlasIcons,
        srcX: AtlasIconsX.getHeadType(headType),
        srcY: AtlasIconsY.getHeadType(headType),
        srcWidth: AtlasIconSize.getHeadType(headType),
        srcHeight: AtlasIconSize.getHeadType(headType),
        scale: 3.0,
      );
}