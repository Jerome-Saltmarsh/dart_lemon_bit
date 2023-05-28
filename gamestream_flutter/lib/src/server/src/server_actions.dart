
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/library.dart';

class ServerActions {

  static void dropEquippedWeapon() =>
      gsEngine.network.sendClientRequestInventoryDrop(ItemType.Equipped_Weapon);

  static void equipWatchBeltType(Watch<int> watchBeltType) =>
      gsEngine.network.sendClientRequestInventoryEquip(
        ServerQuery.mapWatchBeltTypeToItemType(watchBeltType)
    );

  static void inventoryUnequip(int index) =>
      gsEngine.network.sendClientRequestInventoryUnequip(index);

  static void inventoryMoveToWatchBelt(int index, Watch<int> watchBelt)=>
      gsEngine.network.sendClientRequestInventoryMove(
        indexFrom: index,
        indexTo: ServerQuery.mapWatchBeltTypeToItemType(watchBelt),
      );

  static void saveScene(){
    gsEngine.network.sendClientRequest(ClientRequest.Edit, EditRequest.Save.index);
  }

  static void editSceneSpawnAI() =>
      gsEngine.network.sendClientRequest(
        ClientRequest.Edit,
        EditRequest.Spawn_AI.index,
    );

  static void editSceneReset() =>
      gsEngine.network.sendClientRequestEdit(EditRequest.Scene_Reset);

  static void editSceneClearSpawnedAI(){
    gsEngine.network.sendClientRequest(ClientRequest.Edit, EditRequest.Clear_Spawned.index);
  }
}