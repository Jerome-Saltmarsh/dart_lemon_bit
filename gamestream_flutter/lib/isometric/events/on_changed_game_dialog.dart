
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';

void onChangedGameDialog(GameDialog? value){
 GameAudio.audioSingleClickSound();
 if (value == GameDialog.Quests) {
    // actionHideQuestAdded();
 }
}