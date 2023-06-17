

import 'package:bleed_server/common/src/character_type.dart';
import 'package:bleed_server/common/src/direction.dart';
import 'package:bleed_server/common/src/enums/item_group.dart';
import 'package:bleed_server/common/src/enums/perk_type.dart';
import 'package:bleed_server/common/src/game_error.dart';
import 'package:bleed_server/common/src/game_event_type.dart';
import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/common/src/node_size.dart';
import 'package:bleed_server/common/src/node_type.dart';
import 'package:bleed_server/common/src/player_event.dart';
import 'package:bleed_server/common/src/power_type.dart';
import 'package:bleed_server/common/src/team_type.dart';
import 'package:bleed_server/src/engine.dart';
import 'package:bleed_server/src/game/player.dart';
import 'package:bleed_server/src/games/combat/combat_player.dart';
import 'package:bleed_server/src/utilities/system.dart';
import 'package:lemon_math/library.dart';

import '../isometric/isometric_ai.dart';
import '../isometric/isometric_character.dart';
import '../isometric/isometric_collider.dart';
import '../isometric/isometric_environment.dart';
import '../isometric/isometric_game.dart';
import '../isometric/isometric_gameobject.dart';
import '../isometric/isometric_hit_type.dart';
import '../isometric/isometric_player.dart';
import '../isometric/isometric_side.dart';
import '../isometric/isometric_time.dart';

class GameCombat extends IsometricGame<CombatPlayer> {
  // constants
  static final Player_Respawn_Duration  = Engine.Frames_Per_Second * (isLocalMachine ? 4 : 4);
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
  static const Power_Duration_Invisible = Engine.Frames_Per_Second * 6;
  static const Power_Duration_Shield    = Engine.Frames_Per_Second * 4;
  static const Power_Duration_Stun      = Engine.Frames_Per_Second * 3;

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

    if (player.buffDuration > 0) {
      player.buffDuration--;
      if (player.buffDuration == 0) {
        switch (player.powerType) {
          case PowerType.Shield:
            player.buffInvincible = false;
            break;
          case PowerType.Invisible:
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
    player.item_level.clear();
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

    playerRunInDirection(player, Direction.fromInputDirection(direction));
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
     if (src is IsometricPlayer) {
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
    player.perkType         = PerkType.None;
    player.powerType        = PowerType.Bomb;
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
  void customOnPlayerCreditsChanged(IsometricPlayer player) {
    for (final otherPlayer in players) {
      otherPlayer.writeApiPlayersPlayerScore(player);
    }
  }

  @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    if (nodeType == NodeType.Grass_Long && randomBool()) {
      spawnRandomGemsAtIndex(nodeIndex);
    }

    performJob(1000, (){
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
    player.powerCooldown = getPlayerPowerTypeCooldownTotal(player);
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
      case PowerType.Bomb:
        playerThrowGrenade(player);
        break;
      case PowerType.Teleport:
        playerTeleport(player);
        break;
      case PowerType.Revive:
        player.health = player.maxHealth;
        player.energy = player.maxEnergy;
        player.writePlayerEventItemTypeConsumed(ItemType.Consumables_Potion_Blue);
        break;
      case PowerType.Shield:
        player.buffInvincible = true;
        player.buffDuration = Power_Duration_Shield;
        break;
      case PowerType.Invisible:
        player.buffInvisible = true;
        player.buffDuration = Power_Duration_Invisible;
        for (final character in characters) {
          if (character.target != player) continue;
          clearCharacterTarget(character);
        }
        break;
      case PowerType.Stun:
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
  void customOnPlayerPerkTypeChanged(IsometricPlayer player) {
    player.maxHealth = player.perkType == PerkType.Health
        ? Player_Health_Perk
        : Player_Health;

    player.maxEnergy = player.perkType == PerkType.Energy
        ? Player_Energy_Perk
        : Player_Energy;

    player.runSpeed = player.perkType == PerkType.Speed
        ? Player_Run_Speed_Perk
        : Player_Run_Speed;
  }

  @override
  CombatPlayer buildPlayer() => CombatPlayer(this);


  void playerEquipNextItemGroup(CombatPlayer player, ItemGroup itemGroup) {
    if (!player.canChangeEquipment) return;

    final equippedItemType = player.getEquippedItemGroupItem(itemGroup);

    if (equippedItemType == ItemType.Empty) {
      playerEquipFirstItemTypeFromItemGroup(player, itemGroup);
      return;
    }

    final equippedWeaponItemGroup = ItemType.getItemGroup(player.weaponType);

    if (equippedWeaponItemGroup != itemGroup) {
      characterEquipItemType(
          player, player.getEquippedItemGroupItem(itemGroup));
      return;
    }

    final equippedItemIndex = player.getItemIndex(equippedItemType);
    assert (equippedItemType != -1);

    final itemEntries = player.item_level.entries.toList(growable: false);
    final itemEntriesLength = itemEntries.length;
    for (var i = equippedItemIndex + 1; i < itemEntriesLength; i++) {
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      characterEquipItemType(player, entryItemType);
      return;
    }

    for (var i = 0; i < equippedItemIndex; i++) {
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      characterEquipItemType(player, entryItemType);
      return;
    }
  }


  @override
  int get maxPlayers => 12;
}



