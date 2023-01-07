import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';

import 'library.dart';


class GameState {
  static final particleEmitters = <ParticleEmitter>[];
  static final particleOverflow = Particle();

  static var nextParticleFrame = 0;
  static var totalParticles = 0;

  static final gridShadows = Watch(true, onChanged: (bool value){
    GameNodes.resetNodeColorsToAmbient();
  });

  static var nodesTotalZ = 0;
  static var nodesTotalRows = 0;
  static var nodesTotalColumns = 0;
  static var nodesLengthRow = 0.0;
  static var nodesLengthColumn = 0.0;
  static var nodesLengthZ = 0.0;
  static var nodesRaycast = 0;
  static var windLine = 0;

  static int get bodyPartDuration => randomInt(120, 200);
  static bool get playMode => !editMode;
  static bool get editMode => ClientState.edit.value;
  static bool get lightningOn => ServerState.lightningType.value != LightningType.Off;

  static int getNodeIndexV3(Vector3 v3) {
    return getNodeIndexZRC(v3.indexZ, v3.indexRow, v3.indexColumn);
  }

  static int getNodeIndexZRC(int z, int row, int column) {
    return (z * GameNodes.area) + (row * nodesTotalColumns) + column;
  }

  static int convertNodeIndexToIndexZ(int index) =>
      index ~/ GameNodes.area;

  static int convertNodeIndexToIndexX(int index) =>
      (index - ((index ~/ GameNodes.area) * GameNodes.area)) ~/ nodesTotalColumns;

  static int convertNodeIndexToIndexY(int index) =>
      index - ((convertNodeIndexToIndexZ(index) * GameNodes.area) + (convertNodeIndexToIndexX(index) * nodesTotalColumns));

  static int getV3RenderColor(Vector3 vector3) =>
      vector3.outOfBounds
          ? GameNodes.ambient_color
          : GameNodes.nodeColors[vector3.nodeIndex];

  static bool outOfBoundsV3(Vector3 v3) =>
    outOfBoundsXYZ(v3.x, v3.y, v3.z);

  static bool outOfBounds(int z, int row, int column) =>
    z < 0                       ||
    row < 0                     ||
    column < 0                  ||
    z >= nodesTotalZ            ||
    row >= nodesTotalRows       ||
    column >= nodesTotalColumns  ;

  static bool outOfBoundsXYZ(double x, double y, double z) =>
    z < 0                       ||
    y < 0                       ||
    z < 0                       ||
    z >= nodesLengthZ           ||
    x >= nodesLengthRow         ||
    y >= nodesLengthColumn       ;

  // ACTIONS

  static void applyEmissions(){

    for (var i = 0; i < ClientState.nodesLightSourcesTotal; i++){
      final nodeIndex = ClientState.nodesLightSources[i];
      final nodeType = GameNodes.nodeTypes[nodeIndex];

      switch (nodeType){
        case NodeType.Torch:
          GameNodes.emitLightDynamicAmbient(
            index: nodeIndex,
            alpha: 0,
          );
          break;
        case NodeType.Vendor:
          GameNodes.emitLightDynamic(
              index: nodeIndex,
              hue: 259,
              saturation: 0.45,
              value: 0.95,
              alpha: 0.5,
          );
          break;
      }
    }

    applyEmissionsCharacters();
    ServerState.applyEmissionGameObjects();
    applyEmissionsProjectiles();
    applyCharacterColors();

    for (var i = 0; i < totalParticles; i++){
       final particle = ClientState.particles[i];
       if (particle.type != ParticleType.Light_Emission) continue;
       GameNodes.emitLightDynamic(
           index: particle.nodeIndex,
           hue: particle.hue,
           saturation: particle.saturation,
           value: particle.value,
           alpha: particle.alpha,
           strength: particle.strength,
       );
    }
  }

  static void applyCharacterColors(){
    for (var i = 0; i < ServerState.totalCharacters; i++){
      applyCharacterColor(ServerState.characters[i]);
    }
  }

  static void applyCharacterColor(Character character){
    character.color = getV3RenderColor(character);
  }

  static void applyEmissionsCharacters() {
    for (var i = 0; i < ServerState.totalCharacters; i++) {
      final character = ServerState.characters[i];
      if (!character.allie) continue;
      applyVector3EmissionAmbient(
          character,
          alpha: 0.25,
      );
    }
  }

  static void applyEmissionsProjectiles() {
    for (var i = 0; i < ServerState.totalProjectiles; i++){
      applyProjectileEmission(ServerState.projectiles[i]);
    }
  }

  static void applyProjectileEmission(Projectile projectile) {
    if (projectile.type == ProjectileType.Orb) {
      applyVector3Emission(projectile,
          hue: 100,
          saturation: 1,
          value: 1,
          alpha: 0.1,
      );
      return;
    }
    if (projectile.type == ProjectileType.Bullet) {
      applyVector3Emission(projectile,
          hue: 167,
          alpha: 0.25,
          saturation: 1,
          value: 1,
      );
      return;
    }
    if (projectile.type == ProjectileType.Fireball) {
      applyVector3Emission(projectile,
        hue: 167,
        alpha: 0.25,
        saturation: 1,
        value: 1,
      );
      return;
    }
    if (projectile.type == ProjectileType.Arrow) {
      applyVector3Emission(projectile,
        hue: 167,
        alpha: 0.25,
        saturation: 1,
        value: 1,
      );
      return;
    }
  }

  static void applyVector3Emission(Vector3 v, {
    required double hue,
    required double saturation,
    required double value,
    required double alpha,
  }){
    if (!GameQueries.inBoundsVector3(v)) return;
    GameNodes.emitLightDynamic(
      index: GameQueries.getNodeIndexV3(v),
      hue: hue,
      saturation: saturation,
      value: value,
      alpha: alpha,
    );
  }

  static void applyVector3EmissionAmbient(Vector3 v, {
    required double alpha,
  }){
    if (!GameQueries.inBoundsVector3(v)) return;
    GameNodes.emitLightDynamicAmbient(
      index: GameQueries.getNodeIndexV3(v),
      alpha: alpha,
    );
  }


  // static void applyEmissionDynamicV3(Vector3 v3, ) =>
  //     GameNodes.emitLightDynamic(
  //         index: GameQueries.getNodeIndexV3(v3),
  //         hue: 200,
  //     );

  static void onChangedUpdateFrame(int value){
    ClientState.rendersSinceUpdate.value = 0;
  }

  static void actionGameDialogShowMap() {
    if (ServerState.gameType.value != GameType.Dark_Age) return;

    if (GamePlayer.gameDialog.value == GameDialog.Map){
      GamePlayer.gameDialog.value = null;
      return;
    }
    GamePlayer.gameDialog.value = GameDialog.Map;
  }

  static void clear() {
    GamePlayer.position.x = -1;
    GamePlayer.position.y = -1;
    GamePlayer.gameDialog.value = null;
    GamePlayer.npcTalkOptions.value = [];
    ServerState.totalZombies = 0;
    ServerState.totalPlayers = 0;
    ServerState.totalProjectiles = 0;
    ServerState.totalNpcs = 0;
    ServerState.interactMode.value = InteractMode.None;
    ClientState.particles.clear();
    particleEmitters.clear();
    Engine.zoom = 1;
    Engine.redrawCanvas();
  }

  static Particle spawnParticle({
    required int type,
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed,
    bool checkCollision = true,
    double zv = 0,
    double weight = 1,
    int duration = 100,
    double scale = 1,
    double scaleV = 0,
    double rotation = 0,
    double rotationV = 0,
    bounciness = 0.5,
    // double airFriction = 0.98,
    bool animation = false,
  }) {
    if (ClientState.totalActiveParticles >= GameConfig.Particles_Max) {
      return particleOverflow;
    }
    assert(duration > 0);
    final particle = getInstanceParticle();
    assert(!particle.active);
    particle.type = type;
    particle.x = x;
    particle.y = y;
    particle.z = z;
    particle.checkNodeCollision = checkCollision;
    particle.animation = animation;

    if (speed > 0){
      particle.xv = Engine.calculateAdjacent(angle, speed);
      particle.yv = Engine.calculateOpposite(angle, speed);
    } else {
      particle.xv = 0;
      particle.yv = 0;
    }

    particle.zv = zv;
    particle.weight = weight;
    particle.duration = duration;
    particle.scale = scale;
    particle.scaleV = scaleV;
    particle.rotation = rotation;
    particle.rotationVelocity = rotationV;
    particle.bounciness = bounciness;
    return particle;
  }

  static void updateParticle(Particle particle) {
    if (!particle.active) return;
    if (particle.delay > 0) {
      particle.delay--;
      return;
    }
    if (particle.outOfBounds) return particle.deactivate();

    if (particle.type == ParticleType.Light_Emission){
      const change = 0.15;
      if (particle.flash){
        particle.strength += change;
        if (particle.strength >= 1){
          particle.strength = 1.0;
          particle.flash = false;
        }
        return;
      }
      particle.strength -= change;
      if (particle.strength <= 0){
        particle.strength = 0;
        particle.duration = 0;
      }
      return;
    }

    if (particle.animation) {
      if (particle.duration-- <= 0) {
        particle.deactivate();
      }
      return;
    }



    final nodeIndex = GameQueries.getNodeIndexV3(particle);

    assert (nodeIndex >= 0);
    assert (nodeIndex < GameNodes.total);

    final tile = GameNodes.nodeTypes[nodeIndex];
    final airBorn =
        !particle.checkNodeCollision || (
            tile == NodeType.Empty        ||
                tile == NodeType.Rain_Landing ||
                tile == NodeType.Rain_Falling ||
                tile == NodeType.Grass_Long   ||
                tile == NodeType.Fireplace)    ;


    if (particle.checkNodeCollision && !airBorn) {
      particle.deactivate();
      return;
    }

    if (!airBorn){
      particle.z = (particle.indexZ + 1) * Node_Height;
      particle.applyFloorFriction();
    } else {
      if (particle.type == ParticleType.Smoke){
        final wind = GameQueries.getWindAtV3(particle) * 0.01;
        particle.xv -= wind;
        particle.yv += wind;
      }
    }
    final bounce = particle.zv < 0 && !airBorn;
    particle.updateMotion();

    if (particle.outOfBounds) return particle.deactivate();

    if (bounce) {
      if (tile == NodeType.Water){
        return particle.deactivate();
      }
      if (particle.zv < -0.1){
        particle.zv = -particle.zv * particle.bounciness;
      } else {
        particle.zv = 0;
      }
    } else if (airBorn) {
      particle.applyAirFriction();
    }
    particle.applyLimits();
    particle.duration--;

    if (!particle.active) {
      particle.deactivate();
    }
  }


  static void spawnParticleWaterDrop({
    required double x,
    required double y,
    required double z,
  }) {
    spawnParticle(
        type: ParticleType.Water_Drop,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 0.5,
        zv: 1.5,
        weight: 5,
        duration: 15,
        rotation: 0,
        rotationV: 0,
        scaleV: 0,
        checkCollision: false
    );
  }

  static void spawnParticleArm({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    final type = ParticleType.Zombie_Arm;
    spawnParticle(
      type: type,
      x: x,
      y: y,
      z: z,
      angle: angle,
      speed: speed,
      zv: randomBetween(0.04, 0.06),
      weight: 6,
      duration: bodyPartDuration,
      rotation: giveOrTake(pi),
      rotationV: giveOrTake(0.25),
      scale: 0.75,
      scaleV: 0,
    );
  }

  static void spawnParticleBlood({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    spawnParticle(
      type: ParticleType.Blood,
      x: x,
      y: y,
      z: z,
      zv: zv,
      angle: angle,
      speed: speed,
      weight: 5,
      duration: randomInt(220, 250),
      rotation: 0,
      rotationV: 0,
      scale: 0.6,
      scaleV: 0,
      bounciness: 0,
    );
  }

  static void spawnParticleOrgan({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    final type = ParticleType.Zombie_Torso;
    spawnParticle(
        type: type,
        x: x,
        y: y,
        z: z,
        angle: angle,
        speed: speed,
        zv: randomBetween(0.04, 0.06),
        weight: 6,
        duration: bodyPartDuration,
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 1,
        scaleV: 0);
  }

  static void spawnParticleShell(
      double x,
      double y,
      double z,
      ) {
    spawnParticle(
      type: ParticleType.Shell,
      x: x,
      y: y,
      z: z,
      zv: 2,
      angle: randomAngle(),
      speed: 2,
      weight: 6,
      duration: randomInt(120, 200),
      rotation: randomInt(0, 7).toDouble(),
      rotationV: giveOrTake(0.25),
      scale: 0.6,
      scaleV: 0,
      bounciness: 0,
    );
  }

  static void spawnParticleShotSmoke({
    required double x,
    required double y,
    required double z,
    required double zv,
    required double angle,
    required double speed
  }) {
    for (var i = 0; i < 4; i++) {
      spawnParticle(
          type: ParticleType.Smoke,
          x: x,
          y: y,
          z: 0.3,
          angle: angle,
          speed: speed,
          zv: 0.0075,
          weight: 0.0,
          duration: 120,
          rotation: 0,
          rotationV: 0,
          scale: 0.35 + giveOrTake(0.15),
          scaleV: 0.001 + giveOrTake(0.0005));
    }
  }

  static void spawnParticleRockShard(double x, double y){
    spawnParticle(
      type: ParticleType.Rock,
      x: x,
      y: y,
      z: randomBetween(0.0, 0.2),
      angle: randomAngle(),
      speed: randomBetween(0.5, 1.25),
      zv: randomBetween(0.1, 0.2),
      weight: 0.5,
      duration: randomInt(150, 200),
      scale: randomBetween(0.6, 1.25),
      scaleV: 0,
      rotation: randomAngle(),
      bounciness: 0.35,
    );
  }

  static void spawnParticleTreeShard(double x, double y, double z){
    spawnParticle(
      type: ParticleType.Tree_Shard,
      x: x,
      y: y,
      z: z,
      angle: randomAngle(),
      speed: randomBetween(0.5, 1.25),
      zv: randomBetween(0.1, 0.2),
      weight: 0.5,
      duration: randomInt(150, 200),
      scale: randomBetween(0.6, 1.25),
      scaleV: 0,
      rotation: randomAngle(),
      bounciness: 0.35,
    );
  }

  static void spawnParticleBlockWood(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Wood,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: randomBetween(0.5, 1.25),
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0,
        checkCollision: false,
      );
    }
  }

  static void spawnParticleBlockGrass(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Grass,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: randomBetween(0.5, 1.25),
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0,
        checkCollision: false,
      );
    }
  }

  static void spawnParticleBlockBrick(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Brick,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: randomBetween(0.5, 1.25),
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.6,
        scaleV: 0,
        rotation: randomAngle(),
        bounciness: 0,
        checkCollision: false,
      );
    }
  }

  static void spawnParticleHeadZombie({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    spawnParticle(
      type: ParticleType.Zombie_Head,
      x: x,
      y: y,
      z: z,
      angle: angle,
      speed: speed,
      zv: 0.06,
      weight: 6,
      duration: bodyPartDuration,
      rotation: 0,
      rotationV: 0.05,
      scale: 0.75,
      scaleV: 0,
    );
  }

  static void spawnParticleLegZombie({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed
  }) {
    spawnParticle(
        type: ParticleType.Zombie_leg,
        x: x,
        y: y,
        z: z,
        angle: angle,
        speed: speed,
        zv: randomBetween(0, 0.03),
        weight: 6,
        duration: bodyPartDuration,
        rotation: giveOrTake(pi),
        rotationV: giveOrTake(0.25),
        scale: 0.75);
  }

  static void spawnParticleOrbShard({
    required double x,
    required double y,
    required double z,
    required double angle,
    int duration = 12,
    double speed = 1.0,
    double scale = 0.75
  }) {
    spawnParticle(
      type: ParticleType.Orb_Shard,
      x: x,
      y: y,
      z: z,
      angle: angle,
      rotation: angle,
      speed: speed,
      scaleV: 0,
      weight: 0,
      duration: duration,
      scale: scale,
    );
  }

  static void spawnParticleBubbles({
    required int count,
    required double x,
    required double y,
    required double z,
    required double angle,
  }){
    spawnParticleBubble(
      x: x,
      y: y,
      z: z,
      angle: angle + giveOrTake(piQuarter),
      speed: 3 + giveOrTake(2),
    );
  }



  static void spawnParticleBubble({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double angle = 0,
    double speed = 0,
  }) {
    spawnParticle(
      type: randomBool() ? ParticleType.Bubble : ParticleType.Bubble_Small,
      x: x,
      y: y,
      z: z,
      angle: angle,
      rotation: 0,
      speed: speed,
      scaleV: 0,
      weight: -0.5,
      duration: duration,
      scale: scale,
    );
  }


  static void spawnParticleBulletRing({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double angle = 0,
    double speed = 0,
  }) {
    spawnParticle(
      type: ParticleType.Bullet_Ring,
      x: x,
      y: y,
      z: z,
      angle: angle,
      rotation: 0,
      speed: speed,
      scaleV: 0,
      weight: -0.5,
      duration: duration,
      scale: scale,
    );
  }

  static void spawnParticleStrikeBlade({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double angle = 0,
    double speed = 2,
  }) {
    spawnParticle(
      type: ParticleType.Strike_Blade,
      x: x,
      y: y,
      z: z,
      angle: angle,
      rotation: angle,
      speed: speed,
      scaleV: 0,
      weight: 0,
      duration: duration,
      scale: scale,
      checkCollision: false,
      animation: true,
    );
  }

  static void spawnParticleAnimation({
    required double x,
    required double y,
    required double z,
    required int type,
    int duration = 100,
    double scale = 1.0,
    double angle = 0,
  }) =>
      spawnParticle(
        type: type,
        x: x,
        y: y,
        z: z,
        angle: angle,
        rotation: angle,
        speed: 0,
        scaleV: 0,
        weight: 0,
        duration: duration,
        scale: scale,
        checkCollision: false,
        animation: true,
      );

  static void spawnParticleStarExploding({
    required double x,
    required double y,
    required double z,
  }) {
    spawnParticle(
        type: ParticleType.Star_Explosion,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 0,
        weight: 0,
        duration: 100,
        scale: 0.75
    );
  }

  static void spawnParticleLightEmission({
    required double x,
    required double y,
    required double z,
    required double hue,
    required double saturation,
    required double value,
    required double alpha,
  }) =>
      spawnParticle(
        type: ParticleType.Light_Emission,
        x: x,
        y: y,
        z: z,
        angle: 0,
        speed: 0,
        weight: 0,
        duration: 35,
        checkCollision: false,
        animation: true,
      )
        ..hue = hue
        ..saturation = saturation
        ..value = value
        ..alpha = alpha
        ..flash = true
        ..strength = 0.0
  ;

  /// This may be the cause of the bug in which the sword particle does not render
  static Particle getInstanceParticle() {
    ClientState.totalActiveParticles++;
    if (ClientState.totalActiveParticles >= totalParticles){
      final instance = Particle();
      ClientState.particles.add(instance);
      return instance;
    }
    return ClientState.particles[ClientState.totalActiveParticles];
  }

  static Particle spawnParticleFire({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0
  }) =>
    spawnParticle(
      type: ParticleType.Fire,
      x: x,
      y: y,
      z: z,
      zv: 1,
      angle: 0,
      rotation: 0,
      speed: 0,
      scaleV: 0.01,
      weight: -1,
      duration: duration,
      scale: scale,
    );

  static Particle spawnParticleSmoke({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0
  }) =>
      spawnParticle(
        type: ParticleType.Smoke,
        x: x,
        y: y,
        z: z,
        zv: 0,
        angle: 0,
        rotation: 0,
        speed: 0,
        scaleV: 0.01,
        weight: -0.25,
        duration: duration,
        scale: scale,
      );

  static void spawnParticleFirePurple({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double speed = 0.0,
    double angle = 0.0,
  }) {
    spawnParticle(
      type: ParticleType.Fire_Purple,
      x: x,
      y: y,
      z: z,
      zv: 1,
      angle: angle,
      rotation: 0,
      speed: speed,
      scaleV: 0.01,
      weight: -1,
      duration: duration,
      scale: scale,
    );
  }


  static void spawnParticleSlimeDeath({
    required double x,
    required double y,
    required double z,
  }) {
    spawnParticle(
      type: ParticleType.Character_Death_Slime,
      x: x,
      y: y,
      z: z,
      zv: 0,
      angle: 0,
      rotation: 0,
      speed: 0,
      scaleV: 0.01,
      weight: -1,
      duration: 0,
      scale: 1.0,
    );
  }

  /// do this during the draw call so that particles are smoother
  static void updateParticles() {
    nextParticleFrame--;

    for (final particle in ClientState.particles) {
      if (!particle.active) continue;
      updateParticle(particle);
      if (nextParticleFrame <= 0){
        particle.frame++;
      }
    }
    if (nextParticleFrame <= 0) {
      nextParticleFrame = GameConstants.Frames_Per_Particle_Animation_Frame;
    }
  }


  static void interpolatePlayer(){

    if (!GamePlayer.interpolating.value) return;

    if (ClientState.rendersSinceUpdate.value == 0) {
      return;
    }
    if (ClientState.rendersSinceUpdate.value != 1) return;

    final playerCharacter = ServerState.getPlayerCharacter();
    if (playerCharacter == null) return;
    final velocityX = GamePlayer.position.x - GamePlayer.previousPosition.x;
    final velocityY = GamePlayer.position.y - GamePlayer.previousPosition.y;
    final velocityZ = GamePlayer.position.z - GamePlayer.previousPosition.z;
    playerCharacter.x += velocityX;
    playerCharacter.y += velocityY;
    playerCharacter.z -= velocityZ;
  }

  static void renderEditMode() {
    if (playMode) return;
    if (GameEditor.gameObjectSelected.value){
      Engine.renderCircleOutline(
        sides: 24,
        radius: GameEditor.gameObjectSelectedRadius.value,
        x: GameEditor.gameObject.renderX,
        y: GameEditor.gameObject.renderY,
        color: Colors.white,
      );
      return renderCircleV3(GameEditor.gameObject);
    }

    renderEditWireFrames();
    GameRender.renderMouseWireFrame();

    // final nodeData = EditState.selectedNodeData.value;
    // if (nodeData != null){
    //   Engine.renderCircleOutline(
    //        radius: nodeData.spawnRadius.toDouble(),
    //        x: EditState.renderX,
    //        y: EditState.renderY,
    //        color: Colors.white,
    //        sides: 8,
    //    );
    // }
  }

  static void renderEditWireFrames() {
    for (var z = 0; z < GameEditor.z; z++) {
      GameRender.renderWireFrameBlue(z, GameEditor.row, GameEditor.column);
    }
    GameRender.renderWireFrameRed(GameEditor.row, GameEditor.column, GameEditor.z);
  }

  static void update() {
    GameAnimation.updateAnimationFrame();
    updateParticleEmitters();
    updateProjectiles();
    GameAudio.update();
    ClientState.update();
    updatePlayerMessageTimer();
    GameIO.readPlayerInput();
    GameNetwork.sendClientRequestUpdate();
  }

  static void updatePlayerMessageTimer() {
    if (GamePlayer.messageTimer <= 0) return;
    GamePlayer.messageTimer--;
    if (GamePlayer.messageTimer > 0) return;
    GamePlayer.message.value = "";
  }

  static void toggleShadows () => gridShadows.value = !gridShadows.value;

  static void actionGameDialogShowQuests() {
    if (ServerState.gameType.value != GameType.Dark_Age) return;

    if (GamePlayer.gameDialog.value == GameDialog.Quests){
      GamePlayer.gameDialog.value = null;
      return;
    }
    GamePlayer.gameDialog.value = GameDialog.Quests;
  }

    static void updateParticleEmitters(){
      for (final emitter in particleEmitters) {
        if (emitter.next-- > 0) continue;
        emitter.next = emitter.rate;
        final particle = getInstanceParticle();
        particle.x = emitter.x;
        particle.y = emitter.y;
        particle.z = emitter.z;
        emitter.emit(particle);
      }
    }

    static void updateProjectiles() {
      for (var i = 0; i < ServerState.totalProjectiles; i++) {
        final projectile = ServerState.projectiles[i];
        if (projectile.type == ProjectileType.Fireball) {
          spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
          continue;
        }
        if (projectile.type == ProjectileType.Orb) {
          spawnParticleOrbShard(x: projectile.x, y: projectile.y, z: projectile.z, angle: randomAngle());
        }
      }
    }

    static void applyShadows(){
      // if (ServerState.ambientShade.value > Shade.Very_Bright) return;
      applyShadowsMidAfternoon();
    }

    static void applyShadowsMidAfternoon() {
      applyShadowAt(directionZ: -1, directionRow: 0, directionColumn: 0, maxDistance: 1);
    }

    static void applyShadowAt({
      required int directionZ,
      required int directionRow,
      required int directionColumn,
      required int maxDistance,
    }){
      final shadowShade = Shade.Medium;

      for (var z = 0; z < nodesTotalZ; z++) {
        for (var row = 0; row < nodesTotalRows; row++){
          for (var column = 0; column < nodesTotalColumns; column++){
            // final tile = grid[z][row][column];
            final index = getNodeIndexZRC(z, row, column);
            final tile = GameNodes.nodeTypes[index];
            if (!castesShadow(tile)) continue;
            var projectionZ = z + directionZ;
            var projectionRow = row + directionRow;
            var projectionColumn = column + directionColumn;
            while (
            projectionZ >= 0 &&
                projectionRow >= 0 &&
                projectionColumn >= 0 &&
                projectionZ < nodesTotalZ &&
                projectionRow < nodesTotalRows &&
                projectionColumn < nodesTotalColumns
            ) {
              // final shade = GameNodes.nodeBake[index];
              // if (shade < shadowShade){
              //   if (GameQueries.gridNodeZRCType(projectionZ + 1, projectionRow, projectionColumn) == NodeType.Empty){
              //     GameNodes.nodeBake[index] = shadowShade;
              //   }
              // }
              projectionZ += directionZ;
              projectionRow += directionRow;
              projectionColumn += directionColumn;
            }
          }
        }
      }
    }

    static bool castesShadow(int type) =>
        type == NodeType.Brick ||
        type == NodeType.Water;

    static bool gridIsUnderSomething(int z, int row, int column){
      if (outOfBounds(z, row, column)) return false;
      for (var zIndex = z + 1; zIndex < nodesTotalZ; zIndex++){
        if (!GameQueries.gridNodeZRCTypeRainOrEmpty(z, row, column)) return false;
      }
      return true;
    }

    static bool gridIsPerceptible(int index){
      if (index < 0) return true;
      if (index >= GameNodes.total) return true;
      while (true){
        index += GameNodes.area;
        index++;
        index += nodesTotalColumns;
        if (index >= GameNodes.total) return true;
        if (GameNodes.nodeOrientations[index] != NodeOrientation.None){
          return false;
        }
      }
    }

    static void refreshGridMetrics(){
      nodesLengthRow = nodesTotalRows * Node_Size;
      nodesLengthColumn = nodesTotalColumns * Node_Size;
      nodesLengthZ = nodesTotalZ * Node_Height;
    }

    static void setNodeType(int z, int row, int column, int type){
      if (z < 0)
        return;
      if (row < 0)
        return;
      if (column < 0)
        return;
      if (z >= nodesTotalZ)
        return;
      if (row >= nodesTotalRows)
        return;
      if (column >= nodesTotalColumns)
        return;

      GameNodes.nodeTypes[getNodeIndexZRC(z, row, column)] = type;
    }
}