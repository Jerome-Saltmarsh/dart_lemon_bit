
import '../../packages/isometric_engine/packages/common/src/amulet/quests/quest_tutorials.dart';
import '../../packages/src.dart';
import '../amulet_game.dart';
import '../amulet_npc.dart';
import '../amulet_player.dart';
import '../amulet_player_script.dart';


class AmuletGameTutorial extends AmuletGame {

  static const keysGuideSpawn0 = 'guide_spawn_0';
  static const keysGuideSpawn1 = 'guide_spawn_1';
  static const keysPlayerSpawn0 = 'player_spawn_00';
  static const keysDoor01 = 'door01';
  static const keysDoor02 = 'door02';
  static const keysDoor03 = 'door03';
  static const keysFiend01 = 'fiend01';
  static const keysFiend02 = 'fiend02';
  static const keysSpawnBow = 'spawn_bow';
  static const keysExit = 'exit';
  static const keysFinish = 'finish';
  static const keysTriggerSpawnFiends02 = 'trigger_spawn_fiends_02';
  static const keysCrystal1 = 'crystal_1';
  static const keysCrystal2 = 'crystal_2';
  static const flagsBowAddedToWeapons = 'add_bow_to_weapons';
  static const keysRoom4 = 'room_4';

  var indexLeave = -1;

  static const objectives = QuestTutorial.values;

  final scripts = <AmuletPlayerScript>[];

  late final Character guide;
  Character? fiend01;
  final fiends02 = <Character>[];

  late GameObject crystal1GlowingFalse;
  late GameObject crystal1GlowingTrue;
  late GameObject crystal2GlowingFalse;
  late GameObject crystal2GlowingTrue;

  AmuletGameTutorial({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
  }) : super (
      amuletScene: AmuletScene.Tutorial,
      name: 'tutorial'
  ){
    instantiateGuide();

    indexLeave = getSceneKey(keysFinish);

    crystal1GlowingFalse = spawnAtKeyCrystalGlowingFalse(keysCrystal1);
    crystal1GlowingTrue = spawnAtKeyCrystalGlowingTrue(keysCrystal1);

    crystal2GlowingFalse = spawnAtKeyCrystalGlowingFalse(keysCrystal2);
    crystal2GlowingTrue = spawnAtKeyCrystalGlowingTrue(keysCrystal2);
  }

  String getSpawnKey(QuestTutorial objective) => switch (objective){
       QuestTutorial.Acquire_Sword => keysPlayerSpawn0,
       QuestTutorial.Strike_Crystal_1 => keysPlayerSpawn0,
       QuestTutorial.Acquire_Heal => keysPlayerSpawn0,
       QuestTutorial.Use_Heal => keysFiend01,
       QuestTutorial.Vanquish_Fiends_02 => keysFiend01,
       QuestTutorial.Acquire_Bow => keysFiend01,
       QuestTutorial.Equip_Bow => keysRoom4,
       QuestTutorial.Draw_Bow => keysRoom4,
       QuestTutorial.Strike_Crystal_2 => keysRoom4,
       QuestTutorial.Leave => keysRoom4,
       QuestTutorial.Finished => keysRoom4,
    };

  void refreshPlayerGameState(AmuletPlayer player) {
    player.writeClearHighlightedAmuletItem();
    player.writeOptionsSetHighlightIconInventory(false);

    removeFiends();
    gameObjects.removeWhere((element) =>
      !element.persistable &&
      !const[GameObjectType.Crystal_Glowing_False, GameObjectType.Crystal_Glowing_True].contains(element.subType)
    );

    deactivate(crystal1GlowingFalse);
    deactivate(crystal1GlowingTrue);
    deactivate(crystal2GlowingFalse);
    deactivate(crystal2GlowingTrue);

    if (player.readOnce('tutorial_initialized')) {
      actionInitializeNewPlayer(player);
    }

    movePlayerToSpawnPoint(player);
    print("player.objective(${player.tutorialObjective})");

    switch (player.tutorialObjective){
      case QuestTutorial.Acquire_Sword:
        onObjectiveSetAcquireSword(player);
        break;
      case QuestTutorial.Use_Heal:
        onObjectiveSetUseHeal(player);
        break;
      case QuestTutorial.Draw_Bow:
        onObjectiveSetDrawBow(player);
        break;
      case QuestTutorial.Leave:
        onObjectiveSetLeave(player);
        break;
      default:
        break;
    }

    if (objectiveCompleted(player, QuestTutorial.Acquire_Sword)){
      // player.setWeapon(index: 0, amuletItem: AmuletItem.Weapon_Short_Sword);
      // player.equippedWeaponIndex = 0;
    }

    if (objectiveCompleted(player, QuestTutorial.Strike_Crystal_1)){
      setNodeEmpty(getSceneKey(keysDoor01));
      activate(crystal1GlowingTrue);
    } else {
      activate(crystal1GlowingFalse);
      setNode(
        nodeIndex: getSceneKey(keysDoor01),
        nodeType: NodeType.Wood,
        orientation: NodeOrientation.Half_West,
      );
    }

    // if (objectiveCompleted(player, QuestTutorial.Acquire_Heal)){
    //   player.setWeapon(index: 1, amuletItem: AmuletItem.Spell_Heal);
    // } else {
    //   actionInstantiateFiend01();
    // }

    if (objectiveCompleted(player, QuestTutorial.Use_Heal)){
      setNodeEmpty(getSceneKey(keysDoor02));
    } else {
      setNode(
          nodeIndex: getSceneKey(keysDoor02),
          nodeType: NodeType.Brick,
          orientation: NodeOrientation.Solid,
      );
    }

    if (!objectiveCompleted(player, QuestTutorial.Vanquish_Fiends_02)){
      spawnFiends02();
    }

    if (objectiveCompleted(player, QuestTutorial.Vanquish_Fiends_02)){
      setNodeEmpty(getSceneKey(keysDoor03));
    } else {
      setNode(
        nodeIndex: getSceneKey(keysDoor03),
        nodeType: NodeType.Brick,
        orientation: NodeOrientation.Solid,
      );
    }

    if (!objectiveCompleted(player, QuestTutorial.Acquire_Bow)){
      spawnAmuletItemAtIndex(
        item: AmuletItem.Weapon_Bow_1_Common,
        index: getSceneKey(keysSpawnBow),
        deactivationTimer: -1,
      );
    } else {
      // player.setWeapon(index: 2, amuletItem: AmuletItem.Weapon_Old_Bow);
    }

    if (objectiveCompleted(player, QuestTutorial.Strike_Crystal_2)) {
      activate(crystal2GlowingTrue);
    } else {
      activate(crystal2GlowingFalse);
      setNode(
        nodeIndex: getSceneKey(keysExit),
        nodeType: NodeType.Wood,
        orientation: NodeOrientation.Half_South,
      );
    }

    // player.refillItemSlotsWeapons();
    player.writeGameObjects();
  }

  void removeFiends() {
    characters.removeWhere((element) => element.characterType == CharacterType.Fallen);
  }

  void movePlayerToSpawnPoint(AmuletPlayer player) {
    scene.movePositionToKey(player, getSpawnKey(player.tutorialObjective));
    player.writePlayerMoved();
  }

  void instantiateGuide() {
    guide = AmuletNpc(
      name: 'Guide',
      weaponType: 0,
      weaponDamage: 0,
      weaponRange: 0,
      attackDuration: 0,
      interact: onInteractedWithGuide,
      x: 1000,
      y: 1400,
      z: 25,
      team: AmuletTeam.Human,
      health: 50,
      invincible: true,
    )
      ..autoTarget = false
      ..complexion = 0
      ..invincible = true
      // ..legsType = LegType.Leather
      ..armorType = ArmorType.Leather;

    add(guide);
    deactivate(guide);
  }

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
        variation: scene.variations[index],
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
    final players = this.players;
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      if (isObjectiveCompleted(player)) {
        startNextTutorialObjective(player);
      }
    }
  }

  bool isObjectiveCompleted(AmuletPlayer player) =>
    switch (player.tutorialObjective) {
       QuestTutorial.Draw_Bow =>
        player.equippedWeapon == AmuletItem.Weapon_Bow_1_Common,
       QuestTutorial.Leave => getNodeIndexV3(player) == indexLeave,
        _ => false
    };

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

  void startNextTutorialObjective(AmuletPlayer player){
     final current = player.tutorialObjective;

     switch (current) {
       case QuestTutorial.Draw_Bow:
         deactivate(guide);
         break;
       default:
         break;
     }

     final index = objectives.indexOf(current);
     final next = objectives[index + 1];
     setObjective(player, next);
  }

  void setObjective(
      AmuletPlayer player,
      QuestTutorial tutorialObjective,
  ){
    player.tutorialObjective = tutorialObjective;
    player.writeClearHighlightedAmuletItem();
    player.writeOptionsSetHighlightIconInventory(false);

    switch (tutorialObjective) {
      case QuestTutorial.Acquire_Sword:
        onObjectiveSetAcquireSword(player);
        break;
      case QuestTutorial.Strike_Crystal_1:
        onObjectiveSetStrikeCrystal1(player);
        break;
      case QuestTutorial.Acquire_Heal:
        break;
      case QuestTutorial.Use_Heal:
        onObjectiveSetUseHeal(player);
        break;
      case QuestTutorial.Vanquish_Fiends_02:
        break;
      case QuestTutorial.Acquire_Bow:
        break;
      case QuestTutorial.Equip_Bow:
        onObjectiveSetEquipBow(player);
        break;
      case QuestTutorial.Draw_Bow:
        onObjectiveSetDrawBow(player);
        break;
      case QuestTutorial.Strike_Crystal_2:
        break;
      case QuestTutorial.Leave:
        onObjectiveSetLeave(player);
        break;
      case QuestTutorial.Finished:
        onObjectiveFinished(player);
        break;
    }
  }

  void onObjectiveSetUseHeal(AmuletPlayer player) {
    runScript(player)
        .controlsDisabled()
        .movePositionToSceneKey(guide, keysFiend01)
        .activate(guide)
        .wait(seconds: 1)
        .cameraSetTarget(guide)
        .faceEachOther(player, guide)
        // .highlightAmuletItem(AmuletItem.Spell_Heal)
        .talk(guide,
          'one has acquired the spell of healing.'
          'press the flashing heal icon at the bottom of the screen'
        )
        .end();
  }

  bool objectiveCompleted(AmuletPlayer player, QuestTutorial objective) =>
      player.tutorialObjective.index > objective.index;

  void onInteractedWithGuide(AmuletPlayer player, AmuletNpc guide){
    final objective = player.tutorialObjective;
    switch (objective) {
      case QuestTutorial.Acquire_Sword:
        runScript(player)
            .controlsDisabled()
            .activate(guide)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk(guide, 'danger lies ahead')
            .deactivate(guide)
            .add(actionSpawnWeaponSwordAtGuide)
            .end();
        break;
      case QuestTutorial.Strike_Crystal_1:
        runScript(player)
            .controlsDisabled()
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk(guide, 'hover the mouse over a target and left click to strike it')
            .end();
        break;
      case QuestTutorial.Use_Heal:
        runScript(player)
            .controlsDisabled()
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            // .add(() => player.writeHighlightAmuletItems(AmuletItem.Spell_Heal))
            .talk(guide, 'caste heal by pressing the heal icon at the bottom of the screen.')
            .end();
        break;
      case QuestTutorial.Equip_Bow:
        runScript(player)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk(guide, 'add the bow to the weapons rack by clicking the bow icon in the inventory')
            .end();
        break;
      case QuestTutorial.Draw_Bow:
        runScript(player)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk(guide, 'draw the bow by pressing the bow icon at the bottom of the screen.')
            .end();
        break;
      case QuestTutorial.Leave:
        onObjectiveSetLeave(player);
        break;
      case QuestTutorial.Finished:
        onObjectiveSetLeave(player);
        break;
      default:
        break;
    }

  }

  void actionSpawnWeaponSwordAtGuide() =>
    spawnAmuletItem(
      item: AmuletItem.Weapon_Bow_1_Common,
      x: guide.x,
      y: guide.y,
      z: guide.z,
      deactivationTimer: -1
    );

  @override
  void customOnCharacterKilled(Character target, src) {
    super.customOnCharacterKilled(target, src);

    if (target == fiend01) {
      if (src is AmuletPlayer){
        runScript(src).puzzleSolved();
      }
      onCharacterKilledFiend01(target);
      return;
    }

    if (
      src is AmuletPlayer &&
      fiends02.contains(target) &&
      !fiends02.any((element) => element.alive) &&
      src.tutorialObjective == QuestTutorial.Vanquish_Fiends_02
    ){
      onFiends02Vanquished(players.first);
    }
  }

  void onCharacterKilledFiend01(Character target) {
    actionSpawnAmuletItemSpellHeal(target);
  }

  void actionSpawnAmuletItemSpellHeal(Character target) {
    // spawnAmuletItem(
    //     item: AmuletItem.Glove_Healers_Hand,
    //     x: target.x,
    //     y: target.y,
    //     z: target.z,
    //     deactivationTimer: -1,
    // );
  }

  @override
  void onPlayerJoined(AmuletPlayer player) {
    super.onPlayerJoined(player);
    refreshPlayerGameState(player);
  }

  @override
  void customOnPlayerRevived(AmuletPlayer player) {
    super.customOnPlayerRevived(player);
    refreshPlayerGameState(player);
  }

  void actionMoveOxToSceneKey(String sceneKey){
    movePositionToKey(guide, sceneKey);
  }

  void movePositionToKey(Position position, String sceneKey){
    movePositionToIndex(position, getSceneKey(sceneKey));
  }

  void actionWritePlayerPositionAbsolute(AmuletPlayer player) {
    player.writePlayerPositionAbsolute();
  }

  void actionInstantiateFiend01() {
    fiend01 = spawnFiendTypeAtIndex(
        fiendType: FiendType.Fallen,
        index: getSceneKey(keysFiend01),
    )
      ..maxHealth = 3
      ..health = 3
      ..respawnDurationTotal = -1;
  }

  void actionInitializeNewPlayer(AmuletPlayer player) {
    // for (final weapon in player.weapons){
    //   weapon.amuletItem = null;
    // }
    // player.equippedWeaponIndex = -1;
    // player.healthBase = 15;
    player.health = player.maxHealth;
  }

  @override
  void onAmuletItemUsed(AmuletPlayer player, AmuletItem amuletItem) {
    // if (
    //   amuletItem == AmuletItem.Glove_Healers_Hand &&
    //   player.tutorialObjective == QuestTutorial.Use_Heal
    // ) {
    //   onSpellHealUsedForTheFirstTime(player);
    // }
  }

  void spawnFiends02() {
    final fiend02Index = getSceneKey(keysFiend02);
    for (var i = 0; i < 3; i++) {
      const shiftRadius = 10;
      fiends02.add(
      spawnFiendTypeAtIndex(
        fiendType: FiendType.Fallen,
        index: fiend02Index,
      )
        ..respawnDurationTotal = -1
        ..x += giveOrTake(shiftRadius)
        ..y += giveOrTake(shiftRadius)
      );
    }
  }

  @override
  void onAmuletItemAcquired(AmuletPlayer player, AmuletItem amuletItem) {
    switch (amuletItem){
      case AmuletItem.Weapon_Bow_1_Common:
        if (player.tutorialObjective == QuestTutorial.Acquire_Sword){
          startNextTutorialObjective(player);
        }
        break;
      default:
        break;
    }
  }

  void onSpellHealUsedForTheFirstTime(AmuletPlayer player) {
    runScript(player)
      .clearHighlightedItem()
      .controlsDisabled()
      .wait(seconds: 1)
      .faceEachOther(player, guide)
      .talk(guide,
        'one has done well.'
        'each item has a limited number of charges.'
        'charges replenish over time.',
      )
      .cameraSetTargetSceneKey(keysDoor02)
      .wait(seconds: 1)
      .playAudioType(AudioType.unlock_2)
      .setNodeEmptyAtSceneKey(keysDoor02)
      .gameEventSceneKey(GameEvent.Spawn_Confetti, keysDoor02)
      .wait(seconds: 1)
      .deactivate(guide)
      .controlsEnabled()
      .add(() => startNextTutorialObjective(player));
  }

  void onFiends02Vanquished(AmuletPlayer player) =>
      runScript(player)
          .puzzleSolved()
          .controlsDisabled()
          .wait(seconds: 1)
          .movePositionToSceneKey(guide, keysFiend02)
          .activate(guide)
          .faceEachOther(player, guide)
          .talk(guide,
            'congratulations.'
            'one has gained a level.'
            'one will now learn of the elements.'
            'three types there are.'
            'fire.'
            'electricity.'
            'water.'
            'fire is strong against electricity.'
            'electricity is strong against water.'
            'water is strong against fire.'
            'the level of equipped items is determined by these elements.'
            'for example.'
            'the sword one doth possess is at level 1.'
            'level two requires at least 1 element of fire.'
            'hover the mouse over an item icon to see this information.'
            'one can see ones elements at the top left corner of the screen.'
            'one element point is gained per level.'
          )
          .deactivate(guide)
          .wait(seconds: 1)
          .cameraSetTargetSceneKey(keysDoor03)
          .wait(seconds: 1)
          .playAudioType(AudioType.unlock_2)
          .setNodeEmptyAtSceneKey(keysDoor03)
          .gameEventSceneKey(GameEvent.Spawn_Confetti, keysDoor03)
          .wait(seconds: 1)
          .end()
          .add(() => startNextTutorialObjective(player));


  void onObjectiveSetEquipBow(AmuletPlayer player) =>
    runScript(player)
      .faceEachOther(player, guide)
      .highlightAmuletItem(AmuletItem.Weapon_Bow_1_Common)
      .talk(guide,
        'add the bow to the weapons rack by clicking the bow icon in the inventory.',
      );

  AmuletPlayerScript runScript(AmuletPlayer player){
    final instance = AmuletPlayerScript(player);
    scripts.clear();
    scripts.add(instance);
    return instance;
  }

  @override
  void applyHit({
    required Character srcCharacter,
    required Collider target,
    required int damage,
    required DamageType damageType,
    double? angle,
    bool friendlyFire = false,
  }) {
    super.applyHit(
        srcCharacter: srcCharacter,
        target: target,
        damage: damage,
        angle: angle,
        friendlyFire: friendlyFire,
        damageType: damageType,
    );

    if (srcCharacter is! AmuletPlayer){
      return;
    }

    final player = srcCharacter;

    if (
      target == crystal1GlowingFalse &&
      srcCharacter.tutorialObjective == QuestTutorial.Strike_Crystal_1
    ){
      onStruckCrystal1(player);
      return;
    }

    if (target == crystal2GlowingFalse){
      onStruckCrystal2(player);
      return;
    }
  }

  /// zoom the camera in
  /// then return the camera zoom to the previous value
  void onStruckCrystal1(AmuletPlayer player) {
    runScript(player)
        .zoom(2)
        .deactivate(crystal1GlowingFalse)
        .activate(crystal1GlowingTrue)
        .gameEventPosition(GameEvent.Spawn_Confetti, crystal1GlowingTrue)
        .deactivate(guide)
        .puzzleSolved()
        .controlsDisabled()
        .wait(seconds: 1)
        .cameraSetTargetSceneKey(keysDoor01)
        .wait(seconds: 2)
        .playAudioType(AudioType.unlock_2)
        .setNodeEmptyAtSceneKey(keysDoor01)
        .gameEventSceneKey(GameEvent.Spawn_Confetti, keysDoor01)
        .wait(seconds: 1)
        .add(() => startNextTutorialObjective(player))
        .end();
  }

  @override
  void customOnPlayerDisconnected(IsometricPlayer player) {
    amulet.removeGame(this);
  }

  void onObjectiveSetAcquireSword(AmuletPlayer player) {
    runScript(player)
        .controlsDisabled()
        .zoom(1.5)
        .snapCameraToPlayer()
        .wait(seconds: 1)
        .movePositionToSceneKey(guide, keysGuideSpawn0)
        .cameraSetTarget(guide)
        .wait(seconds: 1)
        .gameEventPosition(GameEvent.Teleport_Start, guide)
        .activate(guide)
        .faceEachOther(player, guide)
        .wait(seconds: 1)
        .talk(guide,
          'greetings.'
          'one is here to to guide another.'
          'move by left clicking the mouse.'
        )
        .wait(seconds: 1)
        .gameEventPosition(GameEvent.Teleport_Start, guide)
        .movePositionToSceneKey(guide, keysGuideSpawn1)
        .gameEventPosition(GameEvent.Teleport_End, guide)
        .end()
    ;
  }

  void onObjectiveSetDrawBow(AmuletPlayer player) =>
    runScript(player)
      .controlsDisabled()
      .cameraSetTarget(guide)
      .faceEachOther(player, guide)
      .highlightAmuletItem(AmuletItem.Weapon_Bow_1_Common)
      .talk(guide,
        'excellent.'
        'draw the bow by clicking the bow icon at the bottom of the screen'
      )
      .end();

  void onObjectiveSetStrikeCrystal1(AmuletPlayer player) {}
  // =>
  //     runScript(player)
  //       .controlsDisabled()
  //       .activate(guide)
  //       .cameraSetTarget(guide)
  //       .faceEachOther(player, guide)
  //       .talk(guide,
  //         'strike by hovering the mouse over a target and left clicking.'
  //         'one can also attack at any time using right click.'
  //       )
  //       .end();

  GameObject spawnAtKeyCrystalGlowing(String key, bool value) =>
      value
          ? spawnAtKeyCrystalGlowingTrue(key)
          : spawnAtKeyCrystalGlowingFalse(key)
      ;

  GameObject spawnAtKeyCrystalGlowingTrue(String key) => spawnGameObjectAtKey(
        sceneKey: key,
        subType: GameObjectType.Crystal_Glowing_True,
        team: TeamType.Alone,
      )
        ..hitable = false
        ..fixed = true
        ..destroyable = false
        ..radius = 8
        ..healthMax = 0
        ..health = 0;

  GameObject spawnAtKeyCrystalGlowingFalse(String sceneKey) => spawnGameObjectAtKey(
        sceneKey: sceneKey,
        subType: GameObjectType.Crystal_Glowing_False,
        team: TeamType.Alone,
      )
      ..hitable = true
      ..fixed = true
      ..destroyable = false
      ..radius = 8
      ..healthMax = 0
      ..health = 0;

  GameObject spawnGameObjectAtKey({
    required String sceneKey,
    required int subType,
    required int team,
  }) => spawnGameObjectAtIndex(
        index: getSceneKey(sceneKey),
        type: ItemType.Object,
        subType: subType,
        team: team,
      );

  void onStruckCrystal2(AmuletPlayer player) {

     if (player.tutorialObjective.index > QuestTutorial.Strike_Crystal_2.index){
       return;
     }
     deactivate(crystal2GlowingFalse);
     activate(crystal2GlowingTrue);
     startNextTutorialObjective(player);
  }

  void onObjectiveSetLeave(AmuletPlayer player) =>
      runScript(player)
          .controlsDisabled()
          .activate(guide)
          .movePositionToSceneKey(guide, keysSpawnBow)
          .cameraSetTarget(guide)
          .faceEachOther(player, guide)
          .talk(guide,
            'one has learnt all another can teach.'
            'now one goes to the netherplains where ones destiny awaits.',
          )
          .add(() {
            setObjective(player, QuestTutorial.Finished);
          })
          .end();

  void onObjectiveFinished(AmuletPlayer player) {
    player.endInteraction();
    player.setControlsEnabled(true);
    amulet.playerChangeGame(
          player: player,
          target: amulet.amuletGameWorld00,
          sceneKey: 'player_spawn',
      );
  }
}

