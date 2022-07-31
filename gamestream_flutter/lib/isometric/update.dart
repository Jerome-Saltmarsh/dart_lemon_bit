
import 'package:bleed_common/Projectile_Type.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/update/update_lightning.dart';

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
  updateParticles();
  updateProjectiles();
  updateRandomAudio();
  gridWindResetToAmbient();
  applyObjectsToWind();
  updateZombieGrowls();
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
    if (projectile.type != ProjectileType.Orb) continue;
    spawnParticleOrbShard(x: projectile.x, y: projectile.y, z: projectile.z);
  }
}

