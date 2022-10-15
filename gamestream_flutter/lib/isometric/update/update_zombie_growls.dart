
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:lemon_math/library.dart';
var _nextGrowl = 100;

void updateZombieGrowls(){
   if (GameState.totalZombies <= 0) return;
   if (_nextGrowl-- > 0) return;
   _nextGrowl = randomInt(200, 300);
   randomItem(AudioEngine.audioSingleZombieTalking).playV3(GameState.zombies[randomInt(0, GameState.totalZombies)]);
}