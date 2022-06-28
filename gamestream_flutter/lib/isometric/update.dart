
import 'package:bleed_common/Projectile_Type.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:lemon_engine/engine.dart';

import 'animation_frame.dart';
import 'particle_emitters.dart';
import 'particles.dart';
import 'players.dart';
import 'projectiles.dart';
import 'zombies.dart';

void updateIsometric(){
  updateGameActions();
  updateAnimationFrame();
  updateParticleEmitters();
  updateParticles();
  updateProjectiles();
  updateFootstepAudio();

  gridWindResetToAmbient();
  applyObjectsToWind();

}

void applyObjectsToWind(){
  foreachPlayer(applyCharacterToWind);
  updateWindParticles();
  audio.updateWind();
}

void applyCharacterToWind(Character character){
   if (character.running || character.performing){
      final z = character.indexZ;
        if (z > 0){
          gridWind[z - 1][character.indexRow][character.indexColumn]++;
        }
   }
}

void updateProjectiles() {
  for (var i = 0; i < totalProjectiles; i++) {
    final projectile = projectiles[i];
    if (projectile.type != ProjectileType.Orb) continue;
    spawnParticleOrbShard(x: projectile.x, y: projectile.y, z: projectile.z);
  }
}

void updateFootstepAudio() {
  if (engine.frame % 2 == 0) return;

  for (var i = 0; i < totalPlayers; i++) {
    final player = players[i];
    if (player.running && player.frame % 2 == 0) {
      audio.footstepGrass(player.x, player.y);
    }
  }

  for (var i = 0; i < totalZombies; i++) {
    final zombie = zombies[i];
    if (zombie.running && zombie.frame % 2 == 0) {
      audio.footstepGrass(zombie.x, zombie.y);
    }
  }
}
