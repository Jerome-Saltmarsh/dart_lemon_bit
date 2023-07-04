

import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/isometric/src.dart';
import 'package:gamestream_server/utils/system.dart';
import 'package:lemon_math/src.dart';

import 'combat_player.dart';
import 'combat_zombie.dart';

class CombatGame extends IsometricGame<CombatPlayer> {
  // constants
  static final Player_Respawn_Duration  = Gamestream.Frames_Per_Second * (isLocalMachine ? 4 : 4);
  static const GameObject_Duration      = 500;
  static const GameObject_Respawn_Duration = 1500;
  static const AI_Respawn_Duration      = 6.0; // seconds
  static const Chance_Of_Item_Bombs     = 0.1;
  static const Chance_Of_Item_Gem       = 0.5;
  static const Credits_Collected        = 1;
  static const Health_Gained_Per_Gem    = 2;
  static const Energy_Gained_Per_Gem    = 2;
  static const Credits_Per_Kill         = 10;
  static const Player_Health            = 20;
  static const Player_Health_Perk       = 24;
  static const Player_Energy            = 20;
  static const Player_Energy_Perk       = 24;
  static const Player_Run_Speed         = 1.0;
  static const Player_Run_Speed_Perk    = 1.2;
  static const Power_Duration_Invisible = Gamestream.Frames_Per_Second * 6;
  static const Power_Duration_Shield    = Gamestream.Frames_Per_Second * 4;
  static const Power_Duration_Stun      = Gamestream.Frames_Per_Second * 3;

  static const Power_Range_Stun         = 125.0;

  static const Team_Zombie = 5;

  static const GameObjects_Respawnable = [
    ObjectType.Crate_Wooden,
    ObjectType.Barrel_Explosive,
  ];

  static const GameObjects_Spawn_Loot = [
    ObjectType.Crate_Wooden,
  ];

  static const GameObjects_Destroyable = [
    ObjectType.Crate_Wooden,
  ];

  // constructor
  CombatGame({
    required super.scene,
  }) : super(
      gameType: GameType.Combat,
      time: IsometricTime(enabled: true, hour: 15, minute: 30),
      environment: IsometricEnvironment(),
  );

  @override
  void updatePlayer(CombatPlayer player) {
    super.updatePlayer(player);

    if (player.powerCooldown > 0) {
      player.powerCooldown--;
      if (player.powerCooldown == 0) {
        player.writePlayerPower();
      }
    }

    if (player.respawnTimer > 0) {
      player.respawnTimer--;
    }

    if (player.energy < player.maxEnergy) {
      player.nextEnergyGain--;
      if (player.nextEnergyGain <= 0) {
        player.energy++;
        player.nextEnergyGain = player.energyGainRate;
      }
    }
  }

  @override
  void customInitPlayer(IsometricPlayer player) {
    moveToRandomPlayerSpawnPoint(player);
  }

  @override
  void customOnPlayerRevived(CombatPlayer player) {
    moveToRandomPlayerSpawnPoint(player);
    player.score = 0;
    player.team = TeamType.Alone;
    player.buffInvisible = false;
    player.buffInvincible = false;
    player.buffDoubleDamage = false;
    player.maxHealth = Player_Health;
    player.health = Player_Health;
    player.powerCooldown = 0;
    player.maxEnergy = Player_Energy;
    player.energy = Player_Energy;
    player.score = 0;
    player.writePlayerEquipment();
    player.writePlayerPower();
    player.writePlayerCredits();
  }

  @override
  void onPlayerUpdateRequestReceived({
    required CombatPlayer player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  }) {

    if (player.deadOrBusy) return;
    if (!player.active) return;

    if (!player.weaponStateBusy) {
      player.lookRadian = player.mouseAngle;
    }

    if (!inputTypeKeyboard) {
      if (mouseLeftDown) {
        player.setDestinationToMouse();
      }
      return;
    }

    if (mouseLeftDown){
      final aimTarget = player.aimTarget;
      if (aimTarget != null) {

        player.aimTargetWeaponSide = IsometricSide.Left;
        if (aimTarget is IsometricGameObject && (aimTarget.collectable || aimTarget.interactable)){
          if (player.aimTargetWithinInteractRadius) {
            if (aimTarget.interactable) {
              customOnPlayerInteractWithGameObject(player, aimTarget);
              return;
            }
          }
        }
        if (IsometricCollider.onSameTeam(player, aimTarget)){
          player.target = aimTarget;
          return;
        }
      }

      if (!WeaponType.isMelee(player.weaponPrimary)
          && characterMeleeAttackTargetInRange(player)
      ){
        player.weaponType = player.weaponPrimary;
        characterAttackMelee(player);
        return;
      }

      characterUseOrEquipWeapon(
        character: player,
        weaponType: player.weaponPrimary,
        characterStateChange: false,
      );
    }

    // if (mouseRightDown) {
    //   player.aimTargetWeaponSide = IsometricSide.Right;
    //   final aimTarget = player.aimTarget;
    //   if (aimTarget != null){
    //     player.aimTargetWeaponSide = IsometricSide.Right;
    //
    //     if (aimTarget is IsometricGameObject && (aimTarget.collectable || aimTarget.interactable)){
    //       if (player.aimTargetWithinInteractRadius) {
    //         if (aimTarget.interactable) {
    //           customOnPlayerInteractWithGameObject(player, aimTarget);
    //           return;
    //         }
    //       }
    //     }
    //     if (IsometricCollider.onSameTeam(player, aimTarget)) {
    //       player.target = aimTarget;
    //     }
    //   }
    //
    //   if (!WeaponType.isMelee(player.weaponSecondary)
    //       && characterMeleeAttackTargetInRange(player)
    //   ) {
    //     player.weaponType = player.weaponSecondary;
    //     characterAttackMelee(player);
    //     return;
    //   }
    //
    //   characterUseOrEquipWeapon(
    //     character: player,
    //     weaponType: player.weaponSecondary,
    //     characterStateChange: false,
    //   );
    // }

    if (keySpaceDown) {
      playerUsePower(player);
    }

    characterRunInDirection(player, IsometricDirection.fromInputDirection(direction));
  }

  @override
  void customOnPlayerDead(CombatPlayer player) {
    player.powerCooldown = 0;
    player.respawnTimer = Player_Respawn_Duration;
    player.writePlayerPower();
  }

  @override
  void customOnCharacterKilled(IsometricCharacter target, dynamic src) {
     if (src is CombatPlayer) {
       src.score += Credits_Per_Kill;
     }

     if (target is CombatZombie && scene.spawnPoints.isNotEmpty) {
       addJob(seconds: AI_Respawn_Duration, action: (){
         respawnAI(target);
       });
       if (random.nextDouble() < Chance_Of_Item_Gem) {
         spawnRandomGemsAtIndex(scene.getIndexPosition(target));
       }
     }
  }

  void playerEquipPrimary(CombatPlayer player, int itemType) {
    if (player.weaponPrimary == itemType) return;

    if (player.canChangeEquipment) {
      setCharacterStateChanging(player);
    }

    player.weaponPrimary = itemType;
    player.weaponType = itemType;
    player.writePlayerEquipment();
  }

  void playerEquipSecondary(CombatPlayer player, int itemType) {
    if (player.weaponSecondary == itemType) return;

    if (player.canChangeEquipment) {
      setCharacterStateChanging(player);
    }

    player.weaponSecondary = itemType;
    player.weaponType = itemType;
  }


  @override
  void customInit() {
    // for (final gameObject in gameObjects){
    //    if (!WeaponType.isTypeWeapon(gameObject.type)) continue;
    //    gameObject
    //      ..physical = false
    //      ..interactable = true
    //      ..fixed = true
    //      ..hitable = false
    //      ..gravity = false
    //      ..collectable = true
    //    ;
    // }

    for (final spawnPoint in scene.spawnPoints) {
       spawnAI(nodeIndex: spawnPoint, characterType: CharacterType.Zombie);
    }
  }

  @override
  void customOnPlayerInteractWithGameObject(CombatPlayer player, IsometricGameObject gameObject){
    final gameObjectType = gameObject.type;

    if (player.weaponPrimary == gameObjectType) {
      player.writeGameError(GameError.Already_Equipped);
      return;
    }

    if (player.weaponSecondary == gameObjectType){
      player.writeGameError(GameError.Already_Equipped);
      return;
    }

     player.aimTargetWeaponSide == IsometricSide.Left
         ? playerEquipPrimary(player, gameObjectType)
         : playerEquipSecondary(player, gameObjectType);
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(CombatPlayer player, IsometricGameObject gameObject) {
       if (!gameObject.collectable) return;
       customOnPlayerCollectGameObject(player, gameObject);
  }

  @override
  void customOnGameObjectDestroyed(IsometricGameObject gameObject) {
    if (GameObjects_Respawnable.contains(gameObject.type)){
      performScript(timer: GameObject_Respawn_Duration).writeSpawnGameObject(
        type: gameObject.type,
        x: gameObject.x,
        y: gameObject.y,
        z: gameObject.z,
      );
    }

    if (GameObjects_Spawn_Loot.contains(gameObject.type)){
       spawnGemAtIndex(scene.getIndexPosition(gameObject));
    }
  }

  @override
  void customOnGameObjectSpawned(IsometricGameObject gameObject) {
    gameObject.destroyable = GameObjects_Destroyable.contains(gameObject.type);
  }

  @override
  void customOnPlayerCollectGameObject(CombatPlayer player, IsometricGameObject gameObject) {
    if (!gameObject.collectable) return;

    if (gameObject.type == ObjectType.Credits) {
      player.score += Credits_Collected;
      player.writePlayerEventItemAcquired(gameObject.type);
      player.writeGameEventGameObjectDestroyed(gameObject);
      deactivateCollider(gameObject);
      player.health += Health_Gained_Per_Gem;
      player.energy += Energy_Gained_Per_Gem;
      return;
    }

    // final itemType = gameObject.type;

    // if (ItemType.isTypeWeapon(itemType)) {
    //   if (player.weaponPrimary == itemType) {
    //     return;
    //   }
    //   if (player.weaponSecondary == itemType) {
    //     return;
    //   }
    //
    //   if (player.weaponPrimary == ItemType.Empty) {
    //     playerEquipPrimary(player, itemType);
    //     deactivateCollider(gameObject);
    //     return;
    //   }
    //
    //   if (player.weaponSecondary == ItemType.Empty) {
    //     playerEquipSecondary(player, itemType);
    //     deactivateCollider(gameObject);
    //     return;
    //   }
    // }
  }

  void customActionSpawnAIAtIndex(int index){
    spawnAI(
      characterType: randomItem(const [CharacterType.Dog, CharacterType.Zombie]),
      nodeIndex: index,
      damage: 1,
      health: 5,
    );
  }

  @override
  void customOnPlayerJoined(CombatPlayer player) {
    player.writePlayerApiId();
    writePlayerScoresAll();
    player.powerCooldown = 0;
    player.respawnTimer = 0;
    player.powerType        = CombatPowerType.Bomb;
    player.weaponPrimary    = WeaponType.Plasma_Pistol;
    player.weaponSecondary  = WeaponType.Crowbar;
    player.weaponType       = player.weaponPrimary;
    player.headType         = HeadType.Plain;
    player.bodyType         = BodyType.Shirt_Red;
    player.legsType         = LegType.Blue;
    player.writePlayerPower();
  }

  @override
  void customOnPlayerDisconnected(IsometricPlayer player) {
    writePlayerScoresAll();
  }

  @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    if (nodeType == NodeType.Grass_Long && randomBool()) {
      spawnRandomGemsAtIndex(nodeIndex);
    }

    addJob(seconds: 10, action: (){
      setNode(
        nodeIndex: nodeIndex,
        nodeType: nodeType,
        nodeOrientation: nodeOrientation,
      );
    });
  }

  void spawnRandomGemsAtIndex(int nodeIndex){
    final total = randomInt(1, 3);
    for (var i = 0; i <= total; i++) {
      spawnGemAtIndex(nodeIndex);
    }
  }

  void spawnGemAtIndex(int nodeIndex){
    spawnGameObjectAtIndex(
      index: nodeIndex,
      type: GameObjectType.Object,
      subType: ObjectType.Credits
    )
      ..velocityZ = 7
      ..setVelocity(randomAngle(), 7.0)
      ..fixed = false
      ..gravity = true
      ..physical = true
    ;
  }

  void playerUsePower(CombatPlayer player){
    if (player.powerCooldown > 0) return;
    if (player.deadBusyOrWeaponStateBusy) return;
    player.powerCooldown = player.getPlayerPowerTypeCooldownTotal();
    player.writePlayerPower();
    player.writePlayerEvent(PlayerEvent.Power_Used);

    for (final otherPlayer in players) {
      otherPlayer.writeGameEvent(
          type: GameEventType.Power_Used,
          x: player.x,
          y: player.y,
          z: player.z,
          angle: 0,
      );
      player.writeByte(player.powerType);
    }

    switch (player.powerType) {
      case CombatPowerType.Bomb:
        playerThrowGrenade(player);
        break;
      case CombatPowerType.Teleport:
        playerTeleport(player);
        break;
      case CombatPowerType.Revive:
        player.health = player.maxHealth;
        player.energy = player.maxEnergy;
        // player.writePlayerEventItemTypeConsumed(ItemType.Consumables_Potion_Blue);
        break;
      case CombatPowerType.Shield:
        player.buffInvincible = true;
        break;
      case CombatPowerType.Invisible:
        player.buffInvisible = true;
        for (final character in characters) {
          if (character.target != player) continue;
          clearCharacterTarget(character);
        }
        break;
      case CombatPowerType.Stun:
        const duration = Power_Duration_Stun;
        final playerX = player.x;
        final playerY = player.y;
        final playerZ = player.z;
        for (final character in characters) {
          final distanceX = (playerX - character.x).abs();
          if (distanceX > Power_Range_Stun) continue;
          final distanceY = (playerY - character.y).abs();
          if (distanceY > Power_Range_Stun) continue;
          final distanceZ = (playerZ - character.z).abs();
          if (distanceZ > Power_Range_Stun) continue;
          if (IsometricCollider.onSameTeam(character, player)) continue;
          setCharacterStateStunned(character, duration: duration);
        }
        break;
    }
  }

  @override
  CombatPlayer buildPlayer() => CombatPlayer(this);

  void writePlayerScoresAll() {
    for (final player in players) {
      player.writeApiPlayersAll();
    }
  }

  @override
  int get maxPlayers => 12;

  void customOnPlayerCreditsChanged(CombatPlayer player) {
    for (final otherPlayer in players) {
      otherPlayer.writeApiPlayersPlayerScore(player);
    }
  }

  @override
  void characterUseWeapon(IsometricCharacter character) {
    if (character.deadBusyOrWeaponStateBusy) return;

    final weaponType = character.weaponType;

    if (weaponType == WeaponType.Grenade) {
      if (character is IsometricPlayer) {
        playerThrowGrenade(character, damage: 10);
        return;
      }
      throw Exception('ai cannot throw grenades');
    }

    if (weaponType == WeaponType.Flame_Thrower) {
      if (character is IsometricPlayer) {
        characterUseFlamethrower(character);
        return;
      }
      throw Exception('ai cannot use flamethrower');
    }

    if (weaponType == WeaponType.Bazooka) {
      if (character is IsometricPlayer) {
        characterUseBazooka(character);
      }
      return;
    }

    if (weaponType == WeaponType.Minigun) {
      if (character is IsometricPlayer) {
        characterUseMinigun(character);
      }
      return;
    }

    if (WeaponType.isFirearm(weaponType)) {
      characterFireWeapon(character);
      character.accuracy += 0.25;
      return;
    }

    if (WeaponType.isMelee(weaponType)) {
      characterAttackMelee(character);
      return;
    }

    switch (weaponType) {
      case WeaponType.Crossbow:
        spawnProjectileArrow(
          damage: character.weaponDamage,
          range: character.weaponRange,
          src: character,
          angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        return;
      case WeaponType.Staff:
        spawnProjectileFireball(
          src: character,
          angle: character.lookRadian,
          damage: character.weaponDamage,
          range: character.weaponRange,
        );
        character.assignWeaponStateFiring();
        break;
      case WeaponType.Bow:
        spawnProjectileArrow(
          src: character,
          damage: character.weaponDamage,
          range: character.weaponRange,
          angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        break;
    }
  }

  @override
  void revive(CombatPlayer player) {
    if (player.respawnTimer > 0) {
      player.writeGameError(GameError.Respawn_Duration_Remaining);
      return;
    }
    super.revive(player);
  }

  void playerTeleport(IsometricPlayer player) =>
      characterTeleport(
        character: player,
        x: player.mouseSceneX,
        y: player.mouseSceneY,
        range: 500,
      );

  void characterUseOrEquipWeapon({
    required IsometricCharacter character,
    required int weaponType,
    required bool characterStateChange,
  }) {
    if (character.deadBusyOrWeaponStateBusy) return;

    if (character.weaponType != weaponType) {
      character.weaponType = weaponType;
      if (characterStateChange) {
        setCharacterStateChanging(character);
        return;
      }
    }
    characterUseWeapon(character);
  }

  void respawnAI(CombatZombie ai) {
    assert (ai.dead);
    final distance = randomBetween(0, 100);
    final angle = randomAngle();
    ai.x = ai.spawnX + adj(angle, distance);
    ai.y = ai.spawnY + opp(angle, distance);
    ai.z = ai.spawnZ;
    ai.clearDest();
    clearCharacterTarget(ai);
    ai.clearPath();
    activateCollider(ai);
    ai.health = ai.maxHealth;
    ai.target = null;
    ai.setCharacterStateSpawning();
  }

  @override
  void customOnCharacterDamageApplied(IsometricCharacter target, src, int amount) {
    super.customOnCharacterDamageApplied(target, src, amount);

    if (target is CombatZombie) {
      onDamageAppliedToZombie(target, src);
    }
  }

  void onDamageAppliedToZombie(CombatZombie ai, dynamic src) {
    final targetAITarget = ai.target;
    if (targetAITarget == null) {
      ai.target = src;
      return;
    }
    final aiTargetDistance = ai.getDistance3(targetAITarget);
    final srcTargetDistance =  ai.getDistance3(src);
    if (srcTargetDistance < aiTargetDistance) {
      ai.target = src;
    }
  }

  CombatZombie spawnAI({
    required int nodeIndex,
    required int characterType,
    int health = 10,
    int damage = 1,
    int team = Team_Zombie,
    double wanderRadius = 200,
  }) {
    if (nodeIndex < 0) throw Exception('nodeIndex < 0');
    if (nodeIndex >= scene.volume) {
      throw Exception(
          'game.spawnZombieAtIndex($nodeIndex) \ni >= scene.gridVolume');
    }
    final instance = CombatZombie(
      characterType: characterType,
      health: health,
      damage: damage,
      wanderRadius: wanderRadius,
    );
    moveToIndex(instance, nodeIndex);
    instance.clearDest();
    instance.clearPath();
    instance.spawnX = instance.x;
    instance.spawnY = instance.y;
    instance.spawnZ = instance.z;
    characters.add(instance);
    instance.spawnNodeIndex = nodeIndex;
    return instance;
  }

  void updateAITarget(CombatZombie ai) {
    assert (ai.alive);
    var target = ai.target;

    final targetSet = target != null;

    if (targetSet && !ai.withinChaseRange(target)) {
      clearCharacterTarget(ai);
    }

    var closestDistanceX = ai.viewRange;
    var closestDistanceY = closestDistanceX;

    for (final character in characters) {
      if (!character.aliveAndActive) continue;
      if (IsometricCollider.onSameTeam(character, ai)) continue;
      final distanceX = (ai.x - character.x).abs();
      if (closestDistanceX < distanceX) continue;
      final distanceY = (ai.y - character.y).abs();
      if (closestDistanceY < distanceY) continue;

      closestDistanceX = distanceX;
      closestDistanceY = distanceY;
      ai.target = character;
    }
    target = ai.target;
    if (target == null) return;
    if (!targetSet) {
      dispatchGameEventAITargetAcquired(ai);
      // npcSetPathTo(ai, target);
    }
  }

  void dispatchGameEventAITargetAcquired(CombatZombie ai) {
    for (final player in players) {
      if (!player.onScreen(ai.x, ai.y)) continue;
      player.writeGameEvent(
        type: GameEventType.AI_Target_Acquired,
        x: ai.x,
        y: ai.y,
        z: ai.z,
        angle: 0,
      );
      player.writeByte(ai.characterType);
    }
  }

  @override
  void customUpdate() {
    super.customUpdate();
    updateAITargets();
    updateZombies();
  }

  void updateZombies() {
    for (final character in characters) {
      if (!character.aliveAndActive) continue;
      if (character is! CombatZombie) continue;
      character.updateAI();
      character.applyBehaviorWander(this);

      if (character.running) {
        final frontX = character.x +
            adj(character.faceAngle, Node_Size_Three_Quarters);
        final frontY = character.y +
            adj(character.faceAngle, Node_Size_Three_Quarters);
        final nodeTypeInFront = scene.getTypeXYZ(
            frontX, frontY, character.z - Node_Height_Half);
        if (nodeTypeInFront == NodeType.Water) {
          character.setCharacterStateIdle();
        } else {
          final nodeOrientationInFrontAbove = scene.getOrientationXYZ(
              frontX, frontY, character.z + Node_Height_Half);
          if (nodeOrientationInFrontAbove == NodeOrientation.Solid) {
            character.setCharacterStateIdle();
          }
        }
      }
    }
  }

  void updateAITargets() {
    if (timerUpdateAITargets-- > 0) return;

    timerUpdateAITargets = 15;

    for (final character in characters) {
      if (!character.alive) continue;
      if (character is CombatZombie == false) continue;
      updateAITarget(character as CombatZombie);
    }
  }

  CombatZombie spawnAIXYZ({
    required double x,
    required double y,
    required double z,
    required int characterType,
    int health = 10,
    int damage = 1,
    double wanderRadius = 200,
  }) {
    if (!scene.inboundsXYZ(x, y, z)) throw Exception(
        'game.spawnAIXYZ() - out of bounds');

    final instance = CombatZombie(
      characterType: characterType,
      health: health,
      damage: damage,
      wanderRadius: wanderRadius,
    );
    instance.x = x;
    instance.y = y;
    instance.z = z;
    instance.clearDest();
    instance.clearPath();
    instance.spawnX = instance.x;
    instance.spawnY = instance.y;
    instance.spawnZ = instance.z;
    instance.setCharacterStateSpawning();
    characters.add(instance);
    instance.spawnNodeIndex = scene.getIndexXYZ(x, y, z);
    return instance;
  }

}



