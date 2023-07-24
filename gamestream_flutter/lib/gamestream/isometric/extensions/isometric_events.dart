
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_actions.dart';
import 'package:gamestream_flutter/library.dart';

import '../isometric.dart';

extension IsometricEvents on Isometric {

  void onErrorFullscreenAuto(){
     // TODO show a dialog box asking the user to go fullscreen
  }

  void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case WeaponType.Shotgun:
        playAudioXYZ(audio.cock_shotgun_3, x, y, z);
        break;
      default:
        break;
    }
  }

  void onChangedError(String error) {
    messageStatus.value = error;
    if (error.isNotEmpty) {
      messageStatusDuration = 200;
    } else {
      messageStatusDuration = 0;
    }
  }

  void onChangedNodes(){
    refreshGridMetrics();
    generateHeightMap();
    generateMiniMap();
    minimap.generateSrcDst();
    refreshBakeMapLightSources();

    if (raining.value) {
      rainStop();
      rainStart();
    }
    resetNodeColorsToAmbient();
    editor.refreshNodeSelectedIndex();
  }

  void onFootstep(double x, double y, double z) {
    if (raining.value && (
        getTypeXYZSafe(x, y, z) == NodeType.Rain_Landing
            ||
            getTypeXYZSafe(x, y, z + 24) == NodeType.Rain_Landing
    )
    ){

      playAudioXYZ(audio.footstep_mud_6, x, y, z);

      final amount = rainType.value == RainType.Heavy ? 3 : 2;
      for (var i = 0; i < amount; i++){
        spawnParticleWaterDrop(x: x, y: y, z: z, zv: 1.5);
      }
    }

    final nodeType = getTypeXYZSafe(x, y, z - 2);
    if (NodeType.isMaterialStone(nodeType)) {
      playAudioXYZ(audio.footstep_stone, x, y, z);
      return;
    }
    if (NodeType.isMaterialWood(nodeType)) {
      playAudioXYZ(audio.footstep_wood_4, x, y, z);
      return;
    }
    if (randomBool()){
      playAudioXYZ(audio.footstep_grass_8, x, y, z);
      return;
    }
    playAudioXYZ(audio.footstep_grass_7, x, y, z);
  }

  void onGameEvent(int type, double x, double y, double z, double angle) {
    switch (type) {
      case GameEventType.Footstep:
        onFootstep(x, y, z);
        return;
      case GameEventType.Attack_Performed:
        onAttackPerformed(x, y, z, angle);
        return;
      case GameEventType.Melee_Attack_Performed:
        onMeleeAttackPerformed(x, y, z, angle);
        return;
      case GameEventType.Bullet_Deactivated:
        playAudioXYZ(audio.metal_light_3, x, y, z);
        return;
      case GameEventType.Material_Struck_Metal:
        playAudioXYZ(audio.metal_struck, x, y, z);
        return;
      case GameEventType.Player_Spawn_Started:
        camera.centerOnChaseTarget();
        // audio.teleport.playXYZ(x, y, z);
        return;
      case GameEventType.Explosion:
        onGameEventExplosion(x, y, z);
        return;
      case GameEventType.AI_Target_Acquired:
        final characterType = readByte();
        switch (characterType){
          case CharacterType.Zombie:
            playAudioXYZ(randomItem(audio.audioSingleZombieTalking), x, y, z);
            break;
        }
        break;

      case GameEventType.Node_Set:
        onNodeSet(x, y, z);
        return;
      case GameEventType.GameObject_Timeout:
        spawnBubbles(x, y, z);
        break;
      case GameEventType.Node_Struck:
        onNodeStruck(x, y, z);
        break;
      case GameEventType.Node_Deleted:
        playAudioXYZ(audio.hover_over_button_sound_30, x, y, z);
        break;
      case GameEventType.Weapon_Type_Equipped:
        final attackType =  readByte();
        return onWeaponTypeEquipped(attackType, x, y, z);
      case GameEventType.Player_Spawned:
        for (var i = 0; i < 7; i++){
          spawnParticleOrbShard(x: x, y: y, z: z, angle: randomAngle());
        }
        return;
      case GameEventType.Splash:
        onSplash(x, y, z);
        return;
      case GameEventType.Item_Bounce:
        playAudioXYZ(audio.grenade_bounce, x, y, z);
        return;
      case GameEventType.Spawn_Dust_Cloud:
        break;
      case GameEventType.Player_Hit:
        if (randomBool()) {
          // audio.humanHurt(x, y);
        }
        break;
      case GameEventType.Zombie_Target_Acquired:
        playAudioXYZ(randomItem(audio.audioSingleZombieTalking), x, y, z);
        break;
      case GameEventType.Character_Changing:
        playAudioXYZ(audio.change_cloths, x, y, z);
        break;
      case GameEventType.Zombie_Strike:
        playAudioXYZ(randomItem(audio.audioSingleZombieBits), x, y, z);
        if (randomBool()){
          playAudioXYZ(randomItem(audio.audioSingleZombieTalking), x, y, z);
        }
        break;
      case GameEventType.Player_Death:
        break;
      case GameEventType.Teleported:
        audio.magical_impact_16();
        break;
      case GameEventType.Blue_Orb_Fired:
        playAudioXYZ(audio.sci_fi_blaster_1, x, y, z);
        break;
      case GameEventType.Arrow_Hit:
        playAudioXYZ(audio.arrow_impact, x, y, z);
        break;
      case GameEventType.Draw_Bow:
        playAudioXYZ(audio.bow_draw, x, y, z);
        break;
      case GameEventType.Release_Bow:
        playAudioXYZ(audio.bow_release, x, y, z);
        break;
      case GameEventType.Sword_Woosh:
        playAudioXYZ(audio.swing_sword, x, y, z);
        break;
      case GameEventType.EnemyTargeted:
        break;
      case GameEventType.Attack_Missed:
        final attackType = readUInt16();
        switch (attackType) {
          case WeaponType.Unarmed:
            playAudioXYZ(audio.arm_swing_whoosh_11, x, y, z);
            break;
          case WeaponType.Sword:
            playAudioXYZ(audio.arm_swing_whoosh_11, x, y, z);
            break;
        }
        break;
      case GameEventType.Arrow_Fired:
        playAudioXYZ(audio.arrow_flying_past_6, x, y, z);
        break;
      case GameEventType.Crate_Breaking:
        // return audio.crateBreaking(x, y);
        break;

      case GameEventType.Blue_Orb_Deactivated:
        spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
        for (var i = 0; i < 8; i++) {
          spawnParticleOrbShard(
              x: x, y: y, z: z, duration: 30, speed: randomBetween(1, 2), angle: randomAngle());
        }
        break;

      case GameEventType.Teleport_Start:
        for (var i = 0; i < 5; i++) {
          spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
        }
        break;

      case GameEventType.Teleport_End:
        for (var i = 0; i < 5; i++) {
          spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
        }
        break;

      case GameEventType.Character_Death:
        onCharacterDeath(readByte(), x, y, z, angle);
        return;

      case GameEventType.Character_Hurt:
        onGameEventCharacterHurt(readByte(), x, y, z, angle);
        return;

      case GameEventType.Game_Object_Destroyed:
        onGameEventGameObjectDestroyed(
            x,
            y,
            z,
            angle,
          readUInt16(),
        );
        return;

      case GameEventType.Blink_Arrive:
        playAudioXYZ(audio.sci_fi_blaster_1, x, y, z);
        spawnParticleConfetti(x, y, z);
        break;

      case GameEventType.Blink_Depart:
        spawnParticleConfetti(x, y, z);
        break;
    }
  }

  void onGameEventExplosion(double x, double y, double z) {
    createExplosion(x, y, z);
  }

  void onNodeSet(double x, double y, double z) {
    playAudioXYZ(audio.hover_over_button_sound_43, x, y, z);
  }

  void onNodeStruck(double x, double y, double z) {
    if (!inBoundsXYZ(x, y, z)) return;

    final nodeIndex = getIndexXYZ(x, y, z);
    final nodeType = nodeTypes[nodeIndex];

    if (NodeType.isMaterialWood(nodeType)){
      playAudioXYZ(audio.material_struck_wood, x, y, z);
      spawnParticleBlockWood(x, y, z);
    }

    if (NodeType.isMaterialGrass(nodeType)){
      playAudioXYZ(audio.grass_cut, x, y, z);
      spawnParticleBlockGrass(x, y, z);
    }

    if (NodeType.isMaterialStone(nodeType)){
      playAudioXYZ(audio.material_struck_stone, x, y, z);
      spawnParticleBlockBrick(x, y, z);
    }

    if (NodeType.isMaterialDirt(nodeType)){
      playAudioXYZ(audio.material_struck_dirt, x, y, z);
      spawnParticleBlockSand(x, y, z);
    }
  }

  void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
    playAudioXYZ(audio.swing_sword, x, y, z);
  }

  void onAttackPerformedUnarmed(double x, double y, double z, double angle) {
    spawnParticleBubbles(
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
      spawnParticleWaterDrop(x: x, y: y, z: z, zv: zv, duration: (zv * 12).toInt());
    }
    playAudioXYZ(audio.splash, x, y, z);
  }

  void onAttackPerformed(double x, double y, double z, double angle) {
    final attackType = readUInt16();
    final attackTypeAudio = audio.MapItemTypeAudioSinglesAttack[attackType];

    if (attackTypeAudio != null) {
      playAudioXYZ(attackTypeAudio, x, y, z);
    }

    if (attackType == WeaponType.Unarmed){
      spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == WeaponType.Melee){
      spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (WeaponType.isMelee(attackType)) {
      spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    if (attackType == WeaponType.Flame_Thrower) return;

    const gun_distance = 50.0;
    final gunX = x - adj(angle, gun_distance);
    final gunY = y - opp(angle, gun_distance);

    if (WeaponType.isFirearm(attackType)){
      spawnParticleSmoke(x: gunX, y: gunY, z: z, scale: 0.1, scaleV: 0.006, duration: 50);
      spawnParticleShell(gunX, gunY, z);
    }
    if (WeaponType.Firearms_Automatic.contains(attackType)){
      spawnParticleStrikeBulletLight(x: x, y: y, z: z, angle: angle);
      return;
    }
    spawnParticleStrikeBullet(x: x, y: y, z: z, angle: angle);
  }

  void onMeleeAttackPerformed(double x, double y, double z, double angle) {
    final attackType = readUInt16();
    final attackTypeAudio = audio.MapItemTypeAudioSinglesAttackMelee[attackType];

    if (attackTypeAudio != null) {
      playAudioXYZ(attackTypeAudio, x, y, z);
    }

    if (attackType == WeaponType.Unarmed){
      spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == WeaponType.Knife){
      spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (WeaponType.isMelee(attackType)) {
      spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
    return;
  }

  void onChangedEdit(bool value) {
    if (value) {
      camera.target = null;
      editor.cursorSetToPlayer();
      player.message.value = '-press arrow keys to move\n\n-press tab to play';
      player.messageTimer = 300;
    } else {
      cameraTargetPlayer();
      editor.deselectGameObject();
      // isometric.ui.mouseOverDialog.setFalse();
      if (sceneEditable.value){
        player.message.value = 'press tab to edit';
      }
    }
  }

  void onChangedWindType(int windType) {
    refreshRain();
  }

  void onChangedHour(int hour){
    if (sceneUnderground.value) return;
    updateGameLighting();
  }

  void onChangedSeconds(int seconds){
    final minutes = seconds ~/ 60;
    hours.value = minutes ~/ Duration.minutesPerHour;
    this.minutes.value = minutes % Duration.minutesPerHour;
  }

  void onChangedRain(int value) {
    raining.value = value != RainType.None;
    refreshRain();
    updateGameLighting();
  }

  void onPlayerEvent(int event) {
    switch (event) {
      case PlayerEvent.Reloading:
        switch (player.weapon.value){
          case WeaponType.Handgun:
            audio.reload_6();
            break;
          default:
            audio.reload_6();
        }
        break;
      case PlayerEvent.Teleported:
        audio.magical_swoosh_18();
        break;
      case PlayerEvent.Level_Increased:
        audio.buff_1();
        writeMessage('Level Gained');
        break;
      case PlayerEvent.Item_Consumed:
        break;
      case PlayerEvent.Eat:
        audio.eat();
        break;
      case PlayerEvent.Drink:
        audio.drink();
        break;
      case PlayerEvent.Experience_Collected:
        audio.collect_star_3();
        break;
      case PlayerEvent.Recipe_Crafted:
        audio.unlock();
        break;
      case PlayerEvent.Loot_Collected:
        return audio.collect_star_3();
      case PlayerEvent.Scene_Changed:
        camera.centerOnChaseTarget();
        break;
      case PlayerEvent.Item_Acquired:
        readPlayerEventItemAcquired();
        break;
      case PlayerEvent.Item_Dropped:
        audio.popSounds14();
        break;
      case PlayerEvent.Item_Sold:
        audio.coins_24();
        break;
      case PlayerEvent.GameObject_Deselected:
        editor.gameObjectSelected.value = false;
        break;
      case PlayerEvent.Player_Moved:
        if (gameType.value == GameType.Editor){
          editor.row = player.indexRow;
          editor.column = player.indexColumn;
          editor.z = player.indexZ;
        }
        camera.centerOnChaseTarget();
        io.recenterCursor();
        break;
      case PlayerEvent.Insufficient_Gold:
        writeMessage('Not Enough Gold');
        break;
      case PlayerEvent.Inventory_Full:
        writeMessage('Inventory Full');
        break;
      case PlayerEvent.Invalid_Request:
        writeMessage('Invalid Request');
        break;
      case PlayerEvent.Character_State_Changing:
        audio.change_cloths();
        break;
      case PlayerEvent.Talent_Upgraded:
        audio.collect_star_3();
        break;
    }
  }

  void onCharacterDeath(int characterType, double x, double y, double z, double angle) {
    playAudioXYZ(randomItem(audio.bloody_punches), x, y, z);
    playAudioXYZ(audio.heavy_punch_13, x, y, z);

    for (var i = 0; i < 4; i++){
      spawnParticleBlood(
        x: x,
        y: y,
        z: z,
        zv: randomBetween(1.5, 2),
        angle: angle + giveOrTake(piQuarter),
        speed: randomBetween(1.5, 2.5),
      );
    }

    switch (characterType) {
      case CharacterType.Zombie:
        return onCharacterDeathZombie(characterType, x, y, z, angle);
      case CharacterType.Dog:
        playAudioXYZ(audio.dog_woolf_howl_4, x, y, z);
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

    playAudioXYZ(randomItem(audio.zombie_deaths), x, y, z);
  }

  void onChangedRendersSinceUpdate(int value){
    triggerAlarmNoMessageReceivedFromServer.value = value > 200;
  }

  void onChangedPlayerMessage(String value){
    if (value.isNotEmpty) {
      player.messageTimer = 200;
    } else {
      player.messageTimer = 0;
    }
  }

  void onChangedInputMode(int inputMode){
    if (inputMode == InputMode.Touch){
      camera.centerOnChaseTarget();
      io.recenterCursor();
    }
  }

  void onChangedPlayerWeapon(int weaponType){
    if (weaponType == WeaponType.Unarmed) return;

    switch (weaponType) {
      case WeaponType.Plasma_Rifle:
        audio.gun_pickup_01();
        break;
      case WeaponType.Plasma_Pistol:
        audio.revolver_reload_1();
        break;
      case WeaponType.Revolver:
        audio.revolver_reload_1();
        break;
      case WeaponType.Handgun:
        audio.reload_6();
        break;
      case WeaponType.Shotgun:
        audio.cock_shotgun_3();
        break;
      case WeaponType.Sword:
        audio.sword_unsheathe();
        break;
      case WeaponType.Bow:
        audio.bow_draw();
        break;
      default:
        audio.gun_pickup_01();
        break;
    }
  }

  void readPlayerEventItemAcquired() {
    final itemType = readUInt16();
    // todo read subtype
    if (itemType == WeaponType.Unarmed) return;

    switch (itemType) {
      case WeaponType.Plasma_Rifle:
        audio.gun_pickup_01();
        break;
      case WeaponType.Plasma_Pistol:
        audio.revolver_reload_1();
        break;
      case WeaponType.Revolver:
        audio.revolver_reload_1();
        break;
      case WeaponType.Handgun:
        audio.reload_6();
        break;
      case WeaponType.Shotgun:
        audio.cock_shotgun_3();
        break;
      case WeaponType.Sword:
        audio.sword_unsheathe();
        break;
      case WeaponType.Bow:
        audio.bow_draw();
        break;
      default:
        // if (ItemType.isTypeWeapon(itemType)){
        //   audio.gun_pickup_01();
        // }
        break;
    }
  }

  void onChangedPlayerActive(bool playerActive){
     print('onChangedPlayerActive($playerActive)');
  }

  void onGameEventCharacterHurt(int type, double x, double y, double z, double angle) {

    playAudioXYZ(randomItem(audio.bloody_punches), x, y, z);
    playAudioXYZ(audio.heavy_punch_13, x, y, z);

    for (var i = 0; i < 4; i++){
      spawnParticleBlood(
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
          playAudioXYZ(audio.zombie_hurt_1, x, y, z);
        } else {
          playAudioXYZ(audio.zombie_hurt_4, x, y, z);
        }
        break;
      case CharacterType.Rat:
        playAudioXYZ(audio.rat_squeak, x, y, z);
        break;
      case CharacterType.Slime:
        playAudioXYZ(audio.bloody_punches_3, x, y, z);
        break;
      case CharacterType.Dog:
        playAudioXYZ(audio.dog_woolf_howl_4, x, y, z);
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
        playAudioXYZ(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          spawnParticleBlockWood(x, y, z);
        }
        break;
      case ObjectType.Toilet:
        playAudioXYZ(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          spawnParticleBlockWood(x, y, z);
        }
        break;
      case ObjectType.Crate_Wooden:
        playAudioXYZ(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          spawnParticleBlockWood(x, y, z);
        }
        break;

      case ObjectType.Credits:
        for (var i = 0; i < 8; i++){
          spawnParticleConfettiByType(
            x,
            y,
            z,
            ParticleType.Confetti_Cyan,
          );
        }
    }
  }
}