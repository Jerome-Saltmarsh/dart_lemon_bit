
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:lemon_math/library.dart';
var _nextGrowl = 100;

void updateZombieGrowls(){
   if (totalZombies <= 0) return;
   if (_nextGrowl-- > 0) return;
   _nextGrowl = randomInt(200, 300);
   randomItem(audioSingleZombieTalking).playV3(zombies[randomInt(0, totalZombies)]);
}