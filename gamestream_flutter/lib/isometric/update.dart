

import 'dart:math';

import 'package:bleed_common/Projectile_Type.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';
import 'package:gamestream_flutter/isometric/update/update_lightning.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:lemon_math/library.dart';

import 'animation_frame.dart';
import 'audio/audio_random.dart';
import 'particle_emitters.dart';
import 'update/update_zombie_growls.dart';

void updateIsometric(){
  updateGameActions();
  updateAnimationFrame();
  updateParticleEmitters();
  updateGameObjects();
  updateProjectiles();
  updateRandomAudio();
  applyObjectsToWind();
  updateZombieGrowls();
  updateMouseBubbleSpawn();

  if (Game.player.messageTimer > 0) {
    Game.player.messageTimer--;
     if (Game.player.messageTimer == 0){
       Game.player.message.value = "";
     }
  }
}

void updateMouseBubbleSpawn() {
  if (nextBubbleSpawn-- > 0) return;
  nextBubbleSpawn = 30;
  Game.spawnParticleBubble(x: mouseGridX, y: mouseGridY, z: Game.player.z);
}

var nextBubbleSpawn = 0;
var particleAnimation = 0;

void updateParticleFrames() {
  // if (particleAnimation++ < 3) return;
  particleAnimation = 0;
  for (var i = 0; i < Game.particles.length; i++){
    Game.particles[i].updateFrame();
  }
}

void applyObjectsToWind(){
  // foreachPlayer(applyCharacterToWind);

  for (var i = 0; i < Game.totalProjectiles; i++){
     applyWindFromProjectile(Game.projectiles[i]);
  }

  // updateWindLine();
  GameAudio.updateAudioLoops();
  updateLightning();
}

void applyWindFromProjectile(Projectile projectile){
    // final z = projectile.indexZ;
    // final row = projectile.indexRow;
    // final column = projectile.indexColumn;
    // projectile.tile.wind++;
    // projectile.tileAbove.wind++;
    // if (z > 0){
      // gridWind[z - 1][row][column]++;
    // }
}

void applyCharacterToWind(Character character){
   if (character.running || character.performing) {
     // character.tile.wind++;
     // character.tileAbove.wind++;
     if (gridNodeInBoundsVector3(character)) return;
     gridNodeIncrementWindVector3(character);
   }
}

void updateProjectiles() {
  for (var i = 0; i < Game.totalProjectiles; i++) {
    final projectile = Game.projectiles[i];
    if (projectile.type == ProjectileType.Fireball) {
      Game.spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
      Game.spawnParticleBubble(
          x: projectile.x + giveOrTake(5),
          y: projectile.y + giveOrTake(5),
          z: projectile.z,
          angle: (projectile.angle + pi) + giveOrTake(piHalf ),
          speed: 1.5,
      );
      continue;
    }

    if (projectile.type == ProjectileType.Bullet) {
      Game.spawnParticleBubble(
        x: projectile.x + giveOrTake(5),
        y: projectile.y + giveOrTake(5),
        z: projectile.z,
        angle: (projectile.angle + pi) + giveOrTake(piHalf ),
        speed: 1.5,
      );
      Game.spawnParticleBulletRing(
        x: projectile.x,
        y: projectile.y,
        z: projectile.z,
        angle: projectile.angle,
        speed: 1.5,
      );
      continue;
    }

    if (projectile.type != ProjectileType.Orb) continue;
    Game.spawnParticleOrbShard(x: projectile.x, y: projectile.y, z: projectile.z, angle: randomAngle());
  }
}

