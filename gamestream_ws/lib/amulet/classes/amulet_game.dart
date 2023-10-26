import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/amulet/setters/amulet_player/clear_activated_power_index.dart';
import 'package:gamestream_ws/gamestream.dart';
import 'package:gamestream_ws/isometric.dart';
import 'package:gamestream_ws/packages.dart';

import '../functions/item_slot/item_slot_reduce_charge.dart';
import 'fiend_type.dart';


class AmuletGame extends IsometricGame<AmuletPlayer> {

  final Amulet amulet;

  AmuletGame? gameNorth;
  AmuletGame? gameSouth;
  AmuletGame? gameEast;
  AmuletGame? gameWest;

  final List<FiendType> fiendTypes;
  final String name;
  final chanceOfDropItemOnGrassCut = 0.25;
  final gameObjectDeactivationTimer = 5000;
  final AmuletScene amuletScene;
  var cooldownTimer = 0;

  AmuletGame({
    required this.amulet,
    required super.scene,
    required super.time,
    required super.environment,
    required this.name,
    required this.fiendTypes,
    required this.amuletScene,
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
        amulet.playerChangeGame(
          player: player,
          target: gameNorth,
        );
        player.x = gameNorth.scene.rowLength - 50;
        player.y = player.y.clamp(0, gameNorth.scene.columnLength);
        player.writePlayerPositionAbsolute();
        player.writePlayerEvent(PlayerEvent.Player_Moved);
        i--;
        length = players.length;
        continue;
      }

      if (x > maxX && gameSouth != null){
        amulet.playerChangeGame(
          player: player,
          target: gameSouth,
        );
        player.x = padding + 25;
        player.y = player.y.clamp(0, gameSouth.scene.columnLength);
        player.writePlayerPositionAbsolute();
        player.writePlayerEvent(PlayerEvent.Player_Moved);
        i--;
        length = players.length;
      }
    }
  }

  void updateCooldownTimer() {
    if (cooldownTimer-- > 0)
      return;

    cooldownTimer = Amulet.Frames_Per_Second;
    for (final player in players) {
      player.incrementWeaponCooldowns();
    }
  }

  void spawnFiendsAtSpawnNodes() {
    if (fiendTypes.isEmpty){
      return;
    }
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

  Character spawnFiendTypeAtIndex({
    required FiendType fiendType,
    required int index,
  }) {
    switch (fiendType){
      case FiendType.Fallen_01:
        return spawnCharacterAtIndex(index)
          ..maxHealth = 2
          ..health = 2
          ..name = 'Fallen'
          ..characterType = CharacterType.Fallen;
      case FiendType.Skeleton_01:
        return spawnCharacterAtIndex(index)
          ..maxHealth = 4
          ..health = 4
          ..name = 'Skeleton'
          ..characterType = CharacterType.Skeleton;
    }
  }

  Character spawnCharacterAtIndex(int index) =>
    spawnCharacterAtXYZ(
      x: scene.getIndexX(index),
      y: scene.getIndexY(index),
      z: scene.getIndexZ(index),
    );

  Character spawnCharacterAtXYZ({
    required double x,
    required double y,
    required double z,
  }) {
    final character = Character(
      team: AmuletTeam.Monsters,
      x: x,
      y: y,
      z: z,
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
      ..attackActionFrame = 12;

    characters.add(character);
    return character;
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
    addJob(seconds: 5, action: () {
      // setCharacterStateSpawning(player);
      revive(player);
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
      case AmuletItem.Weapon_Rusty_Old_Sword:
        performAbilityMelee(character);
        break;
      case AmuletItem.Weapon_Old_Bow:
        performAbilityArrow(
            character: character,
            damage: stats.damage,
            range: stats.range,
        );
        break;
      case AmuletItem.Weapon_Holy_Bow:
        performAbilityArrow(
          character: character,
          damage: stats.damage,
          range: stats.range,
        );
        break;
      case AmuletItem.Weapon_Staff_Of_Frozen_Lake:
        performAbilityFrostBall(character, damage: 1, range: 50);
        break;
      case AmuletItem.Spell_Heal:
        useAmuletItemSpellHeal(character);
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

    if (target.spawnLootOnDeath){
      final itemQuality = getRandomItemQuality();
      if (itemQuality != null){
        spawnRandomLootAtPosition(target, itemQuality);
      }
    }

    if (target.respawnDurationTotal > 0){
      addJob(seconds: target.respawnDurationTotal, action: () {
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
      onPlayerLevelGained(player);
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
  }) => spawnAmuletItem(
      x: x,
      y: y,
      z: z,
      item: randomItem(AmuletItem.findByQuality(quality)),
  );

  /// @deactivationTimer set to -1 to prevent amulet item from deactivating over time
  AmuletGameObject spawnAmuletItemAtIndex({
    required int index,
    required AmuletItem item,
    int? deactivationTimer
  }) =>
      spawnAmuletItem(
        x: scene.getIndexX(index),
        y: scene.getIndexY(index),
        z: scene.getIndexZ(index),
        item: item,
        deactivationTimer: deactivationTimer
      );

  AmuletGameObject spawnAmuletItem({
    required AmuletItem item,
    required double x,
    required double y,
    required double z,
    int? deactivationTimer
  }) {
    final amuletGameObject = AmuletGameObject(
      x: x,
      y: y,
      z: z,
      item: item,
      id: generateId(),
      frameSpawned: frame,
      deactivationTimer: deactivationTimer ?? gameObjectDeactivationTimer,
    )
      ..physicsVelocityZ = 10
      ..setVelocity(randomAngle(), 1.0);

    add(amuletGameObject);
    return amuletGameObject;
  }

  int getExperienceRequiredForLevel(int level){
    return level * 5;
  }

  @override
  void onCharacterCollectedGameObject(
    Character character,
    GameObject gameObject,
  ) {

    if (
      character is! AmuletPlayer ||
      gameObject is! AmuletGameObject
    ) return;


    if (character.acquireAmuletItem(gameObject.item)) {
      super.onCharacterCollectedGameObject(character, gameObject);
    }
  }

  @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    switch (nodeType){
      case NodeType.Grass_Long:
        if (randomChance(chanceOfDropItemOnGrassCut)){
          spawnAmuletItemAtIndex(index: nodeIndex, item: AmuletItem.Meat_Drumstick);
        }
        break;
    }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(AmuletPlayer player, GameObject gameObject) {
    if (gameObject is! AmuletGameObject || gameObject.item.collectable)
      return;

    final duration = frame - gameObject.frameSpawned;

    if (duration < Amulet.Frames_Per_Second * 1)
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
    spawnCharacterAtIndex(index);
  }

  @override
  void characterAttack(Character character) {
    if (character is AmuletPlayer){
      final equippedWeaponIndex = character.equippedWeaponIndex;

      if (equippedWeaponIndex == -1){
        character.writeGameError(GameError.No_Weapon_Equipped);
        return;
      }

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

  bool itemSlotChargesRemaining(AmuletItemSlot itemSlot) => itemSlot.charges > 0;

  @override
  AmuletPlayer buildPlayer() {
    // TODO: implement buildPlayer
    throw UnimplementedError();
  }

  void endPlayerInteraction(AmuletPlayer player) =>
      player.endInteraction();

  void useAmuletItemSpellHeal(AmuletPlayer character) {

    final stats = character.getStatsForAmuletItem(AmuletItem.Spell_Heal);
    if (stats == null) {
      character.writeGameError(GameError.Insufficient_Elements);
      return;
    }

    character.health += stats.health;

    dispatchGameEventPosition(GameEventType.Spell_Used, character);
    dispatchByte(SpellType.Heal);
  }

  void onAmuletItemUsed(AmuletPlayer amuletPlayer, AmuletItem amuletItem) {}

  void onAmuletItemAcquired(AmuletPlayer amuletPlayer, AmuletItem amuletItem) {}

  void onPlayerLevelGained(AmuletPlayer player) {}

  void onPlayerInventoryMoved(
      AmuletPlayer player,
      AmuletItemSlot srcAmuletItemSlot,
      AmuletItemSlot targetAmuletItemSlot,
  ) {}

  void onPlayerInventoryOpenChanged(AmuletPlayer player, bool value) { }

  @override
  void customDownloadScene(IsometricPlayer player) {
    super.customDownloadScene(player);
    player.writeByte(NetworkResponse.Amulet);
    player.writeByte(NetworkResponseAmulet.Amulet_Scene);
    player.writeByte(amuletScene.index);
  }

}
