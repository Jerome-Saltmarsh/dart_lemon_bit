
import 'package:gamestream_ws/amulet/src.dart';
import 'package:gamestream_ws/isometric/src.dart';
import 'package:gamestream_ws/packages.dart';

import 'fiend_type.dart';

class AmuletGameTutorial extends AmuletGame {

  late final talkOptionAcceptSword = TalkOption('Accept Sword', onObjectiveAccomplishedAcceptSword);
  late final talkOptionSkipTutorial = TalkOption('Skip Tutorial', amulet.movePlayerToTown);
  late final talkOptionsGoodbye = TalkOption('Goodbye', endPlayerInteraction);

  late final Character ox;
  Character? fiend01;

  AmuletGameTutorial({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
    required super.name,
    required super.fiendTypes,
  }) {
    ox = buildAmuletNpcOx();
    add(ox);
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

  int getKey(String name) =>
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

    if (!player.hasKey('weapon_accepted')){
      player.talk('Did you change your mind?', options: [
        talkOptionAcceptSword,
        talkOptionSkipTutorial,
        talkOptionsGoodbye,
      ]);
      return;
    }

    player.talk('Kill those creatures for me please',
      options: [
        talkOptionSkipTutorial,
        talkOptionsGoodbye,
      ]);
  }

  bool objectiveActiveSpeakToOz(AmuletPlayer player) => player.readFlag('ox_met');

  void objectiveApplySpeakToOx(AmuletPlayer player){
    player.talk(
        'Argh! Oh, you are not one of them.'
        'Such a fright one did give me. '
        'I did think it would be one of the awful creatures.'
        'Those do lurk in that room there yonder'
        'This one has not the courage to face those.'
        'Perhaps another could do it. '
        'Here take this sword'
        'Please dispatch of those creatures',
        options: [
          talkOptionAcceptSword,
        ]
    );
  }

  void onObjectiveAccomplishedAcceptSword(AmuletPlayer player) {
    player.data['weapon_accepted'] = true;
    final doorIndex = getKey('door');
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
      spawnAmuletItem(
          item: AmuletItem.Spell_Heal,
          x: target.x,
          y: target.y,
          z: target.z,
          deactivationTimer: -1,
      );
    }

    if (src is AmuletPlayer){
       if (src.readFlag('enemy_killed')){
         src.writeMessage(
             'You defeated the enemy.'
             'Experience is gained for each enemy defeated.'
             'Experience is indicated by the white bar at the top left side of the screen.'
             'When the bar is full a level is gained.'
             'Try to kill a few more creates to reach the next level.'
         );
       }
    }
  }

  @override
  void onPlayerJoined(AmuletPlayer player) {
    refreshPlayerGameState(player);
  }

  void resetGameState(){

  }

  void refreshPlayerGameState(AmuletPlayer player) {

    resetGameState();

    if (player.readFlag('initialized')) {
      actionInitializeNewPlayer(player);
    }

    if (player.readFlag('introduction')){
      actionMovePlayerToSpawn01(player);
      return;
    }


    if (player.readFlag('show_welcome_message')) {
      actionWriteWelcomeMessage(player);
    }

    actionMovePlayerToSpawn01(player);

    if (player.hasNotKey('weapon_accepted')){
      actionSetDoorEnabled();
    } else {
      actionSetDoorDisabled();
    }

    actionInstantiateFiend01();
  }

  void actionWritePlayerPositionAbsolute(AmuletPlayer player) {
    player.writePlayerPositionAbsolute();
  }

  void actionWriteWelcomeMessage(AmuletPlayer player) {
    player.writeMessage('Hello and welcome to Amulet. Left click the mouse to move. Scroll the mouse wheel to zoom the camera in and out');
  }

  void actionInstantiateFiend01() {
    fiend01 = spawnFiendTypeAtIndex(
        fiendType: FiendType.Fallen_01,
        index: getKey('creep01'),
    )
      ..spawnLootOnDeath = false
      ..respawnDurationTotal = -1;
  }

  void actionSetDoorEnabled() {
     setNode(
      nodeIndex: getKey('door'),
      nodeType: NodeType.Wood,
      nodeOrientation: NodeOrientation.Half_West,
    );
  }

  void actionMovePlayerToSpawn01(AmuletPlayer player) {
    final playerSpawn01 = scene.getKey('player_spawn[0]');
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

      final fiend02Index = getKey('fiend02');
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

  void clearDoor02() => setNodeEmpty(getKey('door02'));

  void refreshSceneState(){

  }

  void actionSetDoorDisabled() =>
      setNodeEmpty(getKey('door'));
}