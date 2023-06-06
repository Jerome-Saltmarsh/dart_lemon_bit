
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/library.dart';

class ClientQuery {

  static int getHoverItemType() =>
      gamestream.isometricEngine.serverState.getItemTypeAtInventoryIndex(gamestream.isometricEngine.clientState.hoverIndex.value);

  static Watch<int> mapKeyboardKeyToWatchBeltType(LogicalKeyboardKey key){
    if (key == LogicalKeyboardKey.digit1)
       return gamestream.isometricEngine.serverState.playerBelt1_ItemType;
     if (key == LogicalKeyboardKey.digit2)
       return gamestream.isometricEngine.serverState.playerBelt2_ItemType;
    if (key == LogicalKeyboardKey.digit3)
      return gamestream.isometricEngine.serverState.playerBelt3_ItemType;
    if (key == LogicalKeyboardKey.digit4)
      return gamestream.isometricEngine.serverState.playerBelt4_ItemType;
    if (key == LogicalKeyboardKey.keyQ)
      return gamestream.isometricEngine.serverState.playerBelt5_ItemType;
    if (key == LogicalKeyboardKey.keyE)
      return gamestream.isometricEngine.serverState.playerBelt6_ItemType;

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
     if (hotKeyWatch == gamestream.isometricEngine.serverState.playerBelt1_ItemType) return '1';
     if (hotKeyWatch == gamestream.isometricEngine.serverState.playerBelt2_ItemType) return '2';
     if (hotKeyWatch == gamestream.isometricEngine.serverState.playerBelt3_ItemType) return '3';
     if (hotKeyWatch == gamestream.isometricEngine.serverState.playerBelt4_ItemType) return '4';
     if (hotKeyWatch == gamestream.isometricEngine.serverState.playerBelt5_ItemType) return 'Q';
     if (hotKeyWatch == gamestream.isometricEngine.serverState.playerBelt6_ItemType) return 'E';
     throw Exception("ClientQuery.mapHotKeyWatchToString($hotKeyWatch)");
  }

  static double getMousePlayerAngle(){
    final adjacent = gamestream.isometricEngine.player.renderX - engine.mouseWorldX;
    final opposite = gamestream.isometricEngine.player.renderY - engine.mouseWorldY;
    return angle(adjacent, opposite);
  }

  static double getMousePlayerRenderDistance(){
    final adjacent = gamestream.isometricEngine.player.renderX - engine.mouseWorldX;
    final opposite = gamestream.isometricEngine.player.renderY - engine.mouseWorldY;
    return hyp(adjacent, opposite);
  }
}