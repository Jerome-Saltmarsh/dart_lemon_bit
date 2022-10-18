
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';

void onChangedGameDialog(GameDialog? value){
 GameAudio.click_sound_8();
 if (value == GameDialog.Quests) {
    // actionHideQuestAdded();
 }
}