
import 'package:flutter_game_engine/bleed/functions/spawnBulletHole.dart';
import 'package:flutter_game_engine/bleed/spawn.dart';

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
    case GameEventType.SniperRifle_Fired:
      playAudioSniperShot();
      break;
    case GameEventType.MachineGun_Fired:
      playAudioAssaultRifleShot();
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
      spawnBulletHole(x.toDouble(), y.toDouble());
      break;
    case GameEventType.Zombie_Strike:
      playAudioZombieBite();
      break;
    case GameEventType.Player_Death:
      playPlayerDeathAudio();
      break;
    case GameEventType.Explosion:
      spawnExplosion(x.toDouble(), y.toDouble());
      break;
  }
}