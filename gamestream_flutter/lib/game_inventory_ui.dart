
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/language_utils.dart';

import 'gamestream/games/isometric/game_isometric_colors.dart';
import 'library.dart';

class GameInventoryUI {

  static Widget buildTableRowDifference2(String key, num itemTypeValue, num? equippedTypeValue, {bool swap = false}){
    if (itemTypeValue == 0) return GameStyle.Null;

     if (equippedTypeValue == null || itemTypeValue == equippedTypeValue){
       return buildTableRow(key, itemTypeValue);
     }

     final percentage = getPercentageDifference(itemTypeValue, equippedTypeValue);
     final changeColor = getValueColor(percentage, swap: swap);
     return buildTableRow(
         buildText(key, color: changeColor),
         Row(
           mainAxisAlignment: MainAxisAlignment.end,
           children: [
            buildText('${percentage > 0 ? "+" : ""}${formatPercentage(percentage)}', color: changeColor, italic: true),
            Container(
                width: 150,
                alignment: Alignment.centerRight,
                child: buildText('${equippedTypeValue.toInt()} -> ${padSpace(itemTypeValue.toInt(), length: 3)}', color: Colors.white70)),
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
      color: GameIsometricColors.white05,
      margin: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          key is Widget ? key : buildText(key, color: color, bold: true),
          value is Widget ? value : buildText(value, color: color),
        ],
      ),
    );

  static Color getValueColor(num value, {bool swap = false}){
     if (value == 0) return  GameIsometricColors.white;
     if (value < 0) {
       if (swap){
         return GameIsometricColors.green;
       }else {
         return GameIsometricColors.red;
       }
     }
     if (swap){
       return GameIsometricColors.red;
     }else {
       return GameIsometricColors.green;
     }
  }
}

class ClientType {
  static const Index_Drag_Start = 0;
  static const Index_Hot_Keys = Index_Drag_Start + 100;
  static const Index_Inventory_Equipped = Index_Hot_Keys + 100;
  static const Index_Inventory = Index_Inventory_Equipped + 100;

  static const Drag_Start_None = Index_Drag_Start + 1;
  static const Drag_Start_Inventory_Unequipped = Drag_Start_None + 1;
  static const Drag_Start_Inventory_Equipped = Drag_Start_Inventory_Unequipped + 1;
  static const Drag_Start_HotKey_Unassigned = Drag_Start_Inventory_Equipped + 1;
  static const Drag_Start_HotKey_Assigned = Drag_Start_HotKey_Unassigned + 1;

  static const Hot_Key_1 = Index_Hot_Keys + 1;
  static const Hot_Key_2 = Hot_Key_1 + 1;
  static const Hot_Key_3 = Hot_Key_2 + 1;
  static const Hot_Key_4 = Hot_Key_3 + 1;
  static const Hot_Key_Q = Hot_Key_4 + 1;
  static const Hot_Key_E = Hot_Key_Q + 1;

  static const Inventory_Equipped = Hot_Key_Q + 1;
  static const Inventory_Equipped_Weapon = Inventory_Equipped + 1;
  static const Inventory_Equipped_Body = Inventory_Equipped + 2;
  static const Inventory_Equipped_Head = Inventory_Equipped + 3;
  static const Inventory_Equipped_Legs = Inventory_Equipped + 4;

  static const Hover_Target_None = 1000;
  static const Hover_Target_Inventory_Slot = Hover_Target_None + 1;
  static const Hover_Target_Player_Stats_Damage = Hover_Target_Inventory_Slot + 1;
  static const Hover_Target_Player_Stats_Health = Hover_Target_Player_Stats_Damage + 1;
  static const Hover_Target_Player_Stats_Energy = Hover_Target_Player_Stats_Health + 1;
}