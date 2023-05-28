import 'package:gamestream_flutter/library.dart';

/// Synchronized server state
///
/// the data inside server state belongs to the server and can only be read by the client
///
/// WARNING - WRITING TO SERVER STATE IS FORBIDDEN
class ServerState {
  static var totalCharacters = 0;
  static var totalPlayers = 0;
  static var totalNpcs = 0;
  static var totalZombies = 0;
  static var totalProjectiles = 0;

  static final playerScores = <PlayerScore>[];
  static final playerScoresReads = Watch(0);
  static final gameObjects = <GameObject>[];
  static final characters = <Character>[];
  static final npcs = <Character>[];
  static final projectiles = <Projectile>[];

  static final highScore = Watch(0);
  static final areaType = Watch(AreaType.None, onChanged: ServerEvents.onChangedAreaType);
  static final interactMode = Watch(InteractMode.None, onChanged: GameEvents.onChangedPlayerInteractMode);
  static final playerHealth = Watch(0);
  static final playerMaxHealth = Watch(0);
  static final playerDamage = Watch(0);
  static final playerCredits = Watch(0);
  static final playerExperiencePercentage = Watch(0.0);
  static final playerLevel = Watch(1);
  static final playerAccuracy = Watch(1.0);
  static final playerAttributes = Watch(0);
  static final sceneEditable = Watch(false);
  static final sceneName = Watch<String?>(null);
  static final gameRunning = Watch(true);
  static final rainType = Watch(RainType.None, onChanged: GameEvents.onChangedRain);
  static final weatherBreeze = Watch(false);
  static final seconds = Watch(0, onChanged: GameEvents.onChangedSeconds);
  static final hours = Watch(0, onChanged: GameEvents.onChangedHour);
  static final minutes = Watch(0);

  static final lightningType = Watch(LightningType.Off);
  static final watchTimePassing = Watch(false);
  static final windTypeAmbient = Watch(WindType.Calm, onChanged: GameEvents.onChangedWindType);
  static final error = Watch("invalid request", onChanged: GameEvents.onChangedError);
  static final gameStatus = Watch(GameStatus.Playing);

  static final playerBelt1_ItemType = Watch(ItemType.Empty);
  static final playerBelt2_ItemType = Watch(ItemType.Empty);
  static final playerBelt3_ItemType = Watch(ItemType.Empty);
  static final playerBelt4_ItemType = Watch(ItemType.Empty);
  static final playerBelt5_ItemType = Watch(ItemType.Empty);
  static final playerBelt6_ItemType = Watch(ItemType.Empty);

  static final playerBelt1_Quantity = Watch(0);
  static final playerBelt2_Quantity = Watch(0);
  static final playerBelt3_Quantity = Watch(0);
  static final playerBelt4_Quantity = Watch(0);
  static final playerBelt5_Quantity = Watch(0);
  static final playerBelt6_Quantity = Watch(0);

  static final equippedWeaponIndex = Watch(0);

  static final watchBeltItemTypes = [
    playerBelt1_ItemType,
    playerBelt2_ItemType,
    playerBelt3_ItemType,
    playerBelt4_ItemType,
    playerBelt5_ItemType,
    playerBelt6_ItemType,
  ];

  // VARIABLES
  static var inventory = Uint16List(0);
  static var inventoryQuantity = Uint16List(0);
  static final tagTypes = <String, int> {};
  static final sceneUnderground = Watch(false);
  static final lightningFlashing = Watch(false, onChanged: ServerEvents.onChangedLightningFlashing);
  static final gameTimeEnabled = Watch(false, onChanged: ServerEvents.onChangedGameTimeEnabled);

  static Character getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(Character());
    }
    return characters[totalCharacters];
  }

  static Character? getPlayerCharacter(){
    for (var i = 0; i < totalCharacters; i++){
      if (characters[i].x != GamePlayer.position.x) continue;
      if (characters[i].y != GamePlayer.position.y) continue;
      return characters[i];
    }
    return null;
  }

  static void applyEmissionGameObjects() {
    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      switch (gameObject.emission_type) {
        case EmissionType.None:
          continue;
        case EmissionType.Color:
          gamestream.games.isometric.clientState.applyVector3Emission(
            gameObject,
            hue: gameObject.emission_hue,
            saturation: gameObject.emission_sat,
            value: gameObject.emission_val,
            alpha: gameObject.emission_alp,
            intensity: gameObject.emission_intensity,
          );
          continue;
        case EmissionType.Ambient:
          gamestream.games.isometric.clientState.applyVector3EmissionAmbient(gameObject,
              alpha: gameObject.emission_alp,
              intensity: gameObject.emission_intensity,
          );
          continue;
      }
    }
  }

  /// TODO Optimize
  static void updateGameObjects() {
    for (final gameObject in gameObjects){
      if (!gameObject.active) continue;
      gameObject.update();
      if (gameObject.type != ItemType.Weapon_Thrown_Grenade) continue;
      projectShadow(gameObject);
    }
  }

  static void projectShadow(Vector3 v3){
     if (!gamestream.games.isometric.nodes.inBoundsVector3(v3)) return;

     final z = getProjectionZ(v3);
     if (z < 0) return;
     gamestream.games.isometric.clientState.spawnParticle(
         type: ParticleType.Shadow,
         x: v3.x,
         y: v3.y,
         z: z,
         angle: 0,
         speed: 0,
         duration: 2,
     );
  }

  static double getProjectionZ(Vector3 vector3){

    final x = vector3.x;
    final y = vector3.y;
    var z = vector3.z;

    while (true) {
        if (z < 0) return -1;
        final nodeIndex = gamestream.games.isometric.nodes.getIndexXYZ(x, y, z);
        final nodeOrientation = gamestream.games.isometric.nodes.nodeOrientations[nodeIndex];

        if (const <int> [
          NodeOrientation.None,
          NodeOrientation.Radial,
          NodeOrientation.Half_South,
          NodeOrientation.Half_North,
          NodeOrientation.Half_East,
          NodeOrientation.Half_West,
        ].contains(nodeOrientation)) {
          z -= GameConstants.Node_Height;
          continue;
        }
        if (z > Node_Height){
          return z + (z % Node_Height);
        } else {
          return Node_Height;
        }
    }
  }

  static GameObject findOrCreateGameObject(int id) {
    for (final gameObject in gameObjects) {
      if (gameObject.id == id) return gameObject;
    }
    final instance = GameObject(id);
    gameObjects.add(instance);
    return instance;
  }

  static GameObject? findGameObjectById(int id) {
    for (final gameObject in gameObjects) {
      if (gameObject.id == id) return gameObject;
    }
    return null;
  }

  static void clean() {
    gameObjects.clear();
    gamestream.games.isometric.nodes.colorStackIndex = -1;
    gamestream.games.isometric.nodes.ambientStackIndex = -1;
  }

  static void sortGameObjects(){
    Engine.insertionSort(
      gameObjects,
      compare: ClientState.compareRenderOrder,
    );
  }

  static void removeGameObjectById(int id )=>
      gameObjects.removeWhere((element) => element.id == id);

  static void setMessage(String value){
    error.value = "";
    error.value = value;
  }

  static void sortPlayerScores(){
    // if (playerScoresInOrder) return;
    playerScores.sort(PlayerScore.compare);
  }

  static bool get playerScoresInOrder {
    final total = playerScores.length;
    if (total <= 1) return true;
    for (var i = 0; i < total - 1; i++){
      if (playerScores[i].credits > playerScores[i + 1].credits)
        return false;
    }
    return true;
  }

  static void updateProjectiles() {
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      if (projectile.type == ProjectileType.Rocket) {
        gamestream.games.isometric.clientState.spawnParticleSmoke(x: projectile.x, y: projectile.y, z: projectile.z);
        ServerState.projectShadow(projectile);
        continue;
      }
      if (projectile.type == ProjectileType.Fireball) {
        gamestream.games.isometric.clientState.spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
        continue;
      }
      if (projectile.type == ProjectileType.Orb) {
        gamestream.games.isometric.clientState.spawnParticleOrbShard(
          x: projectile.x,
          y: projectile.y,
          z: projectile.z,
          angle: randomAngle(),
        );
      }
    }
  }
}



