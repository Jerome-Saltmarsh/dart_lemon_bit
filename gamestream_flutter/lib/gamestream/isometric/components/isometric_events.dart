
import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_client_state.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event_game_object_destroyed.dart';
import 'package:gamestream_flutter/library.dart';

import '../../../isometric/events/on_character_hurt.dart';
import '../isometric.dart';

class IsometricEvents {

  final Gamestream gamestream;
  final IsometricClientState clientState;
  late final Isometric isometric;

  IsometricEvents(this.clientState, this.gamestream) {
    this.isometric = gamestream.isometric;
  }

  void onErrorFullscreenAuto(){
     // TODO show a dialog box asking the user to go fullscreen
  }

  void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case ItemType.Weapon_Ranged_Shotgun:
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
    gamestream.isometric.nodes.refreshGridMetrics();
    gamestream.isometric.nodes.generateHeightMap();
    gamestream.isometric.nodes.generateMiniMap();
    gamestream.isometric.minimap.generateSrcDst();
    gamestream.isometric.clientState.refreshBakeMapLightSources();

    if (clientState.raining.value) {
      gamestream.isometric.actions.rainStop();
      gamestream.isometric.actions.rainStart();
    }
    gamestream.isometric.nodes.resetNodeColorsToAmbient();
    gamestream.isometric.editor.refreshNodeSelectedIndex();
  }

  void onFootstep(double x, double y, double z) {
    if (clientState.raining.value && (
        gamestream.isometric.nodes.gridNodeXYZTypeSafe(x, y, z) == NodeType.Rain_Landing
            ||
            gamestream.isometric.nodes.gridNodeXYZTypeSafe(x, y, z + 24) == NodeType.Rain_Landing
    )
    ){
      gamestream.audio.footstep_mud_6.playXYZ(x, y, z);
      final amount = gamestream.isometric.server.rainType.value == RainType.Heavy ? 3 : 2;
      for (var i = 0; i < amount; i++){
        gamestream.isometric.particles.spawnParticleWaterDrop(x: x, y: y, z: z, zv: 1.5);
      }
    }

    final nodeType = gamestream.isometric.nodes.gridNodeXYZTypeSafe(x, y, z - 2);
    if (NodeType.isMaterialStone(nodeType)) {
      gamestream.audio.footstep_stone.playXYZ(x, y, z);
      return;
    }
    if (NodeType.isMaterialWood(nodeType)) {
      gamestream.audio.footstep_wood_4.playXYZ(x, y, z);
      return;
    }
    if (Engine.randomBool()){
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
        onGameEventPowerUsed(x, y, z, gamestream.serverResponseReader.readByte());
        break;
      case GameEventType.AI_Target_Acquired:
        final characterType = gamestream.serverResponseReader.readByte();
        switch (characterType){
          case CharacterType.Zombie:
            Engine.randomItem(gamestream.audio.audioSingleZombieTalking).playXYZ(x, y, z);
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
        final attackType =  gamestream.serverResponseReader.readByte();
        return onWeaponTypeEquipped(attackType, x, y, z);
      case GameEventType.Player_Spawned:
        for (var i = 0; i < 7; i++){
          gamestream.isometric.particles.spawnParticleOrbShard(x: x, y: y, z: z, angle: Engine.randomAngle());
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
        if (Engine.randomBool()) {
          // audio.humanHurt(x, y);
        }
        break;
      case GameEventType.Zombie_Target_Acquired:
        Engine.randomItem(gamestream.audio.audioSingleZombieTalking).playXYZ(x, y, z);
        break;
      case GameEventType.Character_Changing:
        gamestream.audio.change_cloths.playXYZ(x, y, z);
        break;
      case GameEventType.Zombie_Strike:
        Engine.randomItem(gamestream.audio.audioSingleZombieBits).playXYZ(x, y, z);
        if (Engine.randomBool()){
          Engine.randomItem(gamestream.audio.audioSingleZombieTalking).playXYZ(x, y, z);
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
        final attackType = gamestream.serverResponseReader.readUInt16();
        switch (attackType) {
          case ItemType.Empty:
            gamestream.audio.arm_swing_whoosh_11.playXYZ(x, y, z);
            break;
          case ItemType.Weapon_Melee_Sword:
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
              x: x, y: y, z: z, duration: 30, speed: Engine.randomBetween(1, 2), angle: Engine.randomAngle());
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
        onCharacterDeath(gamestream.serverResponseReader.readByte(), x, y, z, angle);
        return;

      case GameEventType.Character_Hurt:
        onGameEventCharacterHurt(gamestream.serverResponseReader.readByte(), x, y, z, angle);
        return;

      case GameEventType.Game_Object_Destroyed:
        onGameEventGameObjectDestroyed(
            x,
            y,
            z,
            angle,
          gamestream.serverResponseReader.readUInt16(),
        );
        return;
    }
  }

  void onGameEventExplosion(double x, double y, double z) {
    gamestream.isometric.actions.createExplosion(x, y, z);
  }

  void onNodeSet(double x, double y, double z) {
    gamestream.audio.hover_over_button_sound_43.playXYZ(x, y, z);
  }

  void onNodeStruck(double x, double y, double z) {
    if (!gamestream.isometric.nodes.inBounds(x, y, z)) return;

    final nodeIndex = gamestream.isometric.nodes.getIndexXYZ(x, y, z);
    final nodeType = gamestream.isometric.nodes.nodeTypes[nodeIndex];

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
    final attackType = gamestream.serverResponseReader.readUInt16();
    final attackTypeAudio = gamestream.audio.MapItemTypeAudioSinglesAttack[attackType];

    if (attackTypeAudio != null) {
      attackTypeAudio.playXYZ(x, y, z);
    }

    if (attackType == ItemType.Empty){
      isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == ItemType.Weapon_Melee_Knife){
      isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (ItemType.isTypeWeaponMelee(attackType)) {
      isometric.particles.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    if (attackType == ItemType.Weapon_Ranged_Flamethrower) return;

    const gun_distance = 50.0;
    final gunX = x - adj(angle, gun_distance);
    final gunY = y - opp(angle, gun_distance);

    if (ItemType.isTypeWeaponFirearm(attackType)){
      isometric.particles.spawnParticleSmoke(x: gunX, y: gunY, z: z, scale: 0.1, scaleV: 0.006, duration: 50);
      isometric.particles.spawnParticleShell(gunX, gunY, z);
    }
    if (ItemType.isAutomaticFirearm(attackType)){
      isometric.particles.spawnParticleStrikeBulletLight(x: x, y: y, z: z, angle: angle);
      return;
    }
    isometric.particles.spawnParticleStrikeBullet(x: x, y: y, z: z, angle: angle);
  }

  void onMeleeAttackPerformed(double x, double y, double z, double angle) {
    final attackType = gamestream.serverResponseReader.readUInt16();
    final attackTypeAudio = gamestream.audio.MapItemTypeAudioSinglesAttackMelee[attackType];

    if (attackTypeAudio != null) {
      attackTypeAudio.playXYZ(x, y, z);
    }

    if (attackType == ItemType.Empty){
      isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == ItemType.Weapon_Melee_Knife){
      isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (ItemType.isTypeWeaponMelee(attackType)) {
      isometric.particles.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    isometric.particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
    return;
  }


  void onChangedEdit(bool value) {
    if (value) {
      gamestream.isometric.camera.setModeFree();
      gamestream.isometric.editor.cursorSetToPlayer();
      gamestream.isometric.camera.centerOnChaseTarget();
      gamestream.isometric.player.message.value = "-press arrow keys to move\n\n-press tab to play";
      gamestream.isometric.player.messageTimer = 300;
    } else {
      gamestream.isometric.editor.deselectGameObject();
      gamestream.isometric.ui.clearMouseOverDialogType();
      gamestream.isometric.camera.setModeChase();
      if (gamestream.isometric.server.sceneEditable.value){
        gamestream.isometric.player.message.value = "press tab to edit";
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
          case ItemType.Weapon_Ranged_Handgun:
            gamestream.audio.reload_6();
            break;
          default:
            gamestream.audio.reload_6();
        }
        break;
      case PlayerEvent.Teleported:
        gamestream.audio.magical_swoosh_18();
        break;
      case PlayerEvent.Power_Used:
        onPlayerEventPowerUsed();
        break;
      case PlayerEvent.Level_Increased:
        gamestream.audio.buff_1();
        gamestream.isometric.clientState.writeMessage("Level Gained");
        break;
      case PlayerEvent.Item_Consumed:
        readPlayerEventItemConsumed();
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
        gamestream.isometric.clientState.writeMessage("Not Enough Gold");
        break;
      case PlayerEvent.Inventory_Full:
        gamestream.isometric.clientState.writeMessage("Inventory Full");
        break;
      case PlayerEvent.Invalid_Request:
        gamestream.isometric.clientState.writeMessage("Invalid Request");
        break;
    }
  }

  void onPlayerEventPowerUsed() {
    switch (gamestream.isometric.player.powerType.value) {
      case PowerType.Shield:
        gamestream.audio.buff_10();
        break;
      case PowerType.Invisible:
        gamestream.audio.buff_19();
        break;
      case PowerType.Stun:
        // gamestream.audio.debuff_4();
        // GameState.spawnParticle(
        //     type: ParticleType.Lightning_Bolt,
        //     x: gamestream.isometricEngine.player.x,
        //     y: gamestream.isometricEngine.player.y,
        //     z: gamestream.isometricEngine.player.z,
        //     duration: 10,
        //     animation: true,
        // );
        // GameState.spawnParticleLightEmissionAmbient(
        //     x: gamestream.isometricEngine.player.x,
        //     y: gamestream.isometricEngine.player.y,
        //     z: gamestream.isometricEngine.player.z,
        // );
        break;
    }
  }

  void readPlayerEventItemConsumed() {
    switch (gamestream.serverResponseReader.readUInt16()){
      case ItemType.Consumables_Potion_Red:
        gamestream.audio.drink();
        gamestream.audio.reviveHeal1();

        for (var i = 0; i < 8; i++){
          isometric.particles.spawnParticleConfettiByType(
             gamestream.isometric.player.position.x,
             gamestream.isometric.player.position.y,
             gamestream.isometric.player.position.z,
             ParticleType.Confetti_Green,
          );
        }
        break;
      case ItemType.Consumables_Potion_Blue:
        gamestream.audio.drink();
        break;
      case ItemType.Consumables_Meat:
        gamestream.audio.eat();
        break;
      case ItemType.Consumables_Apple:
        gamestream.audio.eat();
        break;
    }
  }

  void onCharacterDeath(int characterType, double x, double y, double z, double angle) {
    randomItem(gamestream.audio.bloody_punches).playXYZ(x, y, z);
    gamestream.audio.heavy_punch_13.playXYZ(x, y, z);
    isometric.particles.spawnPurpleFireExplosion(x, y, z);
    isometric.particles.spawnBubbles(x, y, z);

    for (var i = 0; i < 4; i++){
      isometric.particles.spawnParticleBlood(
        x: x,
        y: y,
        z: z,
        zv: Engine.randomBetween(1.5, 2),
        angle: angle + Engine.randomGiveOrTake(Engine.PI_Quarter),
        speed: Engine.randomBetween(1.5, 2.5),
      );
    }

    switch (characterType) {
      case CharacterType.Zombie:
        return onCharacterDeathZombie(characterType, x, y, z, angle);
      case CharacterType.Dog:
        // GameState.spawnParticleAnimation(
        //     x: x,
        //     y: y,
        //     z: z,
        //     type: ParticleType.Character_Animation_Dog_Death,
        // );
        gamestream.audio.dog_woolf_howl_4();
        break;
    }
  }

  void onCharacterDeathZombie(int type, double x, double y, double z, double angle){
    final zPos = z + Node_Size_Half;
    isometric.particles.spawnParticleHeadZombie(x: x, y: y, z: zPos, angle: angle, speed: 4.0);
    isometric.particles.spawnParticleArm(
        x: x,
        y: y,
        z: zPos,
        angle: angle + Engine.randomGiveOrTake(0.5),
        speed: 4.0 + Engine.randomGiveOrTake(0.5));
    isometric.particles.spawnParticleLegZombie(
        x: x,
        y: y,
        z: zPos,
        angle: angle + Engine.randomGiveOrTake(0.5),
        speed: 4.0 + Engine.randomGiveOrTake(0.5));
    isometric.particles.spawnParticleOrgan(
        x: x,
        y: y,
        z: zPos,
        angle: angle + Engine.randomGiveOrTake(0.5),
        speed: 4.0 + Engine.randomGiveOrTake(0.5),
        zv: 0.1);
    Engine.randomItem(gamestream.audio.zombie_deaths).playXYZ(x, y, z);
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

  void onChangedPlayerInteractMode(int value) {
    final camera = gamestream.isometric.camera;
    gamestream.isometric.clientState.playSoundWindow();
    switch (value) {
      case InteractMode.Inventory:
        camera.translateX = GameInventoryUI.Inventory_Width * 0.5;
        break;
      case InteractMode.Talking:
        camera.translateX = -GameInventoryUI.Inventory_Width * 0.5;
        break;
      case InteractMode.Trading:
        camera.translateX = 0;
        break;
      case InteractMode.None:
        camera.translateX = 0;
        gamestream.isometric.clientState.clearHoverIndex();
        gamestream.isometric.ui.clearMouseOverDialogType();
        break;
    }
  }

  void onChangedPlayerWeaponRanged(int weaponType) {
    clientState.itemGroup.value = ItemGroup.Primary_Weapon;
  }

  void onChangedPlayerWeapon(int itemType){
    clientState.itemGroup.value = ItemType.getItemGroup(itemType);

    if (itemType == ItemType.Empty) return;

    switch (itemType) {
      case ItemType.Weapon_Ranged_Plasma_Rifle:
        gamestream.audio.gun_pickup_01();
        break;
      case ItemType.Weapon_Ranged_Plasma_Pistol:
        gamestream.audio.revolver_reload_1();
        break;
      case ItemType.Weapon_Ranged_Revolver:
        gamestream.audio.revolver_reload_1();
        break;
      case ItemType.Weapon_Ranged_Handgun:
        gamestream.audio.reload_6();
        break;
      case ItemType.Weapon_Ranged_Shotgun:
        gamestream.audio.cock_shotgun_3();
        break;
      case ItemType.Weapon_Melee_Sword:
        gamestream.audio.sword_unsheathe();
        break;
      case ItemType.Weapon_Ranged_Bow:
        gamestream.audio.bow_draw();
        break;
      default:
        gamestream.audio.gun_pickup_01();
        break;
    }
  }

  void onChangedPlayerRespawnTimer(int respawnTimer) {
    if (gamestream.gameType.value == GameType.Combat) {
      clientState.control_visible_player_weapons.value = respawnTimer <= 0;
      clientState.window_visible_player_creation.value = respawnTimer <= 0;
      clientState.control_visible_respawn_timer.value = respawnTimer > 0;
    }
  }

  void onChangedPlayerWeaponMelee(int weaponType) {
     clientState.itemGroup.value = ItemGroup.Secondary_Weapon;
  }

  void onChangedPlayerTertiaryWeapon(int weaponType) {
    clientState.itemGroup.value = ItemGroup.Tertiary_Weapon;
  }

  void readPlayerEventItemAcquired() {
    final itemType = gamestream.serverResponseReader.readUInt16();
    if (itemType == ItemType.Empty) return;

    switch (itemType) {
      case ItemType.Weapon_Ranged_Plasma_Rifle:
        gamestream.audio.gun_pickup_01();
        break;
      case ItemType.Weapon_Ranged_Plasma_Pistol:
        gamestream.audio.revolver_reload_1();
        break;
      case ItemType.Weapon_Ranged_Revolver:
        gamestream.audio.revolver_reload_1();
        break;
      case ItemType.Weapon_Ranged_Handgun:
        gamestream.audio.reload_6();
        break;
      case ItemType.Weapon_Ranged_Shotgun:
        gamestream.audio.cock_shotgun_3();
        break;
      case ItemType.Weapon_Melee_Sword:
        gamestream.audio.sword_unsheathe();
        break;
      case ItemType.Weapon_Ranged_Bow:
        gamestream.audio.bow_draw();
        break;
      case ItemType.Buff_Invincible:
        gamestream.audio.buff_16();
        break;
      case ItemType.Resource_Credit:
        gamestream.audio.collect_star_3();
        break;
      default:
        if (ItemType.isTypeWeapon(itemType)){
          gamestream.audio.gun_pickup_01();
        }
        break;
    }
  }


  void onGameEventPowerUsed(double x, double y, double z, int powerType) {
      switch (powerType){
        case PowerType.Stun:
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

  void onChangedPlayerAlive(bool playerAlive) {

  }

  void onChangedPlayerActive(bool playerActive){
     print("onChangedPlayerActive($playerActive)");
      if (gamestream.gameType.value == GameType.Combat) {
        if (playerActive){
          clientState.window_visible_player_creation.value = false;
        }

      }
  }
}