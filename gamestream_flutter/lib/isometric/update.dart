
import 'package:bleed_common/Projectile_Type.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/game_action.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';

import 'animation_frame.dart';
import 'audio/audio_loops.dart';
import 'audio/audio_random.dart';
import 'particle_emitters.dart';
import 'particles.dart';
import 'players.dart';
import 'projectiles.dart';
import 'weather/breeze.dart';
import 'weather/lightning.dart';

void updateIsometric(){
  updateGameActions();
  updateAnimationFrame();
  updateParticleEmitters();
  updateParticles();
  updateProjectiles();
  // updateFootstepAudio();
  updateRandomAudio();
  gridWindResetToAmbient();
  applyObjectsToWind();

}

void applyObjectsToWind(){
  foreachPlayer(applyCharacterToWind);

  for (var i = 0; i < totalProjectiles; i++){
     applyWindFromProjectile(projectiles[i]);
  }

  updateWindLine();
  updateAudioLoops();
  weatherUpdateLightning();
}

void applyWindFromProjectile(Projectile projectile){
    final z = projectile.indexZ;
    final row = projectile.indexRow;
    final column = projectile.indexColumn;

    gridWind[z][row][column]++;
    if (z > 0){
      gridWind[z - 1][row][column]++;
    }
}

void applyCharacterToWind(Character character){
   if (character.running || character.performing){
      final z = character.indexZ;
      gridWind[z][character.indexRow][character.indexColumn]++;
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

