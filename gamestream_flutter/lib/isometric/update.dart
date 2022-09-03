

import 'dart:math';

import 'package:bleed_common/Projectile_Type.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/update/update_lightning.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:lemon_math/library.dart';

import 'animation_frame.dart';
import 'audio/audio_loops.dart';
import 'audio/audio_random.dart';
import 'particle_emitters.dart';
import 'particles.dart';
import 'players.dart';
import 'projectiles.dart';
import 'update/update_zombie_growls.dart';
import 'weather/breeze.dart';

void updateIsometric(){
  updateGameActions();
  updateAnimationFrame();
  updateParticleEmitters();
  updateGameObjects();
  updateParticles();
  updateProjectiles();
  updateRandomAudio();
  gridWindResetToAmbient();
  applyObjectsToWind();
  updateZombieGrowls();
  updateMouseBubbleSpawn();
  updateCharacters();
}

void updateMouseBubbleSpawn() {
  if (nextBubbleSpawn-- > 0) return;
  nextBubbleSpawn = 30;
  spawnParticleBubble(x: mouseGridX, y: mouseGridY, z: player.z);
}

var _characterBubbleSpawn = 0;

void updateCharacters() {

  for (var i = 0; i < totalCharacters; i++){
    final character = characters[i];
    if (!character.hurt) continue;
    spawnParticleBubble(x: character.x, y: character.y, z: character.z + 24);
  }

  if (_characterBubbleSpawn-- > 0) return;
  _characterBubbleSpawn = 60;
  for (var i = 0; i < totalCharacters; i++){
    final character = characters[i];
    spawnParticleBubble(x: character.x, y: character.y, z: character.z + 24);
  }
}

var nextBubbleSpawn = 0;
var particleAnimation = 0;

void updateParticleFrames() {
  // if (particleAnimation++ < 3) return;
  particleAnimation = 0;
  for (var i = 0; i < particles.length; i++){
    particles[i].updateFrame();
  }
}

void applyObjectsToWind(){
  foreachPlayer(applyCharacterToWind);

  for (var i = 0; i < totalProjectiles; i++){
     applyWindFromProjectile(projectiles[i]);
  }

  updateWindLine();
  updateAudioLoops();
  updateLightning();
}

void applyWindFromProjectile(Projectile projectile){
    // final z = projectile.indexZ;
    // final row = projectile.indexRow;
    // final column = projectile.indexColumn;
    projectile.tile.wind++;
    projectile.tileAbove.wind++;
    // if (z > 0){
      // gridWind[z - 1][row][column]++;
    // }
}

void applyCharacterToWind(Character character){
   if (character.running || character.performing) {
     character.tile.wind++;
     character.tileAbove.wind++;
   }
}

void updateProjectiles() {
  for (var i = 0; i < totalProjectiles; i++) {
    final projectile = projectiles[i];
    if (projectile.type == ProjectileType.Fireball) {
      spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
      spawnParticleBubble(
          x: projectile.x + giveOrTake(5),
          y: projectile.y + giveOrTake(5),
          z: projectile.z,
          angle: (projectile.angle + pi) + giveOrTake(piHalf ),
          speed: 1.5,
      );
      continue;
    }

    if (projectile.type == ProjectileType.Bullet) {
      spawnParticleBubble(
        x: projectile.x + giveOrTake(5),
        y: projectile.y + giveOrTake(5),
        z: projectile.z,
        angle: (projectile.angle + pi) + giveOrTake(piHalf ),
        speed: 1.5,
      );
      spawnParticleBulletRing(
        x: projectile.x,
        y: projectile.y,
        z: projectile.z,
        angle: projectile.angle,
        speed: 1.5,
      );
      continue;
    }

    if (projectile.type != ProjectileType.Orb) continue;
    spawnParticleOrbShard(x: projectile.x, y: projectile.y, z: projectile.z, angle: randomAngle());
  }
}

