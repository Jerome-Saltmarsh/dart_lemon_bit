
import 'package:gamestream_flutter/isometric/actions/action_hide_quest_added.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';

void onChangedGameDialog(GameDialog? value){
 audioSingleClickSound();
 if (value == GameDialog.Quests) {
    actionHideQuestAdded();
 }
}