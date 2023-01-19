
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

  static void saveScene(){
    GameNetwork.sendClientRequest(ClientRequest.Edit, EditRequest.Save.index);
  }

  static void editSceneSpawnAI() =>
    GameNetwork.sendClientRequest(
        ClientRequest.Edit,
        EditRequest.Spawn_AI.index,
    );

  static void editSceneReset() =>
    GameNetwork.sendClientRequestEdit(EditRequest.Scene_Reset);

  static void editSceneClearSpawnedAI(){
    GameNetwork.sendClientRequest(ClientRequest.Edit, EditRequest.Clear_Spawned.index);
  }

  static void selectPerkTypeMaxHealth(){
    GameNetwork.sendClientRequestSelectPerkType(PerkType.Max_Health);
  }

  static void selectPerkTypeDamage(){
    GameNetwork.sendClientRequestSelectPerkType(PerkType.Damage);
  }
}