
import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_actions.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_client.dart';
import 'package:gamestream_flutter/library.dart';

import '../isometric.dart';

class IsometricEvents {

  final Gamestream gamestream;
  final IsometricClient clientState;
  late final Isometric isometric;

  IsometricEvents(this.clientState, this.gamestream) {
    this.isometric = gamestream.isometric;
  }

  void onErrorFullscreenAuto(){
     // TODO show a dialog box asking the user to go fullscreen
  }

  void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case WeaponType.Shotgun:
        gamestream.audio.cock_shotgun_3.playXYZ(x, y, z);
        break;
      default:
        break;
    }
  }

  void onChangedError(String error) {
    clientState.messageStatus.value = error;
    if (error.isNotEmpty) {
      clientState.messageStatusDuration = 200;
    } else {
      clientState.messageStatusDuration = 0;
    }
  }

  void onChangedNodes(){
    gamestream.isometric.scene.refreshGridMetrics();
    gamestream.isometric.scene.generateHeightMap();
    gamestream.isometric.scene.generateMiniMap();
    gamestream.isometric.minimap.generateSrcDst();
    gamestream.isometric.scene.refreshBakeMapLightSources();

    if (clientState.raining.value) {
      gamestream.isometric.rainStop();
      gamestream.isometric.rainStart();
    }
    gamestream.isometric.scene.resetNodeColorsToAmbient();
    gamestream.isometric.editor.refreshNodeSelectedIndex();
  }

  void onFootstep(double x, double y, double z) {
    if (clientState.raining.value && (
        gamestream.isometric.scene.getTypeXYZSafe(x, y, z) == NodeType.Rain_Landing
            ||
            gamestream.isometric.scene.getTypeXYZSafe(x, y, z + 24) == NodeType.Rain_Landing
    )
    ){
      gamestream.audio.footstep_mud_6.playXYZ(x, y, z);
      final amount = gamestream.isometric.server.rainType.value == RainType.Heavy ? 3 : 2;
      for (var i = 0; i < amount; i++){
        gamestream.isometric.particles.spawnParticleWaterDrop(x: x, y: y, z: z, zv: 1.5);
      }
    }

    final nodeType = gamestream.isometric.scene.getTypeXYZSafe(x, y, z - 2);
    if (NodeType.isMaterialStone(nodeType)) {
      gamestream.audio.footstep_stone.playXYZ(x, y, z);
      return;
    }
    if (NodeType.isMaterialWood(nodeType)) {
      gamestream.audio.footstep_wood_4.playXYZ(x, y, z);
      return;
    }
    if (randomBool()){
      gamestream.audio.footstep_grass_8.playXYZ(x, y, z);
      return;
    }
    gamestream.audio.footstep_grass_7.playXYZ(x, y, z);
  }

  void onGameEvent(int type, double x, double y, double z, double angle) {
    switch (type) {
      case GameEventType.Footstep:
        gamestream.isometric.events.onFootstep(x, y, z);
        return;
      case GameEventType.Attack_Performed:
        onAttackPerformed(x, y, z, angle);
        return;
      case GameEventType.Melee_Attack_Performed:
        onMeleeAttackPerformed(x, y, z, angle);
        return;
      case GameEventType.Bullet_Deactivated:
        gamestream.audio.metal_light_3.playXYZ(x, y, z);
        return;
      case GameEventType.Material_Struck_Metal:
        gamestream.audio.metal_struck.playXYZ(x, y, z);
        return;
      case GameEventType.Player_Spawn_Started:
        gamestream.isometric.camera.centerOnChaseTarget();
        gamestream.audio.teleport.playXYZ(x, y, z);
        return;
      case GameEventType.Explosion:
        onGameEventExplosion(x, y, z);
        return;
      case GameEventType.Power_Used:
        onGameEventPowerUsed(x, y, z, gamestream.readByte());
        break;
      case GameEventType.AI_Target_Acquired:
        final characterType = gamestream.readByte();
        switch (characterType){
          case CharacterType.Zombie:
            randomItem(gamestream.audio.audioSingleZombieTalking).playXYZ(x, y, z);
            break;
        }
        break;

      case GameEventType.Node_Set:
        onNodeSet(x, y, z);
        return;
      case GameEventType.GameObject_Timeout:
        isometric.particles.spawnBubbles(x, y, z);
        break;
      case GameEventType.Node_Struck:
        onNodeStruck(x, y, z);
        break;
      case GameEventType.Node_Deleted:
        gamestream.audio.hover_over_button_sound_30.playXYZ(x, y, z);
        break;
      case GameEventType.Weapon_Type_Equipped:
        final attackType =  gamestream.readByte();
        return onWeaponTypeEquipped(attackType, x, y, z);
      case GameEventType.Player_Spawned:
        for (var i = 0; i < 7; i++){
          gamestream.isometric.particles.spawnParticleOrbShard(x: x, y: y, z: z, angle: randomAngle());
        }
        return;
      case GameEventType.Splash:
        onSplash(x, y, z);
        return;
      case GameEventType.Item_Bounce:
        gamestream.audio.grenade_bounce.playXYZ(x, y, z);
        return;
      case GameEventType.Spawn_Dust_Cloud:
        break;
      case GameEventType.Player_Hit:
        if (randomBool()) {
          // audio.humanHurt(x, y);
        }
        break;
      case GameEventType.Zombie_Target_Acquired:
        randomItem(gamestream.audio.audioSingleZombieTalking).playXYZ(x, y, z);
        break;
      case GameEventType.Character_Changing:
        gamestream.audio.change_cloths.playXYZ(x, y, z);
        break;
      case GameEventType.Zombie_Strike:
        randomItem(gamestream.audio.audioSingleZombieBits).playXYZ(x, y, z);
        if (randomBool()){
          randomItem(gamestream.audio.audioSingleZombieTalking).playXYZ(x, y, z);
        }
        break;
      case GameEventType.Player_Death:
        break;
      case GameEventType.Teleported:
        gamestream.audio.magical_impact_16();
        break;
      case GameEventType.Blue_Orb_Fired:
        gamestream.audio.sci_fi_blaster_1.playXYZ(x, y, z);
        break;
      case GameEventType.Arrow_Hit:
        gamestream.audio.arrow_impact.playXYZ(x, y, z);
        break;
      case GameEventType.Draw_Bow:
        return gamestream.audio.bow_draw.playXYZ(x, y, z);
      case GameEventType.Release_Bow:
        return gamestream.audio.bow_release.playXYZ(x, y, z);
      case GameEventType.Sword_Woosh:
        return gamestream.audio.swing_sword.playXYZ(x, y, z);
      case GameEventType.EnemyTargeted:
        break;
      case GameEventType.Attack_Missed:
        final attackType = gamestream.readUInt16();
        switch (attackType) {
          case WeaponType.Unarmed:
            gamestream.audio.arm_swing_whoosh_11.playXYZ(x, y, z);
            break;
          case WeaponType.Sword:
            gamestream.audio.arm_swing_whoosh_11.playXYZ(x, y, z);
            break;
        }
        break;
      case GameEventType.Arrow_Fired:
        return gamestream.audio.arrow_flying_past_6.playXYZ(x, y, z);

      case GameEventType.Crate_Breaking:
        // return audio.crateBreaking(x, y);
        break;

      case GameEventType.Blue_Orb_Deactivated:
        isometric.particles.spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
        for (var i = 0; i < 8; i++) {
          gamestream.isometric.particles.spawnParticleOrbShard(
              x: x, y: y, z: z, duration: 30, speed: randomBetween(1, 2), angle: randomAngle());
        }
        break;

      case GameEventType.Teleport_Start:
        for (var i = 0; i < 5; i++) {
          isometric.particles.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
        }
        break;

      case GameEventType.Teleport_End:
        for (var i = 0; i < 5; i++) {
          isometric.particles.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
        }
        break;

      case GameEventType.Character_Death:
        onCharacterDeath(gamestream.readByte(), x, y, z, angle);
        return;

      case GameEventType.Character_Hurt:
        onGameEventCharacterHurt(gamestream.readByte(), x, y, z, angle);
        return;

      case GameEventType.Game_Object_Destroyed:
        onGameEventGameObjectDestroyed(
            x,
            y,
            z,
            angle,
          gamestream.readUInt16(),
        );
        return;
    }
  }

  void onGameEventExplosion(double x, double y, double z) {
    gamestream.isometric.createExplosion(x, y, z);
  }

  void onNodeSet(double x, double y, double z) {
    gamestream.audio.hover_over_button_sound_43.playXYZ(x, y, z);
  }

  void onNodeStruck(double x, double y, double z) {
    if (!gamestream.isometric.scene.inBoundsXYZ(x, y, z)) return;

    final nodeIndex = gamestream.isometric.scene.getIndexXYZ(x, y, z);
    final nodeType = gamestream.isometric.scene.nodeTypes[nodeIndex];

    if (NodeType.isMaterialWood(nodeType)){
      gamestream.audio.material_struck_wood.playXYZ(x, y, z);
      isometric.particles.spawnParticleBlockWood(x, y, z);
    }

    if (NodeType.isMaterialGrass(nodeType)){
      gamestream.audio.grass_cut.playXYZ(x, y, z);
      isometric.particles.spawnParticleBlockGrass(x, y, z);
    }

    if (NodeType.isMaterialStone(nodeType)){
      gamestream.audio.material_struck_stone.playXYZ(x, y, z);
      isometric.particles.spawnParticleBlockBrick(x, y, z);
    }

    if (NodeType.isMaterialDirt(nodeType)){
      gamestream.audio.material_struck_dirt.playXYZ(x, y, z);
      isometric.particles.spawnParticleBlockSand(x, y, z);
    }
  }

  void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
    gamestream.audio.swing_sword.playXYZ(x, y, z);
  }

  void onAttackPerformedUnarmed(double x, double y, double z, double angle) {
    isometric.particles.spawnParticleBubbles(
      count: 3,
      x: x,
      y: y,
      z: z,
      angle: angle,
    );
  }

  void onSplash(double x, double y, double z) {
    for (var i = 0; i < 12; i++){
      final zv = randomBetween(1.5, 5);
      isometric.particles.spawnParticleWaterDrop(x: x, y: y, z: z, zv: zv, duration: (zv * 12).toInt());
    }
    return gamestream.audio.splash.playXYZ(x, y, z);
  }

  void onAttackPerformed(double x, double y, double z, double angle) {
    final attackType = gamestream.readUInt16();
    final attackTypeAudio = gamestream.audio.MapItemTypeAudioSinglesAttack[attackType];

    if (attackTypeAudio != null) {
      attackTypeAudio.playXYZ(x, y, z);
    }

    if (attackType == WeaponType.Unarmed){
      isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == WeaponType.Melee){
      isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (WeaponType.isMelee(attackType)) {
      isometric.particles.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    if (attackType == WeaponType.Flame_Thrower) return;

    const gun_distance = 50.0;
    final gunX = x - adj(angle, gun_distance);
    final gunY = y - opp(angle, gun_distance);

    if (WeaponType.isFirearm(attackType)){
      isometric.particles.spawnParticleSmoke(x: gunX, y: gunY, z: z, scale: 0.1, scaleV: 0.006, duration: 50);
      isometric.particles.spawnParticleShell(gunX, gunY, z);
    }
    if (WeaponType.Firearms_Automatic.contains(attackType)){
      isometric.particles.spawnParticleStrikeBulletLight(x: x, y: y, z: z, angle: angle);
      return;
    }
    isometric.particles.spawnParticleStrikeBullet(x: x, y: y, z: z, angle: angle);
  }

  void onMeleeAttackPerformed(double x, double y, double z, double angle) {
    final attackType = gamestream.readUInt16();
    final attackTypeAudio = gamestream.audio.MapItemTypeAudioSinglesAttackMelee[attackType];

    if (attackTypeAudio != null) {
      attackTypeAudio.playXYZ(x, y, z);
    }

    if (attackType == WeaponType.Unarmed){
      isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == WeaponType.Knife){
      isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (WeaponType.isMelee(attackType)) {
      isometric.particles.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
    return;
  }

  void onChangedEdit(bool value) {
    if (value) {
      gamestream.isometric.camera.target = null;
      gamestream.isometric.editor.cursorSetToPlayer();
      gamestream.isometric.player.message.value = '-press arrow keys to move\n\n-press tab to play';
      gamestream.isometric.player.messageTimer = 300;
    } else {
      gamestream.isometric.cameraTargetPlayer();
      gamestream.isometric.editor.deselectGameObject();
      gamestream.isometric.ui.mouseOverDialog.setFalse();
      if (gamestream.isometric.server.sceneEditable.value){
        gamestream.isometric.player.message.value = 'press tab to edit';
      }
    }
  }

  void onChangedWindType(int windType) {
    clientState.refreshRain();
  }

  void onChangedHour(int hour){
    if (gamestream.isometric.server.sceneUnderground.value) return;
    clientState.updateGameLighting();
  }

  void onChangedSeconds(int seconds){
    final minutes = seconds ~/ 60;
    gamestream.isometric.server.hours.value = minutes ~/ Duration.minutesPerHour;
    gamestream.isometric.server.minutes.value = minutes % Duration.minutesPerHour;
  }

  void onChangedRain(int value) {
    clientState.raining.value = value != RainType.None;
    clientState.refreshRain();
    clientState.updateGameLighting();
  }

  void onPlayerEvent(int event) {
    switch (event) {
      case PlayerEvent.Reloading:
        switch (gamestream.isometric.player.weapon.value){
          case WeaponType.Handgun:
            gamestream.audio.reload_6();
            break;
          default:
            gamestream.audio.reload_6();
        }
        break;
      case PlayerEvent.Teleported:
        gamestream.audio.magical_swoosh_18();
        break;
      case PlayerEvent.Level_Increased:
        gamestream.audio.buff_1();
        gamestream.isometric.client.writeMessage('Level Gained');
        break;
      case PlayerEvent.Item_Consumed:
        break;
      case PlayerEvent.Recipe_Crafted:
        gamestream.audio.unlock();
        break;
      case PlayerEvent.Loot_Collected:
        return gamestream.audio.collect_star_3();
      case PlayerEvent.Scene_Changed:
        gamestream.isometric.camera.centerOnChaseTarget();
        break;
      case PlayerEvent.Item_Acquired:
        readPlayerEventItemAcquired();
        break;
      case PlayerEvent.Item_Dropped:
        gamestream.audio.popSounds14();
        break;
      case PlayerEvent.Item_Sold:
        gamestream.audio.coins_24();
        break;
      case PlayerEvent.GameObject_Deselected:
        gamestream.isometric.editor.gameObjectSelected.value = false;
        break;
      case PlayerEvent.Player_Moved:
        if (gamestream.gameType.value == GameType.Editor){
          gamestream.isometric.editor.row = gamestream.isometric.player.indexRow;
          gamestream.isometric.editor.column = gamestream.isometric.player.indexColumn;
          gamestream.isometric.editor.z = gamestream.isometric.player.indexZ;
        }
        gamestream.isometric.camera.centerOnChaseTarget();
        gamestream.io.recenterCursor();
        break;
      case PlayerEvent.Insufficient_Gold:
        gamestream.isometric.client.writeMessage('Not Enough Gold');
        break;
      case PlayerEvent.Inventory_Full:
        gamestream.isometric.client.writeMessage('Inventory Full');
        break;
      case PlayerEvent.Invalid_Request:
        gamestream.isometric.client.writeMessage('Invalid Request');
        break;
    }
  }

  void onCharacterDeath(int characterType, double x, double y, double z, double angle) {
    randomItem(gamestream.audio.bloody_punches).playXYZ(x, y, z);
    gamestream.audio.heavy_punch_13.playXYZ(x, y, z);
    // isometric.particles.spawnPurpleFireExplosion(x, y, z);

    for (var i = 0; i < 4; i++){
      isometric.particles.spawnParticleBlood(
        x: x,
        y: y,
        z: z,
        zv: randomBetween(1.5, 2),
        angle: angle + giveOrTake(Engine.PI_Quarter),
        speed: randomBetween(1.5, 2.5),
      );
    }

    switch (characterType) {
      case CharacterType.Zombie:
        return onCharacterDeathZombie(characterType, x, y, z, angle);
      case CharacterType.Dog:
        gamestream.audio.dog_woolf_howl_4();
        break;
    }
  }

  void onCharacterDeathZombie(int type, double x, double y, double z, double angle){
    // final zPos = z + Node_Size_Half;
    // isometric.particles.spawnParticleHeadZombie(x: x, y: y, z: zPos, angle: angle, speed: 4.0);
    // isometric.particles.spawnParticleArm(
    //     x: x,
    //     y: y,
    //     z: zPos,
    //     angle: angle + Engine.randomGiveOrTake(0.5),
    //     speed: 4.0 + Engine.randomGiveOrTake(0.5));
    // isometric.particles.spawnParticleLegZombie(
    //     x: x,
    //     y: y,
    //     z: zPos,
    //     angle: angle + Engine.randomGiveOrTake(0.5),
    //     speed: 4.0 + Engine.randomGiveOrTake(0.5));
    // isometric.particles.spawnParticleOrgan(
    //     x: x,
    //     y: y,
    //     z: zPos,
    //     angle: angle + Engine.randomGiveOrTake(0.5),
    //     speed: 4.0 + Engine.randomGiveOrTake(0.5),
    //     zv: 0.1);
    randomItem(gamestream.audio.zombie_deaths).playXYZ(x, y, z);
  }

  void onChangedRendersSinceUpdate(int value){
    clientState.triggerAlarmNoMessageReceivedFromServer.value = value > 200;
  }

  void onChangedPlayerMessage(String value){
    if (value.isNotEmpty) {
      gamestream.isometric.player.messageTimer = 200;
    } else {
      gamestream.isometric.player.messageTimer = 0;
    }
  }

  void onChangedInputMode(int inputMode){
    if (inputMode == InputMode.Touch){
      gamestream.isometric.camera.centerOnChaseTarget();
      gamestream.io.recenterCursor();
    }
  }

  void onChangedPlayerWeapon(int weaponType){
    if (weaponType == WeaponType.Unarmed) return;

    switch (weaponType) {
      case WeaponType.Plasma_Rifle:
        gamestream.audio.gun_pickup_01();
        break;
      case WeaponType.Plasma_Pistol:
        gamestream.audio.revolver_reload_1();
        break;
      case WeaponType.Revolver:
        gamestream.audio.revolver_reload_1();
        break;
      case WeaponType.Handgun:
        gamestream.audio.reload_6();
        break;
      case WeaponType.Shotgun:
        gamestream.audio.cock_shotgun_3();
        break;
      case WeaponType.Sword:
        gamestream.audio.sword_unsheathe();
        break;
      case WeaponType.Bow:
        gamestream.audio.bow_draw();
        break;
      default:
        gamestream.audio.gun_pickup_01();
        break;
    }
  }

  void readPlayerEventItemAcquired() {
    final itemType = gamestream.readUInt16();
    // todo read subtype
    if (itemType == WeaponType.Unarmed) return;

    switch (itemType) {
      case WeaponType.Plasma_Rifle:
        gamestream.audio.gun_pickup_01();
        break;
      case WeaponType.Plasma_Pistol:
        gamestream.audio.revolver_reload_1();
        break;
      case WeaponType.Revolver:
        gamestream.audio.revolver_reload_1();
        break;
      case WeaponType.Handgun:
        gamestream.audio.reload_6();
        break;
      case WeaponType.Shotgun:
        gamestream.audio.cock_shotgun_3();
        break;
      case WeaponType.Sword:
        gamestream.audio.sword_unsheathe();
        break;
      case WeaponType.Bow:
        gamestream.audio.bow_draw();
        break;
      default:
        // if (ItemType.isTypeWeapon(itemType)){
        //   gamestream.audio.gun_pickup_01();
        // }
        break;
    }
  }


  void onGameEventPowerUsed(double x, double y, double z, int powerType) {
      switch (powerType){
        case CombatPowerType.Stun:
          gamestream.audio.debuff_4();
          gamestream.isometric.particles.spawnParticle(
            type: ParticleType.Lightning_Bolt,
            x: gamestream.isometric.player.x,
            y: gamestream.isometric.player.y,
            z: gamestream.isometric.player.z,
            duration: 10,
            animation: true,
          );
          isometric.particles.spawnParticleLightEmissionAmbient(
            x: gamestream.isometric.player.x,
            y: gamestream.isometric.player.y,
            z: gamestream.isometric.player.z,
          );
          break;
      }
  }

  void onChangedPlayerActive(bool playerActive){
     print('onChangedPlayerActive($playerActive)');
  }

  void onGameEventCharacterHurt(int type, double x, double y, double z, double angle) {

    randomItem(gamestream.audio.bloody_punches).playXYZ(x, y, z);

    gamestream.audio.heavy_punch_13.playXYZ(x, y, z);

    for (var i = 0; i < 4; i++){
      gamestream.isometric.particles.spawnParticleBlood(
        x: x,
        y: y,
        z: z,
        zv: randomBetween(1.5, 2),
        angle: angle + giveOrTake(piQuarter),
        speed: randomBetween(1.5, 2.5),
      );
    }


    switch (type) {
      case CharacterType.Zombie:
        if (randomBool()){
          gamestream.audio.zombie_hurt_1.playXYZ(x, y, z);
        } else {
          gamestream.audio.zombie_hurt_4.playXYZ(x, y, z);
        }
        break;
      case CharacterType.Rat:
        gamestream.audio.rat_squeak.playXYZ(x, y, z);
        break;
      case CharacterType.Slime:
        gamestream.audio.bloody_punches_3.playXYZ(x, y, z);
        break;
      case CharacterType.Dog:
        gamestream.audio.dog_woolf_howl_4();
        break;
    }
  }

  void onGameEventGameObjectDestroyed(
      double x,
      double y,
      double z,
      double angle,
      int type,
      ){
    switch (type){
      case ObjectType.Barrel:
        gamestream.audio.crate_breaking.playXYZ(x, y, z);
        for (var i = 0; i < 5; i++) {
          gamestream.isometric.particles.spawnParticleBlockWood(x, y, z);
        }
        break;
      case ObjectType.Toilet:
        gamestream.audio.crate_breaking.playXYZ(x, y, z);
        for (var i = 0; i < 5; i++) {
          gamestream.isometric.particles.spawnParticleBlockWood(x, y, z);
        }
        break;
      case ObjectType.Crate_Wooden:
        gamestream.audio.crate_breaking.playXYZ(x, y, z);
        for (var i = 0; i < 5; i++) {
          gamestream.isometric.particles.spawnParticleBlockWood(x, y, z);
        }
        break;

      case ObjectType.Credits:
        for (var i = 0; i < 8; i++){
          gamestream.isometric.particles.spawnParticleConfettiByType(
            x,
            y,
            z,
            ParticleType.Confetti_Cyan,
          );
        }
    }
  }
}