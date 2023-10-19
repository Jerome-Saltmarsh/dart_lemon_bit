
import 'package:gamestream_ws/amulet/src.dart';
import 'package:gamestream_ws/isometric/src.dart';
import 'package:gamestream_ws/packages.dart';

import 'fiend_type.dart';

class AmuletGameTutorial extends AmuletGame {

  late final talkOptionAcceptSword = TalkOption('Accept Sword', onAcceptSword);
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
    ox = AmuletNpc(
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
    );

    add(ox);
  }

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

  void onAcceptSword(AmuletPlayer player) {
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

  void onInteractedWithOx(AmuletPlayer player){

    final data = player.data;

    if (player.flag('ox_met')){
      player.talk('Argh! Oh, you are not one of them.'
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
      return;
    }

    if (!data.containsKey('weapon_accepted')){
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
       if (src.flag('enemy_killed')){
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

    if (player.flag('initialized')) {
      player.writeMessage('Hello and welcome to Amulet. Left click the mouse to move.');
      initializeNewPlayer(player);
    }

    player.setPosition(
      x: 1600,
      y: 1515,
      z: 25,
    );

    if (!player.data.containsKey('weapon_accepted')){
      setNode(
        nodeIndex: getKey('door'),
        nodeType: NodeType.Wood,
        nodeOrientation: NodeOrientation.Half_West,
      );
    }

    fiend01 = spawnFiendTypeAtIndex(
        fiendType: FiendType.Fallen_01,
        index: getKey('creep01'),
    )
      ..spawnLootOnDeath = false
      ..respawnDurationTotal = -1;

    player.writePlayerPositionAbsolute();
  }


  void initializeNewPlayer(AmuletPlayer player) {
    for (final weapon in player.weapons){
      weapon.amuletItem = null;
    }
    player.healthBase = 15;
    player.equipBody(AmuletItem.Armor_Leather_Basic, force: true);
    player.equipLegs(AmuletItem.Pants_Travellers, force: true);
    player.health = player.maxHealth;
  }
}