import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';

import '../classes/isometric_position.dart';
import '../classes/isometric_projectile.dart';

/// WARNING - WRITING TO SERVER STATE IS FORBIDDEN
/// the data inside server state belongs to the server and can only be written by serverResponseReader
class IsometricServer {
  var totalProjectiles = 0;
  var inventory = Uint16List(0);
  var inventoryQuantity = Uint16List(0);

  final projectiles = <IsometricProjectile>[];
  final playerExperiencePercentage = Watch(0.0);
  final sceneEditable = Watch(false);
  final sceneName = Watch<String?>(null);
  final gameRunning = Watch(true);
  final weatherBreeze = Watch(false);
  final minutes = Watch(0);
  final lightningType = Watch(LightningType.Off);
  final watchTimePassing = Watch(false);
  final sceneUnderground = Watch(false);

  late final gameTimeEnabled = Watch(false, onChanged: onChangedGameTimeEnabled);
  late final lightningFlashing = Watch(false, onChanged: onChangedLightningFlashing);
  late final rainType = Watch(RainType.None, onChanged: gamestream.isometric.events.onChangedRain);
  late final seconds = Watch(0, onChanged: gamestream.isometric.events.onChangedSeconds);
  late final hours = Watch(0, onChanged: gamestream.isometric.events.onChangedHour);
  late final windTypeAmbient = Watch(WindType.Calm, onChanged: gamestream.isometric.events.onChangedWindType);

  void projectShadow(IsometricPosition v3){
    if (!gamestream.isometric.scene.inBoundsPosition(v3)) return;

    final z = getProjectionZ(v3);
    if (z < 0) return;
    gamestream.isometric.particles.spawnParticle(
      type: ParticleType.Shadow,
      x: v3.x,
      y: v3.y,
      z: z,
      angle: 0,
      speed: 0,
      duration: 2,
    );
  }

  double getProjectionZ(IsometricPosition vector3){

    final x = vector3.x;
    final y = vector3.y;
    var z = vector3.z;

    while (true) {
      if (z < 0) return -1;
      final nodeIndex = gamestream.isometric.scene.getIndexXYZ(x, y, z);
      final nodeOrientation = gamestream.isometric.scene.nodeOrientations[nodeIndex];

      if (const <int> [
        NodeOrientation.None,
        NodeOrientation.Radial,
        NodeOrientation.Half_South,
        NodeOrientation.Half_North,
        NodeOrientation.Half_East,
        NodeOrientation.Half_West,
      ].contains(nodeOrientation)) {
        z -= IsometricConstants.Node_Height;
        continue;
      }
      if (z > Node_Height){
        return z + (z % Node_Height);
      } else {
        return Node_Height;
      }
    }
  }

  void clean() {
    gamestream.isometric.scene.colorStackIndex = -1;
    gamestream.isometric.scene.ambientStackIndex = -1;
  }

  void updateProjectiles() {
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      if (projectile.type == ProjectileType.Rocket) {
        gamestream.isometric.particles.spawnParticleSmoke(x: projectile.x, y: projectile.y, z: projectile.z);
        projectShadow(projectile);
        continue;
      }
      if (projectile.type == ProjectileType.Fireball) {
        gamestream.isometric.particles.spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
        continue;
      }
      if (projectile.type == ProjectileType.Orb) {
        gamestream.isometric.particles.spawnParticleOrbShard(
          x: projectile.x,
          y: projectile.y,
          z: projectile.z,
          angle: randomAngle(),
        );
      }
    }
  }

  void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      gamestream.audio.thunder(1.0);
    } else {
      gamestream.isometric.client.updateGameLighting();
    }
  }

  void onChangedGameTimeEnabled(bool value){
    GameIsometricUI.timeVisible.value = value;
  }
}



