
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games.dart';
import 'package:gamestream_server/games/mmo/mmo_gameobject.dart';
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/games/mmo/mmo_npc.dart';
import 'package:gamestream_server/lemon_math.dart';

class MmoGame extends IsometricGame<MmoPlayer> {

  static const Chance_Drop_Item_On_Grass_Cut = 0.25;
  static const GameObjectDeactivationTimer = 5000;
  static const EnemyRespawnDuration = 30; // in seconds

  late MMONpc npcGuard;

  final playerSpawnX = 2030.0;
  final playerSpawnY = 2040.0;
  final playerSpawnZ = 25.0;

  MmoGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Mmo) {

    spawnMonstersAtSpawnNodes();

    characters.add(MMONpc(
      characterType: CharacterType.Template,
      x: playerSpawnX + giveOrTake(50),
      y: playerSpawnY + giveOrTake(50),
      z: 25,
      health: 50,
      team: MmoTeam.Human,
      weaponType: WeaponType.Handgun,
      weaponDamage: 1,
      weaponRange: 200,
      weaponCooldown: 20,
      name: "Gus",
      interact: (player) {
        player.talk("Hello there", options: [
          TalkOption("Goodbye", player.endInteraction),
          TalkOption("Buy", player.endInteraction),
        ]);
      }
    )..aiDelayAfterPerformFinished = false
    );

    npcGuard = MMONpc(
      characterType: CharacterType.Template,
      x: playerSpawnX + giveOrTake(50),
      y: playerSpawnY + giveOrTake(50),
      z: 25,
      health: 200,
      weaponType: WeaponType.Machine_Gun,
      weaponRange: 200,
      weaponDamage: 1,
      weaponCooldown: 5,
      team: MmoTeam.Human,
      name: "Sam",
    );
    npcGuard.aiDelayAfterPerformFinished = false;

    characters.add(npcGuard);
  }

  static void validate() => MMOItem.values.forEach((item) => item.validate());

  @override
  int get maxPlayers => 64;

  void spawnMonstersAtSpawnNodes() {
    final types = scene.types;
    final length = scene.types.length;
    for (var i = 0; i < length; i++){
       if (types[i] != NodeType.Spawn) continue;
       for (var j = 0; j < 3; j++){
         spawnZombieAtIndex(i);
       }
    }
  }

  void spawnZombieAtIndex(int index) {
    characters.add(IsometricCharacter(
      team: MmoTeam.Monsters,
      x: scene.getIndexX(index),
      y: scene.getIndexY(index),
      z: scene.getIndexZ(index),
      health: 3,
      weaponDamage: 1,
      characterType: CharacterType.Zombie,
      weaponType: WeaponType.Unarmed,
      weaponRange: 20,
      weaponCooldown: 30,
      actionFrame: 15,
      doesWander: true,
      name: 'Zombie',
      runSpeed: 0.75,
    ));
  }

  @override
  void customOnPlayerDead(MmoPlayer player) {
    addJob(seconds: 3, action: () {
      setCharacterStateSpawning(player);
    });
  }


  @override
  void performCharacterActionCustom(IsometricCharacter character) {
    if (character is! MmoPlayer)
      return;

    if (character.performingActivePower){
      character.applyPerformingActivePower();
      return;
    }

    final weapon = character.equippedWeapon;

    if (weapon == null)
      return;

    switch (weapon.attackType) {
      case MMOAttackType.Fire_Ball:
        spawnProjectileFireball(
          src: character,
          damage: weapon.damage,
          range: weapon.range,
          angle: character.lookRadian,
        );
        break;
      case MMOAttackType.Melee:
        characterApplyMeleeHits(character);
        break;
      case MMOAttackType.Arrow:
        spawnProjectileArrow(
          src: character,
          damage: weapon.damage,
          range: weapon.range,
          angle: character.lookRadian,
        );
        break;
      case MMOAttackType.Bullet:
        spawnProjectile(
          src: character,
          damage: weapon.damage,
          range: weapon.range,
          projectileType: ProjectileType.Bullet,
          angle: character.lookRadian,
        );
        break;
      default:
        throw Exception(weapon.attackType?.name);
    }

  }

  MMOItemQuality? getRandomItemQuality({
      double chanceOfMythical = 0.005,
      double chanceOfRare = 0.015,
      double chanceOfMagic = 0.05,
      double chanceOfCommon = 0.3,
    }){

    final value = random.nextDouble();

    if (value <= chanceOfMythical) {
      return MMOItemQuality.Mythical;
    }

    if (value <= chanceOfRare) {
      return MMOItemQuality.Rare;
    }

    if (value <= chanceOfMagic) {
      return MMOItemQuality.Unique;
    }

    if (value <= chanceOfCommon) {
      return MMOItemQuality.Common;
    }

    return null;
  }


  @override
  void customOnCharacterKilled(IsometricCharacter target, src) {
    if (target.characterType == CharacterType.Zombie) {

      final itemQuality = getRandomItemQuality();

      if (itemQuality != null){
        spawnRandomLootAtPosition(target, itemQuality);
      }

       addJob(seconds: EnemyRespawnDuration, action: () {
         setCharacterStateSpawning(target);
       });
    }

    if (src is MmoPlayer) {
      playerGainExperience(src, getCharacterExperienceValue(target));
    }
  }

  void playerGainExperience(MmoPlayer player, int experience){
    player.experience += getCharacterExperienceValue(player);

    while (player.experience > player.experienceRequired) {
      player.level++;
      player.skillPoints++;
      player.experience -= player.experienceRequired;
      player.experienceRequired = getExperienceRequiredForLevel(player.level);
    }
  }

  int getCharacterExperienceValue(IsometricCharacter character){
    return 1;
  }

  void spawnRandomLootAtPosition(IsometricPosition position, MMOItemQuality quality )=>
      spawnRandomLoot(
        x: position.x,
        y: position.y,
        z: position.z,
        quality: quality,
    );

  void spawnRandomLoot({
    required double x,
    required double y,
    required double z,
    required MMOItemQuality quality,
  }) => spawnLoot(
      x: x,
      y: y,
      z: z,
      item: randomItem(MMOItem.findByQuality(quality)),
  );

  void spawnLootAtIndex({required int index, required MMOItem item}) => spawnLoot(
    x: scene.getIndexX(index),
    y: scene.getIndexY(index),
    z: scene.getIndexZ(index),
    item: item,
  );

  void spawnLoot({
    required double x,
    required double y,
    required double z,
    required MMOItem item,
  }) {
    gameObjects.add(MMOGameObject(
      x: x,
      y: y,
      z: z,
      item: item,
      id: generateId(),
      frameSpawned: frame,
    )
      ..velocityZ = 10
      ..setVelocity(randomAngle(), 1.0)
    );
  }

  int getExperienceRequiredForLevel(int level){
    return level * 5;
  }

  @override
  MmoPlayer buildPlayer() => MmoPlayer(
      game: this,
      itemLength: 6,
      x: playerSpawnX,
      y: playerSpawnY,
      z: playerSpawnZ,
  )..level = 1
   ..experience = 0
   ..experienceRequired = getExperienceRequiredForLevel(2);

  @override
  void onCharacterCollectedGameObject(
      IsometricCharacter character,
      IsometricGameObject gameObject,
      ) {
    if (character is! MmoPlayer)
      return;
    if (gameObject is MMOGameObject) {
      if (character.addItem(gameObject.item)){
        super.onCharacterCollectedGameObject(character, gameObject);
      }
    }
  }

  @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    switch (nodeType){
      case NodeType.Grass_Long:
        if (randomChance(Chance_Drop_Item_On_Grass_Cut)){
          spawnLootAtIndex(index: nodeIndex, item: MMOItem.Meat_Drumstick);
        }
        break;
    }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(MmoPlayer player, IsometricGameObject gameObject) {
    if (gameObject is! MMOGameObject || gameObject.item.collectable)
      return;

    final duration = frame - gameObject.frameSpawned;

    if (duration < Gamestream.Frames_Per_Second * 1)
      return;

    player.pickupItem(gameObject.item);
    deactivate(gameObject);
  }

  @override
  void customOnInteraction(IsometricCharacter character, IsometricCharacter target) {
    super.customOnInteraction(character, target);

    if (character is MmoPlayer && target is MMONpc){
       character.interacting = true;
       target.interact?.call(character);
    }
  }
}