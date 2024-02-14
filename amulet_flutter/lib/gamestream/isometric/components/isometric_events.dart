
import 'dart:async';

import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:lemon_math/src.dart';

class IsometricEvents with IsometricComponent {

  void onErrorFullscreenAuto(){
     // TODO show a dialog box asking the user to go fullscreen
  }

  void onWeaponTypeEquipped(int attackType, double x, double y, double z) {
    switch (attackType) {
      case WeaponType.Shortsword:
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
            volume: 0.1,
        );
        break;
      case MaterialType.Stone:
        audio.play(audio.footstep_stone, x, y, z, volume: 0.1);
        break;
      case MaterialType.Wood:
        audio.play(audio.footstep_wood_4, x, y, z, volume: 0.1);
        break;
    }
  }

  void onGameEvent(int gameEvent, double x, double y, double z) {
    switch (gameEvent) {
      case GameEvent.Footstep:
        onFootstep(x, y, z);
        return;
      case GameEvent.Projectile_Fired:
        final projectileType = parser.readByte();
        onProjectileFired(projectileType, x, y, z);
        return;
      case GameEvent.Bullet_Deactivated:
        audio.play(audio.metal_light_3, x, y, z);
        return;
      case GameEvent.Health_Regained:
        particles.spawnParticleHealth(x, y, z);
        break;
      case GameEvent.Magic_Regained:
        particles.spawnParticleMagic(x, y, z);
        break;
      case GameEvent.Shrine_Used:
        particles.spawnParticleMagic(x, y, z);
        particles.spawnParticleHealth(x, y, z);
        audio.notification_sound_10();
        break;
      case GameEvent.Material_Struck:
        onMaterialStruck(x, y, z, parser.readByte());
        return;
      case GameEvent.Explosion:
        onGameEventExplosion(x, y, z);
        return;
      case GameEvent.Melee_Attack_Performed:
        audio.play(audio.swing_arm_11, x, y, z);
        return;
      case GameEvent.AI_Target_Acquired:
        final characterType = parser.readByte();
        switch (characterType){
          case CharacterType.Fallen:
            audio.play(randomItem(audio.audioSingleZombieTalking), x, y, z);
            break;
          case CharacterType.Wolf:
            audio.play(audio.dog_woolf_howl_4, x, y, z);
            break;
          case CharacterType.Gargoyle_01:
            audio.play(audio.growl10, x, y, z);
            break;
        }
        break;
      case GameEvent.Node_Struck:
        onNodeStruck(x, y, z);
        break;
      case GameEvent.Character_Vanished:
        particles.emitFlames(
          x: x,
          y: y,
          z: z,
          count: 8,
          radius: 10,
        );
        break;
      case GameEvent.Amulet_GameObject_Spawned:
        final type = parser.readByte();
        final subType = parser.readByte();
        onGameObjectSpawned(x: x, y: y, z: z, type: type, subType: subType);
        break;
      case GameEvent.Weapon_Type_Equipped:
        final weaponType = parser.readByte();
        return onWeaponTypeEquipped(weaponType, x, y, z);
      case GameEvent.Splash:
        onSplash(x, y, z);
        return;
      case GameEvent.Item_Bounce:
        return;
      case GameEvent.Character_Changing:
        audio.play(audio.change_cloths, x, y, z);
        break;
      case GameEvent.Blue_Orb_Fired:
        audio.play(audio.sci_fi_blaster_1, x, y, z);
        break;
      case GameEvent.Arrow_Hit:
        audio.play(audio.arrow_impact, x, y, z);
        break;
      case GameEvent.Spawn_Confetti:
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
      case GameEvent.Attack_Missed:
        final attackType = parser.readUInt16();
        switch (attackType) {
          case WeaponType.Unarmed:
            audio.play(audio.arm_swing_whoosh_11, x, y, z);
            break;
          case WeaponType.Shortsword:
            audio.play(audio.arm_swing_whoosh_11, x, y, z);
            break;
        }
        break;
      case GameEvent.Teleport_Start:
        final spawnConfetti = particles.spawnParticleConfettiByType;
        for (var i = 0; i < 5; i++) {
          spawnConfetti(x, y, z, ParticleType.Confetti);
        }
        audio.play(audio.magical_swoosh_18, x, y, z);
        break;

      case GameEvent.Teleport_End:
        final particles = this.particles;
        for (var i = 0; i < 5; i++) {
          particles.spawnParticleConfettiByType(x, y, z, ParticleType.Confetti);
        }
        audio.play(audio.magical_swoosh_18, x, y, z);
        break;

      case GameEvent.Character_Death:
        final angle = parser.readAngle();
        final characterType = parser.readByte();
        onCharacterDeath(characterType, x, y, z, angle);
        return;

      case GameEvent.Character_Hurt:
        final angle = parser.readAngle();
        final characterType = parser.readByte();
        onGameEventCharacterHurt(characterType, x, y, z, angle);
        return;

      case GameEvent.Game_Object_Destroyed:
        onGameEventGameObjectDestroyed(
            x,
            y,
            z,
            parser.readUInt16(),
        );
        return;

      case GameEvent.Blink_Arrive:
        audio.play(audio.sci_fi_blaster_1, x, y, z);
        particles.spawnParticleConfetti(x, y, z);
        break;

      case GameEvent.Blink_Depart:
        audio.play(audio.dagger_woosh_9, x, y, z);
        particles.spawnParticleConfetti(x, y, z);
        break;

      case GameEvent.Bow_Drawn:
        audio.play(audio.bow_draw, x, y, z);
        break;

      case GameEvent.Bow_Released:
        audio.play(audio.bow_release, x, y, z);
        break;

      case GameEvent.Lightning_Bolt:
        particles.spawnLightningBolt(x, y, z);
        audio.play(audio.thunder, x, y, z);
        break;

      case GameEvent.Character_Healed:
        audio.buff_1.play();
        for (var i = 0; i < 6; i++) {
          particles.emitWater(
            x: x + giveOrTake(10),
            y: y + giveOrTake(10),
            z: z,
          );
        }
        break;

      case GameEvent.Character_Caste_Healed:
        audio.buff_1.play();
        for (var i = 0; i < 6; i++) {
          particles.emitWater(
            x: x + giveOrTake(10),
            y: y + giveOrTake(10),
            z: z,
          );
        }
        break;
    }
  }

  void onProjectileFired(int projectileType, double x, double y, double z) {
    switch (projectileType){
      case ProjectileType.Arrow:
        audio.play(audio.arrow_flying_past_6, x, y, z);
        break;
      case ProjectileType.Fireball:
        audio.play(audio.fire_bolt_14, x, y, z);
        break;
      default:
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
        particles.emitFlame(x: x, y: y, z: z);
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

  void onSplash(double x, double y, double z) {
    for (var i = 0; i < 12; i++){
      final zv = randomBetween(1.5, 5);
      particles.spawnParticleWaterDrop(x: x, y: y, z: z, zv: zv, duration: (zv * 12).toInt());
    }
    audio.play(audio.splash, x, y, z);
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
      case PlayerEvent.Portal_Used:
        amulet.screenColorI.value = 0;
        break;
      case PlayerEvent.Reloading:
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
        break;
      case PlayerEvent.Item_Acquired:
        readPlayerEventItemAcquired();
        break;
      case PlayerEvent.Item_Dropped:
        audio.popSounds14();
        amulet.aimTargetItemTypeCurrent.value = null;
        break;
      case PlayerEvent.Item_Sold:
        audio.coins_24();
        break;
      case PlayerEvent.GameObject_Deselected:
        editor.gameObject.value = null;
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
      case PlayerEvent.Game_Finished:
        onGameFinished();
        break;
    }
  }

  void onCharacterDeath(int characterType, double x, double y, double z, double angle) {
    audio.play(randomItem(audio.bloody_punches), x, y, z);
    audio.play(audio.heavy_punch_13, x, y, z);
    particles.emitFlames(
      x: x,
      y: y,
      z: z,
      count: 8,
      radius: 10,
    );

    final audioClip = audio.getCharacterTypeAudioDeath(characterType);

    if (audioClip != null){
      audio.play(audioClip, x, y, z);
    }

    switch (characterType) {
      case CharacterType.Gargoyle_01:
        for (var i = 0; i < 5; i++){
          particles.spawnParticleBlockBrick(x, y, z);
        }
        break;
      default:
        for (var i = 0; i < 4; i++){
          particles.spawnBlood(
            x: x,
            y: y,
            z: z,
            angle: angle + giveOrTake(piQuarter),
            speed: randomBetween(1.5, 2.5),
          );
        }
        break;
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
      case WeaponType.Shortsword:
        audio.sword_unsheathe();
        break;
      case WeaponType.Bow:
        audio.bow_draw();
        break;
      default:
        break;
    }
  }

  void readPlayerEventItemAcquired() {
    final itemType = parser.readUInt16();
    // todo read subtype
    if (itemType == WeaponType.Unarmed) return;

    switch (itemType) {
      case WeaponType.Shortsword:
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

  void onGameEventCharacterHurt(
      int type,
      double x,
      double y,
      double z,
      double angle,
      ) {

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

    final hurtAudio = audio.getCharacterTypeAudioHurt(type);
    if (hurtAudio != null) {
      audio.play(hurtAudio, x, y, z);
    }
  }

  void onGameEventGameObjectDestroyed(
      double x,
      double y,
      double z,
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

  void onGameFinished() {
    audio.celestialVoiceAngel.play(volume: 1);
    Timer(Duration(seconds: 3), (){
      ui.showDialogText(
        text: 'Congratulations! You have completed the amulet demo. Thanks very much for playing.',
      );
    });
  }
}