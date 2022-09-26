import 'package:flutter/material.dart';
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

class Game {
  final textEditingControllerMessage = TextEditingController();
  final textFieldMessage = FocusNode();
  final debug = Watch(false);
  final storeTab = Watch(storeTabs[0]);
  final panelTypeKey = <int, GlobalKey> {};
  final playerTextStyle = TextStyle(color: Colors.white);
  final mapVisible = Watch(false);
  final timeVisible = Watch(true);
  final edit = Watch(false);
}





