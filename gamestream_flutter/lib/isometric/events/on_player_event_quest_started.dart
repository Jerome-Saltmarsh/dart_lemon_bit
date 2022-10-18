
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_audio.dart';

void onPlayerEventQuestStarted(){
  GameAudio.notification_sound_10();
  Game.player.questAdded.value = true;
}