import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/events/on_visibility_changed_message_box.dart';
import 'package:gamestream_flutter/modules/game/enums.dart';
import 'package:lemon_watch/watch.dart';

class GameUI {
  static const storeTabs = StoreTab.values;
  static final messageBoxVisible = Watch(false, clamp: (bool value){
    if (GameState.gameType.value == GameType.Skirmish) return false;
    return value;
  }, onChanged: onVisibilityChangedMessageBox);
  static final canOpenMapAndQuestMenu = Watch(false);
  static final textEditingControllerMessage = TextEditingController();
  static final textFieldMessage = FocusNode();
  static final debug = Watch(false);
  static final storeTab = Watch(StoreTab.Armor);
  static final panelTypeKey = <int, GlobalKey> {};
  static final playerTextStyle = TextStyle(color: Colors.white);
  static final mapVisible = Watch(false);
  static final timeVisible = Watch(true);
}