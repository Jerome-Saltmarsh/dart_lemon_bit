
import 'package:gamestream_ws/amulet/src.dart';
import 'package:gamestream_ws/isometric/src.dart';
import 'package:gamestream_ws/packages.dart';

import 'fiend_type.dart';


class AmuletGameTutorial extends AmuletGame {

  static const keysGuideSpawn0 = 'guide_spawn_0';
  static const keysGuideSpawn1 = 'guide_spawn_1';
  static const keysPlayerSpawn = 'player_spawn_00';
  static const keysDoor = 'door';
  static const keysFiend01 = 'fiend01';

  late final talkOptionAcceptSword = TalkOption('Accept Sword', onObjectiveAccomplishedAcceptSword);
  late final talkOptionSkipTutorial = TalkOption('Skip Tutorial', amulet.movePlayerToTown);
  late final talkOptionsGoodbye = TalkOption('Goodbye', endPlayerInteraction);

  late final Character guide;
  Character? fiend01;

  AmuletGameTutorial({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
    required super.name,
    required super.fiendTypes,
  }) {
    guide = buildAmuletNpcOx();
    add(guide);
  }

  AmuletNpc buildAmuletNpcOx() => AmuletNpc(
    name: 'Ox',
    interact: onInteractedWithOx,
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
    ..legsType = LegType.Leather
    ..bodyType = BodyType.Leather_Armour;

  int getSceneKey(String name) =>
      scene.keys[name] ?? (throw Exception('amuletGameTutorial.getKey("$name") is null'));

  void onNodeChanged(int index){
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

  void onInteractedWithOx(AmuletPlayer player){

    if (objectiveActiveSpeakToOz(player)) {
      objectiveApplySpeakToOx(player);
      return;
    }
  }

  bool objectiveActiveSpeakToOz(AmuletPlayer player) => player.readFlag('ox_met');

  void objectiveApplySpeakToOx(AmuletPlayer player) {
    player.talk('in the path ahead lies danger');
    player.onInteractionOver = actionOxSpawnWeapon;
  }

  void actionOxSpawnWeapon() {
    spawnAmuletItem(
        item: AmuletItem.Weapon_Rusty_Old_Sword,
        x: guide.x,
        y: guide.y,
        z: guide.z,
    );
    actionDeactivateGuide();
  }

  void actionDeactivateGuide() {
    deactivate(guide);
  }

  void onObjectiveAccomplishedAcceptSword(AmuletPlayer player) {
    player.data['weapon_accepted'] = true;
    final doorIndex = getSceneKey(keysDoor);
    scene.setNodeEmpty(doorIndex);
    onNodeChanged(doorIndex);
    player.acquireAmuletItem(AmuletItem.Weapon_Rusty_Old_Sword);
    player.endInteraction();
    player.writeMessage(''
        'You have acquired a sword.'
        'The boxes at the bottom of the screen represent your weapons.'
        'The green box indicates what is currently equipped.'
        'Left click and enemy to attack it.'
        'Right click to attack the air.'
        'Each item has a limited number of charges.'
        'Each time an attack is performed the charges are reduced.'
        'If the item runs out of charges it cannot be used again.'
        'An item recharges automatically over time.'
        'Hover the mouse over an item to see its statistics.'
    );
  }

  @override
  void customOnCharacterKilled(Character target, src) {
    super.customOnCharacterKilled(target, src);

    if (target == fiend01) {
      onCharacterKilledFiend01(target);
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

  void refreshPlayerGameState(AmuletPlayer player) {

    if (!player.flagSet('fiend01_defeated')){
      actionInstantiateFiend01();
    }

    if (player.readFlag('initialized')) {
      actionInitializeNewPlayer(player);
    }

    if (player.readFlag('initialized')) {
      actionInitializeNewPlayer(player);
    }

    if (player.readFlag('introduction')){
      actionPlayerControlsDisabled(player);
      actionMovePlayerToSpawn01(player);
      actionMoveGuideToGuideSpawn0();
      actionFaceOneAnother(player, guide);

      addJob(seconds: 2, action: () {
        actionCameraTargetGuide(player);
        player.talk(
          'greetings other one.'
          'one is here to guide another.'
          'left click the mouse to move.'
        );

        player.onInteractionOver = () {
          addJob(seconds: 1, action: () {
            actionMoveGuideToGuideSpawn1();
            actionPlayerControlsEnabled(player);
            actionClearCameraTarget(player);
          });
        };
      });
      return;
    }
  }

  void actionMoveGuideToGuideSpawn0() {
    actionMoveOxToSceneKey(keysGuideSpawn0);
  }

  void actionMoveGuideToGuideSpawn1() {
    actionMoveOxToSceneKey(keysGuideSpawn1);
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

  void actionSetDoorEnabled() {
     setNode(
      nodeIndex: getSceneKey(keysDoor),
      nodeType: NodeType.Wood,
      nodeOrientation: NodeOrientation.Half_West,
    );
  }

  void actionMovePlayerToSpawn01(AmuletPlayer player) {
    final playerSpawn01 = scene.getKey(keysPlayerSpawn);
    actionMovePositionToIndex(player, playerSpawn01);
    actionWritePlayerPositionAbsolute(player);
  }

  void actionInitializeNewPlayer(AmuletPlayer player) {
    for (final weapon in player.weapons){
      weapon.amuletItem = null;
    }
    player.healthBase = 15;
    player.equipBody(AmuletItem.Armor_Leather_Basic, force: true);
    player.equipLegs(AmuletItem.Pants_Travellers, force: true);
    player.health = player.maxHealth;
  }

  @override
  void onAmuletItemUsed(AmuletPlayer amuletPlayer, AmuletItem amuletItem) {
    if (
      amuletItem == AmuletItem.Spell_Heal &&
      amuletPlayer.readFlag('use_spell_heal')
    ) {

      final fiend02Index = getSceneKey('fiend02');
      for (var i = 0; i < 2; i++) {
        const shiftRadius = 10;
        spawnFiendTypeAtIndex(
          fiendType: FiendType.Fallen_01,
          index: fiend02Index,
        )
          ..x += giveOrTake(shiftRadius)
          ..y += giveOrTake(shiftRadius);
      }

      addJob(
          seconds: 3,
          action: clearDoor02,
      );
    }
  }

  void clearDoor02() => setNodeEmpty(getSceneKey('door02'));

  void refreshSceneState(){

  }

  void actionSetDoorDisabled() =>
      setNodeEmpty(getSceneKey('door'));

  void actionFaceOneAnother(Character a, Character b) {
     a.face(b);
     b.face(a);
  }

  void actionPlayerControlsDisabled(AmuletPlayer player) {
     player.controlsEnabled = false;
  }

  void actionPlayerControlsEnabled(AmuletPlayer player) {
     player.controlsEnabled = true;
  }

  void actionClearCameraTarget(AmuletPlayer player){
    actionSetCameraTarget(player, null);
  }

  void actionSetCameraTarget(AmuletPlayer player, Position? target) {
      player.cameraTarget = target;
  }

  @override
  void onAmuletItemAcquired(AmuletPlayer player, AmuletItem amuletItem) {
    if (amuletItem == AmuletItem.Weapon_Rusty_Old_Sword){
      if (player.readFlag('acquired_weapon_sword')){
        actionSetDoorDisabled();
      }
      return;
    }

    if (amuletItem == AmuletItem.Spell_Heal){
      if (player.readFlag('acquired_spell_heal')){
        actionSetDoorDisabled();
        actionPlayerControlsDisabled(player);
        actionMoveGuideToFiend01();
        actionCameraTargetGuide(player);

        addJob(seconds: 2, action: (){
          actionActivateGuide();
          player.talk(
              'one has acquired a healing spell.'
              'press the "Spell Heal" icon at the bottom of the screen.'
              'each item has a limited number of charges.'
              'charges replenish over time.'
          );
          player.onInteractionOver = () {
            actionDeactivateGuide();
            actionClearCameraTarget(player);
            actionPlayerControlsEnabled(player);
          };
        });
      }
      return;
    }
  }

  void actionActivateGuide() {
    activateCollider(guide);
  }

  void actionCameraTargetGuide(AmuletPlayer player) {
    actionSetCameraTarget(player, guide);
  }

  void actionMoveGuideToFiend01() {
    actionMoveOxToSceneKey(keysFiend01);
  }
}