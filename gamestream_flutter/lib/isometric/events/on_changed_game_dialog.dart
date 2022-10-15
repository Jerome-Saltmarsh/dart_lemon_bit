
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';

void onChangedGameDialog(GameDialog? value){
 AudioEngine.audioSingleClickSound();
 if (value == GameDialog.Quests) {
    // actionHideQuestAdded();
 }
}