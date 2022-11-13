
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/library.dart';

class ClientQuery {

  static int getHoverItemType() =>
    ServerQuery.getItemTypeAtInventoryIndex(ClientState.hoverIndex.value);

  static bool keyboardKeyIsHotKey(LogicalKeyboardKey key) =>
      ClientState.hotKeyKeys.contains(key);

  static Watch<int> getKeyboardKeyHotKeyWatch(LogicalKeyboardKey key){
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
}