import 'package:bleed_common/GameType.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_ui.dart';

bool get playMode => !GameState.edit.value;
bool get editMode => GameState.edit.value;

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






