import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/library.dart';

import 'enums/emission_type.dart';
import 'isometric_character.dart';
import 'isometric_gameobject.dart';
import 'isometric_player_score.dart';
import 'isometric_position.dart';
import 'isometric_projectile.dart';

/// WARNING - WRITING TO SERVER STATE IS FORBIDDEN
/// the data inside server state belongs to the server and can only be written by serverResponseReader
class IsometricServer {
  var totalCharacters = 0;
  var totalPlayers = 0;
  var totalNpcs = 0;
  var totalZombies = 0;
  var totalProjectiles = 0;
  var inventory = Uint16List(0);
  var inventoryQuantity = Uint16List(0);

  final tagTypes = <String, int> {};
  final playerScores = <IsometricPlayerScore>[];
  final gameObjects = <IsometricGameObject>[];
  final characters = <IsometricCharacter>[];
  final npcs = <IsometricCharacter>[];
  final projectiles = <IsometricProjectile>[];
  final playerScoresReads = Watch(0);
  final highScore = Watch(0);
  final playerHealth = Watch(0);
  final playerMaxHealth = Watch(0);
  final playerDamage = Watch(0);
  final playerCredits = Watch(0);
  final playerExperiencePercentage = Watch(0.0);
  final playerLevel = Watch(1);
  final playerAccuracy = Watch(1.0);
  final playerAttributes = Watch(0);
  final sceneEditable = Watch(false);
  final sceneName = Watch<String?>(null);
  final gameRunning = Watch(true);
  final weatherBreeze = Watch(false);
  final minutes = Watch(0);
  final lightningType = Watch(LightningType.Off);
  final watchTimePassing = Watch(false);
  final gameStatus = Watch(GameStatus.Playing);
  final playerBelt1_ItemType = Watch(ItemType.Empty);
  final playerBelt2_ItemType = Watch(ItemType.Empty);
  final playerBelt3_ItemType = Watch(ItemType.Empty);
  final playerBelt4_ItemType = Watch(ItemType.Empty);
  final playerBelt5_ItemType = Watch(ItemType.Empty);
  final playerBelt6_ItemType = Watch(ItemType.Empty);
  final playerBelt1_Quantity = Watch(0);
  final playerBelt2_Quantity = Watch(0);
  final playerBelt3_Quantity = Watch(0);
  final playerBelt4_Quantity = Watch(0);
  final playerBelt5_Quantity = Watch(0);
  final playerBelt6_Quantity = Watch(0);
  final equippedWeaponIndex = Watch(0);
  final sceneUnderground = Watch(false);

  late final areaType = Watch(AreaType.None, onChanged: onChangedAreaType);
  late final gameTimeEnabled = Watch(false, onChanged: onChangedGameTimeEnabled);
  late final lightningFlashing = Watch(false, onChanged: onChangedLightningFlashing);
  late final rainType = Watch(RainType.None, onChanged: gamestream.isometric.events.onChangedRain);
  late final seconds = Watch(0, onChanged: gamestream.isometric.events.onChangedSeconds);
  late final hours = Watch(0, onChanged: gamestream.isometric.events.onChangedHour);
  late final interactMode = Watch(InteractMode.None, onChanged: gamestream.isometric.events.onChangedPlayerInteractMode);
  late final windTypeAmbient = Watch(WindType.Calm, onChanged: gamestream.isometric.events.onChangedWindType);
  late final watchBeltItemTypes = [
    playerBelt1_ItemType,
    playerBelt2_ItemType,
    playerBelt3_ItemType,
    playerBelt4_ItemType,
    playerBelt5_ItemType,
    playerBelt6_ItemType,
  ];

  IsometricCharacter getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(IsometricCharacter());
    }
    return characters[totalCharacters];
  }

  IsometricCharacter? getPlayerCharacter(){
    for (var i = 0; i < totalCharacters; i++){
      if (characters[i].x != gamestream.isometric.player.position.x) continue;
      if (characters[i].y != gamestream.isometric.player.position.y) continue;
      return characters[i];
    }
    return null;
  }

  void applyEmissionGameObjects() {
    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      switch (gameObject.emission_type) {
        case IsometricEmissionType.None:
          continue;
        case IsometricEmissionType.Color:
          gamestream.isometric.clientState.applyVector3Emission(
            gameObject,
            hue: gameObject.emission_hue,
            saturation: gameObject.emission_sat,
            value: gameObject.emission_val,
            alpha: gameObject.emission_alp,
            intensity: gameObject.emission_intensity,
          );
          continue;
        case IsometricEmissionType.Ambient:
          gamestream.isometric.clientState.applyVector3EmissionAmbient(gameObject,
            alpha: gameObject.emission_alp,
            intensity: gameObject.emission_intensity,
          );
          continue;
      }
    }
  }

  /// TODO Optimize
  void updateGameObjects() {
    for (final gameObject in gameObjects){
      if (!gameObject.active) continue;
      gameObject.update();
      if (gameObject.type != ItemType.Weapon_Thrown_Grenade) continue;
      projectShadow(gameObject);
    }
  }

  void projectShadow(IsometricPosition v3){
    if (!gamestream.isometric.nodes.inBoundsVector3(v3)) return;

    final z = getProjectionZ(v3);
    if (z < 0) return;
    gamestream.isometric.clientState.spawnParticle(
      type: ParticleType.Shadow,
      x: v3.x,
      y: v3.y,
      z: z,
      angle: 0,
      speed: 0,
      duration: 2,
    );
  }

  double getProjectionZ(IsometricPosition vector3){

    final x = vector3.x;
    final y = vector3.y;
    var z = vector3.z;

    while (true) {
      if (z < 0) return -1;
      final nodeIndex = gamestream.isometric.nodes.getIndexXYZ(x, y, z);
      final nodeOrientation = gamestream.isometric.nodes.nodeOrientations[nodeIndex];

      if (const <int> [
        NodeOrientation.None,
        NodeOrientation.Radial,
        NodeOrientation.Half_South,
        NodeOrientation.Half_North,
        NodeOrientation.Half_East,
        NodeOrientation.Half_West,
      ].contains(nodeOrientation)) {
        z -= GameIsometricConstants.Node_Height;
        continue;
      }
      if (z > Node_Height){
        return z + (z % Node_Height);
      } else {
        return Node_Height;
      }
    }
  }

  IsometricGameObject findOrCreateGameObject(int id) {
    for (final gameObject in gameObjects) {
      if (gameObject.id == id) return gameObject;
    }
    final instance = IsometricGameObject(id);
    gameObjects.add(instance);
    return instance;
  }

  IsometricGameObject? findGameObjectById(int id) {
    for (final gameObject in gameObjects) {
      if (gameObject.id == id) return gameObject;
    }
    return null;
  }

  void clean() {
    gameObjects.clear();
    gamestream.isometric.nodes.colorStackIndex = -1;
    gamestream.isometric.nodes.ambientStackIndex = -1;
  }

  void sortGameObjects(){
    Engine.insertionSort(
      gameObjects,
      compare: gamestream.isometric.clientState.compareRenderOrder,
    );
  }

  void removeGameObjectById(int id )=>
      gameObjects.removeWhere((element) => element.id == id);

  void sortPlayerScores(){
    playerScores.sort(IsometricPlayerScore.compare);
  }

  bool get playerScoresInOrder {
    final total = playerScores.length;
    if (total <= 1) return true;
    for (var i = 0; i < total - 1; i++){
      if (playerScores[i].credits > playerScores[i + 1].credits)
        return false;
    }
    return true;
  }

  void updateProjectiles() {
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      if (projectile.type == ProjectileType.Rocket) {
        gamestream.isometric.clientState.spawnParticleSmoke(x: projectile.x, y: projectile.y, z: projectile.z);
        projectShadow(projectile);
        continue;
      }
      if (projectile.type == ProjectileType.Fireball) {
        gamestream.isometric.clientState.spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
        continue;
      }
      if (projectile.type == ProjectileType.Orb) {
        gamestream.isometric.clientState.spawnParticleOrbShard(
          x: projectile.x,
          y: projectile.y,
          z: projectile.z,
          angle: randomAngle(),
        );
      }
    }
  }


  int getWatchBeltItemTypeIndex(Watch<int> watchBelt){
    if (watchBelt == playerBelt1_ItemType) return ItemType.Belt_1;
    if (watchBelt == playerBelt2_ItemType) return ItemType.Belt_2;
    if (watchBelt == playerBelt3_ItemType) return ItemType.Belt_3;
    if (watchBelt == playerBelt4_ItemType) return ItemType.Belt_4;
    if (watchBelt == playerBelt5_ItemType) return ItemType.Belt_5;
    if (watchBelt == playerBelt6_ItemType) return ItemType.Belt_6;
    throw Exception('ServerQuery.getWatchBeltIndex($watchBelt)');
  }

  Watch<int> getWatchBeltTypeWatchQuantity(Watch<int> watchBelt){
    if (watchBelt == playerBelt1_ItemType) return playerBelt1_Quantity;
    if (watchBelt == playerBelt2_ItemType) return playerBelt2_Quantity;
    if (watchBelt == playerBelt3_ItemType) return playerBelt3_Quantity;
    if (watchBelt == playerBelt4_ItemType) return playerBelt4_Quantity;
    if (watchBelt == playerBelt5_ItemType) return playerBelt5_Quantity;
    if (watchBelt == playerBelt6_ItemType) return playerBelt6_Quantity;
    throw Exception('ServerQuery.getWatchBeltQuantity($watchBelt)');
  }

  int getItemTypeConsumesRemaining(int itemType) {
    final consumeAmount = ItemType.getConsumeAmount(itemType);
    if (consumeAmount <= 0) return 0;
    return countItemTypeQuantityInPlayerPossession(ItemType.getConsumeType(itemType)) ~/ consumeAmount;
  }

  int mapWatchBeltTypeToItemType(Watch<int> watchBeltType){
    if (watchBeltType == playerBelt1_ItemType) return ItemType.Belt_1;
    if (watchBeltType == playerBelt2_ItemType) return ItemType.Belt_2;
    if (watchBeltType == playerBelt3_ItemType) return ItemType.Belt_3;
    if (watchBeltType == playerBelt4_ItemType) return ItemType.Belt_4;
    if (watchBeltType == playerBelt5_ItemType) return ItemType.Belt_5;
    if (watchBeltType == playerBelt6_ItemType) return ItemType.Belt_6;
    throw Exception('ServerQuery.mapWatchBeltTypeToItemType($watchBeltType)');
  }

  int getItemQuantityAtIndex(int index){
    assert (index >= 0);
    if (index < inventory.length)
      return inventoryQuantity[index];
    if (index == ItemType.Belt_1)
      return playerBelt1_Quantity.value;
    if (index == ItemType.Belt_2)
      return playerBelt2_Quantity.value;
    if (index == ItemType.Belt_3)
      return playerBelt3_Quantity.value;
    if (index == ItemType.Belt_4)
      return playerBelt4_Quantity.value;
    if (index == ItemType.Belt_5)
      return playerBelt5_Quantity.value;
    if (index == ItemType.Belt_6)
      return playerBelt6_Quantity.value;

    throw Exception('ServerQuery.getItemQuantityAtIndex($index)');
  }

  int getItemTypeAtInventoryIndex(int index){
    if (index == ItemType.Equipped_Weapon)
      return gamestream.isometric.player.weapon.value;

    if (index == ItemType.Equipped_Head)
      return gamestream.isometric.player.head.value;

    if (index == ItemType.Equipped_Body)
      return gamestream.isometric.player.body.value;

    if (index == ItemType.Equipped_Legs)
      return gamestream.isometric.player.legs.value;

    if (index == ItemType.Belt_1){
      return playerBelt1_ItemType.value;
    }
    if (index == ItemType.Belt_2){
      return playerBelt2_ItemType.value;
    }
    if (index == ItemType.Belt_3){
      return playerBelt3_ItemType.value;
    }
    if (index == ItemType.Belt_4){
      return playerBelt4_ItemType.value;
    }
    if (index == ItemType.Belt_5){
      return playerBelt5_ItemType.value;
    }
    if (index == ItemType.Belt_6){
      return playerBelt6_ItemType.value;
    }
    if (index >= inventory.length){
      throw Exception("ServerQuery.getItemTypeAtInventoryIndex($index) index >= inventory.length");
    }
    if (index < 0){
      throw Exception("ServerQuery.getItemTypeAtInventoryIndex($index) index < 0");
    }
    return inventory[index];
  }

  int countItemTypeQuantityInPlayerPossession(int itemType){
    var total = 0;
    final inventoryLength = inventory.length;
    for (var i = 0; i < inventoryLength; i++){
      if (inventory[i] != itemType) continue;
      total += inventoryQuantity[i];
    }
    if (playerBelt1_ItemType.value == itemType) {
      total += playerBelt1_Quantity.value;
    }
    if (playerBelt2_ItemType.value == itemType) {
      total += playerBelt2_Quantity.value;
    }
    if (playerBelt3_ItemType.value == itemType) {
      total += playerBelt3_Quantity.value;
    }
    if (playerBelt4_ItemType.value == itemType) {
      total += playerBelt4_Quantity.value;
    }
    if (playerBelt5_ItemType.value == itemType) {
      total += playerBelt5_Quantity.value;
    }
    if (playerBelt6_ItemType.value == itemType) {
      total += playerBelt6_Quantity.value;
    }
    return total;
  }

  int getEquippedWeaponType() =>
      getItemTypeAtInventoryIndex(equippedWeaponIndex.value);

  int getEquippedWeaponQuantity() =>
      getItemQuantityAtIndex(equippedWeaponIndex.value);

  int getEquippedItemType(int itemType) =>
      ItemType.isTypeWeapon (itemType) ? gamestream.isometric.player.weapon.value :
      ItemType.isTypeHead   (itemType) ? gamestream.isometric.player.head.value   :
      ItemType.isTypeBody   (itemType) ? gamestream.isometric.player.body.value   :
      ItemType.isTypeLegs   (itemType) ? gamestream.isometric.player.legs.value   :
      ItemType.Empty          ;

  int getEquippedWeaponConsumeType() =>
      ItemType.getConsumeType(getEquippedWeaponType());


  void dropEquippedWeapon() =>
      gamestream.network.sendClientRequestInventoryDrop(ItemType.Equipped_Weapon);

  void equipWatchBeltType(Watch<int> watchBeltType) =>
      gamestream.network.sendClientRequestInventoryEquip(
          gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBeltType)
      );

  void inventoryUnequip(int index) =>
      gamestream.network.sendClientRequestInventoryUnequip(index);

  void inventoryMoveToWatchBelt(int index, Watch<int> watchBelt)=>
      gamestream.network.sendClientRequestInventoryMove(
        indexFrom: index,
        indexTo: gamestream.isometric.server.mapWatchBeltTypeToItemType(watchBelt),
      );

  void saveScene(){
    gamestream.network.sendClientRequest(ClientRequest.Edit, EditRequest.Save.index);
  }

  void editSceneSpawnAI() =>
      gamestream.network.sendClientRequest(
        ClientRequest.Edit,
        EditRequest.Spawn_AI.index,
      );

  void editSceneReset() =>
      gamestream.network.sendClientRequestEdit(EditRequest.Scene_Reset);

  void editSceneClearSpawnedAI(){
    gamestream.network.sendClientRequest(ClientRequest.Edit, EditRequest.Clear_Spawned.index);
  }

  void onChangedAreaType(int areaType) {
    gamestream.isometric.clientState.areaTypeVisible.value = true;
  }

  void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      gamestream.audio.thunder(1.0);
    } else {
      gamestream.isometric.clientState.updateGameLighting();
    }
  }

  void onChangedGameTimeEnabled(bool value){
    GameIsometricUI.timeVisible.value = value;
  }
}



