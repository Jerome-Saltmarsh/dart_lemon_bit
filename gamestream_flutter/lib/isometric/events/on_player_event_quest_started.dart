
import 'package:gamestream_flutter/library.dart';

void onPlayerEventQuestStarted(){
  gamestream.audio.notification_sound_10();
  gamestream.isometric.player.questAdded.value = true;
}