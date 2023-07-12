
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games.dart';
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/games/mmo/mmo_npc.dart';
import 'package:gamestream_server/lemon_math.dart';

class MmoGame extends IsometricGame<MmoPlayer> {

  static const GameObjectDeactivationTimer = 5000;
  static const EnemyRespawnDuration = 30; // in seconds

  late MMONpc npcGuard;

  final playerSpawnX = 1000.0;
  final playerSpawnY = 1000.0;
  final playerSpawnZ = 25.0;

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
  void customOnPlayerDead(MmoPlayer player) {
    addJob(seconds: 3, action: () {
      setCharacterStateSpawning(player);
    });
  }

  @override
  void customOnCharacterKilled(IsometricCharacter target, src) {
    if (target is IsometricZombie) {
       spawnRandomLootAtPosition(target);
       addJob(seconds: EnemyRespawnDuration, action: () {
         setCharacterStateSpawning(target);
       });
    }
  }

  void spawnRandomLootAtPosition(IsometricPosition position){
    spawnRandomLoot(x: position.x, y: position.y, z: position.z);
  }

  void spawnRandomLoot({
    required double x,
    required double y,
    required double z,
  }){
    final type = randomItem(GameObjectType.items);
    final subType = getRandomSubType(type);
    spawnLoot(x: x, y: y, z: z, type: type, subType: subType);
  }

  void spawnLoot({
    required double x,
    required double y,
    required double z,
    required int type,
    required int subType,
  }) => spawnGameObject(
        x: x,
        y: y,
        z: z,
        type: type,
        subType: subType,
        team: TeamType.Neutral,
    )
       ..deactivationTimer = GameObjectDeactivationTimer
       ..fixed = true
       ..collectable = true
       ..persistable = false
       ..hitable = false
       ..physical = false;

  void setCollectableProperties(){

  }

  int getRandomSubType(int type) =>
      randomItem(GameObjectType.Collection[type] ??
          (throw Exception('getRandomSubType($type)')));

  @override
  MmoPlayer buildPlayer() => MmoPlayer(
      game: this,
      itemLength: 6,
      x: playerSpawnX,
      y: playerSpawnY,
      z: playerSpawnZ,
  );

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