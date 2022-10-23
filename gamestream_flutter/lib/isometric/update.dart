

import 'dart:math';

import 'package:bleed_common/Projectile_Type.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';
import 'package:gamestream_flutter/isometric/update/update_lightning.dart';
import 'package:lemon_math/library.dart';

import 'animation_frame.dart';
import 'audio/audio_random.dart';
import 'update/update_zombie_growls.dart';

void updateIsometric(){
  updateGameActions();
  updateAnimationFrame();
  GameState.updateParticleEmitters();
  updateProjectiles();
  updateRandomAudio();
  applyObjectsToWind();
  updateZombieGrowls();

  if (GameState.player.messageTimer > 0) {
    GameState.player.messageTimer--;
     if (GameState.player.messageTimer == 0){
       GameState.player.message.value = "";
     }
  }
}

void updateParticleFrames() {
  for (var i = 0; i < GameState.particles.length; i++){
    GameState.particles[i].updateFrame();
  }
}

void applyObjectsToWind(){
  GameAudio.updateAudioLoops();
  updateLightning();
}

void applyCharacterToWind(Character character){
   if (character.running || character.performing) {
     if (gridNodeInBoundsVector3(character)) return;
     gridNodeIncrementWindVector3(character);
   }
}

void updateProjectiles() {
  for (var i = 0; i < GameState.totalProjectiles; i++) {
    final projectile = GameState.projectiles[i];
    if (projectile.type == ProjectileType.Fireball) {
      GameState.spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
      GameState.spawnParticleBubble(
          x: projectile.x + giveOrTake(5),
          y: projectile.y + giveOrTake(5),
          z: projectile.z,
          angle: (projectile.angle + pi) + giveOrTake(piHalf ),
          speed: 1.5,
      );
      continue;
    }

    if (projectile.type == ProjectileType.Bullet) {
      GameState.spawnParticleBubble(
        x: projectile.x + giveOrTake(5),
        y: projectile.y + giveOrTake(5),
        z: projectile.z,
        angle: (projectile.angle + pi) + giveOrTake(piHalf ),
        speed: 1.5,
      );
      GameState.spawnParticleBulletRing(
        x: projectile.x,
        y: projectile.y,
        z: projectile.z,
        angle: projectile.angle,
        speed: 1.5,
      );
      continue;
    }

    if (projectile.type == ProjectileType.Orb) {
      GameState.spawnParticleOrbShard(x: projectile.x, y: projectile.y, z: projectile.z, angle: randomAngle());
    }
  }
}

