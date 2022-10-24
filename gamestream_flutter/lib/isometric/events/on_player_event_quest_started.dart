
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game_state.dart';

void onPlayerEventQuestStarted(){
  GameAudio.notification_sound_10();
  GameState.player.questAdded.value = true;
}