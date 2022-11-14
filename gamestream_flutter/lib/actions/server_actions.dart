
import 'package:gamestream_flutter/library.dart';

class ServerActions {

  static void dropEquippedWeapon() =>
     GameNetwork.sendClientRequestInventoryDrop(ItemType.Equipped_Weapon);

  static void equipWatchBeltType(Watch<int> watchBeltType) =>
    GameNetwork.sendClientRequestInventoryEquip(
        ServerQuery.mapWatchBeltTypeToItemType(watchBeltType)
    );

  static void inventoryUnequip(int index) =>
      GameNetwork.sendClientRequestInventoryUnequip(index);

  static void inventoryMoveToWatchBelt(int index, Watch<int> watchBelt)=>
      GameNetwork.sendClientRequestInventoryMove(
        indexFrom: index,
        indexTo: ServerQuery.mapWatchBeltTypeToItemType(watchBelt),
      );
}