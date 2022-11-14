
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/library.dart';

class ClientQuery {

  static int getHoverItemType() =>
    ServerQuery.getItemTypeAtInventoryIndex(ClientState.hoverIndex.value);

  static bool keyboardKeyIsHotKey(LogicalKeyboardKey key) =>
      ClientConstants.Hot_Keys.contains(key);

  static Watch<int> mapKeyboardKeyHotKeyToHotKeyWatch(LogicalKeyboardKey key){
    if (key == LogicalKeyboardKey.digit1)
       return ClientState.hotKey1;
     if (key == LogicalKeyboardKey.digit2)
       return ClientState.hotKey2;
    if (key == LogicalKeyboardKey.digit3)
      return ClientState.hotKey3;
    if (key == LogicalKeyboardKey.digit4)
      return ClientState.hotKey4;
    if (key == LogicalKeyboardKey.keyQ)
      return ClientState.hotKeyQ;
    if (key == LogicalKeyboardKey.keyE)
      return ClientState.hotKeyE;

    throw Exception("ClientQuery.getKeyHotKey(key: $key)");
  }

  static String mapHotKeyWatchToString(Watch<int> hotKeyWatch){
     if (hotKeyWatch == ClientState.hotKey1) return '1';
     if (hotKeyWatch == ClientState.hotKey2) return '2';
     if (hotKeyWatch == ClientState.hotKey3) return '3';
     if (hotKeyWatch == ClientState.hotKey4) return '4';
     if (hotKeyWatch == ClientState.hotKeyQ) return 'Q';
     if (hotKeyWatch == ClientState.hotKeyE) return 'E';
     throw Exception("ClientQuery.mapHotKeyWatchToString($hotKeyWatch)");
  }
}