
import 'package:gamestream_flutter/game_minimap.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event_game_object_destroyed.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric/events/on_character_hurt.dart';

class GameEvents {

  static void onErrorFullscreenAuto(){
     // TODO show a dialog box asking the user to go fullscreen
  }

  static void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case ItemType.Weapon_Ranged_Shotgun:
        gamestream.audio.cock_shotgun_3.playXYZ(x, y, z);
        break;
      default:
        break;
    }
  }

  static void onChangedError(String error) {
    ClientState.messageStatus.value = error;
    if (error.isNotEmpty) {
      ClientState.messageStatusDuration = 200;
    } else {
      ClientState.messageStatusDuration = 0;
    }
  }

  static void onChangedNodes(){
    gamestream.games.isometric.nodes.refreshGridMetrics();
    gamestream.games.isometric.nodes.generateHeightMap();
    gamestream.games.isometric.nodes.generateMiniMap();
    GameMinimap.generateSrcDst();
    ClientActions.refreshBakeMapLightSources();

    if (ClientState.raining.value) {
      gamestream.actions.rainStop();
      gamestream.actions.rainStart();
    }
    gamestream.games.isometric.nodes.resetNodeColorsToAmbient();
    GameEditor.refreshNodeSelectedIndex();
  }

  static void onFootstep(double x, double y, double z) {
    if (ClientState.raining.value && (
        gamestream.games.isometric.nodes.gridNodeXYZTypeSafe(x, y, z) == NodeType.Rain_Landing
            ||
            gamestream.games.isometric.nodes.gridNodeXYZTypeSafe(x, y, z + 24) == NodeType.Rain_Landing
    )
    ){
      gamestream.audio.footstep_mud_6.playXYZ(x, y, z);
      final amount = ServerState.rainType.value == RainType.Heavy ? 3 : 2;
      for (var i = 0; i < amount; i++){
        gamestream.games.isometric.clientState.spawnParticleWaterDrop(x: x, y: y, z: z, zv: 1.5);
      }
    }

    final nodeType = gamestream.games.isometric.nodes.gridNodeXYZTypeSafe(x, y, z - 2);
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

  static void onGameEvent(int type, double x, double y, double z, double angle) {
    switch (type) {
      case GameEventType.Footstep:
        GameEvents.onFootstep(x, y, z);
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
        gamestream.games.isometric.camera.centerOnPlayer();
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
        GameSpawn.spawnBubbles(x, y, z);
        break;
      case GameEventType.Node_Struck:
        onNodeStruck(x, y, z);
        break;
      case GameEventType.Node_Deleted:
        gamestream.audio.hover_over_button_sound_30.playXYZ(x, y, z);
        break;
      case GameEventType.Weapon_Type_Equipped:
        final attackType =  gamestream.serverResponseReader.readByte();
        return GameEvents.onWeaponTypeEquipped(attackType, x, y, z);
      case GameEventType.Player_Spawned:
        for (var i = 0; i < 7; i++){
          gamestream.games.isometric.clientState.spawnParticleOrbShard(x: x, y: y, z: z, angle: Engine.randomAngle());
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
        gamestream.games.isometric.clientState.spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
        for (var i = 0; i < 8; i++) {
          gamestream.games.isometric.clientState.spawnParticleOrbShard(
              x: x, y: y, z: z, duration: 30, speed: Engine.randomBetween(1, 2), angle: Engine.randomAngle());
        }
        break;

      case GameEventType.Teleport_Start:
        for (var i = 0; i < 5; i++) {
          gamestream.games.isometric.clientState.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
        }
        break;

      case GameEventType.Teleport_End:
        for (var i = 0; i < 5; i++) {
          gamestream.games.isometric.clientState.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
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

  static void onGameEventExplosion(double x, double y, double z) {
    gamestream.actions.createExplosion(x, y, z);
  }

  static void onNodeSet(double x, double y, double z) {
    gamestream.audio.hover_over_button_sound_43.playXYZ(x, y, z);
  }

  static void onNodeStruck(double x, double y, double z) {
    if (!gamestream.games.isometric.nodes.inBounds(x, y, z)) return;

    final nodeIndex = gamestream.games.isometric.nodes.getIndexXYZ(x, y, z);
    final nodeType = gamestream.games.isometric.nodes.nodeTypes[nodeIndex];

    if (NodeType.isMaterialWood(nodeType)){
      gamestream.audio.material_struck_wood.playXYZ(x, y, z);
      gamestream.games.isometric.clientState.spawnParticleBlockWood(x, y, z);
    }

    if (NodeType.isMaterialGrass(nodeType)){
      gamestream.audio.grass_cut.playXYZ(x, y, z);
      gamestream.games.isometric.clientState.spawnParticleBlockGrass(x, y, z);
    }

    if (NodeType.isMaterialStone(nodeType)){
      gamestream.audio.material_struck_stone.playXYZ(x, y, z);
      gamestream.games.isometric.clientState.spawnParticleBlockBrick(x, y, z);
    }

    if (NodeType.isMaterialDirt(nodeType)){
      gamestream.audio.material_struck_dirt.playXYZ(x, y, z);
      gamestream.games.isometric.clientState.spawnParticleBlockSand(x, y, z);
    }
  }

  static void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
    gamestream.audio.swing_sword.playXYZ(x, y, z);
  }

  static void onAttackPerformedUnarmed(double x, double y, double z, double angle) {
    gamestream.games.isometric.clientState.spawnParticleBubbles(
      count: 3,
      x: x,
      y: y,
      z: z,
      angle: angle,
    );
  }

  static void onSplash(double x, double y, double z) {
    for (var i = 0; i < 12; i++){
      final zv = randomBetween(1.5, 5);
      gamestream.games.isometric.clientState.spawnParticleWaterDrop(x: x, y: y, z: z, zv: zv, duration: (zv * 12).toInt());
    }
    return gamestream.audio.splash.playXYZ(x, y, z);
  }

  static void onAttackPerformed(double x, double y, double z, double angle) {
    final attackType = gamestream.serverResponseReader.readUInt16();
    final attackTypeAudio = gamestream.audio.MapItemTypeAudioSinglesAttack[attackType];

    if (attackTypeAudio != null) {
      attackTypeAudio.playXYZ(x, y, z);
    }

    if (attackType == ItemType.Empty){
      gamestream.games.isometric.clientState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == ItemType.Weapon_Melee_Knife){
      gamestream.games.isometric.clientState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (ItemType.isTypeWeaponMelee(attackType)) {
      gamestream.games.isometric.clientState.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    if (attackType == ItemType.Weapon_Ranged_Flamethrower) return;

    const gun_distance = 50.0;
    final gunX = x - adj(angle, gun_distance);
    final gunY = y - opp(angle, gun_distance);

    if (ItemType.isTypeWeaponFirearm(attackType)){
      gamestream.games.isometric.clientState.spawnParticleSmoke(x: gunX, y: gunY, z: z, scale: 0.1, scaleV: 0.006, duration: 50);
      gamestream.games.isometric.clientState.spawnParticleShell(gunX, gunY, z);
    }
    if (ItemType.isAutomaticFirearm(attackType)){
      gamestream.games.isometric.clientState.spawnParticleStrikeBulletLight(x: x, y: y, z: z, angle: angle);
      return;
    }
    gamestream.games.isometric.clientState.spawnParticleStrikeBullet(x: x, y: y, z: z, angle: angle);
  }

  static void onMeleeAttackPerformed(double x, double y, double z, double angle) {
    final attackType = gamestream.serverResponseReader.readUInt16();
    final attackTypeAudio = gamestream.audio.MapItemTypeAudioSinglesAttackMelee[attackType];

    if (attackTypeAudio != null) {
      attackTypeAudio.playXYZ(x, y, z);
    }

    if (attackType == ItemType.Empty){
      gamestream.games.isometric.clientState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == ItemType.Weapon_Melee_Knife){
      gamestream.games.isometric.clientState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (ItemType.isTypeWeaponMelee(attackType)) {
      gamestream.games.isometric.clientState.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    gamestream.games.isometric.clientState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
    return;
  }


  static void onChangedEdit(bool value) {
    if (value) {
      gamestream.games.isometric.camera.setModeFree();
      GameEditor.cursorSetToPlayer();
      gamestream.games.isometric.camera.centerOnPlayer();
      GamePlayer.message.value = "-press arrow keys to move\n\n-press tab to play";
      GamePlayer.messageTimer = 300;
    } else {
      GameEditor.deselectGameObject();
      ClientActions.clearMouseOverDialogType();
      gamestream.games.isometric.camera.setModeChase();
      if (ServerState.sceneEditable.value){
        GamePlayer.message.value = "press tab to edit";
      }
    }
  }

  static void onChangedWindType(int windType) {
    ClientState.refreshRain();
  }

  static void onChangedHour(int hour){
    if (ServerState.sceneUnderground.value) return;
    ClientState.updateGameLighting();
  }

  static void onChangedSeconds(int seconds){
    final minutes = seconds ~/ 60;
    ServerState.hours.value = minutes ~/ Duration.minutesPerHour;
    ServerState.minutes.value = minutes % Duration.minutesPerHour;
  }

  static void onChangedRain(int value) {
    ClientState.raining.value = value != RainType.None;
    ClientState.refreshRain();
    ClientState.updateGameLighting();
  }

  static void onPlayerEvent(int event) {
    switch (event) {
      case PlayerEvent.Reloading:
        switch (GamePlayer.weapon.value){
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
        ClientActions.writeMessage("Level Gained");
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
        gamestream.games.isometric.camera.centerOnPlayer();
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
        GameEditor.gameObjectSelected.value = false;
        break;
      case PlayerEvent.Player_Moved:
        if (gamestream.gameType.value == GameType.Editor){
          GameEditor.row = GamePlayer.indexRow;
          GameEditor.column = GamePlayer.indexColumn;
          GameEditor.z = GamePlayer.indexZ;
        }
        gamestream.games.isometric.camera.centerOnPlayer();
        gamestream.io.recenterCursor();
        break;
      case PlayerEvent.Insufficient_Gold:
        ClientActions.writeMessage("Not Enough Gold");
        break;
      case PlayerEvent.Inventory_Full:
        ClientActions.writeMessage("Inventory Full");
        break;
      case PlayerEvent.Invalid_Request:
        ClientActions.writeMessage("Invalid Request");
        break;
    }
  }

  static void onPlayerEventPowerUsed() {
    switch (GamePlayer.powerType.value) {
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
        //     x: GamePlayer.x,
        //     y: GamePlayer.y,
        //     z: GamePlayer.z,
        //     duration: 10,
        //     animation: true,
        // );
        // GameState.spawnParticleLightEmissionAmbient(
        //     x: GamePlayer.x,
        //     y: GamePlayer.y,
        //     z: GamePlayer.z,
        // );
        break;
    }
  }

  static void readPlayerEventItemConsumed() {
    switch (gamestream.serverResponseReader.readUInt16()){
      case ItemType.Consumables_Potion_Red:
        gamestream.audio.drink();
        gamestream.audio.reviveHeal1();

        for (var i = 0; i < 8; i++){
          gamestream.games.isometric.clientState.spawnParticleConfettiByType(
             GamePlayer.position.x,
             GamePlayer.position.y,
             GamePlayer.position.z,
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

  static void onCharacterDeath(int characterType, double x, double y, double z, double angle) {
    randomItem(gamestream.audio.bloody_punches).playXYZ(x, y, z);
    gamestream.audio.heavy_punch_13.playXYZ(x, y, z);
    GameSpawn.spawnPurpleFireExplosion(x, y, z);
    GameSpawn.spawnBubbles(x, y, z);

    for (var i = 0; i < 4; i++){
      gamestream.games.isometric.clientState.spawnParticleBlood(
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

  static void onCharacterDeathZombie(int type, double x, double y, double z, double angle){
    final zPos = z + Node_Size_Half;
    gamestream.games.isometric.clientState.spawnParticleHeadZombie(x: x, y: y, z: zPos, angle: angle, speed: 4.0);
    gamestream.games.isometric.clientState.spawnParticleArm(
        x: x,
        y: y,
        z: zPos,
        angle: angle + Engine.randomGiveOrTake(0.5),
        speed: 4.0 + Engine.randomGiveOrTake(0.5));
    gamestream.games.isometric.clientState.spawnParticleLegZombie(
        x: x,
        y: y,
        z: zPos,
        angle: angle + Engine.randomGiveOrTake(0.5),
        speed: 4.0 + Engine.randomGiveOrTake(0.5));
    gamestream.games.isometric.clientState.spawnParticleOrgan(
        x: x,
        y: y,
        z: zPos,
        angle: angle + Engine.randomGiveOrTake(0.5),
        speed: 4.0 + Engine.randomGiveOrTake(0.5),
        zv: 0.1);
    Engine.randomItem(gamestream.audio.zombie_deaths).playXYZ(x, y, z);
  }

  static void onChangedRendersSinceUpdate(int value){
    ClientState.triggerAlarmNoMessageReceivedFromServer.value = value > 200;
  }

  static void onChangedPlayerMessage(String value){
    if (value.isNotEmpty) {
      GamePlayer.messageTimer = 200;
    } else {
      GamePlayer.messageTimer = 0;
    }
  }

  static void onChangedInputMode(int inputMode){
    if (inputMode == InputMode.Touch){
      gamestream.games.isometric.camera.centerOnPlayer();
      gamestream.io.recenterCursor();
    }
  }

  static void onChangedPlayerInteractMode(int value) {
    final camera = gamestream.games.isometric.camera;
    ClientActions.playSoundWindow();
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
        ClientActions.clearHoverIndex();
        ClientActions.clearMouseOverDialogType();
        break;
    }
  }

  static void onChangedPlayerWeaponRanged(int weaponType) {
    ClientState.itemGroup.value = ItemGroup.Primary_Weapon;
  }

  static void onChangedPlayerWeapon(int itemType){
    ClientState.itemGroup.value = ItemType.getItemGroup(itemType);

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

  static void onChangedPlayerRespawnTimer(int respawnTimer) {
    if (gamestream.gameType.value == GameType.Combat) {
      ClientState.control_visible_player_weapons.value = respawnTimer <= 0;
      ClientState.window_visible_player_creation.value = respawnTimer <= 0;
      ClientState.control_visible_respawn_timer.value = respawnTimer > 0;
    }
  }

  static void onChangedPlayerWeaponMelee(int weaponType) {
     ClientState.itemGroup.value = ItemGroup.Secondary_Weapon;
  }

  static void onChangedPlayerTertiaryWeapon(int weaponType) {
    ClientState.itemGroup.value = ItemGroup.Tertiary_Weapon;
  }

  static void readPlayerEventItemAcquired() {
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

  static void onGameEventPowerUsed(double x, double y, double z, int powerType) {
      switch (powerType){
        case PowerType.Stun:
          gamestream.audio.debuff_4();
          gamestream.games.isometric.clientState.spawnParticle(
            type: ParticleType.Lightning_Bolt,
            x: GamePlayer.x,
            y: GamePlayer.y,
            z: GamePlayer.z,
            duration: 10,
            animation: true,
          );
          gamestream.games.isometric.clientState.spawnParticleLightEmissionAmbient(
            x: GamePlayer.x,
            y: GamePlayer.y,
            z: GamePlayer.z,
          );
          break;
      }
  }

  static void onChangedPlayerAlive(bool playerAlive) {

  }

  static void onChangedPlayerActive(bool playerActive){
     print("onChangedPlayerActive($playerActive)");
      if (gamestream.gameType.value == GameType.Combat) {
        if (playerActive){
          ClientState.window_visible_player_creation.value = false;
        }

      }
  }
}