
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game.dart';

void onPlayerEventQuestStarted(){
  GameAudio.audioSingleNotificationSound10();
  Game.player.questAdded.value = true;
}