
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games.dart';
import 'package:gamestream_server/gamestream.dart';
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/lemon_math.dart';

class Amulet extends IsometricGame<AmuletPlayer> {

  final chanceOfDropItemOnGrassCut = 0.25;
  final gameObjectDeactivationTimer = 5000;
  final enemyRespawnDuration = 30; // in seconds

  final playerSpawnX = 2030.0;
  final playerSpawnY = 2040.0;
  final playerSpawnZ = 25.0;

  var cooldownTimer = 0;

  late MMONpc npcGuard;

  Amulet({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Amulet) {

    spawnMonstersAtSpawnNodes();
    // characters.add(MMONpc(
    //   characterType: CharacterType.Template,
    //   x: playerSpawnX + giveOrTake(50),
    //   y: playerSpawnY + giveOrTake(50),
    //   z: 25,
    //   health: 50,
    //   team: MmoTeam.Human,
    //   weaponType: WeaponType.Handgun,
    //   weaponDamage: 1,
    //   weaponRange: 200,
    //   weaponCooldown: 20,
    //   name: "Gus",
    //   interact: (player) {
    //     player.talk("Hello there", options: [
    //       TalkOption("Goodbye", player.endInteraction),
    //       TalkOption("Buy", player.endInteraction),
    //     ]);
    //   }
    // )
    // );
    //
    // npcGuard = MMONpc(
    //   characterType: CharacterType.Template,
    //   x: playerSpawnX + giveOrTake(50),
    //   y: playerSpawnY + giveOrTake(50),
    //   z: 25,
    //   health: 200,
    //   weaponType: WeaponType.Machine_Gun,
    //   weaponRange: 200,
    //   weaponDamage: 1,
    //   weaponCooldown: 5,
    //   team: MmoTeam.Human,
    //   name: "Sam",
    // );
    // characters.add(npcGuard);
  }

  @override
  int get maxPlayers => 64;

  @override
  void update() {
    super.update();
    updateCooldownTimer();
  }

  void updateCooldownTimer() {
    if (cooldownTimer-- > 0)
      return;

    cooldownTimer = Gamestream.Frames_Per_Second;
    for (final player in players) {
      player.reduceCooldown();
    }
  }

  @override
  void endCharacterAction(Character character) {
    if (character.characterTypeZombie){
      setCharacterStateIdle(character, duration: randomInt(50, 250));
      return;
    }

    super.endCharacterAction(character);
  }

  static void validate() => MMOItem.values.forEach((item) => item.validate());

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
    characters.add(Character(
      team: MmoTeam.Monsters,
      x: scene.getIndexX(index),
      y: scene.getIndexY(index),
      z: scene.getIndexZ(index),
      health: 3,
      weaponDamage: 1,
      characterType: CharacterType.Fallen,
      weaponType: WeaponType.Unarmed,
      weaponRange: 20,
      weaponCooldown: 30,
      actionFrame: 15,
      doesWander: true,
      name: 'Fallen',
      runSpeed: 0.75,
    )
      ..weaponHitForce = 2
      ..strikeDuration = 20
      ..strikeActionFrame = 12
    );
  }

  @override
  void customOnPlayerDead(AmuletPlayer player) {
    addJob(seconds: 3, action: () {
      setCharacterStateSpawning(player);
    });
  }

  @override
  void performCharacterAction(Character character) {
    if (character is! AmuletPlayer) {
      super.performCharacterAction(character);
      return;
    }

    character.actionFrame = -1;

    if (character.performingActivePower){
      character.applyPerformingActivePower();
      return;
    }

    final weapon = character.equippedWeapon;

    if (weapon == null)
      return;

    final item = weapon.item;

    if (item == null)
      return;

    switch (item.attackType) {
      case MMOAttackType.Fire_Ball:
        spawnProjectileFireball(
          src: character,
          damage: item.damage,
          range: item.range,
          angle: character.angle,
        );
        break;
      case MMOAttackType.Melee:
        applyAttackTypeMelee(character);
        break;
      case MMOAttackType.Arrow:
        spawnProjectileArrow(
          src: character,
          damage: item.damage,
          range: item.range,
          angle: character.angle,
        );
        break;
      case MMOAttackType.Bullet:
        spawnProjectile(
          src: character,
          damage: item.damage,
          range: item.range,
          projectileType: ProjectileType.Bullet,
          angle: character.angle,
        );
        break;
      case MMOAttackType.Frost_Ball:
        spawnProjectile(
          src: character,
          damage: item.damage,
          range: item.range,
          projectileType: ProjectileType.FrostBall,
          angle: character.angle,
        );
        break;
      default:
        throw Exception(item.attackType?.name);
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
  void customOnCharacterKilled(Character target, src) {
    if (target.characterType == CharacterType.Zombie) {

      final itemQuality = getRandomItemQuality();

      if (itemQuality != null){
        spawnRandomLootAtPosition(target, itemQuality);
      }

       addJob(seconds: enemyRespawnDuration, action: () {
         setCharacterStateSpawning(target);
       });
    }

    if (src is AmuletPlayer) {
      playerGainExperience(src, getCharacterExperienceValue(target));
    }
  }

  void playerGainExperience(AmuletPlayer player, int experience){
    player.experience += getCharacterExperienceValue(player);

    while (player.experience > player.experienceRequired) {
      player.level++;
      player.talentPoints++;
      player.experience -= player.experienceRequired;
      player.experienceRequired = getExperienceRequiredForLevel(player.level);
    }
  }

  int getCharacterExperienceValue(Character character){
    return 1;
  }

  void spawnRandomLootAtPosition(Position position, MMOItemQuality quality )=>
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
      deactivationTimer: gameObjectDeactivationTimer,
    )
      ..velocityZ = 10
      ..setVelocity(randomAngle(), 1.0)
    );
  }

  int getExperienceRequiredForLevel(int level){
    return level * 5;
  }

  @override
  AmuletPlayer buildPlayer() => AmuletPlayer(
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
      Character character,
      GameObject gameObject,
      ) {
    if (character is! AmuletPlayer)
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
        if (randomChance(chanceOfDropItemOnGrassCut)){
          spawnLootAtIndex(index: nodeIndex, item: MMOItem.Meat_Drumstick);
        }
        break;
    }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(AmuletPlayer player, GameObject gameObject) {
    if (gameObject is! MMOGameObject || gameObject.item.collectable)
      return;

    final duration = frame - gameObject.frameSpawned;

    if (duration < Gamestream.Frames_Per_Second * 1)
      return;

    player.pickupItem(gameObject.item);
    deactivate(gameObject);
  }

  @override
  void customOnInteraction(Character character, Character target) {
    super.customOnInteraction(character, target);

    if (character is AmuletPlayer && target is MMONpc){
       character.interacting = true;
       target.interact?.call(character);
    }
  }
}