
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/packages/common.dart';
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

  void onFootstep(double x, double y, double z) {
    if (environment.raining.value && (
        scene.getTypeXYZSafe(x, y, z) == NodeType.Rain_Landing
            ||
        scene.getTypeXYZSafe(x, y, z + 24) == NodeType.Rain_Landing
    )
    ){

      audio.play(audio.footstep_mud_6, x, y, z);

      final amount = environment.rainType.value == RainType.Heavy ? 3 : 2;
      for (var i = 0; i < amount; i++){
        particles.spawnParticleWaterDrop(x: x, y: y, z: z, zv: 1.5);
      }
    }

    final nodeType = scene.getTypeXYZSafe(x, y, z - 2);
    if (NodeType.isMaterialStone(nodeType)) {
      audio.play(audio.footstep_stone, x, y, z);
      return;
    }
    if (NodeType.isMaterialWood(nodeType)) {
      audio.play(audio.footstep_wood_4, x, y, z);
      return;
    }
    if (randomBool()){
      audio.play(audio.footstep_grass_8, x, y, z);
      return;
    }
    audio.play(audio.footstep_grass_7, x, y, z);
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
      case GameEventType.Material_Struck_Metal:
        audio.play(audio.metal_struck, x, y, z);
        return;
      case GameEventType.Player_Spawn_Started:
        camera.centerOnChaseTarget();
        // audio.teleport.playXYZ(x, y, z);
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
        particles.spawnBubbles(x, y, z);
        break;
      case GameEventType.Node_Struck:
        onNodeStruck(x, y, z);
        break;
      case GameEventType.Node_Deleted:
        audio.play(audio.hover_over_button_sound_30, x, y, z);
        break;
      case GameEventType.Weapon_Type_Equipped:
        final weaponType = (angle * radiansToDegrees).toInt();
        return onWeaponTypeEquipped(weaponType, x, y, z);
      case GameEventType.Player_Spawned:
        for (var i = 0; i < 7; i++){
          particles.spawnParticleOrbShard(x: x, y: y, z: z, angle: randomAngle());
        }
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

      case GameEventType.Blue_Orb_Deactivated:
        actions.spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
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

    if (NodeType.isMaterialWood(nodeType)){
      audio.play(audio.material_struck_wood, x, y, z);
      particles.spawnParticleBlockWood(x, y, z);
    }

    if (NodeType.isMaterialGrass(nodeType)){
      audio.play(audio.grass_cut, x, y, z);
      particles.spawnParticleBlockGrass(x, y, z);
    }

    if (NodeType.isMaterialStone(nodeType)){
      audio.play(audio.material_struck_stone, x, y, z);
      particles.spawnParticleBlockBrick(x, y, z);
    }

    if (NodeType.isMaterialDirt(nodeType)){
      audio.play(audio.material_struck_dirt, x, y, z);
      particles.spawnParticleBlockSand(x, y, z);
    }
  }

  void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
    audio.play(audio.swing_sword, x, y, z);
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
    audio.play(audio.splash, x, y, z);
  }

  void onAttackPerformed(double x, double y, double z, double angle) {
    final attackType = network.parser.readUInt16();
    final attackTypeAudio = audio.MapItemTypeAudioSinglesAttack[attackType];

    if (attackTypeAudio != null) {
      audio.play(attackTypeAudio, x, y, z);
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

    particles.spawnParticleStrikeBullet(x: x, y: y, z: z, angle: angle);
  }

  void onMeleeAttackPerformed(double x, double y, double z, double angle) {
    final attackType = network.parser.readUInt16();
    final attackTypeAudio = audio.MapItemTypeAudioSinglesAttackMelee[attackType];

    if (attackTypeAudio != null) {
      audio.play(attackTypeAudio, x, y, z);
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
        print('PlayerEvent.Player_Moved');
        if (options.gameType.value == GameType.Editor){
          editor.row = player.indexRow;
          editor.column = player.indexColumn;
          editor.z = player.indexZ;
        }
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
      case ObjectType.Barrel:
        audio.play(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleBlockWood(x, y, z);
        }
        break;
      case ObjectType.Toilet:
        audio.play(audio.crate_breaking, x, y, z);
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleBlockWood(x, y, z);
        }
        break;
      case ObjectType.Crate_Wooden:
        audio.play(audio.crate_breaking, x, y, z);
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
    network.parser.bufferSize.value = 0;


    amulet.onChangedNetworkConnectionStatus(connection);

    switch (connection) {
      case ConnectionStatus.Connected:
        engine.zoomOnScroll = true;
        engine.zoom = 1.0;
        engine.targetZoom = 1.0;
        audio.enabledSound.value = true;
        options.edit.value = false;
        actions.cameraPlayerTargetPlayer();
        camera.target = options.cameraPlay;
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
        actions.clear();
        actions.clean();
        scene.gameObjects.clear();
        scene.editEnabled.value = false;
        options.gameType.value = GameType.Website;
        audio.enabledSound.value = false;
        break;
      case ConnectionStatus.Failed_To_Connect:
        ui.error.value = 'Failed to connect';
        break;
      case ConnectionStatus.Invalid_Connection:
        ui.error.value = 'Invalid Connection';
        break;
      case ConnectionStatus.Error:
        ui.error.value = 'Connection Error';
        break;
      default:
        break;
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
}