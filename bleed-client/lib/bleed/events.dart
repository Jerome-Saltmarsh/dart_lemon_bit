
import 'dart:math';

import 'package:flutter_game_engine/bleed/functions/spawnBulletHole.dart';
import 'package:flutter_game_engine/bleed/spawn.dart';
import 'package:flutter_game_engine/bleed/spawners/spawnBlood.dart';
import 'package:flutter_game_engine/bleed/spawners/spawnHead.dart';
import 'package:flutter_game_engine/bleed/spawners/spawnShell.dart';

import 'audio.dart';
import 'enums/GameEventType.dart';
import 'maths.dart';
import 'utils.dart';

void onGameEvent(GameEventType type, double x, double y, double xv, double yv){
  switch(type){
    case GameEventType.Handgun_Fired:
      playAudioHandgunShot();
      spawnShell(x, y);
      break;
    case GameEventType.Shotgun_Fired:
      playAudioShotgunShot();
      spawnShell(x, y);
      break;
    case GameEventType.SniperRifle_Fired:
      playAudioSniperShot();
      spawnShell(x, y);
      break;
    case GameEventType.MachineGun_Fired:
      playAudioAssaultRifleShot();
      spawnShell(x, y);
      break;
    case GameEventType.Zombie_Hit:
      if(randomBool()){
        playAudioZombieHit();
      }
      double s = 0.15;
      double r = 1;
      for(int i = 0; i < randomInt(2, 5); i++){
        spawnBlood(x, y, 0.3, xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
      }
      break;
    case GameEventType.Zombie_Killed:
      playAudioZombieDeath();
      double s = 0.15;
      double r = 1;
      for(int i = 0; i < randomInt(2, 5); i++){
        spawnBlood(x, y, 0.3, xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
      }
      break;
    case GameEventType.Zombie_killed_Explosion:
      playAudioZombieDeath();
      double s = 0.15;
      double r = 1;
      for(int i = 0; i < randomInt(2, 5); i++){
        spawnBlood(x, y, 0.3, xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
      }
      spawnHead(x, y, 0.3, xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
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