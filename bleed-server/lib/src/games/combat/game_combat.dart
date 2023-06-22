

import 'package:bleed_server/common/src/isometric/character_type.dart';
import 'package:bleed_server/common/src/isometric/isometric_direction.dart';
import 'package:bleed_server/common/src/game_error.dart';
import 'package:bleed_server/common/src/game_event_type.dart';
import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/common/src/isometric/item_type.dart';
import 'package:bleed_server/common/src/isometric/node_size.dart';
import 'package:bleed_server/common/src/isometric/node_type.dart';
import 'package:bleed_server/common/src/player_event.dart';
import 'package:bleed_server/common/src/combat/combat_power_type.dart';
import 'package:bleed_server/common/src/isometric/team_type.dart';
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/combat/combat_player.dart';
import 'package:bleed_server/utils/system.dart';
import 'package:lemon_math/library.dart';
import 'package:bleed_server/isometric/src.dart';

class GameCombat extends IsometricGame<CombatPlayer> {
  // constants
  static final Player_Respawn_Duration  = Gamestream.Frames_Per_Second * (isLocalMachine ? 4 : 4);
  static const GameObject_Duration      = 500;
  static const GameObject_Respawn_Duration = 1500;
  static const AI_Respawn_Duration      = 300;
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

  static const GameObjects_Respawnable = [
    ItemType.GameObjects_Crate_Wooden,
    ItemType.GameObjects_Barrel_Explosive,
  ];

  static const GameObjects_Spawn_Loot = [
    ItemType.GameObjects_Crate_Wooden,
  ];

  static const GameObjects_Destroyable = [
    ItemType.GameObjects_Crate_Wooden,
  ];

  static const GameObjects_Interactable = [
    ItemType.Weapon_Ranged_Flamethrower,
    ItemType.Weapon_Ranged_Bazooka,
    ItemType.Weapon_Ranged_Plasma_Pistol,
    ItemType.Weapon_Ranged_Plasma_Rifle,
    ItemType.Weapon_Ranged_Sniper_Rifle,
    ItemType.Weapon_Ranged_Teleport,
    ItemType.Weapon_Ranged_Shotgun,
    ItemType.Weapon_Melee_Crowbar,
    ItemType.Weapon_Melee_Pickaxe,
  ];

  static const GameObjects_Collectable = [
    ItemType.Resource_Credit,
    ItemType.Weapon_Thrown_Grenade,
  ];

  // constructor
  GameCombat({
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

    if (player.buffDuration > 0) {
      player.buffDuration--;
      if (player.buffDuration == 0) {
        switch (player.powerType) {
          case CombatPowerType.Shield:
            player.buffInvincible = false;
            break;
          case CombatPowerType.Invisible:
            player.buffInvisible = false;
            break;
        }
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
        player.runToMouse();
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
          setCharacterTarget(player, aimTarget);
          return;
        }
      }

      if (!ItemType.isTypeWeaponMelee(player.weaponPrimary)
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

    if (mouseRightDown) {
      player.aimTargetWeaponSide = IsometricSide.Right;
      final aimTarget = player.aimTarget;
      if (aimTarget != null){
        player.aimTargetWeaponSide = IsometricSide.Right;

        if (aimTarget is IsometricGameObject && (aimTarget.collectable || aimTarget.interactable)){
          if (player.aimTargetWithinInteractRadius) {
            if (aimTarget.interactable) {
              customOnPlayerInteractWithGameObject(player, aimTarget);
              return;
            }
          }
        }
        if (IsometricCollider.onSameTeam(player, aimTarget)) {
          setCharacterTarget(player, aimTarget);
        }
      }

      if (!ItemType.isTypeWeaponMelee(player.weaponSecondary)
          && characterMeleeAttackTargetInRange(player)
      ) {
        player.weaponType = player.weaponSecondary;
        characterAttackMelee(player);
        return;
      }

      characterUseOrEquipWeapon(
        character: player,
        weaponType: player.weaponSecondary,
        characterStateChange: false,
      );
    }

    if (keySpaceDown) {
      playerUsePower(player);
    }

    playerRunInDirection(player, IsometricDirection.fromInputDirection(direction));
  }

  @override
  void customOnPlayerDead(CombatPlayer player) {
    player.powerCooldown = 0;
    player.buffDuration = 0;
    player.respawnTimer = Player_Respawn_Duration;
    player.writePlayerPower();
  }

  @override
  void customOnCharacterKilled(IsometricCharacter target, dynamic src) {
     if (src is CombatPlayer) {
       src.score += Credits_Per_Kill;
     }

     if (target is IsometricAI && scene.spawnPoints.isNotEmpty) {
       final spawnNodeIndex = randomItem(scene.spawnPoints);

       final z = scene.getNodeIndexZ(spawnNodeIndex);
       final row = scene.getNodeIndexRow(spawnNodeIndex);
       final column = scene.getNodeIndexColumn(spawnNodeIndex);

       performScript(timer: AI_Respawn_Duration).writeSpawnAI(
         type: randomItem(const[CharacterType.Zombie, CharacterType.Dog]),
         x: row * Node_Size + Node_Size_Half,
         y: column * Node_Size + Node_Size_Half,
         z: z * Node_Height,
         team: TeamType.Evil,
       );

       if (random.nextDouble() < Chance_Of_Item_Gem) {
         spawnRandomGemsAtIndex(scene.getNodeIndexV3(target));
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
    for (final gameObject in gameObjects){
       if (!ItemType.isTypeWeapon(gameObject.type)) continue;
       gameObject
         ..physical = false
         ..interactable = true
         ..fixed = true
         ..hitable = false
         ..gravity = false
         ..collectable = true
       ;
    }

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

    final itemCost = getItemCost(gameObjectType);

     if (player.score < itemCost) {
       player.writeGameError(GameError.Already_Equipped);
       return;
     }

     player.score -= itemCost;

     player.aimTargetWeaponSide == IsometricSide.Left
         ? playerEquipPrimary(player, gameObjectType)
         : playerEquipSecondary(player, gameObjectType);
  }

  int getItemCost(int itemType) => const <int, int> {
        ItemType.Weapon_Ranged_Plasma_Rifle: 250,
        ItemType.Weapon_Ranged_Plasma_Pistol: 100,
        ItemType.Weapon_Ranged_Shotgun: 250,
        ItemType.Weapon_Ranged_Flamethrower: 400,
        ItemType.Weapon_Ranged_Sniper_Rifle: 300,
        ItemType.Weapon_Ranged_Bazooka: 400,
        ItemType.Weapon_Ranged_Teleport: 400,
  } [itemType] ?? 0;

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
       spawnGemAtIndex(scene.getNodeIndexV3(gameObject));
    }
  }

  @override
  void customOnGameObjectSpawned(IsometricGameObject gameObject) {
    gameObject.destroyable = GameObjects_Destroyable.contains(gameObject.type);
  }

  @override
  void customOnHitApplied({
    required IsometricCharacter srcCharacter,
    required IsometricCollider target,
    required int damage,
    required double angle,
    required int hitType,
    required double force,
  }) {
    if (target is! IsometricGameObject) return;
    if (target.type == ItemType.GameObjects_Barrel_Explosive) {
      if (hitType == IsometricHitType.Projectile || hitType == IsometricHitType.Explosion) {
        destroyGameObject(target);
        createExplosion(
          x: target.x,
          y: target.y,
          z: target.z,
          srcCharacter: srcCharacter,
        );
      }
    }
  }

  @override
  void customOnPlayerCollectGameObject(CombatPlayer player, IsometricGameObject gameObject) {
    if (!gameObject.collectable) return;

    if (gameObject.type == ItemType.Resource_Credit) {
      player.score += Credits_Collected;
      player.writePlayerEventItemAcquired(gameObject.type);
      player.writeGameEventGameObjectDestroyed(gameObject);
      deactivateCollider(gameObject);
      player.health += Health_Gained_Per_Gem;
      player.energy += Energy_Gained_Per_Gem;
      return;
    }

    final itemType = gameObject.type;

    if (ItemType.isTypeWeapon(itemType)) {
      if (player.weaponPrimary == itemType) {
        return;
      }
      if (player.weaponSecondary == itemType) {
        return;
      }

      if (player.weaponPrimary == ItemType.Empty) {
        playerEquipPrimary(player, itemType);
        deactivateCollider(gameObject);
        return;
      }

      if (player.weaponSecondary == ItemType.Empty) {
        playerEquipSecondary(player, itemType);
        deactivateCollider(gameObject);
        return;
      }
    }
  }

  @override
  void customActionSpawnAIAtIndex(int index){
    spawnAI(
      characterType: randomItem(const [CharacterType.Dog, CharacterType.Zombie]),
      nodeIndex: index,
      damage: 1,
      team: TeamType.Evil,
      health: 5,
    );
  }

  @override
  void customOnPlayerJoined(CombatPlayer player) {
    player.writePlayerApiId();
    writePlayerScoresAll();
    player.powerCooldown = 0;
    player.buffDuration = 0;
    player.respawnTimer = 0;
    player.powerType        = CombatPowerType.Bomb;
    player.weaponPrimary    = ItemType.Weapon_Ranged_Plasma_Pistol;
    player.weaponSecondary  = ItemType.Weapon_Melee_Crowbar;
    player.weaponType       = player.weaponPrimary;
    player.headType         = randomItem(ItemType.Collection_Clothing_Head);
    player.bodyType         = randomItem(ItemType.Collection_Clothing_Body);
    player.legsType         = randomItem(ItemType.Collection_Clothing_Legs);
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

    createJob(timer: 1000, action: (){
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
      type: ItemType.Resource_Credit,
    )
      ..velocityZ = 7
      ..setVelocity(randomAngle(), 7.0)
      ..fixed = false
      ..gravity = true
      ..physical = true
    ;
  }

  @override
  void customOnPlayerAimTargetChanged(IsometricPlayer player, IsometricCollider? collider) {
    if (collider is! IsometricGameObject) return;
    player.writeApiPlayerAimTargetName('${getItemCost(collider.type)} credits');
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
        player.writePlayerEventItemTypeConsumed(ItemType.Consumables_Potion_Blue);
        break;
      case CombatPowerType.Shield:
        player.buffInvincible = true;
        player.buffDuration = Power_Duration_Shield;
        break;
      case CombatPowerType.Invisible:
        player.buffInvisible = true;
        player.buffDuration = Power_Duration_Invisible;
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

    if (character is CombatPlayer) {
      final cost = getCharacterWeaponEnergyCost(character);
      if (character.energy < cost) {
        character.writeGameError(GameError.Insufficient_Energy);
        return;
      }
      character.energy -= cost;
    } else if (character is IsometricAI) {
      if (ItemType.isTypeWeaponFirearm(weaponType)) {
        if (character.rounds <= 0) {
          character.assignWeaponStateReloading();
          character.rounds = ItemType.getMaxQuantity(weaponType);
          return;
        }
        character.rounds--;
      }
    }

    if (character.buffInvisible) {
      character.buffInvisible = false;
    }

    if (weaponType == ItemType.Weapon_Thrown_Grenade) {
      if (character is IsometricPlayer) {
        playerThrowGrenade(character, damage: 10);
        return;
      }
      throw Exception('ai cannot throw grenades');
    }

    if (weaponType == ItemType.Weapon_Ranged_Flamethrower) {
      if (character is IsometricPlayer) {
        playerUseFlamethrower(character);
        return;
      }
      throw Exception('ai cannot use flamethrower');
    }

    if (weaponType == ItemType.Weapon_Ranged_Bazooka) {
      if (character is IsometricPlayer) {
        playerUseBazooka(character);
      }
      return;
    }

    if (weaponType == ItemType.Weapon_Ranged_Minigun) {
      if (character is IsometricPlayer) {
        playerUseMinigun(character);
      }
      return;
    }

    if (ItemType.isTypeWeaponFirearm(weaponType)) {
      characterFireWeapon(character);
      // if (character is Player){
      //   if (character.buffNoRecoil > 0) return;
      // }
      character.accuracy += 0.25;
      return;
    }

    if (ItemType.isTypeWeaponMelee(weaponType)) {
      characterAttackMelee(character);
      return;
    }

    switch (weaponType) {
      case ItemType.Weapon_Ranged_Crossbow:
        spawnProjectileArrow(
          damage: character.weaponDamage,
          range: character.weaponRange,
          src: character,
          angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        return;
      case ItemType.Weapon_Melee_Staff:
        characterSpawnProjectileFireball(
          character,
          angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        break;
      case ItemType.Weapon_Ranged_Bow:
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
        x: player.mouseGridX,
        y: player.mouseGridY,
        range: 500,
      );

}



