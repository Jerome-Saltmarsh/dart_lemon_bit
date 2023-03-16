

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import 'package:lemon_math/library.dart';

class GameCombat extends Game {

  // constants
  static const Max_Grenades = 3;
  static const GameObject_Duration = 500;
  static const GameObject_Respawn_Duration = 1500;
  static const AI_Respawn_Duration = 300;
  static const Chance_Of_Item_Bombs = 0.1;
  static const Chance_Of_Item_Gem = 0.5;
  static const Credits_Collected = 1;
  static const Health_Gained_Per_Gem = 2;
  static const Energy_Gained_Per_Gem = 2;
  static const Credits_Per_Kill = 10;
  static const Max_Players = 16;
  static const Player_Health = 20;
  static const Player_Energy = 20;

  static const GameObjects_Spawnable = [
    ItemType.Resource_Credit,
    ItemType.Weapon_Thrown_Grenade,
  ];

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
      time: GameTime(enabled: true, hour: 15, minute: 30),
      environment: GameEnvironment(),
      options: GameOptions(
          perks: false,
          inventory: false,
          items: true,
          itemTypes: [
              ItemType.Weapon_Melee_Knife,
              ItemType.Weapon_Melee_Crowbar,
              ItemType.Weapon_Melee_Axe,
              ItemType.Weapon_Ranged_Plasma_Pistol,
              ItemType.Weapon_Ranged_Plasma_Rifle,
              ItemType.Weapon_Ranged_Shotgun,
              ItemType.Weapon_Ranged_Sniper_Rifle,
              ItemType.Weapon_Ranged_Bazooka,
              ItemType.Weapon_Ranged_Flamethrower,
          ],
      ),
  );

  @override
  void customOnPlayerRevived(Player player) {
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
    player.credits = 0;
    player.grenades = 1;
    player.writePlayerEquipment();
    player.writePlayerPower();
  }

  @override
  void onPlayerUpdateRequestReceived({
    required Player player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keyShiftDown,
    required bool keySpaceDown,
    required double mouseX,
    required double mouseY,
    required double screenLeft,
    required double screenTop,
    required double screenRight,
    required double screenBottom,
  }) {
    player.framesSinceClientRequest = 0;
    player.screenLeft = screenLeft;
    player.screenTop = screenTop;
    player.screenRight = screenRight;
    player.screenBottom = screenBottom;
    player.mouse.x = mouseX;
    player.mouse.y = mouseY;

    if (player.deadOrBusy) return;

    playerUpdateAimTarget(player);

    if (!player.weaponStateBusy) {
      player.lookRadian = player.mouseAngle;
    }

    if (mouseLeftDown){
      final aimTarget = player.aimTarget;
      if (aimTarget != null) {

        player.aimTargetWeaponSide = Side.Left;
        if (aimTarget is GameObject && (aimTarget.collectable || aimTarget.interactable)){
          if (player.aimTargetWithinInteractRadius) {
            if (aimTarget.interactable) {
              customOnPlayerInteractWithGameObject(player, aimTarget);
              return;
            }
          }
        }
        if (Collider.onSameTeam(player, aimTarget)){
          setCharacterTarget(player, aimTarget);
          return;
        }
      }

      if (!keyShiftDown && characterMeleeAttackTargetInRange(player)){
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
      player.aimTargetWeaponSide = Side.Right;
      final aimTarget = player.aimTarget;
      if (aimTarget != null){
        player.aimTargetWeaponSide = Side.Right;

        if (aimTarget is GameObject && (aimTarget.collectable || aimTarget.interactable)){
          if (player.aimTargetWithinInteractRadius) {
            if (aimTarget.interactable) {
              customOnPlayerInteractWithGameObject(player, aimTarget);
              return;
            }
          }
        }
        if (Collider.onSameTeam(player, aimTarget)) {
          setCharacterTarget(player, aimTarget);
        }
      }

      if (!keyShiftDown && characterMeleeAttackTargetInRange(player)) {
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

    playerRunInDirection(player, direction);
  }

  void spawnGrenadeAtPosition(Position3 position){
    final spawnedGameObject = spawnGameObjectAtPosition(
      position: position,
      type: ItemType.Weapon_Thrown_Grenade,
    );

    spawnedGameObject
      ..fixed         = true
      ..collectable   = true
      ..physical      = false
      ..interactable  = false
      ..hitable       = false
      ..gravity       = false
    ;

    performScript(timer: GameObject_Duration)
        .writeGameObjectDeactivate(spawnedGameObject)
    ;
  }

  @override
  void customOnPlayerDead(Player player) {
    player.powerCooldown = 0;
    player.powerDuration = 0;
    player.writePlayerPower();
  }

  @override
  void customOnCharacterKilled(Character target, dynamic src) {
     if (src is Player) {
       src.credits += Credits_Per_Kill;
     }

     if (target is AI && scene.spawnPoints.isNotEmpty) {
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

  @override
  void playerPurchaseItemType(Player player, int itemType, {required Side weaponSide}){
     if (player.dead) return;

     final itemLevel = player.getItemLevel(itemType);

     if (itemLevel < 4) {
       final itemCost = getItemPurchaseCost(itemType, itemLevel);

       if (player.credits < itemCost){
         player.writeError('insufficient credits');
         return;
       }

       player.credits -= itemCost;
       player.item_level[itemType] = itemLevel + 1;
       player.item_quantity[itemType] = player.getItemCapacity(itemType);
       if (itemLevel == 0){
         player.writeInfo('${ItemType.getName(itemType)} Purchased');
       } else {
         player.writeInfo('${ItemType.getName(itemType)} Upgraded');
       }
       player.writePlayerEventItemPurchased(itemType);
     }

     switch (weaponSide) {
       case Side.Left:
         playerEquipPrimary(player, itemType);
         break;
       case Side.Right:
         playerEquipSecondary(player, itemType);
         break;
     }

     player.writePlayerEquipment();
     player.writePlayerWeapons();
  }

  void playerEquipPrimary(Player player, int itemType) {
    if (player.weaponPrimary == itemType) return;

    if (player.canChangeEquipment) {
      setCharacterStateChanging(player);
    }

    player.weaponPrimary = itemType;
    player.weaponType = itemType;
    player.writePlayerEquipment();
  }

  void playerEquipSecondary(Player player, int itemType) {
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
  void customOnPlayerInteractWithGameObject(Player player, GameObject gameObject){
    final gameObjectType = gameObject.type;

    if (gameObjectType == ItemType.Weapon_Thrown_Grenade) {
      if (player.grenades >= Max_Grenades) {
        player.writeInfo('Grenades Full');
        return;
      }
      player.grenades = Max_Grenades;
      player.writePlayerEventItemAcquired(gameObjectType);
      deactivateCollider(gameObject);
      return;
    }

    if (player.weaponPrimary == gameObjectType) {
      player.writeError('already equipped');
      return;
    }

    if (player.weaponSecondary == gameObjectType){
      player.writeError('already equipped');
      return;
    }

    final itemCost = getItemCost(gameObjectType);

     if (player.credits < itemCost) {
       player.writeError('insufficient credits');
       return;
     }

     player.credits -= itemCost;

     player.aimTargetWeaponSide == Side.Left
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
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) {
       if (!gameObject.collectable) return;
       customOnPlayerCollectGameObject(player, gameObject);
  }

  @override
  void customOnGameObjectDestroyed(GameObject gameObject) {
    if (GameObjects_Respawnable.contains(gameObject.type)){
      performScript(timer: GameObject_Respawn_Duration).writeSpawnGameObject(
        type: gameObject.type,
        x: gameObject.x,
        y: gameObject.y,
        z: gameObject.z,
      );
    }

    if (GameObjects_Spawn_Loot.contains(gameObject.type)){
      spawnGrenadeAtPosition(gameObject);
    }
  }

  @override
  void customOnGameObjectSpawned(GameObject gameObject) {
    gameObject.destroyable = GameObjects_Destroyable.contains(gameObject.type);
  }

  @override
  void customOnHitApplied({
    required Character srcCharacter,
    required Collider target,
    required int damage,
    required double angle,
    required int hitType,
    required double force,
  }) {
    if (target is! GameObject) return;
    if (target.type == ItemType.GameObjects_Barrel_Explosive) {
      if (hitType == HitType.Projectile || hitType == HitType.Explosion) {
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
  void customOnPlayerCollectGameObject(Player player, GameObject gameObject) {
    if (!gameObject.collectable) return;

    if (gameObject.type == ItemType.Consumables_Potion_Red) {
      if (player.health >= player.maxHealth) return;
      player.health = player.maxHealth;
      player.writeInfo('Full Health');
      player.writePlayerEventItemTypeConsumed(gameObject.type);
      deactivateCollider(gameObject);
      return;
    }

    if (gameObject.type == ItemType.Weapon_Thrown_Grenade) {

      if (player.grenades >= Max_Grenades) {
        player.writeInfo('Max Grenades');
        return;
      }
      player.grenades++;
      player.writePlayerEventItemAcquired(gameObject.type);
      deactivateCollider(gameObject);
      return;
    }

    if (gameObject.type == ItemType.Resource_Credit) {
      player.credits += Credits_Collected;
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
  void customOnPlayerJoined(Player player) {
    writePlayerScoresAll();
    player.powerType = PowerType.Bomb;
    player.weaponPrimary = ItemType.Weapon_Ranged_Plasma_Pistol;
    player.weaponSecondary = ItemType.Weapon_Melee_Crowbar;
    player.weaponType = player.weaponPrimary;
    player.headType = randomItem(ItemType.Collection_Clothing_Head);
    player.bodyType = randomItem(ItemType.Collection_Clothing_Body);
    player.legsType = randomItem(ItemType.Collection_Clothing_Legs);
    setCharacterStateDead(player);
  }

  @override
  void customOnPlayerDisconnected(Player player) {
    writePlayerScoresAll();
  }

  @override
  void customOnPlayerCreditsChanged(Player player) {
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
  void customOnPlayerAimTargetChanged(Player player, Collider? collider) {
    if (collider is! GameObject) return;
    player.writeApiPlayerAimTargetName('${getItemCost(collider.type)} credits');
  }

  void playerUsePower(Player player){
    if (player.powerCooldown > 0) {
      return;
    }
    player.powerCooldown = getPlayerPowerTypeCooldownTotal(player);
    player.writePlayerPower();
    player.writePlayerEvent(PlayerEvent.Power_Used);

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
        player.powerDuration = Engine.Frames_Per_Second * 4;
        break;
      case PowerType.Invisible:
        player.buffInvisible = true;
        player.powerDuration = Engine.Frames_Per_Second * 4;
        break;
    }
  }

}



