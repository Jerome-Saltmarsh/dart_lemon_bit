
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';

import '../player.dart';

void onPlayerEventQuestStarted(){
  audioSingleNotificationSound10();
  player.questAdded.value = true;
}