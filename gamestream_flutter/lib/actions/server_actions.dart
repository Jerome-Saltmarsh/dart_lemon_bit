
import 'package:gamestream_flutter/library.dart';

class ServerActions {

  // static void equipItemType(int itemType){
  //     for (var i = 0; i < ServerState.inventory.length; i++){
  //        if (ServerState.inventory[i] != itemType) continue;
  //        GameNetwork.sendClientRequestInventoryEquip(i);
  //        return;
  //     }
  // }

  static void dropEquippedWeapon() =>
     GameNetwork.sendClientRequestInventoryDrop(ItemType.Equipped_Weapon);

  static void equipWatchBeltType(Watch<int> watchBeltType) =>
    GameNetwork.sendClientRequestInventoryEquip(
        ServerQuery.mapWatchBeltTypeToItemType(watchBeltType)
    );
}