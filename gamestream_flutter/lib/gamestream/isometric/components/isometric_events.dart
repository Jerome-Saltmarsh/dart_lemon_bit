
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/node_type_material.dart';
import 'package:gamestream_flutter/packages/lemon_websocket_client.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_math/src.dart';

class IsometricEvents with IsometricComponent {

  void onErrorFullscreenAuto(){
     // TODO show a dialog box asking the user to go fullscreen
  }

  void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case WeaponType.Sword:
        audio.play(audio.sword_unsheathe, x, y, z);
      case WeaponType.Bow:
        audio.play(audio.bow_draw, x, y, z);
        break;
      default:
        break;
    }
  }

  void onChangedNodes(){
    scene.onChangedNodes();
    minimap.generateSrcDst();
    editor.refreshNodeSelectedIndex();
  }

  // TODO optimize
  void onFootstep(double x, double y, double z) {
    if (environment.raining.value && (
        scene.getTypeXYZSafe(x, y, z) == NodeType.Rain_Landing
            ||
        scene.getTypeXYZSafe(x, y, z + 24) == NodeType.Rain_Landing
    )
    ){
      audio.play(audio.footstep_mud_6, x, y, z, volume: 0.5);
      final amount = environment.rainType.value == RainType.Heavy ? 3 : 2;
      final particles = this.particles;
      for (var i = 0; i < amount; i++){
        particles.spawnParticleWaterDrop(x: x, y: y, z: z, zv: 1.5);
      }
    }

    final nodeType = scene.getTypeXYZSafe(x, y, z - 2);
    final nodeMaterial = nodeTypeMaterial[nodeType];

    if (nodeMaterial == null){
       return;
    }

    switch (nodeMaterial){
      case MaterialType.Grass:
        audio.play(
            randomBool() ? audio.footstep_grass_7 : audio.footstep_grass_8,
            x,
            y,
            z,
            volume: 0.25,
        );
        break;
      case MaterialType.Stone:
        audio.play(audio.footstep_stone, x, y, z, volume: 0.3);
        break;
      case MaterialType.Wood:
        audio.play(audio.footstep_wood_4, x, y, z, volume: 0.3);
        break;
    }
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
        audio.play(audio.metal_light_3, x, y, z);
        return;
      case GameEventType.Material_Struck:
        onMaterialStruck(x, y, z, parser.readByte());
        return;
      case GameEventType.Player_Spawn_Started:
        camera.centerOnChaseTarget();
        return;
      case GameEventType.Explosion:
        onGameEventExplosion(x, y, z);
        return;
      case GameEventType.AI_Target_Acquired:
        final characterType = network.parser.readByte();
        switch (characterType){
          case CharacterType.Fallen:
            audio.play(randomItem(audio.audioSingleZombieTalking), x, y, z);
            break;
        }
        break;

      case GameEventType.Node_Set:
        onNodeSet(x, y, z);
        return;
      case GameEventType.GameObject_Timeout:
        break;
      case GameEventType.Node_Struck:
        onNodeStruck(x, y, z);
        break;
      case GameEventType.GameObject_Spawned:
        final type = parser.readByte();
        final subType = parser.readByte();
        onGameObjectSpawned(x: x, y: y, z: z, type: type, subType: subType);
        break;
      case GameEventType.Amulet_GameObject_Spawned:
        final type = parser.readByte();
        final subType = parser.readByte();
        onGameObjectSpawned(x: x, y: y, z: z, type: type, subType: subType);
        break;
      case GameEventType.Node_Deleted:
        audio.play(audio.hover_over_button_sound_30, x, y, z);
        break;
      case GameEventType.Weapon_Type_Equipped:
        final weaponType = (angle * radiansToDegrees).toInt();
        return onWeaponTypeEquipped(weaponType, x, y, z);
      case GameEventType.Player_Spawned:
        return;
      case GameEventType.Splash:
        onSplash(x, y, z);
        return;
      case GameEventType.Item_Bounce:
        audio.play(audio.grenade_bounce, x, y, z);
        return;
      case GameEventType.Spawn_Dust_Cloud:
        break;
      case GameEventType.Player_Hit:
        if (randomBool()) {
          // audio.humanHurt(x, y);
        }
        break;
      case GameEventType.Zombie_Target_Acquired:
        audio.play(randomItem(audio.audioSingleZombieTalking), x, y, z);
        break;
      case GameEventType.Character_Changing:
        audio.play(audio.change_cloths, x, y, z);
        break;
      case GameEventType.Zombie_Strike:
        audio.play(randomItem(audio.audioSingleZombieBits), x, y, z);
        if (randomBool()){
          audio.play(randomItem(audio.audioSingleZombieTalking), x, y, z);
        }
        break;
      case GameEventType.Player_Death:
        break;
      case GameEventType.Teleported:
        audio.magical_impact_16();
        break;
      case GameEventType.Blue_Orb_Fired:
        audio.play(audio.sci_fi_blaster_1, x, y, z);
        break;
      case GameEventType.Arrow_Hit:
        audio.play(audio.arrow_impact, x, y, z);
        break;
      case GameEventType.Spawn_Confetti:
        final particles = this.particles;
        for (var i = 0; i < 6; i++){
          particles.spawnParticleConfettiByType(
            x,
            y,
            z,
            ParticleType.Confetti,
          );
        }
        break;
      case GameEventType.Draw_Bow:
        audio.play(audio.bow_draw, x, y, z);
        break;
      case GameEventType.Release_Bow:
        audio.play(audio.bow_release, x, y, z);
        break;
      case GameEventType.Sword_Woosh:
        audio.play(audio.swing_sword, x, y, z);
        break;
      case GameEventType.EnemyTargeted:
        break;
      case GameEventType.Attack_Missed:
        final attackType = network.parser.readUInt16();
        switch (attackType) {
          case WeaponType.Unarmed:
            audio.play(audio.arm_swing_whoosh_11, x, y, z);
            break;
          case WeaponType.Sword:
            audio.play(audio.arm_swing_whoosh_11, x, y, z);
            break;
        }
        break;
      case GameEventType.Arrow_Fired:
        audio.play(audio.arrow_flying_past_6, x, y, z);
        break;
      case GameEventType.Crate_Breaking:
        // return audio.crateBreaking(x, y);
        break;
      case GameEventType.Teleport_Start:
        final spawnConfetti = particles.spawnParticleConfettiByType;
        for (var i = 0; i < 5; i++) {
          spawnConfetti(x, y, z, ParticleType.Confetti);
        }
        audio.play(audio.magical_swoosh_18, x, y, z);
        break;

      case GameEventType.Teleport_End:
        final particles = this.particles;
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti);
        }
        audio.play(audio.magical_swoosh_18, x, y, z);
        break;

      case GameEventType.Character_Death:
        onCharacterDeath(network.parser.readByte(), x, y, z, angle);
        return;

      case GameEventType.Character_Hurt:
        onGameEventCharacterHurt(network.parser.readByte(), x, y, z, angle);
        return;

      case GameEventType.Game_Object_Destroyed:
        onGameEventGameObjectDestroyed(
            x,
            y,
            z,
            angle,
          network.parser.readUInt16(),
        );
        return;

      case GameEventType.Blink_Arrive:
        audio.play(audio.sci_fi_blaster_1, x, y, z);
        particles.spawnParticleConfetti(x, y, z);
        break;

      case GameEventType.Blink_Depart:
        audio.play(audio.dagger_woosh_9, x, y, z);
        particles.spawnParticleConfetti(x, y, z);
        break;

      case GameEventType.Bow_Drawn:
        audio.play(audio.bow_draw, x, y, z);
        break;

      case GameEventType.Bow_Released:
        audio.play(audio.bow_release, x, y, z);
        break;

      case GameEventType.Lightning_Bolt:
        particles.spawnLightningBolt(x, y, z);
        audio.play(audio.thunder, x, y, z);
        break;

      case GameEventType.Spell_Used:
        final spellType = parser.readByte();
        switch (spellType){
          case SpellType.Heal:
            audio.buff_1.play();
            particles.spawnParticleConfetti(x, y, z);
            break;
          case SpellType.Blink:
            audio.dagger_woosh_9.play();
            particles.spawnParticleConfetti(x, y, z);
            break;
        }
        break;
    }
  }

  void onMaterialStruck(double x, double y, double z, int materialType) {
    switch (materialType){
      case MaterialType.Glass:
        audio.play(audio.material_struck_glass, x, y, z);
        break;
      case MaterialType.Metal:
        audio.play(audio.material_struck_metal, x, y, z);
        break;
      case MaterialType.Flesh:
        audio.play(audio.material_struck_flesh, x, y, z);
        break;
      case MaterialType.Stone:
        audio.play(audio.material_struck_stone, x, y, z);
        particles.spawnParticleBlockBrick(x, y, z);
        break;
      case MaterialType.Dirt:
        audio.play(audio.material_struck_dirt, x, y, z);
        particles.spawnParticleBlockSand(x, y, z);
        break;
      case MaterialType.Wood:
        audio.play(audio.material_struck_wood, x, y, z);
        particles.spawnParticleBlockWood(x, y, z);
        break;
      case MaterialType.Grass:
        audio.play(audio.grass_cut, x, y, z);
        particles.spawnParticleBlockGrass(x, y, z);
        break;
    }
  }

  void onGameEventExplosion(double x, double y, double z) {
    actions.createExplosion(x, y, z);
  }

  void onNodeSet(double x, double y, double z) {
    audio.play(audio.hover_over_button_sound_43, x, y, z);
  }

  void onNodeStruck(double x, double y, double z) {
    if (!scene.inBoundsXYZ(x, y, z)) return;

    final nodeIndex = scene.getIndexXYZ(x, y, z);
    final nodeType = scene.nodeTypes[nodeIndex];
    final materialType = nodeTypeMaterial[nodeType];

    if (materialType != null){
      onMaterialStruck(x, y, z, materialType);
    }
  }

  void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
    audio.play(audio.swing_sword, x, y, z);
  }

  void onSplash(double x, double y, double z) {
    for (var i = 0; i < 12; i++){
      final zv = randomBetween(1.5, 5);
      particles.spawnParticleWaterDrop(x: x, y: y, z: z, zv: zv, duration: (zv * 12).toInt());
    }
    audio.play(audio.splash, x, y, z);
  }

  void onAttackPerformed(double x, double y, double z, double angle) {
    final attackType = network.parser.readUInt16();
    final attackTypeAudio = audio.MapItemTypeAudioSinglesAttack[attackType];

    if (attackTypeAudio != null) {
      audio.play(attackTypeAudio, x, y, z);
    }
  }

  void onMeleeAttackPerformed(double x, double y, double z, double angle) {
    final attackType = network.parser.readUInt16();
    final attackTypeAudio = audio.MapItemTypeAudioSinglesAttackMelee[attackType];

    if (attackTypeAudio != null) {
      audio.play(attackTypeAudio, x, y, z);
    }
    return;
  }

  void onPlayerEvent(int event) {
    switch (event) {
      case PlayerEvent.Spawned:
        camera.centerOnChaseTarget();
        io.recenterCursor();
        break;
      case PlayerEvent.Puzzle_Solved:
        audio.notification_sound_10.play();
        break;
      case PlayerEvent.Reloading:
        switch (player.weaponType.value){
          default:
            audio.reload_6();
        }
        break;
      case PlayerEvent.Teleported:
        audio.magical_swoosh_18();
        break;
      case PlayerEvent.Level_Increased:
        audio.buff_1();
        actions.writeMessage('Level Gained');
        break;
      case PlayerEvent.Item_Consumed:
        final consumableType = parser.readByte();
        onItemConsumed(consumableType);
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
        // camera.centerOnChaseTarget();
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
        print('PlayerEvent.Player_Moved');
        if (options.editing){
          editor.row = player.indexRow;
          editor.column = player.indexColumn;
          editor.z = player.indexZ;
        }
        options.setCameraPositionToPlayer();
        camera.centerOnChaseTarget();
        io.recenterCursor();
        break;
      case PlayerEvent.Insufficient_Gold:
        actions.writeMessage('Not Enough Gold');
        break;
      case PlayerEvent.Inventory_Full:
        actions.writeMessage('Inventory Full');
        break;
      case PlayerEvent.Invalid_Request:
        actions.writeMessage('Invalid Request');
        break;
      case PlayerEvent.Character_State_Changing:
        audio.change_cloths();
        break;
      case PlayerEvent.Talent_Upgraded:
        audio.collect_star_3();
        break;
      case PlayerEvent.Game_Joined:
        onGameJoined();
        break;
    }
  }

  void onCharacterDeath(int characterType, double x, double y, double z, double angle) {
    audio.play(randomItem(audio.bloody_punches), x, y, z);
    audio.play(audio.heavy_punch_13, x, y, z);

    for (var i = 0; i < 4; i++){
      particles.spawnBlood(
        x: x,
        y: y,
        z: z,
        angle: angle + giveOrTake(piQuarter),
        speed: randomBetween(1.5, 2.5),
      );
    }

    switch (characterType) {
      case CharacterType.Fallen:
        return onCharacterDeathZombie(characterType, x, y, z, angle);
      // case CharacterType.Dog:
      //   audio.play(audio.dog_woolf_howl_4, x, y, z);
      //   break;
    }
  }

  void onCharacterDeathZombie(int type, double x, double y, double z, double angle){
    audio.play(randomItem(audio.zombie_deaths), x, y, z);
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
      case WeaponType.Revolver:
        audio.revolver_reload_1();
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
    final itemType = network.parser.readUInt16();
    // todo read subtype
    if (itemType == WeaponType.Unarmed) return;

    switch (itemType) {
      case WeaponType.Revolver:
        audio.revolver_reload_1();
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

    audio.play(randomItem(audio.bloody_punches), x, y, z);
    audio.play(audio.heavy_punch_13, x, y, z);

    for (var i = 0; i < 4; i++){
      particles.spawnBlood(
        x: x,
        y: y,
        z: z,
        angle: angle + giveOrTake(piQuarter),
        speed: randomBetween(1.5, 2.5),
      );
    }


    switch (type) {
      case CharacterType.Fallen:
        if (randomBool()){
          audio.play(audio.zombie_hurt_1, x, y, z);
        } else {
          audio.play(audio.zombie_hurt_4, x, y, z);
        }
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
      case GameObjectType.Barrel:
        audio.play(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleBlockWood(x, y, z);
        }
        break;
      case GameObjectType.Toilet:
        audio.play(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleBlockWood(x, y, z);
        }
        break;
      case GameObjectType.Crate_Wooden:
        audio.play(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleBlockWood(x, y, z);
        }
        break;

      case GameObjectType.Credits:
        break;
    }
  }

  void onChangedNetworkConnectionStatus(ConnectionStatus connection) {
    print('isometric.onChangedNetworkConnectionStatus($connection)');
    network.parser.bufferSize.value = 0;
    amulet.onChangedNetworkConnectionStatus(connection);
    io.reset();

    switch (connection) {
      case ConnectionStatus.Connected:
        onConnected();
        break;

      case ConnectionStatus.Done:
        onConnectionDone();
        break;
      case ConnectionStatus.Failed_To_Connect:
        ui.error.value = 'Failed to connect';
        break;
      case ConnectionStatus.Invalid_Connection:
        ui.error.value = 'Invalid Connection';
        break;
      case ConnectionStatus.Error:
        ui.error.value = 'Connection Error';
        options.game.value = options.website;
        break;
      default:
        break;
    }
  }

  void onConnectionDone() {
    options.game.value = options.website;
    engine.cameraX = 0;
    engine.cameraY = 0;
    engine.zoom = 1.0;
    engine.drawCanvasAfterUpdate = true;
    engine.cursorType.value = CursorType.Basic;
    engine.fullScreenExit();
    player.active.value = false;
    actions.clear();
    actions.clean();
    scene.gameObjects.clear();
    scene.editEnabled.value = false;
    audio.enabledSound.value = false;
  }

  void onConnected() {
    options.game.value = options.amulet;
    options.setModePlay();
    options.activateCameraPlay();
    engine.zoomOnScroll = true;
    engine.zoom = 1.0;
    engine.targetZoom = 1.0;
    audio.enabledSound.value = true;
    camera.target = options.cameraPlay;
    if (!engine.isLocalHost) {
      engine.fullScreenEnter();
    }
  }

  @override
  Future onComponentInit(sharedPreferences) async {
    network.websocket.connectionStatus.onChanged(
        onChangedNetworkConnectionStatus
    );
  }

  void onItemConsumed(int consumableType) {
    audio.drink.play();
  }

  void onGameJoined() {
    camera.centerOnPlayer();
  }

  void onGameObjectSpawned({
    required double x,
    required double y,
    required double z,
    required int type,
    required int subType,
  }) {
    audio.play(audio.change_cloths, x, y, z);
  }
}