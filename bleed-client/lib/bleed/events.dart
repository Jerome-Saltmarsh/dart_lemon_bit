
import 'audio.dart';
import 'enums.dart';
import 'utils.dart';

void onGameEvent(GameEventType type){
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
  }

}