
import 'package:gamestream_ws/amulet/classes/enums/tutorial_objective.dart';
import 'package:gamestream_ws/amulet/src.dart';
import 'package:gamestream_ws/isometric/src.dart';
import 'package:gamestream_ws/packages.dart';

import 'amulet_player_script.dart';
import 'fiend_type.dart';


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
  static const flagsBowAddedToWeapons = 'add_bow_to_weapons';
  static const keysRoom4 = 'room_4';

  static const objectives = TutorialObjective.values;

  final scripts = <AmuletPlayerScript>[];

  late final Character guide;
  Character? fiend01;
  final fiends02 = <Character>[];

  late GameObject crystal1;
  late GameObject crystal1Glowing;
  GameObject? crystal2;
  GameObject? crystal2Glowing;

  final finish = Position(x: -100);

  AmuletGameTutorial({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
  }) : super (
      amuletScene: AmuletScene.Tutorial,
      fiendTypes: const[],
      name: 'tutorial'
  ){
    instantiateGuide();
    crystal1 = spawnCrystalAtKey(keysCrystal1, glowing: false);
    crystal1Glowing = spawnCrystalAtKey(keysCrystal1, glowing: true);
    spawnGameObjectAtIndex(
        type: ItemType.Object,
        subType: ObjectType.Barrel,
        index: getSceneKey(keysCrystal1),
        team: 0,
    )..fixed = true;

    scene.movePositionToKey(finish, keysFinish);
  }

  String getSpawnKey(TutorialObjective objective) => switch (objective){
       TutorialObjective.Acquire_Sword => keysPlayerSpawn0,
       TutorialObjective.Strike_Crystal_1 => keysPlayerSpawn0,
       TutorialObjective.Acquire_Heal => keysPlayerSpawn0,
       TutorialObjective.Use_Heal => keysFiend01,
       TutorialObjective.Vanquish_Fiends_02 => keysFiend01,
       TutorialObjective.Acquire_Bow => keysFiend01,
       TutorialObjective.Equip_Bow => keysRoom4,
       TutorialObjective.Draw_Bow => keysRoom4,
       TutorialObjective.Open_Inventory => keysRoom4,
       TutorialObjective.Shoot_Crystal => keysRoom4,
       TutorialObjective.Leave => keysRoom4,
       TutorialObjective.Finished => keysRoom4,
    };

  void refreshPlayerGameState(AmuletPlayer player) {

    removeFiends();
    gameObjects.removeWhere((element) =>
      !element.persistable &&
      element != crystal1 &&
      element != crystal1Glowing);

    player.equipBody(AmuletItem.Armor_Leather_Basic, force: true);
    player.equipLegs(AmuletItem.Pants_Travellers, force: true);
    player.equippedWeaponIndex = -1;

    deactivate(crystal1);
    deactivate(crystal1Glowing);

    for (final weapon in player.weapons){
      weapon.amuletItem = null;
    }

    for (final item in player.items){
      item.amuletItem = null;
    }

    if (player.readOnce('tutorial_initialized')) {
      actionInitializeNewPlayer(player);
    }

    movePlayerToSpawnPoint(player);

    switch (getObjective(player)){
      case TutorialObjective.Acquire_Sword:
        onObjectiveSetAcquireSword(player);
        break;
      default:
        break;
    }

    if (objectiveCompleted(player, TutorialObjective.Acquire_Sword)){
      player.setWeapon(index: 0, amuletItem: AmuletItem.Weapon_Rusty_Old_Sword);
      player.equippedWeaponIndex = 0;
    }

    if (objectiveCompleted(player, TutorialObjective.Strike_Crystal_1)){
      setNodeEmpty(getSceneKey(keysDoor01));
      activate(crystal1Glowing);
    } else {
      activate(crystal1);
      setNode(
        nodeIndex: getSceneKey(keysDoor01),
        nodeType: NodeType.Wood,
        nodeOrientation: NodeOrientation.Half_West,
      );
    }

    if (objectiveCompleted(player, TutorialObjective.Acquire_Heal)){
      player.setWeapon(index: 1, amuletItem: AmuletItem.Spell_Heal);
    } else {
      actionInstantiateFiend01();
    }

    if (objectiveCompleted(player, TutorialObjective.Use_Heal)){
      setNodeEmpty(getSceneKey(keysDoor02));
    } else {
      setNode(
          nodeIndex: getSceneKey(keysDoor02),
          nodeType: NodeType.Brick,
          nodeOrientation: NodeOrientation.Solid,
      );
    }

    if (!objectiveCompleted(player, TutorialObjective.Vanquish_Fiends_02)){
      spawnFiends02();
    }

    if (objectiveCompleted(player, TutorialObjective.Vanquish_Fiends_02)){
      setNodeEmpty(getSceneKey(keysDoor03));
    } else {
      setNode(
        nodeIndex: getSceneKey(keysDoor03),
        nodeType: NodeType.Brick,
        nodeOrientation: NodeOrientation.Solid,
      );
    }

    if (!objectiveCompleted(player, TutorialObjective.Acquire_Bow)){
      spawnAmuletItemAtIndex(
        item: AmuletItem.Weapon_Old_Bow,
        index: getSceneKey(keysSpawnBow),
        deactivationTimer: -1,
      );
    } else {
      player.setWeapon(index: 2, amuletItem: AmuletItem.Weapon_Old_Bow);
    }

    if (!objectiveCompleted(player, TutorialObjective.Shoot_Crystal)){
      crystal2 = spawnCrystalAtKey('bow_target');
    }

    if (!objectiveCompleted(player, TutorialObjective.Shoot_Crystal)){
      setNode(
        nodeIndex: getSceneKey(keysExit),
        nodeType: NodeType.Wood,
        nodeOrientation: NodeOrientation.Half_South,
      );
    }

    player.refillItemSlotsWeapons();
    player.writeGameObjects();
  }

  void removeFiends() {
    characters.removeWhere((element) => element.characterType == CharacterType.Fallen);
  }

  void movePlayerToSpawnPoint(AmuletPlayer player) {
    scene.movePositionToKey(player, getSpawnKey(getObjective(player)));
    player.writePlayerMoved();
  }

  void instantiateGuide() {
    guide = AmuletNpc(
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
      ..autoTarget = false
      ..complexion = 20
      ..invincible = true
      ..legsType = LegType.Leather
      ..bodyType = BodyType.Leather_Armour;

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
       if (isObjectiveCompleted(player)){
          startNextTutorialObjective(player);
       }
    }
  }

  bool isObjectiveCompleted(AmuletPlayer player) =>
    switch (getObjective(player)) {
      TutorialObjective.Open_Inventory =>
        player.inventoryOpen,
       TutorialObjective.Equip_Bow =>
          player.weapons.any((element) => element.amuletItem == AmuletItem.Weapon_Old_Bow),
       TutorialObjective.Draw_Bow =>
        player.equippedWeapon?.amuletItem == AmuletItem.Weapon_Old_Bow,
       TutorialObjective.Leave =>
           player.withinRadiusPosition(finish, 10),
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
     final current = getObjective(player);
     if (current == objectives.last) {
       print("startNextTutorialObjective() - current == tutorialObjectives.last");
       return;
     }

     final index = objectives.indexOf(current);
     final next = objectives[index + 1];
     setObjective(player, next);
  }

  void setObjective(
      AmuletPlayer player,
      TutorialObjective tutorialObjective,
  ){
    player.data['tutorial_objective'] = tutorialObjective.name;
    switch (tutorialObjective) {
      case TutorialObjective.Acquire_Sword:
        onObjectiveSetAcquireSword(player);
        break;
      case TutorialObjective.Strike_Crystal_1:
        onObjectiveSetStrikeCrystal1(player);
        break;
      case TutorialObjective.Acquire_Heal:
        onObjectiveSetAcquireHeal(player);
        break;
      case TutorialObjective.Use_Heal:
        onObjectiveSetUseHeal(player);
        break;
      case TutorialObjective.Vanquish_Fiends_02:
        break;
      case TutorialObjective.Acquire_Bow:
        break;
      case TutorialObjective.Open_Inventory:
        onObjectiveSetOpenInventory(player);
        break;
      case TutorialObjective.Equip_Bow:
        onObjectiveSetEquipBow(player);
        break;
      case TutorialObjective.Draw_Bow:
        onObjectiveSetDrawBow(player);
        break;
      case TutorialObjective.Shoot_Crystal:
        break;
      case TutorialObjective.Leave:
        break;
      case TutorialObjective.Finished:
        onObjectiveSetFinished(player);
        break;
    }
  }

  void onObjectiveSetAcquireHeal(AmuletPlayer player) {
    // runScript(player)
    //     .deactivate(guide)
    //     .controlsDisabled()
    //     .wait(seconds: 1)
    //     .cameraSetTargetSceneKey(keysDoor01)
    //     .wait(seconds: 2)
    //     .setNodeEmptyAtSceneKey(keysDoor01)
    //     .wait(seconds: 1)
    //     .controlsEnabled();
  }

  void onObjectiveSetUseHeal(AmuletPlayer player) {
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
        .end();
  }

  bool objectiveCompleted(AmuletPlayer player, TutorialObjective objective) =>
      getObjective(player).index > objective.index;

  TutorialObjective getObjective(AmuletPlayer player){
     final data = player.data['tutorial_objective'];

     if (data == null){
       return objectives.first;
     }

     if (data is int){
       return objectives[data];
     }

     if (data is String){
       for (final objective in objectives){
         if (objective.name == data){
           return objective;
         }
       }
       throw Exception('could not find objective $name');
     }

     throw Exception();
  }

  void onInteractedWithGuide(AmuletPlayer player){
    final objective = getObjective(player);
    switch (objective) {
      case TutorialObjective.Acquire_Sword:
        runScript(player)
            .controlsDisabled()
            .activate(guide)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk('danger doth lieth ahead')
            .add(actionSpawnWeaponSwordAtGuide)
            .deactivate(guide)
            .end();
        break;
      case TutorialObjective.Use_Heal:
        runScript(player)
            .controlsDisabled()
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk('caste heal by pressing the heal icon at the bottom of the screen.')
            .end();
        break;
      case TutorialObjective.Open_Inventory:
        runScript(player)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk('open the inventory by hovering the mouse over the inventory icon at the bottom left corner of the screen')
            .end();
        break;
      case TutorialObjective.Equip_Bow:
        runScript(player)
            .cameraSetTarget(guide)
            .faceEachOther(player, guide)
            .talk('add the bow to the weapons rack by clicking the bow icon in the inventory')
            .end();
        break;
      case TutorialObjective.Draw_Bow:
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

  void actionSpawnWeaponSwordAtGuide() =>
    spawnAmuletItem(
      item: AmuletItem.Weapon_Rusty_Old_Sword,
      x: guide.x,
      y: guide.y,
      z: guide.z,
      deactivationTimer: -1
    );

  @override
  void customOnCharacterKilled(Character target, src) {
    super.customOnCharacterKilled(target, src);

    if (target == fiend01) {
      onCharacterKilledFiend01(target);
      return;
    }

    if (
      src is AmuletPlayer &&
      fiends02.contains(target) &&
      !fiends02.any((element) => element.alive) &&
      getObjective(src) == TutorialObjective.Vanquish_Fiends_02
    ){
      onFiends02Vanquished(players.first);
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
        fiendType: FiendType.Fallen_01,
        index: getSceneKey(keysFiend01),
    )
      ..maxHealth = 3
      ..health = 3
      ..spawnLootOnDeath = false
      ..respawnDurationTotal = -1;
  }

  void actionInitializeNewPlayer(AmuletPlayer player) {
    for (final weapon in player.weapons){
      weapon.amuletItem = null;
    }
    // player.equippedWeaponIndex = -1;
    // player.healthBase = 15;
    player.health = player.maxHealth;
  }

  @override
  void onAmuletItemUsed(AmuletPlayer player, AmuletItem amuletItem) {
    if (
      amuletItem == AmuletItem.Spell_Heal &&
      getObjective(player) == TutorialObjective.Use_Heal
    ) {
      onSpellHealUsedForTheFirstTime(player);
    }
  }

  void spawnFiends02() {
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

  @override
  void onAmuletItemAcquired(AmuletPlayer player, AmuletItem amuletItem) {
    switch (amuletItem){
      case AmuletItem.Weapon_Rusty_Old_Sword:
        if (getObjective(player) == TutorialObjective.Acquire_Sword){
          startNextTutorialObjective(player);
        }
        break;
      case AmuletItem.Spell_Heal:
        if (getObjective(player) == TutorialObjective.Acquire_Heal){
          startNextTutorialObjective(player);
        }
        break;
      case AmuletItem.Weapon_Old_Bow:
        if (getObjective(player) == TutorialObjective.Acquire_Bow){
          startNextTutorialObjective(player);
        }
        break;
      default:
        break;
    }
  }

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
      .wait(seconds: 1)
      .deactivate(guide)
      .controlsEnabled()
      .add(() => startNextTutorialObjective(player));


  void onFiends02Vanquished(AmuletPlayer player) =>
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
          .end()
          .add(() => startNextTutorialObjective(player));

  void onObjectiveSetOpenInventory(AmuletPlayer player) => runScript(player)
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
        .faceEachOther(player, guide)
        .talk(
          'one hath acquired a new weapon.'
          'one must now learn of the inventory.'
          'open the inventory by hovering the mouse over the bag icon at the bottom left corner of the screen'
        )
        .end();

  void onObjectiveSetEquipBow(AmuletPlayer player) =>
    runScript(player)
      .faceEachOther(player, guide)
      .talk(
        'one adds the bow to the weapons rack by clicking the bow icon in the inventory.',
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
      getObjective(player) == TutorialObjective.Equip_Bow
    ) {
      startNextTutorialObjective(player);
    }
  }

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
    double? angle,
    bool friendlyFire = false,
  }) {
    super.applyHit(
        srcCharacter: srcCharacter,
        target: target,
        damage: damage,
        angle: angle,
        friendlyFire: friendlyFire,
    );

    if (srcCharacter is! AmuletPlayer){
      return;
    }

    final player = srcCharacter;

    if (
      target == crystal1 &&
      getObjective(srcCharacter) == TutorialObjective.Strike_Crystal_1
    ){
      onStruckCrystal1(player);
      return;
    }

    if (
      target == crystal2 &&
      getObjective(srcCharacter) == TutorialObjective.Shoot_Crystal
    ){
      startNextTutorialObjective(player);
      return;
    }
  }

  void onStruckCrystal1(AmuletPlayer player) =>
      runScript(player)
        .deactivate(crystal1)
        .activate(crystal1Glowing)
        .deactivate(guide)
        .puzzleSolved()
        .controlsDisabled()
        .wait(seconds: 1)
        .cameraSetTargetSceneKey(keysDoor01)
        .wait(seconds: 2)
        .setNodeEmptyAtSceneKey(keysDoor01)
        .wait(seconds: 1)
        .add(() => startNextTutorialObjective(player))
        .end();

  void startObjectiveFinish(AmuletPlayer srcCharacter) => runScript(srcCharacter)
      .controlsDisabled()
      .wait(seconds: 1)
      .cameraSetTargetSceneKey(keysExit)
      .wait(seconds: 1)
      .setNodeEmptyAtSceneKey(keysExit)
      .wait(seconds: 1)
      .end();

  @override
  void customOnPlayerDisconnected(IsometricPlayer player) {
    amulet.removeGame(this);
  }

  void onObjectiveSetAcquireSword(AmuletPlayer player) {
    runScript(player)
        .controlsDisabled()
        .zoom(1.5)
        .snapCameraToPlayer()
        .movePositionToSceneKey(guide, keysGuideSpawn0)
        .wait(seconds: 1)
        .activate(guide)
        .cameraSetTarget(guide)
        .faceEachOther(player, guide)
        .talk(
          'greetings other.'
          'one is here to to guide another.'
          'one moves by left clicking the mouse.'
        )
        .movePositionToSceneKey(guide, keysGuideSpawn1)
        .controlsEnabled()
        .cameraClearTarget()
    ;
  }

  void onObjectiveSetFinished(AmuletPlayer player) {

  }

  void onObjectiveSetDrawBow(AmuletPlayer player) =>
    runScript(player)
      .controlsDisabled()
      .cameraSetTarget(guide)
      .faceEachOther(player, guide)
      .talk(
        'excellent.'
        'draw the bow by clicking the bow icon at the bottom of the screen'
      )
      .end();

  void onObjectiveSetStrikeCrystal1(AmuletPlayer player) =>
      runScript(player)
        .controlsDisabled()
        .activate(guide)
        .cameraSetTarget(guide)
        .faceEachOther(player, guide)
        .talk(
          'strike by hovering the mouse over a target and left clicking.'
          'one can also attack at any time using right click.'
        )
        .add(() {
          player.writeGameEvent(
              type: GameEventType.Blink_Depart,
              x: guide.x,
              y: guide.y,
              z: guide.z,
              angle: 0,
          );
        })
        .deactivate(guide)
        .end();

  GameObject spawnCrystalAtKey(String sceneKey, {bool glowing = false}) => spawnGameObjectAtIndex(
        index: getSceneKey(sceneKey),
        type: ItemType.Object,
        subType: glowing ? ObjectType.Crystal_Glowing : ObjectType.Crystal,
        team: TeamType.Alone,
      )
        ..hitable = true
        ..fixed = true
        ..destroyable = false
        ..radius = 12
        ..healthMax = 0
        ..health = 0;

}

