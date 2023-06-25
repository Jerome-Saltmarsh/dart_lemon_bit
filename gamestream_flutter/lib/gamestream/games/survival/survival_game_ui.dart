
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/games/survival/survival_game.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:gamestream_flutter/library.dart';

import 'inventory_type.dart';

extension SurvivalGameUI on SurvivalGame {

  static final atlasIconSlotEmpty = GameIsometricUI.buildAtlasIconType(IconType.Slot, scale: Slot_Scale);
  static const Slot_Size = 32.0;
  static const Slot_Scale = 1.5;
  static const Scaled_Slot_Size = Slot_Size * Slot_Scale;
  static const Slot_Item_Scale = Slot_Scale * 0.9;
  static const Columns_Per_Row = 5;
  static const Inventory_Width = Slot_Size * Slot_Scale * Columns_Per_Row + 8;

  Widget buildWatchBeltType(Watch<int> watchBeltType) {
    return buildWatch(
        watchBeltType,
            (int beltItemType) {
          return Stack(
            children: [
              buildWatch(gamestream.isometric.server.equippedWeaponIndex, (equippedWeaponIndex) =>
                  buildDragTargetSlot(
                      index: gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBeltType),
                      scale: 2.0,
                      outlineColor: gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBeltType) == equippedWeaponIndex ? GameIsometricColors.white : GameIsometricColors.brown02
                  ),),
              Positioned(
                left: 5,
                top: 5,
                child: buildText(mapWatchBeltTypeTokeyboardKeyString(watchBeltType)),
              ),
              if (beltItemType != ItemType.Empty)
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  child: buildDraggableItemIndex(
                    itemIndex: gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBeltType),
                    scale: 2,
                  ),
                ),

              if (beltItemType != ItemType.Empty)
                Positioned(
                    right: 5,
                    bottom: 5,
                    child: buildInventoryAware(
                        builder: () => buildText(
                          gamestream.isometric.server.getWatchBeltTypeWatchQuantity(watchBeltType).value,
                          italic: true,
                          color: Colors.white70,
                        ))),
            ],
          );
        });
  }


  Widget buildDragTargetSlot({required int index, double scale = 1.0, Color? outlineColor}) =>
      DragTarget<int>(
        builder: (context, data, rejectedData) =>
            Container(
              width: 64,
              height: 64,
              decoration: GameIsometricUI.buildDecorationBorder(
                colorBorder: outlineColor ?? GameIsometricColors.brown01,
                colorFill: GameIsometricColors.brown02,
                width: 2,
              ),
            ),
        onWillAccept: (int? data) => data != null,
        onAccept: (int? data) {
          if (data == null) return;
          sendClientRequestInventoryMove(
            indexFrom: data,
            indexTo: index,
          );
        },
      );


  Column buildColumnBelt() => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildRowBeltItems(),
          width32,
        ],
      ),
      buildRowHotKeyLettersAndInventory(),
    ],
  );


  Row buildRowBeltItems() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      buildWatchBeltType(gamestream.isometric.server.playerBelt1_ItemType),
      buildWatchBeltType(gamestream.isometric.server.playerBelt2_ItemType),
      buildWatchBeltType(gamestream.isometric.server.playerBelt3_ItemType),
      buildWatchBeltType(gamestream.isometric.server.playerBelt4_ItemType),
    ],
  );


  Row buildRowHotKeyLettersAndInventory() => Row(
    children: [
      width96,
      buildWatchBeltType(gamestream.isometric.server.playerBelt5_ItemType),
      width64,
      buildWatchBeltType(gamestream.isometric.server.playerBelt6_ItemType),
      buildButtonInventory(),
    ],
  );


  Stack buildButtonInventory() {
    return Stack(
      children: [
        // TODO DragTarget
        DragTarget<int>(
          onWillAccept: (int? data){
            return data != null;
          },
          onAccept: (int? data){
            if (data == null) return;
            onAcceptDragInventoryIcon();
          },
          builder: (context, data, dataRejected){
            return onPressed(
              hint: 'Inventory',
              action: sendClientRequestInventoryToggle,
              onRightClick: sendClientRequestInventoryToggle,
              child: GameIsometricUI.buildAtlasIconType(IconType.Inventory, scale: 2.0),
            );
          },
        ),
        Positioned(top: 5, left: 5, child: buildText('R'))
      ],
    );
  }


  Widget buildStackSlotGrid() {
    final children = <Widget>[];
    for (var i = 0; i < gamestream.isometric.server.inventory.length; i++) {
      children.add(buildPositionedGridSlot(i));
    }
    return Stack(
      children: children,
    );
  }


  Widget buildInventoryUI() =>
      GSDialog(
        child: Container(
          width: Inventory_Width,
          color: GameIsometricColors.brownDark,
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: buildContainerPlayerStats()),
                    buildContainerEquippedItems(),
                  ],
                ),
              ),
              buildContainerInventory(),
            ],
          ),
        ),
      );


  Widget buildContainerInventory() =>
      Container(
        height: 300,
        child: Stack(
          children: [
            buildStackSlotGrid(),
            buildStackInventoryItems(),
          ],
        ),
      );


  Widget buildStackInventoryItems() =>
      buildWatch(inventoryReads, (int reads){
        final positioned = <Widget>[];
        for (var i = 0; i < gamestream.isometric.server.inventory.length; i++){
          if (gamestream.isometric.server.inventory[i] == ItemType.Empty) continue;
          positioned.add(
              buildPositionInventoryItem(i)
          );
        }
        return Stack(
          children: positioned,
        );
      });


  Widget buildPositionInventoryItem(int index) =>
      buildPositionGridItem(
        index: index,
        child: buildDraggableItemIndex(itemIndex: index, itemQuantity: gamestream.isometric.server.getItemQuantityAtIndex(index)),
      );


  Widget buildPositionGridItem({required int index, required Widget child}) =>
      buildPositionGridElement(
        index: index,
        child: DragTarget<int>(
          onWillAccept: (int? index) => index != null,
          onAccept: (int? indexFrom){
            if (indexFrom == null) return;
            sendClientRequestInventoryMove(
              indexFrom: indexFrom,
              indexTo: index,
            );
          },
          builder: (context, candidate, i){
            return child;
          },
        ),
      );

  Widget buildDraggableItemIndex({required int itemIndex, double scale = Slot_Item_Scale, int? itemQuantity}) =>
      Draggable(
        onDragStarted: () => onDragStarted(itemIndex),
        onDragEnd: onDragEnd,
        onDraggableCanceled: onDragCancelled,
        onDragCompleted: onDragCompleted,
        data: itemIndex,
        hitTestBehavior: HitTestBehavior.opaque,
        feedback: buildPressableItemIndex(
          itemIndex: itemIndex,
          scale: scale,
          itemQuantity: itemQuantity,
        ),
        child: buildPressableItemIndex(
          itemIndex: itemIndex,
          scale: scale,
          itemQuantity: itemQuantity,
        ),
      );

  Container buildContainerPlayerStats({Color? backgroundColor}) =>
      Container(
        color: backgroundColor ?? Colors.white12,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        height: 148,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildPlayerHealthBar(),
            height8,
            buildPlayerEnergyBar(),
            height8,
            buildPlayerDamageBar(),
            height8,
          ],
        ),
      );

  Widget buildPressableItemIndex({
    required int itemIndex,
    double scale = Slot_Item_Scale,
    int? itemType,
    int? itemQuantity,
  }) =>
      onPressed(
        action: () => onItemIndexPrimary(itemIndex),
        onRightClick: () => onItemIndexSecondary(itemIndex),
        child: MouseRegion(
          onEnter: (event) {
            engine.mousePositionX = event.position.dx;
            engine.mousePositionY = event.position.dy;
            hoverIndex.value = itemIndex;
          },
          onExit: (_) {
            if (hoverIndex.value == itemIndex) {
              clearHoverIndex();
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: 32 * scale,
            height: 32 * scale,
            child: Stack(
              children: [
                GameIsometricUI.buildAtlasItemType(
                  itemType ?? gamestream.isometric.server.getItemTypeAtInventoryIndex(itemIndex),
                ),
                if (itemQuantity != null && itemQuantity > 1)
                  Positioned(child: buildText(itemQuantity, size: 13, color: Colors.white70), right: 0, bottom: 0),
              ],
            ),
          ),
        ),
      );

  Widget buildContainerEquippedItems() =>
      DragTarget<int>(
          onWillAccept: onDragWillAccept,
          onAccept: onDragAcceptEquippedItemContainer,
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

  bool onDragWillAccept(int? i) => i != null;

  Widget buildPositionGridElement({
    required int index,
    required Widget child,
  }) =>
      Positioned(
        left: getIndexX(index),
        top: getIndexY(index),
        child: child,
      );

  double getIndexX(int index) => getIndexColumn(index) * Scaled_Slot_Size;

  double getIndexY(int index) => getIndexRow(index) * Scaled_Slot_Size;


  int getIndexRow(int index) => index ~/ Columns_Per_Row;

  int getIndexColumn(int index) =>  index % Columns_Per_Row;

  Widget buildWatchEquippedItemType(Watch<int> watchInt, int index) =>
      Container(
        alignment: Alignment.center,
        width: 32 * Slot_Scale, height: 32 * Slot_Scale, color: GameIsometricColors.brown02,
        child: buildWatch(watchInt, (int itemType) => buildDraggableItemIndex(itemIndex: index)),
      );


  Widget buildContainerEquippedWeapon() =>
      buildWatchEquippedItemType(gamestream.isometric.player.weapon, ItemType.Equipped_Weapon);

  Widget buildContainerEquippedBody() =>
      buildWatchEquippedItemType(gamestream.isometric.player.body, ItemType.Equipped_Body);

  Widget buildContainerEquippedHead() =>
      buildWatchEquippedItemType(gamestream.isometric.player.head, ItemType.Equipped_Head);

  Widget buildContainerEquippedLegs() =>
      buildWatchEquippedItemType(gamestream.isometric.player.legs, ItemType.Equipped_Legs);


  Widget buildIconSlotEmpty() =>
      GameIsometricUI.buildAtlasIconType(IconType.Slot, scale: Slot_Scale);

  Widget buildPositionedGridSlot(int i) =>
      buildPositionGridItem(
        index: i,
        child: atlasIconSlotEmpty,
      );

  static String mapWatchBeltTypeTokeyboardKeyString(Watch<int> hotKeyWatch){
    if (hotKeyWatch == gamestream.isometric.server.playerBelt1_ItemType) return '1';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt2_ItemType) return '2';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt3_ItemType) return '3';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt4_ItemType) return '4';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt5_ItemType) return 'Q';
    if (hotKeyWatch == gamestream.isometric.server.playerBelt6_ItemType) return 'E';
    throw Exception('ClientQuery.mapHotKeyWatchToString($hotKeyWatch)');
  }

  /// Automatically rebuilds whenever the inventory gets updated
  Widget buildInventoryAware({required BasicWidgetBuilder builder}) =>
      buildWatch(inventoryReads, (int reads) => builder());

  Widget buildStackHotKeyContainer({
    required int itemType,
    required String hotKey,
  }) => Stack(
    children: [
      GameIsometricUI.buildAtlasIconType(IconType.Slot, scale: 2.0),
      GameIsometricUI.buildAtlasItemType(itemType),
      Positioned(
        left: 5,
        top: 5,
        child: buildText(hotKey),
      ),
      if (ItemType.getConsumeType(itemType) != ItemType.Empty)
        Positioned(
            right: 5,
            bottom: 5,
            child: buildInventoryAware(
                builder: () => buildText(
                  gamestream.isometric.server.getItemTypeConsumesRemaining(itemType),
                  italic: true,
                  color: Colors.white70,
                ))),
      if (itemType != ItemType.Empty && gamestream.isometric.player.weapon.value == itemType)
        Container(
          width: 64,
          height: 64,
          decoration: GameIsometricUI.buildDecorationBorder(
            colorBorder: Colors.white,
            colorFill: Colors.transparent,
            width: 3,
          ),
        )
    ],
  );

  Widget buildPlayerHealthBar() {
    const width = 150.0;
    const height = 30.0;
    return GSDialog(
      child: buildHoverTarget(
        hoverTargetType: InventoryType.Hover_Target_Player_Stats_Health,
        child: buildWatch(gamestream.isometric.server.playerMaxHealth, (int maxHealth) {
          return buildWatch(gamestream.isometric.server.playerHealth, (int currentHealth) {
            return Stack(
              children: [
                Container(color: Colors.white24, height: height, width: width),
                Container(color: GameIsometricColors.Red_3, height: height, width: width * (currentHealth / maxHealth)),
                Container(
                  padding: const EdgeInsets.all(6),
                  width: width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        child: FittedBox(
                            child: GameIsometricUI.buildAtlasIconType(IconType.Heart)
                        ),
                      ),
                      buildText(
                          '$currentHealth / ${padSpace(maxHealth, length: 3)}',
                          color: GameStyle.Player_Stats_Text_Color
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        }),
      ),
    );
  }

  Widget buildHoverTarget({required Widget child, required int hoverTargetType}) =>
      MouseRegion(
        onEnter: (_){
          this.hoverTargetType.value = hoverTargetType;
        },
        onExit: (_){
          if (this.hoverTargetType.value == hoverTargetType){
            this.hoverTargetType.value = InventoryType.Hover_Target_None;
          }
        },
        child: child,
      );

  Widget buildPlayerDamageBar() {
    return GSDialog(
      child: buildHoverTarget(
        hoverTargetType: InventoryType.Hover_Target_Player_Stats_Damage,
        child: buildWatch(gamestream.isometric.server.playerDamage, (int damage) {
          return Container(
            color: Colors.white24,
            padding: const EdgeInsets.all(6),
            width: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: 20,
                    height: 20,
                    child: FittedBox(
                        child:
                        GameIsometricUI.buildAtlasIconType(IconType.Damage))),
                buildText(damage, color: GameStyle.Player_Stats_Text_Color),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget buildPlayerEnergyBar() {
    const width = 150.0;
    const height = 30.0;

    return GSDialog(
      child: buildHoverTarget(
        hoverTargetType: InventoryType.Hover_Target_Player_Stats_Energy,
        child: buildWatch(gamestream.isometric.player.energyMax, (int energyMax) {
          return buildWatch(gamestream.isometric.player.energy, (int energy) {
            return Stack(
              children: [
                Container(color: Colors.white24, height: height, width: width),
                Container(color: GameIsometricColors.Blue_3, height: height, width: width * (energy / energyMax)),
                Container(
                  padding: const EdgeInsets.all(6),
                  width: width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: 20,
                          height: 20,
                          child: FittedBox(
                              child:
                              GameIsometricUI.buildAtlasIconType(IconType.Energy))),
                      buildText('$energy / ${padSpace(energyMax, length: 3)}',
                          color: GameStyle.Player_Stats_Text_Color),
                    ],
                  ),
                ),
              ],
            );
          });
        }),
      ),
    );
  }

}