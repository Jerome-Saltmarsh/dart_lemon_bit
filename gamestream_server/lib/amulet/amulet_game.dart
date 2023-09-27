import 'package:gamestream_server/gamestream/gamestream_server.dart';
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/packages.dart';

import 'talk_option.dart';
import 'mmo_gameobject.dart';
import 'mmo_npc.dart';
import 'amulet_player.dart';

class AmuletGame extends IsometricGame<AmuletPlayer> {

  final chanceOfDropItemOnGrassCut = 0.25;
  final gameObjectDeactivationTimer = 5000;
  final enemyRespawnDuration = 30; // in seconds

  final playerSpawnX = 2030.0;
  final playerSpawnY = 2040.0;
  final playerSpawnZ = 25.0;

  var cooldownTimer = 0;

  late MMONpc npcGuard;

  AmuletGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Amulet) {

    spawnMonstersAtSpawnNodes();
    characters.add(MMONpc(
      characterType: CharacterType.Kid,
      x: 2010,
      y: 1760,
      z: 24,
      health: 50,
      team: AmuletTeam.Human,
      weaponType: WeaponType.Unarmed,
      weaponDamage: 1,
      weaponRange: 200,
      weaponCooldown: 30,
      name: "Sybil",
      interact: (player) {
        player.talk("Hello there", options: [
          TalkOption("Goodbye", player.endInteraction),
          TalkOption("Buy", player.endInteraction),
        ]);
      }
    )..invincible = true
        ..helmType = HelmType.None
        ..bodyType = BodyType.Leather_Armour
        ..legsType = LegType.Leather
        ..complexion = ComplexionType.fair
    );

    npcGuard = MMONpc(
      characterType: CharacterType.Kid,
      x: 2416,
      y: 1851,
      z: 24,
      health: 200,
      weaponType: WeaponType.Bow,
      weaponRange: 200,
      weaponDamage: 1,
      weaponCooldown: 30,
      team: AmuletTeam.Human,
      name: "Guard",
    )
      ..invincible = true
      ..helmType = HelmType.Steel
      ..bodyType = BodyType.Leather_Armour
      ..legsType = LegType.Leather
      ..attackDuration = 30
      ..attackActionFrame = 20
      ..complexion = ComplexionType.fair;

    characters.add(npcGuard);
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

    cooldownTimer = GamestreamServer.Frames_Per_Second;
    for (final player in players) {
      player.reduceCooldown();
    }
  }

  // @override
  // void endCharacterAction(Character character) {
  //   if (character.characterTypeZombie){
  //     setCharacterStateIdle(character, duration: randomInt(50, 250));
  //     return;
  //   }
  //
  //   super.endCharacterAction(character);
  // }

  static void validate() => AmuletItem.values.forEach((item) => item.validate());

  void spawnMonstersAtSpawnNodes() {
    final marks = scene.marks;
    final length = marks.length;
    for (var i = 0; i < length; i++){
      final markValue = marks[i];
      final markType = MarkType.getType(markValue);
      if (markType != MarkType.Spawn_Fallen)
         continue;

      final markIndex = MarkType.getIndex(markValue);
       for (var j = 0; j < 3; j++){
         if (randomBool()){
           spawnFallenAtIndex(markIndex);
         } else {
           spawnSkeletonArcherAtIndex(markIndex);
         }
       }
    }
  }

  void spawnFallenAtIndex(int index) {
    characters.add(Character(
      team: AmuletTeam.Monsters,
      x: scene.getIndexX(index),
      y: scene.getIndexY(index),
      z: scene.getIndexZ(index),
      health: 7,
      weaponDamage: 1,
      characterType: CharacterType.Fallen,
      weaponType: WeaponType.Unarmed,
      weaponCooldown: 20,
      weaponRange: 20,
      actionFrame: 15,
      doesWander: true,
      name: 'Fallen',
      runSpeed: 0.75,
    )
      ..weaponHitForce = 2
      ..attackDuration = 20
      ..attackActionFrame = 12
    );
  }

  void spawnSkeletonArcherAtIndex(int index) {
    characters.add(Character(
      team: AmuletTeam.Monsters,
      x: scene.getIndexX(index),
      y: scene.getIndexY(index),
      z: scene.getIndexZ(index),
      health: 7,
      weaponDamage: 1,
      characterType: CharacterType.Skeleton,
      weaponType: WeaponType.Bow,
      weaponRange: 220,
      weaponCooldown: 30,
      actionFrame: 15,
      doesWander: true,
      name: 'Skeleton',
      runSpeed: 0.75,
    )
      ..weaponHitForce = 2
      ..attackDuration = 20
      ..attackActionFrame = 12
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
      case AmuletAttackType.Fire_Ball:
        spawnProjectileFireball(
          src: character,
          damage: item.damage,
          range: item.range,
          angle: character.angle,
        );
        break;
      case AmuletAttackType.Melee:
        applyAttackTypeMelee(character);
        break;
      case AmuletAttackType.Arrow:
        dispatchGameEvent(
          GameEventType.Bow_Released,
          character.x,
          character.y,
          character.z,
        );
        spawnProjectileArrow(
          src: character,
          damage: item.damage,
          range: item.range,
          angle: character.angle,
        );
        break;
      case AmuletAttackType.Bullet:
        spawnProjectile(
          src: character,
          damage: item.damage,
          range: item.range,
          projectileType: ProjectileType.Bullet,
          angle: character.angle,
        );
        break;
      case AmuletAttackType.Frost_Ball:
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

  AmuletItemQuality? getRandomItemQuality({
      double chanceOfMythical = 0.005,
      double chanceOfRare = 0.015,
      double chanceOfMagic = 0.05,
      double chanceOfCommon = 0.3,
    }){

    final value = random.nextDouble();

    if (value <= chanceOfMythical) {
      return AmuletItemQuality.Mythical;
    }

    if (value <= chanceOfRare) {
      return AmuletItemQuality.Rare;
    }

    if (value <= chanceOfMagic) {
      return AmuletItemQuality.Unique;
    }

    if (value <= chanceOfCommon) {
      return AmuletItemQuality.Common;
    }

    return null;
  }


  @override
  void customOnCharacterKilled(Character target, src) {
    if (target.characterType == CharacterType.Fallen) {

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

  void spawnRandomLootAtPosition(Position position, AmuletItemQuality quality )=>
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
    required AmuletItemQuality quality,
  }) => spawnLoot(
      x: x,
      y: y,
      z: z,
      item: randomItem(AmuletItem.findByQuality(quality)),
  );

  void spawnLootAtIndex({required int index, required AmuletItem item}) => spawnLoot(
    x: scene.getIndexX(index),
    y: scene.getIndexY(index),
    z: scene.getIndexZ(index),
    item: item,
  );

  void spawnLoot({
    required double x,
    required double y,
    required double z,
    required AmuletItem item,
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
   ..complexion = ComplexionType.fair
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
          spawnLootAtIndex(index: nodeIndex, item: AmuletItem.Meat_Drumstick);
        }
        break;
    }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(AmuletPlayer player, GameObject gameObject) {
    if (gameObject is! MMOGameObject || gameObject.item.collectable)
      return;

    final duration = frame - gameObject.frameSpawned;

    if (duration < GamestreamServer.Frames_Per_Second * 1)
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

  List<int> getMarkTypes(int markType) =>
      scene.marks.where((markValue) => MarkType.getType(markValue) == markType).toList(growable: false);

  void spawnRandomEnemy() {
    final marks = scene.marks;
    if (marks.isEmpty){
      return;
    }
    final spawnFallens = getMarkTypes(MarkType.Spawn_Fallen);
    if (spawnFallens.isEmpty)
      return;

    final markValue = randomItem(spawnFallens.toList());
    final index = MarkType.getIndex(markValue);
    spawnFallenAtIndex(index);
  }
}
