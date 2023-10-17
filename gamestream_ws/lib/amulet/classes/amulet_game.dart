import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/amulet/functions/player/player_change_game.dart';
import 'package:gamestream_ws/amulet/setters/amulet_player/clear_activated_power_index.dart';
import 'package:gamestream_ws/gamestream/gamestream_server.dart';
import 'package:gamestream_ws/isometric.dart';
import 'package:gamestream_ws/packages.dart';

import '../functions/item_slot/item_slot_reduce_charge.dart';
import 'fiend_type.dart';


class AmuletGame extends IsometricGame<AmuletPlayer> {

  AmuletGame? gameNorth;
  AmuletGame? gameSouth;
  AmuletGame? gameEast;
  AmuletGame? gameWest;

  final List<FiendType> fiendTypes;
  final String name;
  final chanceOfDropItemOnGrassCut = 0.25;
  final gameObjectDeactivationTimer = 5000;
  final enemyRespawnDuration = 30; // in seconds
  var cooldownTimer = 0;

  AmuletGame({
    required super.scene,
    required super.time,
    required super.environment,
    required this.name,
    required this.fiendTypes,
  }) : super(gameType: GameType.Amulet) {
    spawnFiendsAtSpawnNodes();
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
    final players = this.players;
    final gameNorth = this.gameNorth;
    final gameSouth = this.gameSouth;
    final maxX = scene.rowLength - padding;

    var length = players.length;

    for (var i = 0; i < length; i++){
      final player = players[i];
      final x = player.x;
      if (x < padding && gameNorth != null) {
        playerChangeGame(
          player: player,
          src: this,
          target: gameNorth,
        );
        player.x = gameNorth.scene.rowLength - 50;
        player.y = player.y.clamp(0, gameNorth.scene.columnLength);
        player.writePlayerPosition();
        player.writePlayerEvent(PlayerEvent.Player_Moved);
        i--;
        length = players.length;
        continue;
      }

      if (x > maxX && gameSouth != null){
        playerChangeGame(
          player: player,
          src: this,
          target: gameSouth,
        );
        player.x = padding + 25;
        player.y = player.y.clamp(0, gameSouth.scene.columnLength);
        player.writePlayerPosition();
        player.writePlayerEvent(PlayerEvent.Player_Moved);
        i--;
        length = players.length;
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

  static void validate() => AmuletItem.values.forEach((item) => item.validate());

  void spawnFiendsAtSpawnNodes() {
    final marks = scene.marks;
    final length = marks.length;
    for (var i = 0; i < length; i++) {
      final markValue = marks[i];
      final markType = MarkType.getType(markValue);
      if (markType != MarkType.Spawn_Fallen){
        continue;
      }
      spawnFiendTypeAtIndex(
          fiendType: randomItem(fiendTypes),
          index: MarkType.getIndex(markValue),
      );
    }
  }

  void spawnFiendTypeAtIndex({
    required FiendType fiendType,
    required int index,
  }) {
    switch (fiendType){
      case FiendType.Fallen_01:
        spawnFallenAtIndex(index);
        break;
      case FiendType.Skeleton_01:
        spawnSkeletonArcherAtIndex(index);
        break;
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

  @override
  AmuletPlayer buildPlayer() {
    // TODO: implement buildPlayer
    throw UnimplementedError();
  }
}
