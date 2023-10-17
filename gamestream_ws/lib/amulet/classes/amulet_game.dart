import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/amulet/functions/player/player_change_game.dart';
import 'package:gamestream_ws/amulet/setters/amulet_player/clear_activated_power_index.dart';
import 'package:gamestream_ws/gamestream/gamestream_server.dart';
import 'package:gamestream_ws/isometric.dart';
import 'package:gamestream_ws/packages.dart';

import '../functions/item_slot/item_slot_reduce_charge.dart';

class AmuletGame extends IsometricGame<AmuletPlayer> {

  AmuletGame? gameNorth;
  AmuletGame? gameSouth;
  AmuletGame? gameEast;
  AmuletGame? gameWest;

  final String name;

  final chanceOfDropItemOnGrassCut = 0.25;
  final gameObjectDeactivationTimer = 5000;
  final enemyRespawnDuration = 30; // in seconds

  final playerSpawnX = 2030.0;
  final playerSpawnY = 2040.0;
  final playerSpawnZ = 25.0;

  var cooldownTimer = 0;

  late AmuletNpc npcGuard;

  AmuletGame({
    required super.scene,
    required super.time,
    required super.environment,
    required this.name,
    this.gameNorth,
    this.gameEast,
    this.gameSouth,
    this.gameWest,
  }) : super(gameType: GameType.Amulet) {

    spawnMonstersAtSpawnNodes();
    characters.add(AmuletNpc(
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

    npcGuard = AmuletNpc(
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
    updatePlayers();
  }

  void updatePlayers() {
    const padding = 25.0;
    final characters = this.characters;
    final gameNorth = this.gameNorth;
    final gameSouth = this.gameSouth;
    var length = characters.length;

    final maxX = scene.rowLength - padding;

    for (var i = 0; i < length; i++){
      final character = characters[i];
      if (character is! AmuletPlayer){
        continue;
      }
      final x = character.x;
      if (x < padding && gameNorth != null) {
        playerChangeGame(
          player: character,
          src: this,
          target: gameNorth,
        );
        character.x = gameNorth.scene.rowLength - 50;
        character.y = character.y.clamp(0, gameNorth.scene.columnLength);
        i--;
        length = characters.length;
        continue;
      }

      if (x > maxX && gameSouth != null){
        playerChangeGame(
          player: character,
          src: this,
          target: gameSouth,
        );
        character.x = padding + 25;
        character.y = character.y.clamp(0, gameSouth.scene.columnLength);
        i--;
        length = characters.length;
      }
    }

    if (gameNorth != null){
      for (final character in characters) {
        if (character.x < 50){

        }
      }
    }
  }

  void updateCooldownTimer() {
    if (cooldownTimer-- > 0)
      return;

    cooldownTimer = GamestreamServer.Frames_Per_Second;
    for (final player in players) {
      player.incrementWeaponCooldowns();
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
    final activeItemSlot = character.activeItemSlot;

    if (activeItemSlot == null) {
      return;
    }

    clearActivatedPowerIndex(character);

    final amuletItem = activeItemSlot.amuletItem;

    if (amuletItem == null){
      throw Exception('activeSlotItem == null');
    }

    final level = amuletItem.getLevel(
        fire: character.elementFire,
        water: character.elementWater,
        wind: character.elementWind,
        earth: character.elementEarth,
        electricity: character.elementElectricity,
    );

    if (level == -1){
      character.writeGameError(GameError.Insufficient_Elements);
      return;
    }

    final stats = amuletItem.getStatsForLevel(level);

    if (stats == null){
      throw Exception('stats == null');
    }

    switch (amuletItem) {
      case AmuletItem.Spell_Thunderbolt:
        performAbilityLightning(character);
        break;
      case AmuletItem.Spell_Blink:
        performAbilityBlink(character);
        break;
      case AmuletItem.Blink_Dagger:
        performAbilityBlink(character);
        break;
      case AmuletItem.Rusty_Old_Sword:
        performAbilityMelee(character);
        break;
      case AmuletItem.Old_Bow:
        performAbilityArrow(
            character: character,
            damage: stats.damage,
            range: stats.range,
        );
        break;
      case AmuletItem.Holy_Bow:
        performAbilityArrow(
          character: character,
          damage: stats.damage,
          range: stats.range,
        );
        break;
      case AmuletItem.Staff_Of_Frozen_Lake:
        performAbilityFrostBall(character, damage: 1, range: 50);
        break;
      default:
        throw Exception('amulet.PerformCharacterAction($amuletItem)');
    }
  }

  void performAbilityFrostBall(AmuletPlayer character, {required int damage, required double range}) {
     spawnProjectile(
      src: character,
      damage: damage,
      range: range,
      projectileType: ProjectileType.FrostBall,
      angle: character.angle,
    );
  }

  void performAbilityArrow({
    required Character character,
    required int damage,
    required double range,
  }) {
     dispatchGameEvent(
      GameEventType.Bow_Released,
      character.x,
      character.y,
      character.z,
    );
    spawnProjectileArrow(
      src: character,
      damage: damage,
      range: range,
      angle: character.angle,
    );
  }

  void performAbilityBlink(AmuletPlayer player){
    dispatchGameEventPosition(GameEventType.Blink_Depart, player);
    player.x = player.activePowerX;
    player.y = player.activePowerY;
    player.z = player.activePowerZ;
    dispatchGameEventPosition(GameEventType.Blink_Arrive, player);
  }

  void performAbilityLightning(Character character){
    var boltsRemaining = 3;
    final characters = this.characters;
    for (final otherCharacter in characters){
      if (!character.active || !character.isEnemy(otherCharacter)) {
        continue;
      }
      if (!character.withinRadiusPosition(otherCharacter, 300)){
        continue;
      }
      dispatchGameEventPosition(GameEventType.Lightning_Bolt, otherCharacter);
      applyHit(
        srcCharacter: character,
        target: otherCharacter,
        damage: 3,
      );
      boltsRemaining--;
      if (boltsRemaining <= 0) {
        return;
      }
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
      player.elementPoints++;
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
    gameObjects.add(AmuletGameObject(
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
      amulet: this,
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
    if (gameObject is AmuletGameObject) {
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
    if (gameObject is! AmuletGameObject || gameObject.item.collectable)
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

    if (character is AmuletPlayer && target is AmuletNpc){
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

  @override
  void characterAttack(Character character) {
    if (character is AmuletPlayer){
      final equippedWeaponIndex = character.equippedWeaponIndex;
      final weapons = character.weapons;
      final equippedWeapon = weapons[equippedWeaponIndex];

      if (!itemSlotChargesRemaining(equippedWeapon)) {
        character.writeGameError(GameError.Insufficient_Weapon_Charges);
        return;
      }

      itemSlotReduceCharge(equippedWeapon);
    }
    super.characterAttack(character);
  }

  bool itemSlotChargesRemaining(ItemSlot itemSlot) => itemSlot.charges > 0;

  void onPlayerLoaded(AmuletPlayer player) {
    playerRefillItemSlots(
        player: player,
        itemSlots: player.weapons,
    );
  }

  void playerRefillItemSlots({
    required AmuletPlayer player,
    required List<ItemSlot> itemSlots,
  }){
    for (final itemSlot in itemSlots) {
      playerRefillItemSlot(
          player: player,
          itemSlot: itemSlot,
      );
    }
    player.writeWeapons();
  }

  void playerRefillItemSlot({
    required AmuletPlayer player,
    required ItemSlot itemSlot,
  }){
    final amuletItem = itemSlot.amuletItem;
    if (amuletItem == null) {
      return;
    }
    final itemStats = player.getItemStatsForItemSlot(itemSlot);
    if (itemStats == null) {
      throw Exception('itemStats == null');
    }
    final max = itemStats.charges;
    itemSlot.max = max;
    itemSlot.charges = max;
    itemSlot.cooldown = 0;
    itemSlot.cooldownDuration = itemStats.cooldown;
  }
}
