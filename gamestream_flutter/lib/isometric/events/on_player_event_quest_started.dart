
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/game_state.dart';

void onPlayerEventQuestStarted(){
  AudioEngine.audioSingleNotificationSound10();
  GameState.player.questAdded.value = true;
}