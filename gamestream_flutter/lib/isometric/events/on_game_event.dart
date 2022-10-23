import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_library.dart';
import 'package:lemon_math/library.dart';


void onGameEventNodeSet(double x, double y, double z) {
  GameAudio.hover_over_button_sound_43.playXYZ(x, y, z);
}

void onGameEventNodeStruck(int nodeType, double x, double y, double z) {

  if (NodeType.isMaterialWood(nodeType)){
    GameAudio.material_struck_wood.playXYZ(x, y, z);
    GameState.spawnParticleBlockWood(x, y, z);
  }

  if (NodeType.isMaterialGrass(nodeType)){
    GameAudio.grass_cut.playXYZ(x, y, z);
    GameState.spawnParticleBlockGrass(x, y, z);
  }

  if (NodeType.isMaterialStone(nodeType)){
    GameAudio.material_struck_stone.playXYZ(x, y, z);
    GameState.spawnParticleBlockBrick(x, y, z);
  }
}

void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
  GameState.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
  // audioSingleSciFiBlaster8.playXYZ(x, y, z);

  GameAudio.swing_sword.playXYZ(x, y, z);
  // const range = 5.0;
  // engine.camera.x += getAdjacent(angle + piQuarter, range);
  // engine.camera.y += getOpposite(angle + piQuarter, range);

  GameState.spawnParticleBubbles(
    count: 3,
    x: x,
    y: y,
    z: z,
    angle: angle,
  );
}

void onGameEventAttackPerformedUnarmed(double x, double y, double z, double angle) {
  GameState.spawnParticleBubbles(
    count: 3,
    x: x,
    y: y,
    z: z,
    angle: angle,
  );
}

void onGameEventSpawnDustCloud(double x, double y, double z) {
  for (var i = 0; i < 3; i++){
    GameState.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
  }
}

void onGameEventSplash(double x, double y, double z) {
  for (var i = 0; i < 8; i++){
    GameState.spawnParticleWaterDrop(x: x, y: y, z: z);
  }
  return GameAudio.splash.playXYZ(x, y, z);
}
