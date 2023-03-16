
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/library.dart';

class ClientQuery {

  static int getHoverItemType() =>
    ServerQuery.getItemTypeAtInventoryIndex(ClientState.hoverIndex.value);

  static Watch<int> mapKeyboardKeyToWatchBeltType(LogicalKeyboardKey key){
    if (key == LogicalKeyboardKey.digit1)
       return ServerState.playerBelt1_ItemType;
     if (key == LogicalKeyboardKey.digit2)
       return ServerState.playerBelt2_ItemType;
    if (key == LogicalKeyboardKey.digit3)
      return ServerState.playerBelt3_ItemType;
    if (key == LogicalKeyboardKey.digit4)
      return ServerState.playerBelt4_ItemType;
    if (key == LogicalKeyboardKey.keyQ)
      return ServerState.playerBelt5_ItemType;
    if (key == LogicalKeyboardKey.keyE)
      return ServerState.playerBelt6_ItemType;

    throw Exception("ClientQuery.getKeyHotKey(key: $key)");
  }

  static int mapKeyboardKeyToBeltIndex(LogicalKeyboardKey key){
    if (key == LogicalKeyboardKey.digit1)
      return ItemType.Belt_1;
    if (key == LogicalKeyboardKey.digit2)
      return ItemType.Belt_2;
    if (key == LogicalKeyboardKey.digit3)
      return ItemType.Belt_3;
    if (key == LogicalKeyboardKey.digit4)
      return ItemType.Belt_4;
    if (key == LogicalKeyboardKey.keyQ)
      return ItemType.Belt_5;
    if (key == LogicalKeyboardKey.keyE)
      return ItemType.Belt_6;
    throw Exception("ClientEvents.convertKeyboardKeyToBeltIndex($key)");
  }

  static String mapWatchBeltTypeTokeyboardKeyString(Watch<int> hotKeyWatch){
     if (hotKeyWatch == ServerState.playerBelt1_ItemType) return '1';
     if (hotKeyWatch == ServerState.playerBelt2_ItemType) return '2';
     if (hotKeyWatch == ServerState.playerBelt3_ItemType) return '3';
     if (hotKeyWatch == ServerState.playerBelt4_ItemType) return '4';
     if (hotKeyWatch == ServerState.playerBelt5_ItemType) return 'Q';
     if (hotKeyWatch == ServerState.playerBelt6_ItemType) return 'E';
     throw Exception("ClientQuery.mapHotKeyWatchToString($hotKeyWatch)");
  }

  static double getMousePlayerAngle(){
    final adjacent = GamePlayer.renderX - Engine.mouseWorldX;
    final opposite = GamePlayer.renderY - Engine.mouseWorldY;
    return Engine.calculateAngle(adjacent, opposite);
  }

  static double getMousePlayerRenderDistance(){
    final adjacent = GamePlayer.renderX - Engine.mouseWorldX;
    final opposite = GamePlayer.renderY - Engine.mouseWorldY;
    return Engine.calculateHypotenuse(adjacent, opposite);
  }

  static bool dialogOpenInventory() =>
      GameOptions.inventory.value &&
      ServerState.interactMode.value == InteractMode.Inventory;
}