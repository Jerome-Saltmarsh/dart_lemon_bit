
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';

void onPlayerEventQuestStarted(){
  audioSingleNotificationSound10();
  GameState.player.questAdded.value = true;
}