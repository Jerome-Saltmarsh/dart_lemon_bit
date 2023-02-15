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

  static final gameObjects = <GameObject>[];
  static final characters = <Character>[];
  static final npcs = <Character>[];
  static final projectiles = <Projectile>[];

  static final areaType = Watch(AreaType.None, onChanged: ServerEvents.onChangedAreaType);
  static final interactMode = Watch(InteractMode.None, onChanged: GameEvents.onChangedPlayerInteractMode);
  static final playerHealth = Watch(0);
  static final playerMaxHealth = Watch(0);
  static final playerDamage = Watch(0);
  static final playerBaseHealth = Watch(0);
  static final playerBaseDamage = Watch(0);
  static final playerBaseEnergy = Watch(0);
  static final playerPerkMaxHealth = Watch(0);
  static final playerPerkMaxDamage = Watch(0);
  static final playerGold = Watch(0);
  static final playerExperiencePercentage = Watch(0.0);
  static final playerLevel = Watch(1);
  static final playerAttributes = Watch(0);
  static final playerAccuracy = Watch(1.0);
  static final playerSelectHero = Watch(false);
  static final sceneEditable = Watch(false);
  static final sceneName = Watch<String?>(null);
  static final gameRunning = Watch(true);
  static final rainType = Watch(RainType.None, onChanged: GameEvents.onChangedRain);
  static final weatherBreeze = Watch(false);
  static final hours = Watch(0, onChanged: GameEvents.onChangedHour);
  static final minutes = Watch(0);

  static final gameType = Watch<int?>(null, onChanged: ServerEvents.onChangedGameType);
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

  static var lightsOn = true;
  static var lightsNext = 200;

  static void applyEmissionGameObjects() {
    lightsNext--;
    if (lightsNext <= 0) {
      lightsOn = !lightsOn;
      if (lightsOn) {
        lightsNext = randomInt(5, 200);
      } else {
        lightsNext = randomInt(2, 15);
      }
    }

    for (final gameObject in gameObjects) {

      if (!gameObject.active) continue;

      if (gameObject.type == ItemType.GameObjects_Barrel_Flaming) {
        GameState.applyVector3EmissionAmbient(gameObject, alpha: 0);
        continue;
      }

      if (gameObject.type == ItemType.GameObjects_Grenade) {
        GameState.applyVector3EmissionAmbient(gameObject, alpha: 0);
        continue;
      }

      if (gameObject.type == ItemType.GameObjects_Crystal_Small_Blue) {
        GameState.applyVector3Emission(
          gameObject,
          hue: 209,
          saturation: 66,
          value: 90,
          alpha: 156,
        );
        continue;
      }

      if (gameObject.emission) {
        GameState.applyVector3Emission(
          gameObject,
          hue: gameObject.emission_hue,
          saturation: gameObject.emission_sat,
          value: gameObject.emission_val,
          alpha: gameObject.emission_alp,
        );
        continue;
      }

      // if (gameObject.type == ItemType.GameObjects_Neon_Sign_01) {
      //   if (!lightsOn) continue;
      //   GameState.applyVector3Emission(
      //     gameObject,
      //     hue: 344,
      //     saturation: 67,
      //     value: 94,
      //     alpha: 156,
      //   );
      //   continue;
      // }
      //
      // if (gameObject.type == ItemType.GameObjects_Neon_Sign_02) {
      //   if (!lightsOn) continue;
      //   GameState.applyVector3Emission(
      //     gameObject,
      //     hue: 166,
      //     saturation: 78,
      //     value: 88,
      //     alpha: 156,
      //   );
      //   continue;
      // }

      if (gameObject.type == ItemType.GameObjects_Crystal_Small_Red) {
        GameState.applyVector3Emission(gameObject,
          hue: 360,
          saturation: 74,
          value: 90,
          alpha: 156,
        );
        continue;
      }
    }
  }

  static void updateGameObjects() {
    for (final gameObject in gameObjects){
      if (!gameObject.active) continue;
      if (gameObject.type != ItemType.GameObjects_Grenade) continue;
      projectShadow(gameObject);
    }
  }


  static void projectShadow(Vector3 v3){
     final z = getProjectionZ(v3);
     if (z < 0) return;
     GameState.spawnParticle(
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
        final nodeIndex = GameNodes.getIndexXYZ(x, y, z);
        final nodeOrientation = GameNodes.nodeOrientations[nodeIndex];

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

  /// TODO rename to findOrCreateGameObject
  static GameObject findGameObjectById(int id){
    for (final gameObject in gameObjects){
      if (gameObject.id != id) continue;
      return gameObject;
    }
    final instance = GameObject()..id = id;
    gameObjects.add(instance);
    return instance;
  }

  static GameObject? findGameObjectById2(int id){
    for (final gameObject in gameObjects){
      if (gameObject.id != id) continue;
      return gameObject;
    }
    return null;
  }

  static void clean() {
    gameObjects.clear();
    GameNodes.colorStackIndex = -1;
    GameNodes.ambientStackIndex = -1;
  }

  static void sortGameObjects(){
    Engine.insertionSort(
      gameObjects,
      compare: ClientState.compareRenderOrder,
    );
  }

  static void removeGameObjectById(int id )=>
      gameObjects.removeWhere((element) => element.id == id);
}



