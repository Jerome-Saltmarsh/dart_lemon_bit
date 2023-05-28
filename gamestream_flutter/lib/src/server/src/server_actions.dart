
import 'package:gamestream_flutter/library.dart';

class ServerActions {

  static void dropEquippedWeapon() =>
      gamestream.network.sendClientRequestInventoryDrop(ItemType.Equipped_Weapon);

  static void equipWatchBeltType(Watch<int> watchBeltType) =>
      gamestream.network.sendClientRequestInventoryEquip(
        ServerQuery.mapWatchBeltTypeToItemType(watchBeltType)
    );

  static void inventoryUnequip(int index) =>
      gamestream.network.sendClientRequestInventoryUnequip(index);

  static void inventoryMoveToWatchBelt(int index, Watch<int> watchBelt)=>
      gamestream.network.sendClientRequestInventoryMove(
        indexFrom: index,
        indexTo: ServerQuery.mapWatchBeltTypeToItemType(watchBelt),
      );

  static void saveScene(){
    gamestream.network.sendClientRequest(ClientRequest.Edit, EditRequest.Save.index);
  }

  static void editSceneSpawnAI() =>
      gamestream.network.sendClientRequest(
        ClientRequest.Edit,
        EditRequest.Spawn_AI.index,
    );

  static void editSceneReset() =>
      gamestream.network.sendClientRequestEdit(EditRequest.Scene_Reset);

  static void editSceneClearSpawnedAI(){
    gamestream.network.sendClientRequest(ClientRequest.Edit, EditRequest.Clear_Spawned.index);
  }
}