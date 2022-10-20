
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_audio.dart';

void onPlayerEventQuestStarted(){
  GameAudio.notification_sound_10();
  GameState.player.questAdded.value = true;
}