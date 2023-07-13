
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games.dart';
import 'package:gamestream_server/games/mmo/mmo_gameobject.dart';
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/games/mmo/mmo_npc.dart';
import 'package:gamestream_server/lemon_math.dart';

class MmoGame extends IsometricGame<MmoPlayer> {

  static const GameObjectDeactivationTimer = 5000;
  static const EnemyRespawnDuration = 30; // in seconds

  late MMONpc npcGuard;

  final playerSpawnX = 2030.0;
  final playerSpawnY = 2040.0;
  final playerSpawnZ = 25.0;

  MmoGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Mmo) {

    spawnMonsters();

    characters.add(MMONpc(
      characterType: CharacterType.Template,
      x: playerSpawnX + giveOrTake(50),
      y: playerSpawnY + giveOrTake(50),
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
      x: playerSpawnX + giveOrTake(50),
      y: playerSpawnY + giveOrTake(50),
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

  @override
  int get maxPlayers => 64;

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
    spawnLoot(x: x, y: y, z: z, item: randomItem(MMOItem.values));
  }

  void spawnLootAtIndex({required int index, required MMOItem item}) => spawnLoot(
    x: scene.getIndexX(index),
    y: scene.getIndexY(index),
    z: scene.getIndexZ(index),
    item: item,
  );

  void spawnLoot({
    required double x,
    required double y,
    required double z,
    required MMOItem item,
  }) {
    gameObjects.add(MMOGameObject(
      x: x,
      y: y,
      z: z,
      item: item,
      id: generateId(),
    ));
  }

  @override
  MmoPlayer buildPlayer() => MmoPlayer(
      game: this,
      itemLength: 6,
      x: playerSpawnX,
      y: playerSpawnY,
      z: playerSpawnZ,
  );

  @override
  void characterCollectGameObject(
      IsometricCharacter character,
      IsometricGameObject gameObject,
      ) {
    if (character is! MmoPlayer) return;
    if (gameObject is MMOGameObject) {
      if (character.addItem(gameObject.item)){
        super.characterCollectGameObject(character, gameObject);
      }
    }
  }

  @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    switch (nodeType){
      case NodeType.Grass_Long:
        spawnLootAtIndex(index: nodeIndex, item: MMOItem.Meat_Drumstick);
        break;
    }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(MmoPlayer player, IsometricGameObject gameObject) {
    if (gameObject is! MMOGameObject || !gameObject.collectable)
      return;

    player.collectItem(gameObject.item);
    deactivate(gameObject);
  }


}