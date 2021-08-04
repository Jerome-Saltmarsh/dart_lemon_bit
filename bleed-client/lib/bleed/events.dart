
import 'package:flutter_game_engine/bleed/state.dart';

import 'audio.dart';
import 'enums.dart';
import 'utils.dart';

void onGameEvent(GameEventType type, int x, int y){
  switch(type){
    case GameEventType.Handgun_Fired:
      playAudioHandgunShot();
      break;
    case GameEventType.Shotgun_Fired:
      playAudioShotgunShot();
      break;
    case GameEventType.Zombie_Hit:
      if(randomBool()){
        playAudioZombieHit();
      }
      break;
    case GameEventType.Zombie_Killed:
      playAudioZombieDeath();
      break;
    case GameEventType.Zombie_Target_Acquired:
      playAudioZombieTargetAcquired();
      break;
    case GameEventType.Bullet_Hole:
      bulletHoles.add(x.toDouble());
      bulletHoles.add(y.toDouble());
      break;
  }
}