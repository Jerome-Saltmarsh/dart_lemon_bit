
import 'package:gamestream_flutter/game_minimap.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event_game_object_destroyed.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric/events/on_character_hurt.dart';

class GameEvents {

  static void onErrorFullscreenAuto(){
     // TODO show a dialog box asking the user to go fullscreen
  }

  static void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case ItemType.Weapon_Ranged_Shotgun:
        GameAudio.cock_shotgun_3.playXYZ(x, y, z);
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
    GameNodes.refreshGridMetrics();
    GameNodes.generateHeightMap();
    GameNodes.generateMiniMap();
    GameMinimap.generateSrcDst();
    ClientActions.refreshBakeMapLightSources();

    if (ClientState.raining.value) {
      GameActions.rainStop();
      GameActions.rainStart();
    }
    GameNodes.resetNodeColorsToAmbient();
    GameEditor.refreshNodeSelectedIndex();
  }

  static void onFootstep(double x, double y, double z) {
    if (ClientState.raining.value && (
        GameQueries.gridNodeXYZTypeSafe(x, y, z) == NodeType.Rain_Landing
            ||
            GameQueries.gridNodeXYZTypeSafe(x, y, z + 24) == NodeType.Rain_Landing
    )
    ){
      GameAudio.footstep_mud_6.playXYZ(x, y, z);
      final amount = ServerState.rainType.value == RainType.Heavy ? 3 : 2;
      for (var i = 0; i < amount; i++){
        GameState.spawnParticleWaterDrop(x: x, y: y, z: z, zv: 1.5);
      }
    }

    final nodeType = GameQueries.gridNodeXYZTypeSafe(x, y, z - 2);
    if (NodeType.isMaterialStone(nodeType)) {
      GameAudio.footstep_stone.playXYZ(x, y, z);
      return;
    }
    if (NodeType.isMaterialWood(nodeType)) {
      GameAudio.footstep_wood_4.playXYZ(x, y, z);
      return;
    }
    if (Engine.randomBool()){
      GameAudio.footstep_grass_8.playXYZ(x, y, z);
      return;
    }
    GameAudio.footstep_grass_7.playXYZ(x, y, z);
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
        GameAudio.metal_light_3.playXYZ(x, y, z);
        return;
      case GameEventType.Material_Struck_Metal:
        GameAudio.metal_struck.playXYZ(x, y, z);
        return;
      case GameEventType.Player_Spawn_Started:
        GameCamera.centerOnPlayer();
        GameAudio.teleport.playXYZ(x, y, z);
        return;
      case GameEventType.Explosion:
        onGameEventExplosion(x, y, z);
        return;
      case GameEventType.Power_Used:
        onGameEventPowerUsed(x, y, z, serverResponseReader.readByte());
        break;
      case GameEventType.AI_Target_Acquired:
        final characterType = serverResponseReader.readByte();
        switch (characterType){
          case CharacterType.Zombie:
            Engine.randomItem(GameAudio.audioSingleZombieTalking).playXYZ(x, y, z);
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
        GameAudio.hover_over_button_sound_30.playXYZ(x, y, z);
        break;
      case GameEventType.Weapon_Type_Equipped:
        final attackType =  serverResponseReader.readByte();
        return GameEvents.onWeaponTypeEquipped(attackType, x, y, z);
      case GameEventType.Player_Spawned:
        for (var i = 0; i < 7; i++){
          GameState.spawnParticleOrbShard(x: x, y: y, z: z, angle: Engine.randomAngle());
        }
        return;
      case GameEventType.Splash:
        onSplash(x, y, z);
        return;
      case GameEventType.Item_Bounce:
        GameAudio.grenade_bounce.playXYZ(x, y, z);
        return;
      case GameEventType.Spawn_Dust_Cloud:
        break;
      case GameEventType.Player_Hit:
        if (Engine.randomBool()) {
          // audio.humanHurt(x, y);
        }
        break;
      case GameEventType.Zombie_Target_Acquired:
        Engine.randomItem(GameAudio.audioSingleZombieTalking).playXYZ(x, y, z);
        break;
      case GameEventType.Character_Changing:
        GameAudio.change_cloths.playXYZ(x, y, z);
        break;
      case GameEventType.Zombie_Strike:
        Engine.randomItem(GameAudio.audioSingleZombieBits).playXYZ(x, y, z);
        if (Engine.randomBool()){
          Engine.randomItem(GameAudio.audioSingleZombieTalking).playXYZ(x, y, z);
        }
        break;
      case GameEventType.Player_Death:
        break;
      case GameEventType.Teleported:
        GameAudio.magical_impact_16();
        break;
      case GameEventType.Blue_Orb_Fired:
        GameAudio.sci_fi_blaster_1.playXYZ(x, y, z);
        break;
      case GameEventType.Arrow_Hit:
        GameAudio.arrow_impact.playXYZ(x, y, z);
        break;
      case GameEventType.Draw_Bow:
        return GameAudio.bow_draw.playXYZ(x, y, z);
      case GameEventType.Release_Bow:
        return GameAudio.bow_release.playXYZ(x, y, z);
      case GameEventType.Sword_Woosh:
        return GameAudio.swing_sword.playXYZ(x, y, z);
      case GameEventType.EnemyTargeted:
        break;
      case GameEventType.Attack_Missed:
        final attackType = serverResponseReader.readUInt16();
        switch (attackType) {
          case ItemType.Empty:
            GameAudio.arm_swing_whoosh_11.playXYZ(x, y, z);
            break;
          case ItemType.Weapon_Melee_Sword:
            GameAudio.arm_swing_whoosh_11.playXYZ(x, y, z);
            break;
        }
        break;
      case GameEventType.Arrow_Fired:
        return GameAudio.arrow_flying_past_6.playXYZ(x, y, z);

      case GameEventType.Crate_Breaking:
        // return audio.crateBreaking(x, y);
        break;

      case GameEventType.Blue_Orb_Deactivated:
        GameState.spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
        for (var i = 0; i < 8; i++) {
          GameState.spawnParticleOrbShard(
              x: x, y: y, z: z, duration: 30, speed: Engine.randomBetween(1, 2), angle: Engine.randomAngle());
        }
        break;

      case GameEventType.Teleport_Start:
        for (var i = 0; i < 5; i++) {
          GameState.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
        }
        break;

      case GameEventType.Teleport_End:
        for (var i = 0; i < 5; i++) {
          GameState.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
        }
        break;

      case GameEventType.Character_Death:
        onCharacterDeath(serverResponseReader.readByte(), x, y, z, angle);
        return;

      case GameEventType.Character_Hurt:
        onGameEventCharacterHurt(serverResponseReader.readByte(), x, y, z, angle);
        return;

      case GameEventType.Game_Object_Destroyed:
        onGameEventGameObjectDestroyed(
            x,
            y,
            z,
            angle,
            serverResponseReader.readUInt16(),
        );
        return;
    }
  }

  static void onGameEventExplosion(double x, double y, double z) {
    GameActions.createExplosion(x, y, z);
  }

  static void onNodeSet(double x, double y, double z) {
    GameAudio.hover_over_button_sound_43.playXYZ(x, y, z);
  }

  static void onNodeStruck(double x, double y, double z) {
    if (!GameQueries.inBounds(x, y, z)) return;

    final nodeIndex = GameNodes.getIndexXYZ(x, y, z);
    final nodeType = GameNodes.nodeTypes[nodeIndex];

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

    if (NodeType.isMaterialDirt(nodeType)){
      GameAudio.material_struck_dirt.playXYZ(x, y, z);
      GameState.spawnParticleBlockSand(x, y, z);
    }
  }

  static void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
    GameAudio.swing_sword.playXYZ(x, y, z);
  }

  static void onAttackPerformedUnarmed(double x, double y, double z, double angle) {
    GameState.spawnParticleBubbles(
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
      GameState.spawnParticleWaterDrop(x: x, y: y, z: z, zv: zv, duration: (zv * 12).toInt());
    }
    return GameAudio.splash.playXYZ(x, y, z);
  }

  static void onAttackPerformed(double x, double y, double z, double angle) {
    final attackType = serverResponseReader.readUInt16();
    final attackTypeAudio = GameAudio.MapItemTypeAudioSinglesAttack[attackType];

    if (attackTypeAudio != null) {
      attackTypeAudio.playXYZ(x, y, z);
    }

    if (attackType == ItemType.Empty){
      GameState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == ItemType.Weapon_Melee_Knife){
      GameState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (ItemType.isTypeWeaponMelee(attackType)) {
      GameState.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    if (attackType == ItemType.Weapon_Ranged_Flamethrower) return;

    const gun_distance = 50.0;
    final gunX = x - getAdjacent(angle, gun_distance);
    final gunY = y - getOpposite(angle, gun_distance);

    if (ItemType.isTypeWeaponFirearm(attackType)){
      GameState.spawnParticleSmoke(x: gunX, y: gunY, z: z, scale: 0.1, scaleV: 0.006, duration: 50);
      GameState.spawnParticleShell(gunX, gunY, z);
    }
    if (ItemType.isAutomaticFirearm(attackType)){
      GameState.spawnParticleStrikeBulletLight(x: x, y: y, z: z, angle: angle);
      return;
    }
    GameState.spawnParticleStrikeBullet(x: x, y: y, z: z, angle: angle);
  }

  static void onMeleeAttackPerformed(double x, double y, double z, double angle) {
    final attackType = serverResponseReader.readUInt16();
    final attackTypeAudio = GameAudio.MapItemTypeAudioSinglesAttackMelee[attackType];

    if (attackTypeAudio != null) {
      attackTypeAudio.playXYZ(x, y, z);
    }

    if (attackType == ItemType.Empty){
      GameState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == ItemType.Weapon_Melee_Knife){
      GameState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (ItemType.isTypeWeaponMelee(attackType)) {
      GameState.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    GameState.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
    return;
  }


  static void onChangedEdit(bool value) {
    if (value) {
      GameCamera.setModeFree();
      GameEditor.cursorSetToPlayer();
      GameCamera.centerOnPlayer();
      GamePlayer.message.value = "-press arrow keys to move\n\n-press tab to play";
      GamePlayer.messageTimer = 300;
    } else {
      GameEditor.deselectGameObject();
      ClientActions.clearMouseOverDialogType();
      GameCamera.setModeChase();
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
            GameAudio.reload_6();
            break;
          default:
            GameAudio.reload_6();
        }
        break;
      case PlayerEvent.Teleported:
        GameAudio.magical_swoosh_18();
        break;
      case PlayerEvent.Power_Used:
        onPlayerEventPowerUsed();
        break;
      case PlayerEvent.Level_Increased:
        GameAudio.buff_1();
        ClientActions.writeMessage("Level Gained");
        break;
      case PlayerEvent.Item_Consumed:
        readPlayerEventItemConsumed();
        break;
      case PlayerEvent.Recipe_Crafted:
        GameAudio.unlock();
        break;
      case PlayerEvent.Loot_Collected:
        return GameAudio.collect_star_3();
      case PlayerEvent.Scene_Changed:
        GameCamera.centerOnPlayer();
        // GameActions.setAmbientShadeToHour();
        break;
      case PlayerEvent.Item_Acquired:
        readPlayerEventItemAcquired();
        break;
      case PlayerEvent.Item_Dropped:
        GameAudio.popSounds14();
        break;
      case PlayerEvent.Item_Sold:
        GameAudio.coins_24();
        break;
      case PlayerEvent.GameObject_Deselected:
        GameEditor.gameObjectSelected.value = false;
        break;
      case PlayerEvent.Player_Moved:
        if (ServerState.gameType.value == GameType.Editor){
          GameEditor.row = GamePlayer.indexRow;
          GameEditor.column = GamePlayer.indexColumn;
          GameEditor.z = GamePlayer.indexZ;
        }
        GameCamera.centerOnPlayer();
        GameIO.recenterCursor();
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
        GameAudio.buff_10();
        break;
      case PowerType.Invisible:
        GameAudio.buff_19();
        break;
      case PowerType.Stun:
        // GameAudio.debuff_4();
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
    switch (serverResponseReader.readUInt16()){
      case ItemType.Consumables_Potion_Red:
        GameAudio.drink();
        GameAudio.reviveHeal1();

        for (var i = 0; i < 8; i++){
          GameState.spawnParticleConfettiByType(
             GamePlayer.position.x,
             GamePlayer.position.y,
             GamePlayer.position.z,
             ParticleType.Confetti_Green,
          );
        }
        break;
      case ItemType.Consumables_Potion_Blue:
        GameAudio.drink();
        break;
      case ItemType.Consumables_Meat:
        GameAudio.eat();
        break;
      case ItemType.Consumables_Apple:
        GameAudio.eat();
        break;
      case ItemType.Consumables_Meat:
        GameAudio.eat();
        break;
    }
  }

  static void onCharacterDeath(int characterType, double x, double y, double z, double angle) {
    randomItem(GameAudio.bloody_punches).playXYZ(x, y, z);
    GameAudio.heavy_punch_13.playXYZ(x, y, z);
    GameSpawn.spawnPurpleFireExplosion(x, y, z);
    GameSpawn.spawnBubbles(x, y, z);

    for (var i = 0; i < 4; i++){
      GameState.spawnParticleBlood(
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
        GameAudio.dog_woolf_howl_4();
        break;
    }
  }

  static void onCharacterDeathZombie(int type, double x, double y, double z, double angle){
    final zPos = z + Node_Size_Half;
    GameState.spawnParticleHeadZombie(x: x, y: y, z: zPos, angle: angle, speed: 4.0);
    GameState.spawnParticleArm(
        x: x,
        y: y,
        z: zPos,
        angle: angle + Engine.randomGiveOrTake(0.5),
        speed: 4.0 + Engine.randomGiveOrTake(0.5));
    GameState.spawnParticleLegZombie(
        x: x,
        y: y,
        z: zPos,
        angle: angle + Engine.randomGiveOrTake(0.5),
        speed: 4.0 + Engine.randomGiveOrTake(0.5));
    GameState.spawnParticleOrgan(
        x: x,
        y: y,
        z: zPos,
        angle: angle + Engine.randomGiveOrTake(0.5),
        speed: 4.0 + Engine.randomGiveOrTake(0.5),
        zv: 0.1);
    Engine.randomItem(GameAudio.zombie_deaths).playXYZ(x, y, z);
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
      GameCamera.centerOnPlayer();
      GameIO.recenterCursor();
    }
  }

  static void onChangedPlayerInteractMode(int value) {
    ClientActions.playSoundWindow();
    switch (value) {
      case InteractMode.Inventory:
        GameCamera.translateX = GameInventoryUI.Inventory_Width * 0.5;
        break;
      case InteractMode.Talking:
        GameCamera.translateX = -GameInventoryUI.Inventory_Width * 0.5;
        break;
      case InteractMode.Trading:
        GameCamera.translateX = 0;
        break;
      case InteractMode.None:
        GameCamera.translateX = 0;
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
        GameAudio.gun_pickup_01();
        break;
      case ItemType.Weapon_Ranged_Plasma_Pistol:
        GameAudio.revolver_reload_1();
        break;
      case ItemType.Weapon_Ranged_Revolver:
        GameAudio.revolver_reload_1();
        break;
      case ItemType.Weapon_Ranged_Handgun:
        GameAudio.reload_6();
        break;
      case ItemType.Weapon_Ranged_Shotgun:
        GameAudio.cock_shotgun_3();
        break;
      case ItemType.Weapon_Melee_Sword:
        GameAudio.sword_unsheathe();
        break;
      case ItemType.Weapon_Ranged_Bow:
        GameAudio.bow_draw();
        break;
      default:
        GameAudio.gun_pickup_01();
        break;
    }
  }

  static void onChangedPlayerRespawnTimer(int respawnTimer) {
    if (ServerState.gameType.value == GameType.Combat) {
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
    final itemType = serverResponseReader.readUInt16();
    if (itemType == ItemType.Empty) return;

    switch (itemType) {
      case ItemType.Weapon_Ranged_Plasma_Rifle:
        GameAudio.gun_pickup_01();
        break;
      case ItemType.Weapon_Ranged_Plasma_Pistol:
        GameAudio.revolver_reload_1();
        break;
      case ItemType.Weapon_Ranged_Revolver:
        GameAudio.revolver_reload_1();
        break;
      case ItemType.Weapon_Ranged_Handgun:
        GameAudio.reload_6();
        break;
      case ItemType.Weapon_Ranged_Shotgun:
        GameAudio.cock_shotgun_3();
        break;
      case ItemType.Weapon_Melee_Sword:
        GameAudio.sword_unsheathe();
        break;
      case ItemType.Weapon_Ranged_Bow:
        GameAudio.bow_draw();
        break;
      case ItemType.Buff_Invincible:
        GameAudio.buff_16();
        break;
      case ItemType.Buff_Invincible:
        GameAudio.buff_16();
        break;
      case ItemType.Resource_Credit:
        GameAudio.collect_star_3();
        break;
      default:
        if (ItemType.isTypeWeapon(itemType)){
          GameAudio.gun_pickup_01();
        }
        break;
    }
  }

  static void onGameEventPowerUsed(double x, double y, double z, int powerType) {
      switch (powerType){
        case PowerType.Stun:
          GameAudio.debuff_4();
          GameState.spawnParticle(
            type: ParticleType.Lightning_Bolt,
            x: GamePlayer.x,
            y: GamePlayer.y,
            z: GamePlayer.z,
            duration: 10,
            animation: true,
          );
          GameState.spawnParticleLightEmissionAmbient(
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
      if (ServerState.gameType.value == GameType.Combat) {
        if (playerActive){
          ClientState.window_visible_player_creation.value = false;
        }

      }
  }
}