
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

  static void onChangedStoreVisible(bool storeVisible){
    // GameState.inventoryOpen.value = storeVisible;
  }

  static void onChangedAmbientShade(int shade) {
    GameState.ambientColor = GameState.colorShades[shade];
    GameState.refreshLighting();
    // GameState.torchesIgnited.value = shade != Shade.Very_Bright;
  }

  static void onChangedNodes(){
    GameState.refreshGridMetrics();
    GameState.gridWindResetToAmbient();

    if (GameState.raining.value) {
      GameActions.rainStart();
    }
    GameState.refreshLighting();
    GameEditor.refreshNodeSelectedIndex();
  }

  static void onFootstep(double x, double y, double z) {
    if (GameState.raining.value && (
        GameQueries.gridNodeXYZTypeSafe(x, y, z) == NodeType.Rain_Landing
            ||
            GameQueries.gridNodeXYZTypeSafe(x, y, z + 24) == NodeType.Rain_Landing
    )
    ){
      GameAudio.footstep_mud_6.playXYZ(x, y, z);
      final amount = GameState.rain.value == Rain.Heavy ? 3 : 2;
      for (var i = 0; i < amount; i++){
        GameState.spawnParticleWaterDrop(x: x, y: y, z: z);
      }
    }

    final nodeType = GameQueries.gridNodeXYZTypeSafe(x, y, z - 2);
    if (NodeType.isMaterialStone(nodeType)) {
      return GameAudio.footstep_stone.playXYZ(x, y, z);
    }
    if (NodeType.isMaterialWood(nodeType)) {
      return GameAudio.footstep_wood_4.playXYZ(x, y, z);
    }
    if (Engine.randomBool()){
      return GameAudio.footstep_grass_8.playXYZ(x, y, z);
    }
    return GameAudio.footstep_grass_7.playXYZ(x, y, z);
  }

  static void onGameEvent(int type, double x, double y, double z, double angle) {
    switch (type) {
      case GameEventType.Footstep:
        return GameEvents.onFootstep(x, y, z);
      case GameEventType.Attack_Performed:
        return onAttackPerformed(x, y, z, angle);
      case GameEventType.Player_Spawn_Started:
        GameCamera.centerOnPlayer();
        return GameAudio.teleport.playXYZ(x, y, z);
      case GameEventType.AI_Target_Acquired:
        final characterType = serverResponseReader.readByte();
        switch (characterType){
          case CharacterType.Zombie:
            Engine.randomItem(GameAudio.audioSingleZombieTalking).playXYZ(x, y, z);
            break;
        }
        break;
      case GameEventType.Node_Set:
        return onNodeSet(x, y, z);
      case GameEventType.Node_Struck:
        final nodeType = serverResponseReader.readByte();
        onNodeStruck(nodeType, x, y, z);
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
        return onSplash(x, y, z);
      case GameEventType.Spawn_Dust_Cloud:
        return GameActions.spawnDustCloud(x, y, z);
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
        final attackType = serverResponseReader.readByte();
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
        for (var i = 0; i < 8; i++) {
          GameState.spawnParticleOrbShard(
              x: x, y: y, z: z, duration: 30, speed: Engine.randomBetween(1, 2), angle: Engine.randomAngle());
        }
        GameState.spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
        break;

      case GameEventType.Character_Death:
        final characterType = serverResponseReader.readByte();
        return onCharacterDeath(characterType, x, y, z, angle);

      case GameEventType.Character_Hurt:
        final characterType = serverResponseReader.readByte();
        return onGameEventCharacterHurt(characterType, x, y, z, angle);

      case GameEventType.Game_Object_Destroyed:
        final type = serverResponseReader.readByte();
        return onGameEventGameObjectDestroyed(x, y, z, angle, type);
    }
  }

  static void onNodeSet(double x, double y, double z) {
    GameAudio.hover_over_button_sound_43.playXYZ(x, y, z);
  }

  static void onNodeStruck(int nodeType, double x, double y, double z) {

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

  static void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
    GameState.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
    GameAudio.swing_sword.playXYZ(x, y, z);
    GameState.spawnParticleBubbles(
      count: 3,
      x: x,
      y: y,
      z: z,
      angle: angle,
    );
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
    for (var i = 0; i < 8; i++){
      GameState.spawnParticleWaterDrop(x: x, y: y, z: z);
    }
    return GameAudio.splash.playXYZ(x, y, z);
  }

  static void onAttackPerformed(double x, double y, double z, double angle) {
    final attackType = serverResponseReader.readUInt16();
    switch (attackType){
      case ItemType.Weapon_Ranged_Handgun:
        GameAudio.pistol_shot_20.playXYZ(x, y, z);
        GameState.spawnParticleShell(x, y, z);
        break;
      case ItemType.Weapon_Ranged_Shotgun:
        return GameAudio.shotgun_shot.playXYZ(x, y, z);
      case ItemType.Weapon_Ranged_Assault_Rifle:
        return GameAudio.assault_rifle_shot.playXYZ(x, y, z);
      case ItemType.Weapon_Ranged_Rifle:
        return GameAudio.sniper_shot_4.playXYZ(x, y, z);
      case ItemType.Weapon_Ranged_Revolver:
        return GameAudio.revolver_shot_2.playXYZ(x, y, z);
      case ItemType.Weapon_Melee_Sword:
        return onGameEventAttackPerformedBlade(x, y, z, angle);
      case ItemType.Empty:
        return onAttackPerformedUnarmed(x, y, z, angle);
      case ItemType.Weapon_Melee_Crowbar:
        GameAudio.swing_sword.playXYZ(x, y, z);
        break;
      default:
        return;
    }
  }

  static void onChangedEdit(bool value) {
    if (value) {
      GameCamera.setModeFree();
      GameEditor.cursorSetToPlayer();
      GameState.player.message.value = "-press arrow keys to move\n\n-press tab to play";
      GameState.player.messageTimer = 300;
    } else {
      GameCamera.setModeChase();
      if (GameState.sceneEditable.value){
        GameState.player.message.value = "press tab to edit";
      }
    }
  }

  static void onChangedWind(Wind value) {
    GameState.gridWindResetToAmbient();
  }

  static void onChangedHour(int hour){
    GameState.torchesIgnited.value = Shade.fromHour(hour) != Shade.Very_Bright;
  }

  static void onChangedRain(Rain value) {
    GameState.raining.value = value != Rain.None;

    switch (value) {
      case Rain.None:
        break;
      case Rain.Light:
        GameState.srcXRainFalling = AtlasNode.Node_Rain_Falling_Light_X;
        GameState.srcXRainLanding = AtlasNode.Node_Rain_Landing_Light_X;
        break;
      case Rain.Heavy:
        GameState.srcXRainFalling = AtlasNode.Node_Rain_Falling_Heavy_X;
        GameState.srcXRainLanding = AtlasNode.Node_Rain_Landing_Heavy_X;
        break;
    }
  }

  static void onPlayerEvent(int event) {
    switch (event) {
      case PlayerEvent.Level_Increased:
        GameAudio.buff_1();
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
        GameAudio.coins_24();
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
        GameAudio.errorSound15();
        break;
      case PlayerEvent.Inventory_Full:
        GameAudio.errorSound15();
        break;
      case PlayerEvent.Invalid_Request:
        GameAudio.errorSound15();
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
      case ItemType.Weapon_Ranged_Revolver:
        GameAudio.revolver_reload_1();
        break;
      case ItemType.Weapon_Ranged_Handgun:
        GameAudio.reload_6();
        break;
      case ItemType.Weapon_Ranged_Shotgun:
        GameAudio.cock_shotgun_3();
        break;
      case ItemType.Weapon_Ranged_Rifle:
        GameAudio.mag_in_03();
        break;
      case ItemType.Weapon_Melee_Sword:
        GameAudio.sword_unsheathe();
        break;
      case ItemType.Weapon_Ranged_Assault_Rifle:
        GameAudio.gun_pickup_01();
        break;
      case ItemType.Weapon_Ranged_Bow:
        GameAudio.bow_draw();
        break;
    }
  }

  static void onCharacterDeath(int type, double x, double y, double z, double angle) {
    GameSpawn.spawnPurpleFireExplosion(x, y, z);
    GameSpawn.spawnBubbles(x, y, z);

    for (var i = 0; i < 4; i++){
      GameState.spawnParticleBlood(
        x: x,
        y: y,
        z: z,
        zv: Engine.randomBetween(1.5, 2),
        angle: angle + Engine.PI + Engine.randomGiveOrTake(Engine.PI_Quarter),
        speed: Engine.randomBetween(1.5, 2.5),
      );
    }

    switch (type) {
      case CharacterType.Zombie:
        return onCharacterDeathZombie(type, x, y, z, angle);
    }
  }

  static void onCharacterDeathZombie(int type, double x, double y, double z, double angle){
    GameState.spawnParticleAnimation(
      type: Engine.randomItem(
          const [
            ParticleType.Character_Animation_Death_Zombie_1,
            ParticleType.Character_Animation_Death_Zombie_2,
            ParticleType.Character_Animation_Death_Zombie_3,
          ]
      ),
      x: x,
      y: y,
      z: z,
      angle: angle,
    );
    angle += Engine.PI;
    final zPos = z + tileSizeHalf;
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
    GameState.triggerAlarmNoMessageReceivedFromServer.value = value > 200;
  }

  static void onChangedPlayerMessage(String value){
    if (value.isNotEmpty) {
      GameState.player.messageTimer = 200;
    } else {
      GameState.player.messageTimer = 0;
    }
  }

  static void onChangedInputMode(int inputMode){
    if (inputMode == InputMode.Touch){
      GameCamera.centerOnPlayer();
      GameIO.recenterCursor();
    }
  }

  static void onChangedPlayerInteractMode(int value) {
    GameAudio.click_sound_8(1);
    switch (value) {
      case InteractMode.Inventory:
        GameCamera.translateX = 200;
        break;
      case InteractMode.Talking:
        GameCamera.translateX = -200;
        break;
      case InteractMode.Trading:
        GameCamera.translateX = 0;
        break;
      case InteractMode.None:
        GameCamera.translateX = 0;
        ClientState.itemTypeHover.value = ItemType.Empty;
        GameUI.mouseOverDialogType.value = DialogType.None;
        break;
    }
  }

  static void onChangedPlayerStoreItems(List<int> values){
    if (values.isEmpty) {
       ServerState.interactMode.value = InteractMode.None;
    } else {
      ServerState.interactMode.value = InteractMode.Trading;
    }
  }
}