
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/language_utils.dart';

import 'library.dart';

class GameInventoryUI {
  static const Slot_Size = 32.0;
  static const Slot_Scale = 1.5;
  static const Scaled_Slot_Size = Slot_Size * Slot_Scale;
  static const Slot_Item_Scale = Slot_Scale * 0.9;
  static const Columns_Per_Row = 5;
  static const Inventory_Width = Slot_Size * Slot_Scale * Columns_Per_Row + 8;
  static final atlasIconSlotEmpty = GameUI.buildIconSlotEmpty();

  static Widget buildInventoryUI() =>
      GameUI.buildDialog(
        dialogType: DialogType.Inventory,
        child: Container(
          width: Inventory_Width,
          color: GameColors.brownDark,
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

  static Widget buildHoverTarget({required Widget child, required int hoverTargetType}) =>
      MouseRegion(
        onEnter: (_){
          ClientState.hoverTargetType.value = hoverTargetType;
        },
        onExit: (_){
          if (ClientState.hoverTargetType.value == hoverTargetType){
            ClientState.hoverTargetType.value = ClientType.Hover_Target_None;
          }
        },
        child: child,
    );

  static Container buildContainerPlayerStats({Color? backgroundColor}) =>
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

  static Widget buildPlayerDamageBar() {
    return GameUI.buildDialogUIControl(
      child: buildHoverTarget(
              hoverTargetType: ClientType.Hover_Target_Player_Stats_Damage,
              child: watch(ServerState.playerDamage, (int damage) {
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
                                  GameUI.buildAtlasIconType(IconType.Damage))),
                      text(damage, color: GameStyle.Player_Stats_Text_Color),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  static Widget buildPlayerEnergyBar() {
    const width = 150.0;
    const height = 30.0;

    return GameUI.buildDialogUIControl(
      child: buildHoverTarget(
              hoverTargetType: ClientType.Hover_Target_Player_Stats_Energy,
              child: watch(GamePlayer.energyMax, (int energyMax) {
                return watch(GamePlayer.energy, (int energy) {
                  return Stack(
                    children: [
                      Container(color: Colors.white24, height: height, width: width),
                      Container(color: GameColors.Blue_3, height: height, width: width * (energy / energyMax)),
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
                                    GameUI.buildAtlasIconType(IconType.Energy))),
                            text("$energy / ${padSpace(energyMax, length: 3)}",
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

  // TODO optimize
  static Widget buildPlayerHealthBar() {
    const width = 150.0;
    const height = 30.0;
    return GameUI.buildDialogUIControl(
      child: buildHoverTarget(
              hoverTargetType: ClientType.Hover_Target_Player_Stats_Health,
              child: watch(ServerState.playerMaxHealth, (int maxHealth) {
                return watch(ServerState.playerHealth, (int currentHealth) {
                  return Stack(
                    children: [
                      Container(color: Colors.white24, height: height, width: width),
                      Container(color: GameColors.Red_3, height: height, width: width * (currentHealth / maxHealth)),
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
                                    child: GameUI.buildAtlasIconType(IconType.Heart)
                                ),
                            ),
                            text(
                                "$currentHealth / ${padSpace(maxHealth, length: 3)}",
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

  static Widget buildPressableItemIndex({
    required int itemIndex,
    double scale = Slot_Item_Scale,
    int? itemType,
    int? itemQuantity,
  }) =>
      onPressed(
        action: () => ClientEvents.onItemIndexPrimary(itemIndex),
        onRightClick: () => ClientEvents.onItemIndexSecondary(itemIndex),
        child: MouseRegion(
          onEnter: (event) {
            Engine.mousePositionX = event.position.dx;
            Engine.mousePositionY = event.position.dy;
            ClientState.hoverIndex.value = itemIndex;
          },
          onExit: (_) {
            if (ClientState.hoverIndex.value == itemIndex) {
              ClientActions.clearHoverIndex();
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: 32 * scale,
            height: 32 * scale,
            child: Stack(
              children: [
                GameUI.buildAtlasItemType(
                  itemType ?? ServerQuery.getItemTypeAtInventoryIndex(itemIndex),
                ),
                if (itemQuantity != null && itemQuantity > 1)
                  Positioned(child: text(itemQuantity, size: 13, color: Colors.white70), right: 0, bottom: 0),
              ],
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
            buildStackInventoryItems(),
          ],
        ),
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


  static bool onDragWillAccept(int? i) => i != null;

  static Widget buildStackInventoryItems() =>
      watch(ClientState.inventoryReads, (int reads){
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
    });

  static Widget buildPositionInventoryItem(int index) =>
      buildPositionGridItem(
        index: index,
        child: buildDraggableItemIndex(itemIndex: index, itemQuantity: ServerQuery.getItemQuantityAtIndex(index)),
      );

  static Widget buildDraggableItemIndex({required int itemIndex, double scale = Slot_Item_Scale, int? itemQuantity}) =>
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
          itemQuantity: itemQuantity,
        ),
        child: buildPressableItemIndex(
          itemIndex: itemIndex,
          scale: scale,
          itemQuantity: itemQuantity,
        ),
      );

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

  static Widget buildPositionedContainerHoverTarget(int hoverTarget){
     if (hoverTarget == ClientType.Hover_Target_None) return GameStyle.Null;;

     final children = <Widget>[];

     if (hoverTarget == ClientType.Hover_Target_Player_Stats_Damage){
         final total = ServerState.playerDamage.value;
         children.add(Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             text("Damage", color: GameColors.blue),
             text(total, color: GameColors.blue),
           ],
         ));
         children.add(height8);

         children.add(
             _buildRowHoverValue(
                 itemType: ItemType.Base_Damage,
                 // value: ServerState.playerBaseDamage.value,
                 value: 0,
                 total: total,
             )
         );

         final equippedWeaponType = ServerQuery.getEquippedWeaponType();
         children.add(
             _buildRowHoverValue(
               itemType: equippedWeaponType,
               // value: GameOptions.getItemTypeDamage(equippedWeaponType, ignoreEmpty: false),
               value: 0,
               total: total,
             )
         );

         if (GamePlayer.head.value != ItemType.Empty) {
           children.add(
               _buildRowHoverValue(itemType: GamePlayer.head.value,
                 // value: GameOptions.getItemTypeDamage(GamePlayer.head.value),
                 value: 0,
                 total: total,)
           );
         }
         if (GamePlayer.body.value != ItemType.Empty) {
           children.add(
               _buildRowHoverValue(itemType: GamePlayer.body.value,
                 // value: GameOptions.getItemTypeDamage(GamePlayer.body.value),
                 value: 0,
                 total: total,)
           );
         }
         if (GamePlayer.legs.value != ItemType.Empty) {
           children.add(
               _buildRowHoverValue(itemType: GamePlayer.legs.value,
                 // value: GameOptions.getItemTypeDamage(GamePlayer.legs.value),
                 value: 0,
                 total: total,)
           );
         }
         for (final beltType in ServerState.watchBeltItemTypes) {
           if (!ItemType.isTypeTrinket(beltType.value)) continue;
           children.add(
               _buildRowHoverValue(
                   itemType: beltType.value,
                   // value: GameOptions.getItemTypeDamage(beltType.value),
                   value: 0,
                   total: total,
               )
           );
         }
     }

     if (hoverTarget == ClientType.Hover_Target_Player_Stats_Health){
       final total = ServerState.playerMaxHealth.value;
       children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text("Health", color: GameColors.blue),
          text(total, color: GameColors.blue),
        ],
      ));
       children.add(height8);

       children.add(
           _buildRowHoverValue(
             itemType: ItemType.Base_Health,
             // value: ServerState.playerBaseHealth.value,
             value: 0,
             total: total,
           )
       );

       children.add(
           _buildRowHoverValue(itemType: GamePlayer.head.value, value: ItemType.getMaxHealth(GamePlayer.head.value), total: total)
       );
       children.add(
           _buildRowHoverValue(itemType: GamePlayer.body.value, value: ItemType.getMaxHealth(GamePlayer.body.value), total: total)
       );
       children.add(
           _buildRowHoverValue(itemType: GamePlayer.legs.value, value: ItemType.getMaxHealth(GamePlayer.legs.value), total: total)
       );
       for (final beltType in ServerState.watchBeltItemTypes) {
         if (!ItemType.isTypeTrinket(beltType.value)) continue;
         children.add(
             _buildRowHoverValue(itemType: beltType.value, value: ItemType.getMaxHealth(beltType.value), total: total)
         );
       }
       final equippedWeapon = ServerQuery.getEquippedWeaponType();
       children.add(
           _buildRowHoverValue(itemType: equippedWeapon, value: ItemType.getMaxHealth(equippedWeapon), total: total)
       );
     }

     if (hoverTarget == ClientType.Hover_Target_Player_Stats_Energy) {
       final total = GamePlayer.energyMax.value;
       children.add(Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           text("Energy", color: GameColors.blue),
           text(total, color: GameColors.blue),
         ],
       ));
       children.add(height8);

       children.add(
           _buildRowHoverValue(
             itemType: ItemType.Base_Energy,
             // value: ServerState.playerBaseEnergy.value,
             value: 0,
             total: total,
           )
       );

       if (GamePlayer.head.value != ItemType.Empty) {
         children.add(
             _buildRowHoverValue(itemType: GamePlayer.head.value,
               value: ItemType.getEnergy(GamePlayer.head.value),
               total: total,)
         );
       }

       if (GamePlayer.body.value != ItemType.Empty) {
         children.add(
             _buildRowHoverValue(itemType: GamePlayer.body.value,
               value: ItemType.getEnergy(GamePlayer.body.value),
               total: total,)
         );
       }
       if (GamePlayer.legs.value != ItemType.Empty) {
         children.add(
             _buildRowHoverValue(itemType: GamePlayer.legs.value,
               value: ItemType.getEnergy(GamePlayer.legs.value),
               total: total,)
         );
       }
       for (final beltType in ServerState.watchBeltItemTypes) {
         if (!ItemType.isTypeTrinket(beltType.value)) continue;
         children.add(
             _buildRowHoverValue(
               itemType: beltType.value,
               value: ItemType.getEnergy(beltType.value),
               total: total,
             )
         );
       }
     }


     return Positioned(
        top: 200,
        right: 300,
        child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
            padding: const EdgeInsets.all(12),
            color: brownDark,
            constraints: BoxConstraints(
              minWidth: 480,
              maxWidth: 550,
            )));
  }

  static Widget _buildRowHoverValue({required int itemType, required int value, required int total})
  =>
      value == 0 ? GameStyle.Null :
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GameUI.buildAtlasItemType(itemType),
            width8,
            text(ItemType.getName(itemType), color: GameStyle.Text_Color_Default),
          ],
        ),
        Row(
          children: [
            if (total > 0)
            text('${((value / total) * 100).toInt()}%' ),
            Container(
                width: 60,
                alignment: Alignment.centerRight,
                child: text(value, color: GameStyle.Text_Color_Default)),
          ],
        )
      ],
    );

  static Widget buildPositionedContainerItemTypeInformation(int itemIndex){
    if (itemIndex == -1) return GameStyle.Null;

    final itemType = ClientState.hoverDialogType.value == DialogType.Trade ? GamePlayer.storeItems.value[itemIndex] : ServerQuery.getItemTypeAtInventoryIndex(itemIndex);

    if (itemType == ItemType.Empty) return GameStyle.Null;

    final itemTypeIsConsumable = ItemType.isTypeConsumable(itemType);
    final itemTypeConsumeType = ItemType.getConsumeType(itemType);
    final itemIndexInBelt = ItemType.isIndexBelt(itemIndex);
    final replenishHealth = ItemType.getHealAmount(itemType);
    final replenishEnergy = ItemType.getReplenishEnergy(itemType);
    final itemTypeIsEquippable = ItemType.isTypeEquippable(itemType);
    final equippedItemType          = ServerQuery.getEquippedItemType(itemType);
    final itemTypeIsTrinket         = ItemType.isTypeTrinket(itemType);
    // final itemTypeDamage            = GameOptions.getItemTypeDamage(itemType);
    final itemTypeDamage            = 0;
    final itemTypeRange             = ItemType.getRange(itemType).toInt();
    final itemTypeCooldown          = ItemType.getCooldown(itemType);
    final itemTypeMaxHealth         = ItemType.getMaxHealth(itemType);
    // final equippedItemTypeDamage    = itemTypeIsEquippable ? GameOptions.getItemTypeDamage(equippedItemType) : null;
    final equippedItemTypeDamage    = 0;
    final equippedItemTypeRange     = itemTypeIsEquippable ? ItemType.getRange(equippedItemType) : null;
    final equippedItemTypeCooldown  = itemTypeIsEquippable ? ItemType.getCooldown(equippedItemType) : null;
    final equippedItemTypeMaxHealth = itemTypeIsEquippable ? ItemType.getMaxHealth(equippedItemType) : null;
    final itemTypeIsEquipped        = itemType == equippedItemType
                                      || (itemTypeIsTrinket && itemIndexInBelt);

    return Positioned(
      top: 100,
      left:  Engine.mousePositionX < (Engine.screen.width * 0.5) ? 300 : null,
      right: Engine.mousePositionX >= (Engine.screen.width * 0.5) ? 300 : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: brownDark,
        constraints: BoxConstraints(
          minWidth: 480,
          maxWidth: 550,
        ),
        child: Container(
          width: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GameUI.buildAtlasItemType(itemType),
                  width8,
                  Expanded(child: text(ItemType.getName(itemType), color: GameColors.blue)),
                  if (itemTypeIsEquipped)
                    text("Equipped", color: Colors.white60),
                ],
              ),
              height8,
              buildTableRow("Type", ItemType.getGroupTypeName(itemType)),
              if (replenishHealth > 0)
              buildTableRow("Replenishes Health", replenishHealth),
              if (replenishEnergy > 0)
                buildTableRow("Replenishes Energy", replenishEnergy),
              if (!itemTypeIsConsumable)
              buildTableRowDifference2("Damage", itemTypeDamage, equippedItemTypeDamage),
              if (!itemTypeIsConsumable)
              buildTableRowDifference2("Range", itemTypeRange, equippedItemTypeRange),
              if (!itemTypeIsConsumable)
              buildTableRowDifference2("Cooldown", itemTypeCooldown, equippedItemTypeCooldown, swap: true),
              if (!itemTypeIsConsumable)
              buildTableRowDifference2("Max Health", itemTypeMaxHealth, equippedItemTypeMaxHealth),

              if (itemTypeConsumeType != ItemType.Empty)
                buildTableRow("Uses", Row(children: [
                  GameUI.buildAtlasItemType(itemTypeConsumeType),
                  width6,
                  text("${ItemType.getName(itemTypeConsumeType)} x${ItemType.getConsumeAmount(itemType)}", color: Colors.white70),
                ],)),
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
      ),
    );
  }

  static Widget buildTableRowDifference2(String key, num itemTypeValue, num? equippedTypeValue, {bool swap = false}){
    if (itemTypeValue == 0) return GameStyle.Null;

     if (equippedTypeValue == null || itemTypeValue == equippedTypeValue){
       return buildTableRow(key, itemTypeValue);
     }

     final percentage = getPercentageDifference(itemTypeValue, equippedTypeValue);
     final changeColor = getValueColor(percentage, swap: swap);
     return buildTableRow(
         text(key, color: changeColor),
         Row(
           mainAxisAlignment: MainAxisAlignment.end,
           children: [
            text('${percentage > 0 ? "+" : ""}${formatPercentage(percentage)}', color: changeColor, italic: true),
            Container(
                width: 150,
                alignment: Alignment.centerRight,
                child: text('${equippedTypeValue.toInt()} -> ${padSpace(itemTypeValue.toInt(), length: 3)}', color: Colors.white70)),
          ],
         )
     );
  }

  static Widget buildTableRowDifference(
      dynamic key,
      dynamic value,
      num difference,
      {bool swap = false})
  => buildTableRow(key, difference == 0 ? value : '${difference > 0 ? "(+" : "("}${difference.toInt()}) ${padSpace(value, length: 5)}', color: getValueColor(difference.toInt(), swap: swap));

  static Widget buildTableRow(dynamic key, dynamic value, {Color color = Colors.white70}) =>
    Container(
      padding: const EdgeInsets.all(5),
      color: GameColors.white05,
      margin: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          key is Widget ? key : text(key, color: color, bold: true),
          value is Widget ? value : text(value, color: color),
        ],
      ),
    );

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
       children.add(
           Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: GameUI.buildAtlasItemType(recipeItemType)),
                width4,
                text(ItemType.getName(recipeItemType), color: textColor),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                child: text('($recipeItemQuantityPossessed)',
                    italic: true, color: textColor),
                alignment: Alignment.centerRight,
              ),
              Container(
                  width: 70,
                  child: text(recipeItemQuantityRequired, color: textColor),
                  alignment: Alignment.centerRight),
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

  static Color getValueColor(num value, {bool swap = false}){
     if (value == 0) return  GameColors.white;
     if (value < 0) {
       if (swap){
         return GameColors.green;
       }else {
         return GameColors.red;
       }
     }
     if (swap){
       return GameColors.red;
     }else {
       return GameColors.green;
     }
  }
}
