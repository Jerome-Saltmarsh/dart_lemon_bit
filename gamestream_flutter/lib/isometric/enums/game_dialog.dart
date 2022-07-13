import 'package:gamestream_flutter/isometric/events/on_changed_game_dialog.dart';
import 'package:lemon_watch/watch.dart';

final gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);

enum GameDialog {
  Scene_Load,
  Scene_Save,
  Canvas_Size,
  Debug,
  Audio_Mixer,
  Quests,
}

void actionGameDialogShowSceneLoad(){
    gameDialog.value = GameDialog.Scene_Load;
}

void actionGameDialogShowSceneSave(){
  gameDialog.value = GameDialog.Scene_Save;
}

void actionGameDialogClose(){
  gameDialog.value = null;
}


void actionGameDialogShowQuests(){
  gameDialog.value = GameDialog.Quests;
}