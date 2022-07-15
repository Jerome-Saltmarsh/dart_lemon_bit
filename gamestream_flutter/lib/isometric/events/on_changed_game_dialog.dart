
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/player.dart';

void onChangedGameDialog(GameDialog? value){
 audioSingleClickSound();
 if (value == GameDialog.Quests) {
   player.questAdded.value = false;
 }
}