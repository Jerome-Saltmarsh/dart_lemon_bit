
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games.dart';
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/games/mmo/mmo_npc.dart';

class MmoGame extends IsometricGame<MmoPlayer> {

  late MMONpc npcGuard;

  MmoGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Mmo) {

    spawnMonsters();

    characters.add(MMONpc(
      characterType: CharacterType.Template,
      x: 900,
      y: 1100,
      z: 25,
      health: 50,
      team: MmoTeam.Human,
      weaponType: WeaponType.Handgun,
      weaponDamage: 1,
      weaponRange: 200,
      weaponCooldown: 20,
      name: "Gus",
      interact: (player) {
        player.talk("Hello there", options: [
          TalkOption("Goodbye", player.endInteraction),
          TalkOption("Buy", player.endInteraction),
        ]);
      }
    ));

    npcGuard = MMONpc(
      characterType: CharacterType.Template,
      x: 800,
      y: 1000,
      z: 25,
      health: 200,
      weaponType: WeaponType.Machine_Gun,
      weaponRange: 200,
      weaponDamage: 1,
      weaponCooldown: 5,
      team: MmoTeam.Human,
      name: "Sam",
    );

    characters.add(npcGuard);
  }

  void spawnMonsters() {
    final types = scene.types;
    final length = scene.types.length;
    for (var i = 0; i < length; i++){
       if (types[i] != NodeType.Spawn) continue;
       for (var j = 0; j < 3; j++){
         characters.add(IsometricZombie(
           team: MmoTeam.Monsters,
           game: this,
           x: scene.getIndexX(i),
           y: scene.getIndexY(i),
           z: scene.getIndexZ(i),
           health: 5,
           weaponDamage: 1,
         ));
       }
    }
  }

  @override
  void customOnCharacterKilled(IsometricCharacter target, src) {
    if (target is IsometricZombie) {
       spawnLoot(target);
    }
  }

  void spawnLoot(IsometricZombie target) {
    spawnGameObject(
        x: target.x,
        y: target.y,
        z: target.z,
        type: GameObjectType.Weapon,
        subType: WeaponType.Handgun,
        team: TeamType.Neutral,
    )
       ..deactivationTimer = 5000
       ..fixed = true
       ..collectable = true
       ..persistable = false
       ..hitable = false
       ..physical = false
    ;

    addJob(seconds: 30, action: () {
      setCharacterStateSpawning(target);
    });
  }

  @override
  MmoPlayer buildPlayer() => MmoPlayer(game: this, itemLength: 6)
    ..x = 880
    ..y = 1100
    ..z = 50
    ..team = MmoTeam.Human
    ..setDestinationToCurrentPosition();

  @override
  int get maxPlayers => 64;

  @override
  void characterCollectGameObject(IsometricCharacter character, IsometricGameObject gameObject) {
    if (character is! MmoPlayer) return;
    if (character.addGameObject(gameObject)){
      super.characterCollectGameObject(character, gameObject);
    }
  }
}