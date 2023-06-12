import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_constants.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';
import 'package:gamestream_flutter/library.dart';

import 'atlases/atlas_nodes.dart';
import 'enums/dialog_type.dart';
import 'enums/emission_type.dart';
import 'enums/touch_button_side.dart';
import 'isometric_character.dart';
import 'isometric_particle.dart';
import 'isometric_position.dart';
import 'isometric_projectile.dart';


mixin class IsometricClientState {

  static const Particles_Max = 500;

  final sceneChanged = Watch(0);
  final readsHotKeys = Watch(0);
  final hoverTargetType = Watch(ClientType.Hover_Target_None);
  final hoverIndex = Watch(-1);
  final hoverDialogType = Watch(DialogType.None);
  final Map_Visible = WatchBool(true);
  final touchButtonSide = Watch(TouchButtonSide.Right);
  final dragStart = Watch(-1);
  final dragEnd = Watch(-1);
  final overrideColor = WatchBool(false);
  final window_visible_light_settings = WatchBool(false);
  final window_visible_menu = WatchBool(false);
  final window_visible_player_creation = WatchBool(false);
  final window_visible_attributes = WatchBool(false);
  final control_visible_player_weapons = WatchBool(false);
  final control_visible_player_power = WatchBool(true);
  final control_visible_scoreboard = WatchBool(false);
  final control_visible_respawn_timer = WatchBool(false);
  final triggerAlarmNoMessageReceivedFromServer = Watch(false);
  final itemGroup = Watch(ItemGroup.Primary_Weapon);
  final mouseOverItemType = Watch(-1);
  final buff_active_infinite_ammo = Watch(false);
  final buff_active_double_damage = Watch(false);
  final buff_active_fast = Watch(false);
  final buff_active_invincible = Watch(false);
  final buff_active_no_recoil = Watch(false);
  final particles = <IsometricParticle>[];
  final particleOverflow = IsometricParticle();

  var totalParticles = 0;
  var totalActiveParticles = 0;
  var srcXRainFalling = 6640.0;
  var srcXRainLanding = 6739.0;
  var messageStatusDuration = 0;
  var areaTypeVisibleDuration = 0;
  var nodesLightSources = Uint16List(0);
  var nodesLightSourcesTotal = 0;
  var nextLightingUpdate = 0;
  var lights_active = 0;
  var interpolation_padding = 0.0;
  var dynamicShadows = true;
  var emissionAlphaCharacter = 50;
  var torch_emission_start = 0.8;
  var torch_emission_end = 1.0;
  var torch_emission_vel = 0.061;
  var torch_emission_t = 0.0;
  var torch_emission_intensity = 1.0;
  var nextParticleFrame = 0;
  var nodesRaycast = 0;
  var windLine = 0;

  DateTime? timeConnectionEstablished;

  late final rendersSinceUpdate = Watch(0, onChanged: gamestream.isometric.events.onChangedRendersSinceUpdate);
  late final edit = Watch(false, onChanged: gamestream.isometric.events.onChangedEdit);
  late final messageStatus = Watch("", onChanged: onChangedMessageStatus);
  late final debugMode = Watch(false, onChanged: onChangedDebugMode);
  late final raining = Watch(false, onChanged: onChangedRaining);
  late final inventoryReads = Watch(0, onChanged: onInventoryReadsChanged);
  late final areaTypeVisible = Watch(false, onChanged: onChangedAreaTypeVisible);
  late final playerCreditsAnimation = Watch(0, onChanged: onChangedCredits);

  final gridShadows = Watch(true, onChanged: (bool value){
    gamestream.isometric.nodes.resetNodeColorsToAmbient();
  });

  int get bodyPartDuration => randomInt(120, 200);
  bool get playMode => !editMode;
  bool get editMode => edit.value;
  bool get lightningOn => gamestream.isometric.server.lightningType.value != LightningType.Off;

  // ACTIONS

  void applyEmissions(){
    lights_active = 0;
    applyEmissionsLightSources();
    applyEmissionsCharacters();
    gamestream.isometric.server.applyEmissionGameObjects();
    applyEmissionsProjectiles();
    applyCharacterColors();
    applyEmissionsParticles();
    applyEmissionEditorSelectedNode();
  }

  void applyEmissionEditorSelectedNode() {
    if (!editMode) return;
    if ((gamestream.isometric.editor.gameObject.value == null || gamestream.isometric.editor.gameObject.value!.emission_type == IsometricEmissionType.None)){
      gamestream.isometric.nodes.emitLightAHSVShadowed(
        index: gamestream.isometric.editor.nodeSelectedIndex.value,
        hue: gamestream.isometric.nodes.ambient_hue,
        saturation: gamestream.isometric.nodes.ambient_sat,
        value: gamestream.isometric.nodes.ambient_val,
        alpha: 0,
      );
    }
  }

  void applyEmissionsLightSources() {
    final nodes = gamestream.isometric.nodes;
    for (var i = 0; i < nodesLightSourcesTotal; i++){
      final nodeIndex = nodesLightSources[i];
      final nodeType = nodes.nodeTypes[nodeIndex];

      switch (nodeType){
        case NodeType.Torch:
          nodes.emitLightAmbient(
            index: nodeIndex,
            alpha: Engine.linerInterpolationInt(
              nodes.ambient_hue,
              0,
              torch_emission_intensity,
            ),
          );
          break;
      }
    }
  }


  void applyCharacterColors(){
    for (var i = 0; i < gamestream.isometric.server.totalCharacters; i++){
      applyCharacterColor(gamestream.isometric.server.characters[i]);
    }
  }

  void applyCharacterColor(IsometricCharacter character){
    character.color = gamestream.isometric.nodes.getV3RenderColor(character);
  }

  void applyEmissionsCharacters() {
    final serverState = gamestream.isometric.server;
    final characters = serverState.characters;
    for (var i = 0; i < serverState.totalCharacters; i++) {
      final character = characters[i];
      if (!character.allie) continue;

      if (character.weaponType == ItemType.Weapon_Melee_Staff){
        applyVector3Emission(
          character,
          alpha: 150,
          saturation: 100,
          value: 100,
          hue: 50,
        );
      } else {
        applyVector3EmissionAmbient(
          character,
          alpha: emissionAlphaCharacter,
        );
      }
    }
  }

  void applyEmissionsProjectiles() {
    for (var i = 0; i < gamestream.isometric.server.totalProjectiles; i++){
      applyProjectileEmission(gamestream.isometric.server.projectiles[i]);
    }
  }

  void applyProjectileEmission(IsometricProjectile projectile) {
    if (projectile.type == ProjectileType.Orb) {
      applyVector3Emission(projectile,
        hue: 100,
        saturation: 1,
        value: 1,
        alpha: 20,
      );
      return;
    }
    if (projectile.type == ProjectileType.Bullet) {
      applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
    if (projectile.type == ProjectileType.Fireball) {
      applyVector3Emission(projectile,
        hue: 167,
        alpha: 50,
        saturation: 1,
        value: 1,
      );
      return;
    }
    if (projectile.type == ProjectileType.Arrow) {
      applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
  }

  /// @hue a number between 0 and 360
  /// @saturation a number between 0 and 100
  /// @value a number between 0 and 100
  /// @alpha a number between 0 and 255
  /// @intensity a number between 0.0 and 1.0
  void applyVector3Emission(IsometricPosition v, {
    required int hue,
    required int saturation,
    required int value,
    required int alpha,
    double intensity = 1.0,
  }){
    if (!gamestream.isometric.nodes.inBoundsVector3(v)) return;
    gamestream.isometric.nodes.emitLightAHSVShadowed(
      index: gamestream.isometric.nodes.getNodeIndexV3(v),
      hue: hue,
      saturation: saturation,
      value: value,
      alpha: alpha,
      intensity: intensity,
    );
  }

  /// @alpha a number between 0 and 255
  /// @intensity a number between 0.0 and 1.0
  void applyVector3EmissionAmbient(IsometricPosition v, {
    required int alpha,
    double intensity = 1.0,
  }){
    assert (intensity >= 0);
    assert (intensity <= 1);
    assert (alpha >= 0);
    assert (alpha <= 255);
    if (!gamestream.isometric.nodes.inBoundsVector3(v)) return;
    gamestream.isometric.nodes.emitLightAmbient(
      index: gamestream.isometric.nodes.getNodeIndexV3(v),
      alpha: Engine.linerInterpolationInt(gamestream.isometric.nodes.ambient_hue, alpha , intensity),
    );
  }

  void onChangedUpdateFrame(int value){
    rendersSinceUpdate.value = 0;
  }

  void clear() {
    gamestream.isometric.player.position.x = -1;
    gamestream.isometric.player.position.y = -1;
    gamestream.isometric.player.gameDialog.value = null;
    gamestream.isometric.player.npcTalkOptions.value = [];
    gamestream.isometric.server.totalZombies = 0;
    gamestream.isometric.server.totalPlayers = 0;
    gamestream.isometric.server.totalProjectiles = 0;
    gamestream.isometric.server.totalNpcs = 0;
    gamestream.isometric.server.interactMode.value = InteractMode.None;
    particles.clear();
    engine.zoom = 1;
    engine.redrawCanvas();
  }

  IsometricParticle spawnParticle({
    required int type,
    required double x,
    required double y,
    required double z,
    double speed = 0,
    double angle = 0,
    bool checkCollision = true,
    double zv = 0,
    double weight = 1,
    int duration = 100,
    double scale = 1,
    double scaleV = 0,
    double rotation = 0,
    double rotationV = 0,
    bounciness = 0.5,
    bool animation = false,
    int delay = 0,
  }) {
    if (totalActiveParticles >= Particles_Max) {
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
    particle.emitsLight = false;
    particle.delay = delay;

    if (speed > 0){
      particle.xv = adj(angle, speed);
      particle.yv = opp(angle, speed);
    } else {
      particle.xv = 0;
      particle.yv = 0;
    }

    particle.zv = zv;
    particle.weight = weight;
    particle.duration = duration;
    particle.durationTotal = duration;
    particle.scale = scale;
    particle.scaleV = scaleV;
    particle.rotation = rotation;
    particle.rotationVelocity = rotationV;
    particle.bounciness = bounciness;
    return particle;
  }

  void updateParticle(IsometricParticle particle) {
    if (!particle.active) return;
    if (particle.delay > 0) {
      particle.delay--;
      return;
    }
    if (particle.outOfBounds) return particle.deactivate();

    if (particle.type == ParticleType.Light_Emission){
      const change = 0.125;
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



    final nodeIndex = gamestream.isometric.nodes.getNodeIndexV3(particle);

    assert (nodeIndex >= 0);
    assert (nodeIndex < gamestream.isometric.nodes.total);

    final tile = gamestream.isometric.nodes.nodeTypes[nodeIndex];
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
        final wind = gamestream.isometric.server.windTypeAmbient.value * 0.01;
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

  void spawnParticleWaterDrop({
    required double x,
    required double y,
    required double z,
    required double zv,
    int duration = 30,
  }) {
    spawnParticle(
        type: ParticleType.Water_Drop,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 0.5,
        zv: zv,
        weight: 5,
        duration: duration,
        rotation: 0,
        rotationV: 0,
        scaleV: 0,
        checkCollision: false
    );
  }

  void spawnParticleArm({
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

  void spawnParticleBlood({
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

  void spawnParticleOrgan({
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

  void spawnParticleShell(
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


  void spawnParticleShotSmoke({
    required double x,
    required double y,
    required double z,
    required double angle,
    required double speed,
    int delay = 0,
  }) => spawnParticle(
    type: ParticleType.Gunshot_Smoke,
    x: x,
    y: y,
    z: z,
    angle: angle,
    speed: speed,
    zv: 0.32,
    weight: 0.0,
    duration: 120,
    scale: 0.35 + giveOrTake(0.15),
    scaleV: 0.0015,
  )..delay = delay;


  void spawnParticleRockShard(double x, double y){
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

  void spawnParticleTreeShard(double x, double y, double z){
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

  void spawnParticleBlockWood(double x, double y, double z, [int count = 3]){
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

  void spawnParticleBlockGrass(double x, double y, double z, [int count = 3]){
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

  void spawnParticleBlockBrick(double x, double y, double z, [int count = 3]){
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

  void spawnParticleBlockSand(double x, double y, double z, [int count = 3]){
    for (var i = 0; i < count; i++){
      spawnParticle(
        type: ParticleType.Block_Sand,
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

  void spawnParticleHeadZombie({
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

  void spawnParticleLegZombie({
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

  void spawnParticleOrbShard({
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

  void spawnParticleBubbles({
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



  void spawnParticleBubble({
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


  void spawnParticleBulletRing({
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

  void spawnParticleStrikeBlade({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 0.75,
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

  void spawnParticleStrikePunch({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 0.75,
    double angle = 0,
    double speed = 2,
  }) {
    spawnParticle(
      type: ParticleType.Strike_Punch,
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

  void spawnParticleStrikeBulletLight({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 0.75,
    double angle = 0,
    double speed = 2,
  }) {
    spawnParticle(
      type: ParticleType.Strike_Light,
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


  void spawnParticleStrikeBullet({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 0.75,
    double angle = 0,
    double speed = 2,
  }) {
    spawnParticle(
      type: ParticleType.Strike_Bullet,
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

  void spawnParticleAnimation({
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

  void spawnParticleStarExploding({
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

  void spawnParticleLightEmission({
    required double x,
    required double y,
    required double z,
    required int hue,
    required int saturation,
    required int value,
    required int alpha,
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
        ..lightHue = hue
        ..lightSaturation = saturation
        ..lightValue = value
        ..alpha = alpha
        ..flash = true
        ..strength = 0.0
  ;

  void spawnParticleLightEmissionAmbient({
    required double x,
    required double y,
    required double z,
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
        ..lightHue = gamestream.isometric.nodes.ambient_hue
        ..lightSaturation = gamestream.isometric.nodes.ambient_sat
        ..lightValue = gamestream.isometric.nodes.ambient_val
        ..alpha = 0
        ..flash = true
        ..strength = 0.0
  ;


  IsometricParticle spawnParticleFire({
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
      )
        ..emitsLight = true
        ..lightHue = gamestream.isometric.nodes.ambient_hue
        ..lightSaturation = gamestream.isometric.nodes.ambient_sat
        ..lightValue = gamestream.isometric.nodes.ambient_val
        ..alpha = 0
        ..checkNodeCollision = false
        ..strength = 0.5
  ;

  IsometricParticle spawnParticleSmoke({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0,
    double scaleV = 0.01,
  }) =>
      spawnParticle(
        type: ParticleType.Smoke,
        x: x,
        y: y,
        z: z,
        zv: 0,
        angle: 0,
        rotation: 0,
        rotationV: giveOrTake(0.05),
        speed: 0,
        scaleV: scaleV,
        weight: -0.25,
        duration: duration,
        scale: scale,
      );

  void spawnParticleFirePurple({
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

  /// do this during the draw call so that particles are smoother
  void updateParticles() {
    nextParticleFrame--;

    for (final particle in particles) {
      if (!particle.active) continue;
      updateParticle(particle);
      if (nextParticleFrame <= 0){
        particle.frame++;
      }
    }
    if (nextParticleFrame <= 0) {
      nextParticleFrame = GameIsometricConstants.Frames_Per_Particle_Animation_Frame;
    }
  }


  void interpolatePlayer(){

    if (!gamestream.isometric.player.interpolating.value) return;
    if (rendersSinceUpdate.value == 0) {
      return;
    }
    if (rendersSinceUpdate.value != 1) return;

    final playerCharacter = gamestream.isometric.server.getPlayerCharacter();
    if (playerCharacter == null) return;
    final velocityX = gamestream.isometric.player.position.x - gamestream.isometric.player.previousPosition.x;
    final velocityY = gamestream.isometric.player.position.y - gamestream.isometric.player.previousPosition.y;
    final velocityZ = gamestream.isometric.player.position.z - gamestream.isometric.player.previousPosition.z;
    playerCharacter.x += velocityX;
    playerCharacter.y += velocityY;
    playerCharacter.z -= velocityZ;
  }

  void renderEditMode() {
    if (playMode) return;
    if (gamestream.isometric.editor.gameObjectSelected.value){
      engine.renderCircleOutline(
        sides: 24,
        radius: ItemType.getRadius(gamestream.isometric.editor.gameObjectSelectedType.value),
        x: gamestream.isometric.editor.gameObject.value!.renderX,
        y: gamestream.isometric.editor.gameObject.value!.renderY,
        color: Colors.white,
      );
      return renderCircleV3(gamestream.isometric.editor.gameObject.value!);
    }

    renderEditWireFrames();
    gamestream.isometric.renderer.renderMouseWireFrame();
  }

  void renderEditWireFrames() {
    for (var z = 0; z < gamestream.isometric.editor.z; z++) {
      gamestream.isometric.renderer.renderWireFrameBlue(z, gamestream.isometric.editor.row, gamestream.isometric.editor.column);
    }
    gamestream.isometric.renderer.renderWireFrameRed(gamestream.isometric.editor.row, gamestream.isometric.editor.column, gamestream.isometric.editor.z);
  }

  void updateTorchEmissionIntensity(){
    if (torch_emission_vel == 0) return;
    torch_emission_t += torch_emission_vel;

    if (
    torch_emission_t < torch_emission_start ||
        torch_emission_t > torch_emission_end
    ) {
      torch_emission_t = clamp(torch_emission_t, torch_emission_start, torch_emission_end);
      torch_emission_vel = -torch_emission_vel;
    }

    torch_emission_intensity = interpolateDouble(
      start: torch_emission_start,
      end: torch_emission_end,
      t: torch_emission_t,
    );
  }

  void updatePlayerMessageTimer() {
    if (gamestream.isometric.player.messageTimer <= 0) return;
    gamestream.isometric.player.messageTimer--;
    if (gamestream.isometric.player.messageTimer > 0) return;
    gamestream.isometric.player.message.value = "";
  }

  void toggleShadows () => gridShadows.value = !gridShadows.value;

  var nextEmissionSmoke = 0;

  void updateParticleEmitters(){
    nextEmissionSmoke--;
    if (nextEmissionSmoke > 0) return;
    nextEmissionSmoke = 20;
    for (final gameObject in gamestream.isometric.server.gameObjects){
      if (!gameObject.active) continue;
      if (gameObject.type != ItemType.GameObjects_Barrel_Flaming) continue;
      spawnParticleSmoke(x: gameObject.x + giveOrTake(5), y: gameObject.y + giveOrTake(5), z: gameObject.z + 35);
    }
  }

  // void setNodeType(int z, int row, int column, int type){
  //   if (z < 0)
  //     return;
  //   if (row < 0)
  //     return;
  //   if (column < 0)
  //     return;
  //   if (z >= gamestream.isometric.nodes.totalZ)
  //     return;
  //   if (row >= gamestream.isometric.nodes.totalRows)
  //     return;
  //   if (column >= gamestream.isometric.nodes.totalColumns)
  //     return;
  //
  //   gamestream.isometric.nodes.nodeTypes[getNodeIndexZRC(z, row, column)] = type;
  // }

  void spawnParticleConfetti(double x, double y, double z) {
    spawnParticle(
      type: randomItem(const[
        ParticleType.Confetti_Red,
        ParticleType.Confetti_Yellow,
        ParticleType.Confetti_Blue,
        ParticleType.Confetti_Green,
        ParticleType.Confetti_Purple,
      ]),
      x: x,
      y: y,
      z: z,
      angle: randomAngle(),
      speed: randomBetween(0.5, 2.0),
      weight: -0.02,
      scale: 0.5,
      duration: 40,
      delay: randomInt(0, 8),
    );
  }

  void spawnParticleConfettiByType(double x, double y, double z, int type) {
    spawnParticle(
      type: type,
      x: x,
      y: y,
      z: z,
      zv: randomBetween(0, 1),
      angle: randomAngle(),
      speed: randomBetween(0.5, 1.0),
      weight: -0.02,
      scale: 0.5,
      duration: randomInt(25, 150),
      delay: randomInt(0, 10),
    );
  }




  // PROPERTIES
  bool get hoverDialogIsInventory => hoverDialogType.value == DialogType.Inventory;
  bool get hoverDialogDialogIsTrade => hoverDialogType.value == DialogType.Trade;

  void update(){
    interpolation_padding = ((gamestream.isometric.nodes.interpolation_length + 1) * Node_Size) / engine.zoom;
    if (areaTypeVisible.value) {
      if (areaTypeVisibleDuration-- <= 0) {
        areaTypeVisible.value = false;
      }
    }

    if (messageStatusDuration > 0) {
      messageStatusDuration--;
      if (messageStatusDuration <= 0) {
        messageStatus.value = "";
      }
    }

    if (nextLightingUpdate-- <= 0){
      nextLightingUpdate = GameIsometricConstants.Frames_Per_Lighting_Update;
      updateGameLighting();
    }

    updateCredits();
  }

  var _updateCredits = true;

  void updateCredits() {
    _updateCredits = !_updateCredits;
    if (!_updateCredits) return;
    final diff = playerCreditsAnimation.value - gamestream.isometric.server.playerCredits.value;
    if (diff == 0) return;
    final diffAbs = diff.abs();
    final speed = max(diffAbs ~/ 10, 1);
    if (diff > 0) {
      playerCreditsAnimation.value -= speed;
    } else {
      playerCreditsAnimation.value += speed;
    }
  }

  void updateGameLighting(){
    if (overrideColor.value) return;
    if (gamestream.isometric.server.lightningFlashing.value) return;
    const Seconds_Per_Hour = 3600;
    const Seconds_Per_Hours_12 = Seconds_Per_Hour * 12;
    final totalSeconds = (gamestream.isometric.server.hours.value * Seconds_Per_Hour) + (gamestream.isometric.server.minutes.value * 60);

    gamestream.isometric.nodes.ambient_alp = ((totalSeconds < Seconds_Per_Hours_12
        ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
        : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) * 255).round();

    if (gamestream.isometric.server.rainType.value == RainType.Light){
      gamestream.isometric.nodes.ambient_alp += 20;
    }
    if (gamestream.isometric.server.rainType.value == RainType.Heavy){
      gamestream.isometric.nodes.ambient_alp += 40;
    }
    gamestream.isometric.nodes.resetNodeColorsToAmbient();
  }

  void countTotalActiveParticles(){
    totalActiveParticles = 0;
    totalParticles = particles.length;
    for (; totalActiveParticles < totalParticles; totalActiveParticles++){
      if (!particles[totalActiveParticles].active) break;
    }
  }


  void sortParticles() {
    sortParticlesActive();
    countTotalActiveParticles();

    if (totalActiveParticles == 0) return;

    assert (verifyTotalActiveParticles());

    Engine.insertionSort(
      particles,
      compare: compareRenderOrder,
      end: totalActiveParticles,
    );
  }

  bool compareRenderOrder(IsometricPosition a, IsometricPosition b) {
    final aRowColumn = a.indexRow + a.indexColumn;
    final bRowColumn = b.indexRow + b.indexColumn;

    if (aRowColumn > bRowColumn) return false;
    if (aRowColumn < bRowColumn) return true;

    final aIndexZ = a.indexZ;
    final bIndexZ = b.indexZ;

    if (aIndexZ > bIndexZ) return false;
    if (aIndexZ < bIndexZ) return true;

    return a.sortOrder < b.sortOrder;
  }

  void sortParticlesActive(){
    var total = particles.length;
    totalParticles = total;

    for (var pos = 1; pos < total; pos++) {
      var min = 0;
      var max = pos;
      var element = particles[pos];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (!particles[mid].active) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      particles.setRange(min + 1, pos + 1, particles, min);
      particles[min] = element;
    }
  }

  bool verifyTotalActiveParticles() =>
      countActiveParticles() == totalActiveParticles;

  int countActiveParticles(){
    var active = 0;
    for (var i = 0; i < particles.length; i++){
      if (particles[i].active)
        active++;
    }
    return active;
  }

  /// This may be the cause of the bug in which the sword particle does not render
  IsometricParticle getInstanceParticle() {
    totalActiveParticles++;
    if (totalActiveParticles >= totalParticles){
      final instance = IsometricParticle();
      particles.add(instance);
      return instance;
    }
    return particles[totalActiveParticles];
  }

  void refreshRain(){
    switch (gamestream.isometric.server.rainType.value) {
      case RainType.None:
        break;
      case RainType.Light:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Light_X;
        if (gamestream.isometric.server.windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = AtlasNode.Node_Rain_Falling_Light_X;
        } else {
          srcXRainFalling = 1851;
        }
        break;
      case RainType.Heavy:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Heavy_X;
        if (gamestream.isometric.server.windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = 1900;
        } else {
          srcXRainFalling = 1606;
        }
        break;
    }
  }

  void applyEmissionsParticles() {
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      final particle = particles[i];
      if (!particle.active) continue;
      if (particle.type != ParticleType.Light_Emission) continue;
      gamestream.isometric.nodes.emitLightAHSVShadowed(
        index: particle.nodeIndex,
        hue: particle.lightHue,
        saturation: particle.lightSaturation,
        value: particle.lightValue,
        alpha: particle.alpha,
      );
    }
  }

  Duration? get connectionDuration {
    if (timeConnectionEstablished == null) return null;
    return DateTime.now().difference(timeConnectionEstablished!);
  }

  String get formattedConnectionDuration {
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes;
    return 'minutes: $minutes, seconds: $seconds';
  }

  String formatAverageBufferSize(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds;
    final bytesPerSecond = (bytes / seconds).round();
    final bytesPerMinute = bytesPerSecond * 60;
    final bytesPerHour = bytesPerMinute * 60;
    return 'per second: $bytesPerSecond, per minute: $bytesPerMinute, per hour: $bytesPerHour';
  }

  String formatAverageBytePerSecond(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round());
  }

  String formatAverageBytePerMinute(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 60);
  }

  String formatAverageBytePerHour(int bytes){
    final duration = connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 3600);
  }

  void clearParticles(){
    particles.clear();
    totalActiveParticles = 0;
    totalParticles = 0;
  }

  static String formatBytes(int bytes){
    final kb = bytes ~/ 1000;
    final mb = kb ~/ 1000;
    return 'mb: $mb, kb: ${kb % 1000}';
  }

  void spawnBubbles(double x, double y, double z, {int amount = 5}){
    for (var i = 0; i < amount; i++) {
      spawnParticleBubble(x: x + Engine.randomGiveOrTake(5), y: y + Engine.randomGiveOrTake(5), z: z, speed: 1, angle: Engine.randomAngle());
    }
  }

  void spawnPurpleFireExplosion(double x, double y, double z){
    gamestream.audio.magical_impact_16.playXYZ(x, y, z, maxDistance: 600);
    for (var i = 0; i < 5; i++) {
      spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: Engine.randomAngle());
      spawnParticleFirePurple(x: x + Engine.randomGiveOrTake(5), y: y + Engine.randomGiveOrTake(5), z: z, speed: 1, angle: Engine.randomAngle());
    }

    spawnParticleLightEmission(
      x: x,
      y: y,
      z: z,
      hue: 259,
      saturation: 45,
      value: 95,
      alpha: 0,
    );
  }

  void toggleDynamicShadows() => dynamicShadows = !dynamicShadows;
  void redrawInventory() => inventoryReads.value++;
  void redrawHotKeys() => readsHotKeys.value++;

  void clearMouseOverDialogType() =>
      hoverDialogType.value = DialogType.None;

  void clearHoverIndex() =>
      hoverIndex.value = -1;


  void refreshBakeMapLightSources() {
    nodesLightSourcesTotal = 0;
    for (var i = 0; i < gamestream.isometric.nodes.total; i++){
      if (!NodeType.emitsLight(gamestream.isometric.nodes.nodeTypes[i])) continue;
      if (nodesLightSourcesTotal >= nodesLightSources.length) {
        nodesLightSources = Uint16List(nodesLightSources.length + 100);
        refreshBakeMapLightSources();
        return;
      }
      nodesLightSources[nodesLightSourcesTotal] = i;
      nodesLightSourcesTotal++;
    }
  }

  void clearHoverDialogType() {
    hoverDialogType.value = DialogType.None;
  }

  void showMessage(String message){
    messageStatus.value = "";
    messageStatus.value = message;
  }

  void spawnConfettiPlayer() {
    for (var i = 0; i < 10; i++){
      spawnParticleConfetti(
        gamestream.isometric.player.position.x,
        gamestream.isometric.player.position.y,
        gamestream.isometric.player.position.z,
      );
    }
  }

  void inventorySwapDragTarget(){
    if (dragStart.value == -1) return;
    if (hoverIndex.value == -1) return;
    gamestream.network.sendClientRequestInventoryMove(
      indexFrom: dragStart.value,
      indexTo: hoverIndex.value,
    );
  }

   void playSoundWindow() =>
      gamestream.audio.click_sound_8(1);

   void dragStartSetNone(){
    gamestream.isometric.clientState.dragStart.value = -1;
  }

   void setDragItemIndex(int index) =>
          () => gamestream.isometric.clientState.dragStart.value = index;

   void dropDraggedItem(){
    if (gamestream.isometric.clientState.dragStart.value == -1) return;
    gamestream.network.sendClientRequestInventoryDrop(gamestream.isometric.clientState.dragStart.value);
  }

   void messageClear(){
    writeMessage("");
  }

   void writeMessage(String value){
    gamestream.isometric.clientState.messageStatus.value = value;
  }

   void playAudioError(){
    gamestream.audio.errorSound15();
  }

  void onInventoryReadsChanged(int value){
    gamestream.isometric.clientState.clearHoverIndex();
  }

  void onChangedAttributesWindowVisible(bool value){
    gamestream.isometric.clientState.playSoundWindow();
  }

  void onChangedHotKeys(int value){
    gamestream.isometric.clientState.redrawHotKeys();
  }

  void onChangedRaining(bool raining){
    raining ? gamestream.isometric.actions.rainStart() : gamestream.isometric.actions.rainStop();
    gamestream.isometric.nodes.resetNodeColorsToAmbient();
  }

  void onDragStarted(int itemIndex){
    // print("onDragStarted()");
    gamestream.isometric.clientState.dragStart.value = itemIndex;
    gamestream.isometric.clientState.dragEnd.value = -1;
  }

  void onDragCompleted(){
    // print("onDragCompleted()");
  }

  void onDragEnd(DraggableDetails details){
    // print("onDragEnd()");
  }

  void onItemIndexPrimary(int itemIndex) {
    if (gamestream.isometric.clientState.hoverDialogDialogIsTrade){
      gamestream.network.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    gamestream.network.sendClientRequestInventoryEquip(itemIndex);
  }

  void onItemIndexSecondary(int itemIndex){
    if (gamestream.isometric.clientState.hoverDialogDialogIsTrade){
      gamestream.network.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    gamestream.isometric.player.interactModeTrading
        ? gamestream.network.sendClientRequestInventorySell(itemIndex)
        : gamestream.network.sendClientRequestInventoryDrop(itemIndex);
  }

  void onDragAcceptEquippedItemContainer(int? i){
    if (i == null) return;
    gamestream.network.sendClientRequestInventoryEquip(i);
  }

  void onDragCancelled(Velocity velocity, Offset offset){
    // print("onDragCancelled()");
    if (gamestream.isometric.clientState.hoverIndex.value == -1){
      gamestream.isometric.clientState.dropDraggedItem();
    } else {
      gamestream.isometric.clientState.inventorySwapDragTarget();
    }
    gamestream.isometric.clientState.dragStart.value = -1;
    gamestream.isometric.clientState.dragEnd.value = -1;
  }

  void onDragAcceptWatchBelt(Watch<int> watchBelt, int index) =>
      gamestream.isometric.server.inventoryMoveToWatchBelt(index, watchBelt);

  void onButtonPressedWatchBelt(Watch<int> watchBeltType) =>
      gamestream.isometric.server.equipWatchBeltType(watchBeltType);

  void onRightClickedWatchBelt(Watch<int> watchBelt){
     gamestream.isometric.server.inventoryUnequip(
        gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBelt)
    );
  }

  void onAcceptDragInventoryIcon(){
    if (gamestream.isometric.clientState.dragStart.value == -1) return;
    gamestream.network.sendClientRequestInventoryDeposit(gamestream.isometric.clientState.dragStart.value);
  }

  void onChangedMessageStatus(String value){
    if (value.isEmpty){
      gamestream.isometric.clientState.messageStatusDuration = 0;
    } else {
      gamestream.isometric.clientState.messageStatusDuration = 150;
    }
  }

  void onChangedAreaTypeVisible(bool value) =>
      gamestream.isometric.clientState.areaTypeVisibleDuration = value
          ? 150
          : 0;

  void onChangedDebugMode(bool value){
    gamestream.isometric.renderer.renderDebug = value;
  }

  void onChangedCredits(int value){
    gamestream.audio.coins.play();
  }


}