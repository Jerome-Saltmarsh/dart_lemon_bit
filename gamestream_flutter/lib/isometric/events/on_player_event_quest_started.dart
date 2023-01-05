
import 'package:gamestream_flutter/library.dart';

void onPlayerEventQuestStarted(){
  GameAudio.notification_sound_10();
  GamePlayer.questAdded.value = true;
}