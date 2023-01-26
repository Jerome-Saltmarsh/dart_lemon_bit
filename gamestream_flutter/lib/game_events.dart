
import 'package:gamestream_flutter/game_minimap.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event_game_object_destroyed.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event_quest_started.dart';
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
      ClientActions.playAudioError();
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
        // audio.magicalSwoosh(x, y);
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

      case GameEventType.Character_Death:
        final characterType = serverResponseReader.readByte();
        return onCharacterDeath(characterType, x, y, z, angle);

      case GameEventType.Character_Hurt:
        final characterType = serverResponseReader.readByte();
        return onGameEventCharacterHurt(characterType, x, y, z, angle);

      case GameEventType.Game_Object_Destroyed:
        final type = serverResponseReader.readUInt16();
        return onGameEventGameObjectDestroyed(x, y, z, angle, type);
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
    for (var i = 0; i < 10; i++){
      GameState.spawnParticleWaterDrop(x: x, y: y, z: z, zv: randomBetween(1.5, 2.5));
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
    if (ItemType.isAutomaticFirearm(attackType)){
      GameState.spawnParticleStrikeBulletLight(x: x, y: y, z: z, angle: angle);
      return;
    }
    GameState.spawnParticleStrikeBullet(x: x, y: y, z: z, angle: angle);
  }


  static void onChangedEdit(bool value) {
    if (value) {
      GameCamera.setModeFree();
      GameEditor.cursorSetToPlayer();
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

  static void onChangedRain(int value) {
    ClientState.raining.value = value != RainType.None;
    ClientState.refreshRain();
    ClientState.updateGameLighting();
  }

  static void onPlayerEvent(int event) {
    switch (event) {
      case PlayerEvent.Reloading:
        switch (GamePlayer.weapon.value){
          case ItemType.Weapon_Handgun_Glock:
            GameAudio.reload_6();
            break;
          default:
            GameAudio.reload_6();
        }
        break;
      case PlayerEvent.Level_Increased:
        print("onPlayerEvent_LevelIncreased()");
        GameAudio.buff_1();
        ClientActions.writeMessage("Level Gained");
        break;
      case PlayerEvent.Item_Consumed:
        onItemTypeConsumed(serverResponseReader.readUInt16());
        break;
      case PlayerEvent.Recipe_Crafted:
        GameAudio.unlock();
        break;
      case PlayerEvent.Spawn_Started:
        GameAudio.teleport();

        break;
      case PlayerEvent.Inventory_Item_Moved:
        GameAudio.switch_sounds_4();
        break;
      case PlayerEvent.Loot_Collected:
        return GameAudio.collect_star_3();
      case PlayerEvent.Scene_Changed:
        GameCamera.centerOnPlayer();
        // GameActions.setAmbientShadeToHour();
        break;
      case PlayerEvent.Quest_Started:
        onPlayerEventQuestStarted();
        break;
      case PlayerEvent.Quest_Completed:
        GameAudio.notification_sound_12();
        break;
      case PlayerEvent.Skill_Upgraded:
        // audio.unlock(GameState.player.x, GameState.player.y);
        break;
      case PlayerEvent.Item_Picked_Up:
        GameAudio.hoverOverButtonSound5();
        break;
      case PlayerEvent.Dash_Activated:
        // audio.buff11(GameState.player.x, GameState.player.y);
        break;
      case PlayerEvent.Item_Purchased:
        final itemType = serverResponseReader.readUInt16();
        GameAudio.coins_24();
        ClientActions.writeMessage('purchased ${ItemType.getName(itemType)}');
        break;

      case PlayerEvent.Ammo_Acquired:
        // audio.itemAcquired(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
        break;
      case PlayerEvent.Item_Equipped:
        final type = serverResponseReader.readByte();
        onPlayerEventItemEquipped(type);
        break;
      case PlayerEvent.Item_Dropped:
        GameAudio.popSounds14();
        break;
      case PlayerEvent.Item_Sold:
        GameAudio.coins_24();
        break;
      case PlayerEvent.Drink_Potion:
        // audio.bottle(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
        break;
      case PlayerEvent.Collect_Wood:
        // audio.coins(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
        break;
      case PlayerEvent.Collect_Rock:
        // audio.coins(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
        break;
      case PlayerEvent.Collect_Experience:
        // audio.collectStar3(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
        break;
      case PlayerEvent.Collect_Gold:
        // audio.coins(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
        break;
      case PlayerEvent.Hello_Male_01:
        GameAudio.male_hello.play();
        break;
      case PlayerEvent.GameObject_Deselected:
        GameEditor.gameObjectSelected.value = false;
        break;
      case PlayerEvent.Player_Moved:
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

  static void onItemTypeConsumed(int itemType) {
    if (ItemType.isFood(itemType)) {
      GameAudio.eat();
      return;
    }
  }

  static void onPlayerEventItemEquipped(int type) {
    switch (type) {
      case ItemType.Weapon_Handgun_Revolver:
        GameAudio.revolver_reload_1();
        break;
      case ItemType.Weapon_Handgun_Glock:
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
    // GameState.spawnParticleAnimation(
    //   type: Engine.randomItem(
    //       const [
    //         ParticleType.Character_Animation_Death_Zombie_1,
    //         ParticleType.Character_Animation_Death_Zombie_2,
    //         ParticleType.Character_Animation_Death_Zombie_3,
    //       ]
    //   ),
    //   x: x,
    //   y: y,
    //   z: z,
    //   angle: angle,
    // );
    angle += Engine.PI;
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
}