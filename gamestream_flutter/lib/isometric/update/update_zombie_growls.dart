
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:lemon_math/library.dart';
var _nextGrowl = 100;

void updateZombieGrowls(){
   if (Game.totalZombies <= 0) return;
   if (_nextGrowl-- > 0) return;
   _nextGrowl = randomInt(200, 300);
   randomItem(GameAudio.audioSingleZombieTalking).playV3(Game.zombies[randomInt(0, Game.totalZombies)]);
}