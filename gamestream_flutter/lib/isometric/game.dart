import 'package:bleed_common/GameType.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_edit.dart';
import 'package:gamestream_flutter/isometric/events/on_visibility_changed_message_box.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_scene_meta_data_player_is_owner.dart';
import 'package:lemon_watch/watch.dart';

import '../modules/game/enums.dart';

final game = Game();

bool get playMode => !game.edit.value;
bool get editMode => game.edit.value;

void actionSetModePlay(){
  game.edit.value = false;
}

void actionSetModeEdit(){
  game.edit.value = true;
}

void actionToggleEdit() {
  game.edit.value = !game.edit.value;
}

void messageBoxToggle(){
  game.messageBoxVisible.value = !game.messageBoxVisible.value;
}

void messageBoxShow(){
  game.messageBoxVisible.value = true;
}

void messageBoxHide(){
  game.messageBoxVisible.value = false;
}

class Game {
  final editTab = Watch(EditTab.Grid);
  final messageBoxVisible = Watch(false, clamp: (bool value){
     if (gameType.value == GameType.Skirmish) return false;
     return value;
  }, onChanged: onVisibilityChangedMessageBox);
  final canOpenMapAndQuestMenu = Watch(false);
  final textEditingControllerMessage = TextEditingController();
  final textFieldMessage = FocusNode();
  final debug = Watch(false);
  final storeTab = Watch(storeTabs[0]);
  final panelTypeKey = <int, GlobalKey> {};
  final playerTextStyle = TextStyle(color: Colors.white);
  final mapVisible = Watch(false);
  final timeVisible = Watch(true);
  final edit = Watch(false, onChanged: onChangedEdit);
}





