
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/lemon_websocket_client/connection_status.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricEvents with IsometricComponent {

  void onErrorFullscreenAuto(){
     // TODO show a dialog box asking the user to go fullscreen
  }

  void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case WeaponType.Shotgun:
        audio.playAudioXYZ(audio.cock_shotgun_3, x, y, z);
        break;
      default:
        break;
    }
  }

  void onNodesInitialized(){

  }

  void onChangedNodes(){
    scene.refreshGridMetrics();
    scene.generateHeightMap();
    scene.generateMiniMap();
    scene.refreshLightSources();
    scene.refreshSmokeSources();
    scene.refreshLightSources();
    minimap.generateSrcDst();

    rendererNodes.nodeColors = scene.nodeColors;
    rendererNodes.nodeOrientations = scene.nodeOrientations;

    if (environment.raining.value) {
      scene.rainStop();
      scene.rainStart();
    }
    scene.updateAmbientAlphaAccordingToTime();
    scene.resetNodeColorsToAmbient();
    editor.refreshNodeSelectedIndex();
    particles.children.clear();
  }

  void onFootstep(double x, double y, double z) {
    if (environment.raining.value && (
        scene.getTypeXYZSafe(x, y, z) == NodeType.Rain_Landing
            ||
        scene.getTypeXYZSafe(x, y, z + 24) == NodeType.Rain_Landing
    )
    ){

      audio.playAudioXYZ(audio.footstep_mud_6, x, y, z);

      final amount = environment.rainType.value == RainType.Heavy ? 3 : 2;
      for (var i = 0; i < amount; i++){
        particles.spawnParticleWaterDrop(x: x, y: y, z: z, zv: 1.5);
      }
    }

    final nodeType = scene.getTypeXYZSafe(x, y, z - 2);
    if (NodeType.isMaterialStone(nodeType)) {
      audio.playAudioXYZ(audio.footstep_stone, x, y, z);
      return;
    }
    if (NodeType.isMaterialWood(nodeType)) {
      audio.playAudioXYZ(audio.footstep_wood_4, x, y, z);
      return;
    }
    if (randomBool()){
      audio.playAudioXYZ(audio.footstep_grass_8, x, y, z);
      return;
    }
    audio.playAudioXYZ(audio.footstep_grass_7, x, y, z);
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
        audio.playAudioXYZ(audio.metal_light_3, x, y, z);
        return;
      case GameEventType.Material_Struck_Metal:
        audio.playAudioXYZ(audio.metal_struck, x, y, z);
        return;
      case GameEventType.Player_Spawn_Started:
        camera.centerOnChaseTarget();
        // audio.teleport.playXYZ(x, y, z);
        return;
      case GameEventType.Explosion:
        onGameEventExplosion(x, y, z);
        return;
      case GameEventType.AI_Target_Acquired:
        final characterType = network.responseReader.readByte();
        switch (characterType){
          case CharacterType.Zombie:
            audio.playAudioXYZ(randomItem(audio.audioSingleZombieTalking), x, y, z);
            break;
        }
        break;

      case GameEventType.Node_Set:
        onNodeSet(x, y, z);
        return;
      case GameEventType.GameObject_Timeout:
        particles.spawnBubbles(x, y, z);
        break;
      case GameEventType.Node_Struck:
        onNodeStruck(x, y, z);
        break;
      case GameEventType.Node_Deleted:
        audio.playAudioXYZ(audio.hover_over_button_sound_30, x, y, z);
        break;
      case GameEventType.Weapon_Type_Equipped:
        final attackType = network.responseReader.readByte();
        return onWeaponTypeEquipped(attackType, x, y, z);
      case GameEventType.Player_Spawned:
        for (var i = 0; i < 7; i++){
          particles.spawnParticleOrbShard(x: x, y: y, z: z, angle: randomAngle());
        }
        return;
      case GameEventType.Splash:
        onSplash(x, y, z);
        return;
      case GameEventType.Item_Bounce:
        audio.playAudioXYZ(audio.grenade_bounce, x, y, z);
        return;
      case GameEventType.Spawn_Dust_Cloud:
        break;
      case GameEventType.Player_Hit:
        if (randomBool()) {
          // audio.humanHurt(x, y);
        }
        break;
      case GameEventType.Zombie_Target_Acquired:
        audio.playAudioXYZ(randomItem(audio.audioSingleZombieTalking), x, y, z);
        break;
      case GameEventType.Character_Changing:
        audio.playAudioXYZ(audio.change_cloths, x, y, z);
        break;
      case GameEventType.Zombie_Strike:
        audio.playAudioXYZ(randomItem(audio.audioSingleZombieBits), x, y, z);
        if (randomBool()){
          audio.playAudioXYZ(randomItem(audio.audioSingleZombieTalking), x, y, z);
        }
        break;
      case GameEventType.Player_Death:
        break;
      case GameEventType.Teleported:
        audio.magical_impact_16();
        break;
      case GameEventType.Blue_Orb_Fired:
        audio.playAudioXYZ(audio.sci_fi_blaster_1, x, y, z);
        break;
      case GameEventType.Arrow_Hit:
        audio.playAudioXYZ(audio.arrow_impact, x, y, z);
        break;
      case GameEventType.Draw_Bow:
        audio.playAudioXYZ(audio.bow_draw, x, y, z);
        break;
      case GameEventType.Release_Bow:
        audio.playAudioXYZ(audio.bow_release, x, y, z);
        break;
      case GameEventType.Sword_Woosh:
        audio.playAudioXYZ(audio.swing_sword, x, y, z);
        break;
      case GameEventType.EnemyTargeted:
        break;
      case GameEventType.Attack_Missed:
        final attackType = network.responseReader.readUInt16();
        switch (attackType) {
          case WeaponType.Unarmed:
            audio.playAudioXYZ(audio.arm_swing_whoosh_11, x, y, z);
            break;
          case WeaponType.Sword:
            audio.playAudioXYZ(audio.arm_swing_whoosh_11, x, y, z);
            break;
        }
        break;
      case GameEventType.Arrow_Fired:
        audio.playAudioXYZ(audio.arrow_flying_past_6, x, y, z);
        break;
      case GameEventType.Crate_Breaking:
        // return audio.crateBreaking(x, y);
        break;

      case GameEventType.Blue_Orb_Deactivated:
        action.spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
        for (var i = 0; i < 8; i++) {
          particles.spawnParticleOrbShard(
              x: x, y: y, z: z, duration: 30, speed: randomBetween(1, 2), angle: randomAngle());
        }
        break;

      case GameEventType.Teleport_Start:
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
        }
        break;

      case GameEventType.Teleport_End:
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti_Blue);
        }
        break;

      case GameEventType.Character_Death:
        onCharacterDeath(network.responseReader.readByte(), x, y, z, angle);
        return;

      case GameEventType.Character_Hurt:
        onGameEventCharacterHurt(network.responseReader.readByte(), x, y, z, angle);
        return;

      case GameEventType.Game_Object_Destroyed:
        onGameEventGameObjectDestroyed(
            x,
            y,
            z,
            angle,
          network.responseReader.readUInt16(),
        );
        return;

      case GameEventType.Blink_Arrive:
        audio.playAudioXYZ(audio.sci_fi_blaster_1, x, y, z);
        particles.spawnParticleConfetti(x, y, z);
        break;

      case GameEventType.Blink_Depart:
        particles.spawnParticleConfetti(x, y, z);
        break;
    }
  }

  void onGameEventExplosion(double x, double y, double z) {
    action.createExplosion(x, y, z);
  }

  void onNodeSet(double x, double y, double z) {
    audio.playAudioXYZ(audio.hover_over_button_sound_43, x, y, z);
  }

  void onNodeStruck(double x, double y, double z) {
    if (!scene.inBoundsXYZ(x, y, z)) return;

    final nodeIndex = scene.getIndexXYZ(x, y, z);
    final nodeType = scene.nodeTypes[nodeIndex];

    if (NodeType.isMaterialWood(nodeType)){
      audio.playAudioXYZ(audio.material_struck_wood, x, y, z);
      particles.spawnParticleBlockWood(x, y, z);
    }

    if (NodeType.isMaterialGrass(nodeType)){
      audio.playAudioXYZ(audio.grass_cut, x, y, z);
      particles.spawnParticleBlockGrass(x, y, z);
    }

    if (NodeType.isMaterialStone(nodeType)){
      audio.playAudioXYZ(audio.material_struck_stone, x, y, z);
      particles.spawnParticleBlockBrick(x, y, z);
    }

    if (NodeType.isMaterialDirt(nodeType)){
      audio.playAudioXYZ(audio.material_struck_dirt, x, y, z);
      particles.spawnParticleBlockSand(x, y, z);
    }
  }

  void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
    audio.playAudioXYZ(audio.swing_sword, x, y, z);
  }

  void onAttackPerformedUnarmed(double x, double y, double z, double angle) {
    particles.spawnParticleBubbles(
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
      particles.spawnParticleWaterDrop(x: x, y: y, z: z, zv: zv, duration: (zv * 12).toInt());
    }
    audio.playAudioXYZ(audio.splash, x, y, z);
  }

  void onAttackPerformed(double x, double y, double z, double angle) {
    final attackType = network.responseReader.readUInt16();
    final attackTypeAudio = audio.MapItemTypeAudioSinglesAttack[attackType];

    if (attackTypeAudio != null) {
      audio.playAudioXYZ(attackTypeAudio, x, y, z);
    }

    if (attackType == WeaponType.Unarmed){
      particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == WeaponType.Melee){
      particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (WeaponType.isMelee(attackType)) {
      particles.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    if (attackType == WeaponType.Flame_Thrower) return;

    const gun_distance = 50.0;
    final gunX = x - adj(angle, gun_distance);
    final gunY = y - opp(angle, gun_distance);

    if (WeaponType.isFirearm(attackType)){
      particles.emitSmoke(x: gunX, y: gunY, z: z, scale: 0.1, scaleV: 0.006, duration: 50);
      particles.spawnParticleShell(gunX, gunY, z);
    }
    if (WeaponType.Firearms_Automatic.contains(attackType)){
      particles.spawnParticleStrikeBulletLight(x: x, y: y, z: z, angle: angle);
      return;
    }
    particles.spawnParticleStrikeBullet(x: x, y: y, z: z, angle: angle);
  }

  void onMeleeAttackPerformed(double x, double y, double z, double angle) {
    final attackType = network.responseReader.readUInt16();
    final attackTypeAudio = audio.MapItemTypeAudioSinglesAttackMelee[attackType];

    if (attackTypeAudio != null) {
      audio.playAudioXYZ(attackTypeAudio, x, y, z);
    }

    if (attackType == WeaponType.Unarmed){
      particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (attackType == WeaponType.Knife){
      particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
      return;
    }
    if (WeaponType.isMelee(attackType)) {
      particles.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
      return;
    }

    particles.spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
    return;
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
        action.writeMessage('Level Gained');
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
        if (options.gameType.value == GameType.Editor){
          editor.row = player.indexRow;
          editor.column = player.indexColumn;
          editor.z = player.indexZ;
        }
        camera.centerOnChaseTarget();
        io.recenterCursor();
        break;
      case PlayerEvent.Insufficient_Gold:
        action.writeMessage('Not Enough Gold');
        break;
      case PlayerEvent.Inventory_Full:
        action.writeMessage('Inventory Full');
        break;
      case PlayerEvent.Invalid_Request:
        action.writeMessage('Invalid Request');
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
    audio.playAudioXYZ(randomItem(audio.bloody_punches), x, y, z);
    audio.playAudioXYZ(audio.heavy_punch_13, x, y, z);

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
      case CharacterType.Zombie:
        return onCharacterDeathZombie(characterType, x, y, z, angle);
      case CharacterType.Dog:
        audio.playAudioXYZ(audio.dog_woolf_howl_4, x, y, z);
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

    audio.playAudioXYZ(randomItem(audio.zombie_deaths), x, y, z);
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
    final itemType = network.responseReader.readUInt16();
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

    audio.playAudioXYZ(randomItem(audio.bloody_punches), x, y, z);
    audio.playAudioXYZ(audio.heavy_punch_13, x, y, z);

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
      case CharacterType.Zombie:
        if (randomBool()){
          audio.playAudioXYZ(audio.zombie_hurt_1, x, y, z);
        } else {
          audio.playAudioXYZ(audio.zombie_hurt_4, x, y, z);
        }
        break;
      case CharacterType.Rat:
        audio.playAudioXYZ(audio.rat_squeak, x, y, z);
        break;
      case CharacterType.Slime:
        audio.playAudioXYZ(audio.bloody_punches_3, x, y, z);
        break;
      case CharacterType.Dog:
        audio.playAudioXYZ(audio.dog_woolf_howl_4, x, y, z);
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
        audio.playAudioXYZ(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleBlockWood(x, y, z);
        }
        break;
      case ObjectType.Toilet:
        audio.playAudioXYZ(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleBlockWood(x, y, z);
        }
        break;
      case ObjectType.Crate_Wooden:
        audio.playAudioXYZ(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleBlockWood(x, y, z);
        }
        break;

      case ObjectType.Credits:
        for (var i = 0; i < 8; i++){
          particles.spawnParticleConfettiByType(
            x,
            y,
            z,
            ParticleType.Confetti_Cyan,
          );
        }
    }
  }

  void onChangedNetworkConnectionStatus(ConnectionStatus connection) {
    print('isometric.onChangedNetworkConnectionStatus($connection)');
    network.responseReader.bufferSize.value = 0;

    switch (connection) {
      case ConnectionStatus.Connected:
        engine.cursorType.value = CursorType.None;
        engine.zoomOnScroll = true;
        engine.zoom = 1.0;
        engine.targetZoom = 1.0;
        audio.enabledSound.value = true;
        if (!engine.isLocalHost) {
          engine.fullScreenEnter();
        }
        break;

      case ConnectionStatus.Done:
        engine.cameraX = 0;
        engine.cameraY = 0;
        engine.zoom = 1.0;
        engine.drawCanvasAfterUpdate = true;
        engine.cursorType.value = CursorType.Basic;
        engine.fullScreenExit();
        player.active.value = false;
        action.clear();
        action.clean();
        scene.gameObjects.clear();
        scene.sceneEditable.value = false;
        options.gameType.value = GameType.Website;
        audio.enabledSound.value = false;
        break;
      case ConnectionStatus.Failed_To_Connect:
        website.error.value = 'Failed to connect';
        break;
      case ConnectionStatus.Invalid_Connection:
        website.error.value = 'Invalid Connection';
        break;
      case ConnectionStatus.Error:
        website.error.value = 'Connection Error';
        break;
      default:
        break;
    }
  }

  @override
  Future initializeComponent(sharedPreferences) async {
    network.websocket.connectionStatus.onChanged(
        onChangedNetworkConnectionStatus
    );
  }
}