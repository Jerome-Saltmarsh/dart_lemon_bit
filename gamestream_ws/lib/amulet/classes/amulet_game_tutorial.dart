
import 'package:gamestream_ws/amulet/src.dart';
import 'package:gamestream_ws/isometric/src.dart';
import 'package:gamestream_ws/packages.dart';

import 'amulet_player_script.dart';
import 'fiend_type.dart';


class AmuletGameTutorial extends AmuletGame {

  static const keysGuideSpawn0 = 'guide_spawn_0';
  static const keysGuideSpawn1 = 'guide_spawn_1';
  static const keysPlayerSpawn = 'player_spawn_00';
  static const keysDoor01 = 'door01';
  static const keysDoor02 = 'door02';
  static const keysDoor03 = 'door03';
  static const keysFiend01 = 'fiend01';
  static const keysFiend02 = 'fiend02';
  static const keysSpawnBow = 'spawn_bow';
  static const keysExit = 'exit';

  static const flagsDoor01Opened = 'door01_opened';
  static const flagsDoor02Opened = 'door02_opened';
  static const flagsDoor03Opened = 'door03_opened';
  static const flagsFiend01Defeated = 'fiend01_defeated';
  static const flagsBowAddedToWeapons = 'add_bow_to_weapons';

  static const objectiveTalkToGuide01 = 'talk_to_guide_01';
  static const objectiveUseHeal = 'use_heal';
  static const objectiveBowObtained = 'bow_obtained';
  static const objectiveEquipBow = 'equip_bow';
  static const objectiveDrawBow = 'draw_bow';
  static const objectiveOpenInventory = 'open_inventory';
  static const objectiveKillFiends02 = 'kill_fiends02';
  static const objectiveOpenBridge = 'open_bridge';
  static const objectiveShootCrystal = 'shoot_crystal';

  final scripts = <AmuletPlayerScript>[];

  late final Character guide;
  Character? fiend01;
  final fiends02 = <Character>[];
  GameObject? crystal;


  AmuletGameTutorial({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
    required super.name,
    required super.fiendTypes,
  }) {
    guide = buildAmuletNpcGuide();
    add(guide);
  }

  void refreshPlayerGameState(AmuletPlayer player) {

    if (player.flagSet(flagsDoor01Opened)){
      setNodeEmpty(getSceneKey(keysDoor01));
    } else {
      setNode(
        nodeIndex: getSceneKey(keysDoor01),
        nodeType: NodeType.Wood,
        nodeOrientation: NodeOrientation.Half_West,
      );
    }

    if (player.flagSet(flagsDoor02Opened)){
      setNodeEmpty(getSceneKey(flagsDoor02Opened));
    } else {
      setNode(
          nodeIndex: getSceneKey(keysDoor02),
          nodeType: NodeType.Brick,
          nodeOrientation: NodeOrientation.Solid,
      );
    }

    if (player.flagNotSet(flagsFiend01Defeated)){
      actionInstantiateFiend01();
    }

    if (player.readFlag('initialized')) {
      actionInitializeNewPlayer(player);
    }

    if (player.readFlag('introduction')){
      runScriptIntroduction(player);
    }
    
    if (!player.objectiveCompleted('destroy_crystal')){
      crystal = spawnGameObjectAtIndex(
          index: getSceneKey('bow_target'),
          type: ItemType.Object,
          subType: ObjectType.Crystal,
          team: AmuletTeam.Monsters,
      );
    }

    if (!player.objectivesCompleted.contains(objectiveBowObtained)){
      spawnAmuletItemAtIndex(
        item: AmuletItem.Weapon_Old_Bow,
        index: getSceneKey(keysSpawnBow),
        deactivationTimer: -1,
      );
    }
  }

  void runScriptIntroduction(AmuletPlayer player) {
    runScript(player)
      .controlsDisabled()
      .zoom(1.5)
      .movePlayerToSceneKey(keysPlayerSpawn)
      .snapCameraToPlayer()
      .movePositionToSceneKey(guide, keysGuideSpawn0)
      .wait(seconds: 1)
      .cameraSetTarget(guide)
      .faceEachOther(player, guide)
      .talk(
        'greetings other.'
        'one is here to to guide another.'
        'move by left clicking the mouse'
      )
      .movePositionToSceneKey(guide, keysGuideSpawn1)
      .dataSet('objective', objectiveTalkToGuide01)
      .controlsEnabled()
      .cameraClearTarget()
    ;
  }

  AmuletNpc buildAmuletNpcGuide() => AmuletNpc(
    name: 'Guide',
    interact: onInteractedWithGuide,
    x: 1000,
    y: 1400,
    z: 25,
    team: AmuletTeam.Human,
    characterType: CharacterType.Kid,
    health: 50,
    weaponType: WeaponType.Unarmed,
    weaponDamage: 1,
    weaponRange: 50,
    weaponCooldown: 50,
    invincible: true,
  )
    ..complexion = 20
    ..invincible = true
    ..legsType = LegType.Leather
    ..bodyType = BodyType.Leather_Armour;

  int getSceneKey(String name) =>
      scene.keys[name] ?? (throw Exception('amuletGameTutorial.getKey("$name") is null'));

  void onNodeChanged(int index) {
    final players = this.players;
    final scene = this.scene;
    for (final player in players) {
      player.writeNode(
        index: index,
        type: scene.types[index],
        shape: scene.shapes[index],
      );
    }
  }

  @override
  void update() {
    super.update();
    updateScripts();
    updatePlayersObjectiveConditions();
  }

  void updatePlayersObjectiveConditions() {
    for (final player in players){
       updatePlayerObjectiveConditions(player);
    }
  }

  void updatePlayerObjectiveConditions(AmuletPlayer player) {
    switch (player.objective) {
      case objectiveDrawBow:
        if (player.equippedWeapon?.amuletItem != AmuletItem.Weapon_Old_Bow){
          return;
        }
        runScript(player)
          .objective(objectiveOpenBridge)
          .cameraSetTarget(guide)
          .talk(
            'good.'
            'fire at any time by pressing the right mouse button.'
          )
          .deactivate(guide)
          .end()
        ;
        break;
    }
  }

  void updateScripts() {
    final scripts = this.scripts;
    for (var i = 0; i < scripts.length; i++){
      final script = scripts[i];
      if (script.finished){
        scripts.removeAt(i);
        i--;
      } else {
        script.update();
      }
    }
  }

  void onInteractedWithGuide(AmuletPlayer player){

    switch (player.objective) {
      case objectiveTalkToGuide01:
        runScript(player)
            .completeObjective()
            .controlsDisabled()
            .activate(guide)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk('danger doth lieth ahead')
            .add(actionSpawnWeaponSwordAtGuide)
            .deactivate(guide)
            .end();
        break;
      case objectiveUseHeal:
        runScript(player)
            .controlsDisabled()
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk('caste heal by pressing the heal icon at the bottom of the screen.')
            .end();
        break;

      case objectiveOpenInventory:
        runScript(player)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk('open the inventory by hovering the mouse over the inventory icon at the bottom left corner of the screen')
            .end();
        break;

      case objectiveEquipBow:
        runScript(player)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk('add the bow to the weapons rack by clicking the bow icon in the inventory')
            .end();
        break;
      case objectiveDrawBow:
        runScript(player)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk('draw the bow by pressing the bow icon at the bottom of the screen.')
            .end();
        break;
      default:
        break;
    }

  }

  bool objectiveActiveSpeakToGuide(AmuletPlayer player) => player.readFlag('guide_met');

  void actionSetCameraTargetGuide(AmuletPlayer player) {
    actionSetCameraTarget(player, guide);
  }

  void actionSpawnWeaponSwordAtGuide() =>
    spawnAmuletItem(
      item: AmuletItem.Weapon_Rusty_Old_Sword,
      x: guide.x,
      y: guide.y,
      z: guide.z,
      deactivationTimer: -1
    );

  void actionDeactivateGuide() {
    deactivate(guide);
  }

  @override
  void customOnCharacterKilled(Character target, src) {
    super.customOnCharacterKilled(target, src);

    if (target == fiend01) {
      onCharacterKilledFiend01(target);
      return;
    }

    if (fiends02.contains(target) && !fiends02.any((element) => element.alive)){
      runScriptExplainElements(players.first);
    }
  }

  void onCharacterKilledFiend01(Character target) {
    actionSpawnAmuletItemSpellHeal(target);
  }

  void actionSpawnAmuletItemSpellHeal(Character target) {
    spawnAmuletItem(
        item: AmuletItem.Spell_Heal,
        x: target.x,
        y: target.y,
        z: target.z,
        deactivationTimer: -1,
    );
  }

  @override
  void onPlayerJoined(AmuletPlayer player) {
    refreshPlayerGameState(player);
  }

  @override
  void customOnPlayerRevived(AmuletPlayer player) {
    super.customOnPlayerRevived(player);
    refreshPlayerGameState(player);
  }

  void actionMoveOxToSceneKey(String sceneKey){
    actionMovePositionToSceneKey(guide, sceneKey);
  }

  void actionMovePositionToSceneKey(Position position, String sceneKey){
    movePositionToIndex(position, getSceneKey(sceneKey));
  }

  void actionWritePlayerPositionAbsolute(AmuletPlayer player) {
    player.writePlayerPositionAbsolute();
  }

  void actionInstantiateFiend01() {
    fiend01 = spawnFiendTypeAtIndex(
        fiendType: FiendType.Fallen_01,
        index: getSceneKey(keysFiend01),
    )
      ..spawnLootOnDeath = false
      ..respawnDurationTotal = -1;
  }

  void actionInitializeNewPlayer(AmuletPlayer player) {
    for (final weapon in player.weapons){
      weapon.amuletItem = null;
    }
    player.equippedWeaponIndex = -1;
    player.healthBase = 15;
    player.equipBody(AmuletItem.Armor_Leather_Basic, force: true);
    player.equipLegs(AmuletItem.Pants_Travellers, force: true);
    player.health = player.maxHealth;
  }

  @override
  void onAmuletItemUsed(AmuletPlayer player, AmuletItem amuletItem) {
    if (
      amuletItem == AmuletItem.Spell_Heal &&
      player.objective == objectiveUseHeal
    ) {
      onSpellHealUsedForTheFirstTime(player);
    }
  }

  void actionSpawnFiends02() {
    final fiend02Index = getSceneKey(keysFiend02);
    for (var i = 0; i < 3; i++) {
      const shiftRadius = 10;
      fiends02.add(
      spawnFiendTypeAtIndex(
        fiendType: FiendType.Fallen_01,
        index: fiend02Index,
      )
        ..spawnLootOnDeath = false
        ..respawnDurationTotal = -1
        ..x += giveOrTake(shiftRadius)
        ..y += giveOrTake(shiftRadius)
      );
    }
  }

  void onAcquiredWeaponSword(AmuletPlayer player) {
    runScript(player)
      .controlsDisabled()
      .wait(seconds: 1)
      .cameraSetTargetSceneKey(keysDoor01)
      .wait(seconds: 2)
      .setNodeEmptyAtSceneKey(keysDoor01)
      .flag(flagsDoor01Opened)
      .wait(seconds: 1)
      .controlsEnabled();
  }

  void actionSetCameraTarget(AmuletPlayer player, Position? target) {
      player.cameraTarget = target;
  }

  @override
  void onAmuletItemAcquired(AmuletPlayer player, AmuletItem amuletItem) {
    if (amuletItem == AmuletItem.Weapon_Rusty_Old_Sword){
      if (player.readFlag('acquired_weapon_sword')){
        onAcquiredWeaponSword(player);
      }
      return;
    }

    if (amuletItem == AmuletItem.Spell_Heal){
      if (player.readFlag('acquired_spell_heal')){
        startObjectiveUseHeal(player);
      }
      return;
    }

    if (amuletItem == AmuletItem.Weapon_Old_Bow){
      if (player.readFlag('acquired_weapon_old_bow')){
        startObjectiveOpenInventory(player);
      }
      return;
    }
  }

  void startObjectiveUseHeal(AmuletPlayer player) =>
      runScript(player)
      .controlsDisabled()
      .movePositionToSceneKey(guide, keysFiend01)
      .activate(guide)
      .wait(seconds: 1)
      .cameraSetTarget(guide)
      .faceEachOther(player, guide)
      .talk(
        'one has acquired the spell of healing.'
        'caste heal by pressing the heal icon at the bottom of the screen'
      )
      .objective(objectiveUseHeal)
      .end();

  void onSpellHealUsedForTheFirstTime(AmuletPlayer player) => runScript(player)
      .controlsDisabled()
      .wait(seconds: 1)
      .faceEachOther(player, guide)
      .talk(
        'one has done well.'
        'each item has a limited number of charges.'
        'charges replenish over time.',
        target: guide,
      )
      .cameraSetTargetSceneKey(keysDoor02)
      .wait(seconds: 1)
      .setNodeEmptyAtSceneKey(keysDoor02)
      .objective(objectiveKillFiends02)
      .flag(flagsDoor02Opened)
      .wait(seconds: 1)
      .deactivate(guide)
      .add(actionSpawnFiends02)
      .controlsEnabled();

  void runScriptExplainElements(AmuletPlayer player) {
      runScript(player)
          .controlsDisabled()
          .wait(seconds: 1)
          .movePositionToSceneKey(guide, keysFiend02)
          .activate(guide)
          .faceEachOther(player, guide)
          .talk(
            'congratulations.'
            'one has gained a level.'
            'one must learn of the elements.'
            'five types there are.'
            'fire.'
            'water.'
            'wind.'
            'earth.'
            'electricity.'
            'the power of every item is determined by these elements.'
            'for example.'
            'the sword one doth possess is at level 1.'
            'level two demands one hath at least 1 element of fire.'
            'hover the mouse over an item to see this information.'
            'one can see ones elements at the top left corner of the screen.'
            'each level gained allows one to improve one element.'
            'one may select an element to improve it.'
            'another challenge doth await one.'
          )
          .deactivate(guide)
          .wait(seconds: 1)
          .cameraSetTargetSceneKey(keysDoor03)
          .wait(seconds: 1)
          .setNodeEmptyAtSceneKey(keysDoor03)
          .wait(seconds: 1)
          .end();
  }

  void startObjectiveOpenInventory(AmuletPlayer player) {
    runScript(player)
        .controlsDisabled()
        .add(() {
          for (final weapon in player.weapons){
            if (weapon.amuletItem == AmuletItem.Weapon_Old_Bow){
              player.swapAmuletItemSlots(
                  weapon,
                  player.getEmptyItemSlot(),
              );
            }
          }
        })
        .movePositionToSceneKey(guide, keysSpawnBow)
        .cameraSetTarget(guide)
        .wait(seconds: 1)
        .activate(guide)
        .wait(seconds: 1)
        .objective(objectiveOpenInventory)
        .faceEachOther(player, guide)
        .talk(
          'one hath acquired a new weapon.'
          'one must now learn of the inventory.'
          'open the inventory by hovering the mouse over the inventory icon at the bottom left corner of the screen'
        )
        .end();

  }

  @override
  void onPlayerInventoryOpenChanged(AmuletPlayer player, bool value) {
    if (value && player.objective == objectiveOpenInventory){
      startObjectiveEquipBow(player);
    }
  }

  void startObjectiveEquipBow(AmuletPlayer player) => runScript(player)
        .objective(objectiveEquipBow)
        .faceEachOther(player, guide)
        .talk(
          'add the bow to the weapons rack by clicking the bow icon in the inventory',
          target: guide
        );

  @override
  void onPlayerInventoryMoved(
      AmuletPlayer player,
      AmuletItemSlot srcAmuletItemSlot,
      AmuletItemSlot targetAmuletItemSlot,
  ) {
    if (
      player.weapons.contains(targetAmuletItemSlot) &&
      targetAmuletItemSlot.amuletItem == AmuletItem.Weapon_Old_Bow &&
      player.objective == objectiveEquipBow
    ) {
      startObjectiveDrawBow(player);
    }
  }

  void startObjectiveDrawBow(AmuletPlayer player) => runScript(player)
      .controlsDisabled()
      .cameraSetTarget(guide)
      .faceEachOther(player, guide)
      .objective(objectiveDrawBow)
      .talk(
        'excellent.'
        'draw the bow by clicking the bow icon at the bottom of the screen'
      )
      .end();

  AmuletPlayerScript runScript(AmuletPlayer player){
    final instance = AmuletPlayerScript(player);
    scripts.clear();
    scripts.add(instance);
    return instance;
  }

  @override
  void customOnCharacterDamageApplied(Character target, src, int amount) {
    // TODO: implement customOnCharacterDamageApplied
    super.customOnCharacterDamageApplied(target, src, amount);
  }

  @override
  void applyHit({required Character srcCharacter, required Collider target, required int damage, double? angle, bool friendlyFire = false}) {
    super.applyHit(
        srcCharacter: srcCharacter,
        target: target,
        damage: damage,
        angle: angle,
        friendlyFire: friendlyFire,
    );

    if (target == crystal){
      if (srcCharacter is AmuletPlayer){
        if (!srcCharacter.objectiveCompleted(objectiveShootCrystal)) {
          srcCharacter.objectivesCompleted.add(objectiveShootCrystal);
          runScript(srcCharacter)
            .controlsDisabled()
            .wait(seconds: 1)
            .cameraSetTargetSceneKey(keysExit)
            .wait(seconds: 1)
            .setNodeEmptyAtSceneKey(keysExit)
            .wait(seconds: 1)
            .end();
        }
      }
    }
  }
}

