import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_ui.dart';

bool get playMode => !Game.edit.value;
bool get editMode => Game.edit.value;

void actionSetModePlay(){
  Game.edit.value = false;
}

void actionSetModeEdit(){
  Game.edit.value = true;
}

void actionToggleEdit() {
  Game.edit.value = !Game.edit.value;
}

void messageBoxToggle(){
  GameUI.messageBoxVisible.value = !GameUI.messageBoxVisible.value;
}

void messageBoxShow(){
  GameUI.messageBoxVisible.value = true;
}

void messageBoxHide(){
  GameUI.messageBoxVisible.value = false;
}






