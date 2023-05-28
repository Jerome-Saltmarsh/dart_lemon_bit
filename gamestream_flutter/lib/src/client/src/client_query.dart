
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/library.dart';

class ClientQuery {

  static int getHoverItemType() =>
      gamestream.games.isometric.serverState.getItemTypeAtInventoryIndex(gamestream.games.isometric.clientState.hoverIndex.value);

  static Watch<int> mapKeyboardKeyToWatchBeltType(LogicalKeyboardKey key){
    if (key == LogicalKeyboardKey.digit1)
       return gamestream.games.isometric.serverState.playerBelt1_ItemType;
     if (key == LogicalKeyboardKey.digit2)
       return gamestream.games.isometric.serverState.playerBelt2_ItemType;
    if (key == LogicalKeyboardKey.digit3)
      return gamestream.games.isometric.serverState.playerBelt3_ItemType;
    if (key == LogicalKeyboardKey.digit4)
      return gamestream.games.isometric.serverState.playerBelt4_ItemType;
    if (key == LogicalKeyboardKey.keyQ)
      return gamestream.games.isometric.serverState.playerBelt5_ItemType;
    if (key == LogicalKeyboardKey.keyE)
      return gamestream.games.isometric.serverState.playerBelt6_ItemType;

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
     if (hotKeyWatch == gamestream.games.isometric.serverState.playerBelt1_ItemType) return '1';
     if (hotKeyWatch == gamestream.games.isometric.serverState.playerBelt2_ItemType) return '2';
     if (hotKeyWatch == gamestream.games.isometric.serverState.playerBelt3_ItemType) return '3';
     if (hotKeyWatch == gamestream.games.isometric.serverState.playerBelt4_ItemType) return '4';
     if (hotKeyWatch == gamestream.games.isometric.serverState.playerBelt5_ItemType) return 'Q';
     if (hotKeyWatch == gamestream.games.isometric.serverState.playerBelt6_ItemType) return 'E';
     throw Exception("ClientQuery.mapHotKeyWatchToString($hotKeyWatch)");
  }

  static double getMousePlayerAngle(){
    final adjacent = GamePlayer.renderX - engine.mouseWorldX;
    final opposite = GamePlayer.renderY - engine.mouseWorldY;
    return angle(adjacent, opposite);
  }

  static double getMousePlayerRenderDistance(){
    final adjacent = GamePlayer.renderX - engine.mouseWorldX;
    final opposite = GamePlayer.renderY - engine.mouseWorldY;
    return hyp(adjacent, opposite);
  }
}