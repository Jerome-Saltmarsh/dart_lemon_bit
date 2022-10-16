
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/game.dart';

void onPlayerEventQuestStarted(){
  AudioEngine.audioSingleNotificationSound10();
  Game.player.questAdded.value = true;
}