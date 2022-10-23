import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_ui.dart';

void actionSetModePlay(){
  GameState.edit.value = false;
}

void actionSetModeEdit(){
  GameState.edit.value = true;
}

void actionToggleEdit() {
  GameState.edit.value = !GameState.edit.value;
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






