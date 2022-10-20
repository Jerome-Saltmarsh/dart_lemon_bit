
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/particle_type.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/classes/particle_emitter.dart';
import 'package:lemon_math/library.dart';


void updateParticleEmitters(){
  for (final emitter in GameState.particleEmitters) {
    if (emitter.next-- > 0) continue;
    emitter.next = emitter.rate;
    final particle = GameState.getParticleInstance();
    particle.x = emitter.x;
    particle.y = emitter.y;
    particle.z = emitter.z;
    emitter.emit(particle);
  }
}

var nextCrystalEmission = 0;
var nextBubble = 0;

void updateGameObjects() {
  // updateCrystals();
  if (nextBubble-- > 0) return;
  nextBubble = 50;
  for (var i = 0; i < GameState.totalGameObjects; i++) {
    if (!GameObjectType.emitsBubbles(GameState.gameObjects[i].type)) continue;
    GameState.spawnParticleBubbleV3(GameState.gameObjects[i]);
  }
}


void updateCrystals(){
  if (nextCrystalEmission++ < 15) return;
  nextCrystalEmission = 0;
  for (var i = 0; i < GameState.totalGameObjects; i++) {
    if (GameState.gameObjects[i].type != GameObjectType.Crystal) continue;
    final crystal = GameState.gameObjects[i];
    GameState.spawnParticleOrbShard(
      x: crystal.x,
      y: crystal.y,
      z: crystal.z,
      speed: 2,
      duration: 50,
      angle: randomAngle(),
    );
  }
}

void isometricParticleEmittersActionAddSmokeEmitter(double x, double y){
  // particleEmitters.add(ParticleEmitter(x: x, y: y, rate: 12, emit: emitSmoke));
}

void addSmokeEmitter(int z, int row, int column){
  GameState.particleEmitters.add(
      ParticleEmitter(
          z: z,
          row: row,
          column: column,
          rate: 12,
          emit: emitSmoke,
      )
  );
}

void emitSmoke(Particle particle) {
  particle.type = ParticleType.Smoke;
  particle.duration = randomBetween(150, 200).toInt();
  particle.weight = 0;
  particle.scale = 0.15;
  particle.scaleV = 0.002;
  particle.rotation = 0;
  particle.rotationVelocity = 0;
  particle.bounciness = 0;
  particle.xv = randomBetween(0, -pi * 0.1);
  particle.yv = randomBetween(0, pi * 0.1);
  particle.zv = 0.25;
  particle.airFriction = 0.99;
}
