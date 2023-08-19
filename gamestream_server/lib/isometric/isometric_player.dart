
import 'dart:typed_data';


import 'package:gamestream_server/lemon_bits.dart';
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/utils.dart';

import 'package:gamestream_server/core/player.dart';
import 'package:gamestream_server/games/isometric_editor/isometric_editor.dart';

import 'package:lemon_byte/byte_writer.dart';

import 'package:gamestream_server/lemon_math.dart';

import 'collider.dart';
import 'editor_state.dart';
import 'isometric_game.dart';
import 'character.dart';
import 'gameobject.dart';
import 'position.dart';
import 'power.dart';
import 'projectile.dart';
import 'scene.dart';
import 'scene_writer.dart';
import 'isometric_settings.dart';


class IsometricPlayer extends Character with ByteWriter implements Player {

  static const Cache_Length = 100;

  /// The power the user has selected but must still caste
  late final powerActivated = ChangeNotifier<Power?>(null, onActivatedPowerChanged);

  var _cacheAimTargetHealthPercentage = 0.0;
  var _debugging = false;
  var mouseLeftDownDuration = 0;
  var mouseLeftDownIgnore = false;
  var mouseRightDownDuration = 0;
  var mouseRightDownIgnore = false;
  var _mouseLeftDown = false;
  var _aimTargetAction = TargetAction.Run;
  Collider? _aimTarget;

  var weaponDurationPercentagePrevious = 0.0;
  var accuracyPrevious = 0.0;
  var totalProjectiles = 0;
  var inputMode = InputMode.Keyboard;
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var framesSinceClientRequest = 0;
  var name = generateRandomName();
  var sceneDownloaded = false;
  var initialized = false;
  var id = 0;
  var selectedColliderDirty = false;
  var gameTimeInMinutes = 0;
  var mouseX = 0.0;
  var mouseY = 0.0;

  var charactersIStart = 0;
  var charactersIEnd = 0;

  var positionCacheX = 0;
  var positionCacheY = 0;
  var positionCacheZ = 0;
  var cacheIndex = 0;

  late final EditorState editor;
  final cacheStateB = Uint8List(Cache_Length);
  final cacheStateA = Uint32List(Cache_Length);
  final cachePositionX = Int16List(Cache_Length);
  final cachePositionY = Int16List(Cache_Length);
  final cachePositionZ = Int16List(Cache_Length);
  final cacheTemplateA = Uint64List(Cache_Length);

  GameObject? editorSelectedGameObject;
  IsometricGame game;
  Collider? selectedCollider;

  var controlsCanTargetEnemies = false;

  IsometricPlayer({
    required this.game,
    required super.x,
    required super.y,
    required super.z,
    required super.health,
    required super.team,
    bool autoTargetNearbyEnemies = false,
  }) : super(
    characterType: CharacterType.Template,
    weaponCooldown: 20,
    weaponRange: 100,
    weaponType: WeaponType.Unarmed,
    weaponDamage: 1,
  ){
    editor  = EditorState(this);
    this.autoTarget = autoTargetNearbyEnemies;
    id = game.playerId++;
  }

  set debugging(bool value){
    if (_debugging == value)
      return;

    _debugging = value;
    writeDebugging();
  }

  bool get debugging => _debugging;

  @override
  set runToDestinationEnabled(bool value){
    if (super.runToDestinationEnabled == value)
      return;

    super.runToDestinationEnabled = value;
    writeRunToDestinationEnabled();
  }

  @override
  set arrivedAtDestination(bool value){
    if (super.arrivedAtDestination == value)
      return;

    super.arrivedAtDestination = value;
    writePlayerArrivedAtDestination();
  }

  @override
  set maxHealth(int value){
    if (maxHealth == value) return;
    super.maxHealth = value;
    writePlayerHealth();
  }

  set health (int value) {
    if (health == value) return;
    super.health = value;
    writePlayerHealth();
  }

  Collider? get aimTarget => _aimTarget;

  int get aimTargetCategory => _aimTargetAction;

  @override
  bool get isPlayer => true;

  set aimTargetCategory(int value){
    if (_aimTargetAction == value) return;
    _aimTargetAction = value;
    writePlayerAimTargetAction();
  }

  set aimTarget(Collider? value){
    if (value == _aimTarget) return;
    _aimTarget = value;
    onChangedAimTarget();
  }

  int get mouseIndex => game.scene.getIndexXYZ(mouseSceneX, mouseSceneY, mouseSceneZ);

  bool get aimTargetWithinInteractRadius => aimTarget != null
      ? getDistance(aimTarget!) < IsometricSettings.Interact_Radius
      : false;

  double get mouseSceneX => game.clampX((mouseX + mouseY) + z);

  double get mouseSceneY => game.clampY((mouseY - mouseX) + z);

  double get mouseSceneZ => game.clampZ(z);

  /// in radians
  double get mouseAngle => getAngleXY(
      mouseSceneX  + Character_Gun_Height,
      mouseSceneY + Character_Gun_Height,
  );

  Scene get scene => game.scene;

  double get mouseDistance => this.getDistanceXY(mouseSceneX, mouseSceneY);

  set mouseLeftDown(bool value){
    if (_mouseLeftDown != value) {
      _mouseLeftDown = value;
      if (value){
        onMouseLeftClicked();
      } else {
        onMouseLeftReleased();
      }
    } else {
      if (value){
        onMouseLeftHeld();
      }
    }
  }

  void writeErrorInvalidInventoryIndex(int index){
     writeGameError(GameError.Invalid_Inventory_Index);
  }

  void writeInfo(String info){
    writeByte(ServerResponse.Info);
    writeString(info);
  }

  void writeIsometricPlayer(){
    // final weaponDurationPercentage = this.weaponDurationPercentage;
    // if (weaponDurationPercentagePrevious != weaponDurationPercentage){
    //   weaponDurationPercentagePrevious = weaponDurationPercentage;
    //   writeByte(ServerResponse.Isometric);
    //   writeByte(IsometricResponse.Player_Weapon_Duration_Percentage);
    //   writePercentage(weaponDurationPercentage);
    // }

    if (weaponAccuracy != accuracyPrevious){
      accuracyPrevious = weaponAccuracy;
      writeByte(ServerResponse.Isometric);
      writeByte(IsometricResponse.Player_Accuracy);
      writePercentage(weaponAccuracy);
    }

    final diffX = -(positionCacheX - x.toInt()).toInt();
    final diffY = -(positionCacheY - y.toInt()).toInt();
    final diffZ = -(positionCacheZ - z.toInt()).toInt();

    if (diffX == 0 && diffY == 0 && diffZ == 0) return;

    if (diffX.abs() < 126 && diffY.abs() < 126 && diffZ.abs() < 126){
      writeByte(ServerResponse.Isometric);
      writeByte(IsometricResponse.Player_Position_Change);
      writeInt8(diffX);
      writeInt8(diffY);
      writeInt8(diffZ);
    } else {
      writeByte(ServerResponse.Isometric);
      writeByte(IsometricResponse.Player_Position);
      writeIsometricPosition(this);
    }
    positionCacheX = x.toInt();
    positionCacheY = y.toInt();
    positionCacheZ = z.toInt();
  }

  void writePlayerHealth(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Health);
    writeUInt16(health);
    writeUInt16(maxHealth); // 2
  }

  void writePlayerDamage() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Damage);
    writeUInt16(weaponDamage);
  }

  void writePlayerAlive(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Alive);
    writeBool(alive);
  }

  void writePlayerActive(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Active);
    writeBool(active);
  }

  void writePlayerExperiencePercentage(double value){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Experience_Percentage);
    writePercentage(value);
  }

  void writePlayerAimAngle(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Aim_Angle);
    writeAngle(mouseAngle);
  }

  @override
  void writePlayerGame() {

    if (!initialized) {
      initialized = true;
      writePlayerInitialized();
      game.customInitPlayer(this);
      writeIsometricPlayer();
      writePlayerSpawned();
      writePlayerHealth();
      writePlayerAlive();
      writeDebugging();
      writePlayerControls();
    }

    if (!sceneDownloaded){
      downloadScene();
    }

    writeIsometricPlayer();
    writePlayerTargetPosition();
    writePlayerAimTargetPosition();
    writePlayerAimTargetAction();
    writePlayerDestination();

    writeSelectedCollider();

    writeProjectiles();
    writeCharacters();
    writeEditorGameObjectSelected();
    writeGameTime();
    writeAimTargetHealthPercentage();
  }

  void writeAimTargetHealthPercentage() {
    final aimTarget = this.aimTarget;
    if (aimTarget is Character && _cacheAimTargetHealthPercentage != aimTarget.healthPercentage) {
      _cacheAimTargetHealthPercentage = aimTarget.healthPercentage;
      writeByte(ServerResponse.Player);
      writeByte(PlayerResponse.Aim_Target_Health);
      writePercentage(_cacheAimTargetHealthPercentage);
    }
  }

  void writeGameObjects(){
    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.GameObjects);
    final gameObjects = game.gameObjects;
    for (final gameObject in gameObjects) {
      writeGameObject(gameObject);
    }
  }

  void writeCharacters() {
    writeByte(ServerResponse.Isometric_Characters);

    const padding = 100.0;
    final characters = game.characters;
    final charactersLength = characters.length;
    final screenBottomPadded = screenBottom + padding;
    final screenTopPadded = screenTop - padding;
    final screenLeftPadded = screenLeft - padding;
    final screenRightPadded = screenRight + padding;

    cacheIndex = 0;

    // var start = charactersIStart;
    // var end = charactersIEnd;
    // var startShiftedDown = false;
    // var endShiftedDown = false;
    //
    // while (true) {
    //
    //   if (start == 0)
    //     break;
    //
    //   if (start >= charactersLength){
    //     start--;
    //     continue;
    //   }
    //
    //   final previous = characters[start - 1];
    //
    //   if (
    //      previous.renderX > screenLeftPadded ||
    //      previous.renderY > screenTopPadded
    //   ){
    //     start--;
    //     startShiftedDown = true;
    //     continue;
    //   }
    //   break;
    // }
    //
    // if (!startShiftedDown) {
    //   while (true) {
    //
    //     if (start >= charactersLength){
    //       break;
    //     }
    //
    //     final next = characters[start + 1];
    //
    //     if (
    //       next.renderX < screenLeftPadded ||
    //       next.renderY < screenTopPadded
    //     ){
    //       start++;
    //       continue;
    //     }
    //     break;
    //   }
    // }
    //
    //
    // /// check end
    //
    // if (end <= start){
    //   end = start + 1;
    // }
    //
    // while (true) {
    //
    //   if (end <= 0)
    //     break;
    //
    //   if (end >= charactersLength){
    //     end--;
    //     continue;
    //   }
    //
    //   final previous = characters[end - 1];
    //
    //   if (
    //      previous.renderX > screenRightPadded ||
    //      previous.renderY > screenBottomPadded
    //   ){
    //     end--;
    //     endShiftedDown = true;
    //     continue;
    //   }
    //   break;
    // }
    //
    // if (!endShiftedDown) {
    //   while (true) {
    //
    //     if (end >= charactersLength - 1){
    //       break;
    //     }
    //
    //     final next = characters[end + 1];
    //
    //     if (
    //       next.renderX < screenRightPadded ||
    //       next.renderY < screenBottomPadded
    //     ){
    //       end++;
    //       continue;
    //     }
    //     break;
    //   }
    // }
    //
    // charactersIStart = start;
    // charactersIEnd = end;

    for (var i = 0; i < charactersLength; i++) {

      final character = characters[i];

      if (character.inactive)
        continue;

      final renderX = character.renderX;

      if (renderX < screenLeftPadded || renderX > screenRightPadded)
        continue;

      final renderY = character.renderY;

      if (renderY < screenTopPadded)
        continue;

      if (renderY > screenBottomPadded){
        assert (() {
          while (i < charactersLength){
            final characterI = characters[i];
            final renderY = characterI.renderY;
            if (renderY < screenBottomPadded){
              return false;
            }
            i++;
          }
          return true;
        }());
        break;
      }

      final characterX = character.x.toInt();
      final characterY = character.y.toInt();
      final characterZ = character.z.toInt();

      final diffX = -(cachePositionX[cacheIndex] - characterX);
      final diffY = -(cachePositionY[cacheIndex] - characterY);
      final diffZ = -(cachePositionZ[cacheIndex] - characterZ);

      final diffXChangeType = ChangeType.fromDiff(diffX);
      final diffYChangeType = ChangeType.fromDiff(diffY);
      final diffZChangeType = ChangeType.fromDiff(diffZ);

      final compressedState = character.compressedState;
      final compressedFrameAndDirection = character.compressedAnimationFrameAndDirection;

      final stateAChanged = compressedState != cacheStateA[cacheIndex];
      final stateBChanged = compressedFrameAndDirection != cacheStateB[cacheIndex];

      final compressionLevel = writeBitsToByte(stateAChanged, stateBChanged, false, false, false, false, false, false)
         | (diffXChangeType << 2)
         | (diffYChangeType << 4)
         | (diffZChangeType << 6);

      writeByte(compressionLevel);

      if (stateAChanged){
        writeByte(character.characterType);
        writeByte(character.state);
        writeByte(character.team);
        writePercentage(character.healthPercentage);
        cacheStateA[cacheIndex] = compressedState;
      }

      if (stateBChanged) {
        writeByte(compressedFrameAndDirection);
        cacheStateB[cacheIndex] = compressedFrameAndDirection;
      }

      if (diffXChangeType == ChangeType.Small) {
        writeInt8(diffX);
        cachePositionX[cacheIndex] = characterX;
      } else if (diffXChangeType == ChangeType.Big) {
        writeInt16(characterX);
        cachePositionX[cacheIndex] = characterX;
      }

      if (diffYChangeType == ChangeType.Small) {
        writeInt8(diffY);
        cachePositionY[cacheIndex] = characterY;
      } else if (diffYChangeType == ChangeType.Big) {
        writeInt16(characterY);
        cachePositionY[cacheIndex] = characterY;
      }

      if (diffZChangeType == ChangeType.Small) {
        writeInt8(diffZ);
        cachePositionZ[cacheIndex] = characterZ;
      } else if (diffZChangeType == ChangeType.Big) {
        writeInt16(characterZ);
        cachePositionZ[cacheIndex] = characterZ;
      }

      if (character.characterTypeTemplate) {
        writeCharacterTemplate(character);
      }

      writePercentage(character.actionCompletionPercentage);
      cacheIndex++;
    }
    writeByte(CHARACTER_END);
  }

  void downloadScene(){
    writeGameType();
    writeGameTime();
    writePlayerTeam();
    writeGameProperties();
    writeScene();
    writeWeather();
    writeGameObjects();
    writeFPS();
    game.customDownloadScene(this);
    writePlayerEvent(PlayerEvent.Scene_Changed);
    sceneDownloaded = true;
  }

  void writePlayerSpawned(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Spawned);
  }

  void writePlayerTargetPosition(){
    if (target == null) return;
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Target_Position);
    writeIsometricPosition(target!);
  }

  void writePlayerDestination(){
    if (!runToDestinationEnabled || arrivedAtDestination)
      return;

    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Destination);
    writeDouble(runX);
    writeDouble(runY);
    writeDouble(runZ);
  }

  void writePlayerArrivedAtDestination(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Arrived_At_Destination);
    writeBool(arrivedAtDestination);
  }

  void writePlayerAimTargetPosition() {
    if (aimTarget == null) return;
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Aim_Target_Position);
    writeIsometricPosition(aimTarget!);
  }

  void writePlayerAimTargetAction() {
    writeByte(ServerResponse.Player);
    writeByte(PlayerResponse.Aim_Target_Action);
    writeByte(_aimTargetAction);
  }

  void writePlayerAimTargetType() {
    if (aimTarget == null) return;
    if (aimTarget is GameObject){
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Aim_Target_Type);
      writeUInt16((aimTarget as GameObject).type);
    }
    if (aimTarget is Character) {
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Aim_Target_Type);
      writeUInt16((aimTarget as Character).characterType);
    }
  }

  void writePlayerAimTargetQuantity() {
    if (aimTarget is GameObject) {
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Aim_Target_Quantity);
      writeUInt16((aimTarget as GameObject).quantity);
    }
  }

  int getTargetAction(Position? value){

    if (value == null)
      return TargetAction.Run;

    if (value is GameObject) {
      if (value.interactable) {
        return TargetAction.Talk;
      }
      if (value.collectable){
        return TargetAction.Collect;
      }
      if (value.physical && value.hitable){
        return TargetAction.Attack;
      }
      return TargetAction.Run;
    }

    if (isEnemy(value))
      return TargetAction.Attack;

    return TargetAction.Run;
  }

  bool onScreen(double x, double y){
    const Max_Distance = 800.0;
    if ((this.x - x).abs() > Max_Distance) return false;
    if ((this.y - y).abs() > Max_Distance) return false;
    return true;
  }

  void writeProjectiles(){
    final projectiles = game.projectiles;
    var totalActiveProjectiles = 0;
    for (final projectile in projectiles) {
      if (!projectile.active) continue;
      totalActiveProjectiles++;
    }
    if (totalActiveProjectiles == 0){
      if (totalProjectiles == 0) return;
      totalProjectiles = 0;
    }
    totalProjectiles = totalActiveProjectiles;
    writeByte(ServerResponse.Projectiles);
    writeUInt16(totalActiveProjectiles);
    projectiles.forEach(writeProjectile);
  }

  void writeGameEvent({
    required int type,
    required double x,
    required double y,
    required double z,
    required double angle,
  }){
    writeByte(ServerResponse.Game_Event);
    writeByte(type);
    writeDouble(x);
    writeDouble(y);
    writeDouble(z);
    writeDouble(angle * radiansToDegrees);
  }

  void writePlayerEventItemTypeConsumed(int itemType){
    writePlayerEvent(PlayerEvent.Item_Consumed);
    writeByte(itemType);
  }

  void writePlayerEventRecipeCrafted() =>
    writePlayerEvent(PlayerEvent.Recipe_Crafted);

  void writePlayerEventInventoryFull() =>
      writePlayerEvent(PlayerEvent.Inventory_Full);

  void writePlayerEventInvalidRequest() =>
      writePlayerEvent(PlayerEvent.Invalid_Request);

  void writePlayerEventItemAcquired(int itemType){
    writePlayerEvent(PlayerEvent.Item_Acquired);
    writeUInt16(itemType);
  }

  void writePlayerEvent(int value){
    writeByte(ServerResponse.Player_Event);
    writeByte(value);
  }

  void writePlayerMoved(){
    writeIsometricPlayer();
    writePlayerEvent(PlayerEvent.Player_Moved);
  }

  void writeApiPlayerSpawned(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Spawned);
  }

  void writePlayerMessage(String message){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Message);
    writeString(message);
  }

  void writeGameTime(){
    final gameTimeInMinutes = game.time.time ~/ Duration.secondsPerMinute;
    if (gameTimeInMinutes == this.gameTimeInMinutes) return;
    this.gameTimeInMinutes = gameTimeInMinutes;
    writeByte(ServerResponse.Game_Time);
    writeUInt24(game.time.time);
  }

  void writeProjectile(Projectile projectile){
    if (!projectile.active) return;
    writePosition(projectile);
    writeByte(projectile.type);
    writeAngle(projectile.velocityAngle);
  }

  void writeCharacterTemplate(Character character) {

    final compressedA = compressBytesToUInt64(
      character.weaponType,
      character.bodyType,
      character.helmType,
      character.legsType,
      character.handTypeLeft,
      character.handTypeRight,
      0,
      0,
    );

    // final compressedB = character.compressedLookAndWeaponState;

    final writeA = cacheTemplateA[cacheIndex] != compressedA;
    // final writeB = cacheTemplateB[cacheIndex] != compressedB;

    writeByte(
      writeBitsToByte(writeA, false, false, false, false, false, false, false)
    );

    if (writeA){
      cacheTemplateA[cacheIndex] = compressedA;
      writeByte(character.weaponType);
      writeByte(character.bodyType);
      writeByte(character.helmType);
      writeByte(character.legsType);
      writeByte(character.handTypeLeft);
      writeByte(character.handTypeRight);
    }

    // if (writeB){
    //   cacheTemplateB[cacheIndex] = compressedB;
    //   writeByte(compressedB);
    // }
  }

  void writeWeather() {
    final environment = game.environment;
    writeByte(ServerResponse.Weather);
    writeByte(environment.rainType);
    writeBool(environment.breezy);
    writeByte(environment.lightningType);
    writeByte(environment.windType);
    writeByte(environment.mystType);
    writeGameTimeEnabled();
  }

  void writePercentage(double value){
    if (value.isNaN) {
      writeByte(0);
      return;
    }
    if (value > 1.0) writeByte(255);
    writeByte((value * 255).toInt());
  }

  void writePosition(Position value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeIsometricPosition(Position value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeVector3(Position value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeScene() {
    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.Scene);
    var compiled = scene.compiled;
    if (compiled == null) {
      compiled = SceneWriter.compileScene(scene, gameObjects: false);
      scene.compiled = compiled;
    }
    writeBytes(compiled);
  }

  void writePlayerTarget() {
    final target = this.target;
    if (target == null) return;
    writeByte(ServerResponse.Player_Target);
    writePosition(target);
  }

  void writeAngle(double radians){
    writeDouble(radians * radiansToDegrees);
  }

  void writeGameProperties() {
    writeByte(ServerResponse.Game_Properties);
    writeBool((game is IsometricEditor || isLocalMachine));
    writeString(game.scene.name);
    writeBool(game.running);
  }

  void writeEditorGameObjectSelected() {
    final selectedGameObject = editorSelectedGameObject;
    if (selectedGameObject == null) return;
    writeByte(ServerResponse.Editor_GameObject_Selected);
    writeUInt16(selectedGameObject.id);
    writeBool(selectedGameObject.hitable);
    writeBool(selectedGameObject.fixed);
    writeBool(selectedGameObject.collectable);
    writeBool(selectedGameObject.physical);
    writeBool(selectedGameObject.persistable);
    writeBool(selectedGameObject.gravity);
  }

  void writeEnvironmentLightning(int value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Lightning);
    writeByte(value);
  }

  void writeEnvironmentWind(int windType){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Wind);
    writeByte(windType);
  }

  void writeGameTimeEnabled(){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Time_Enabled);
    writeBool(game.time.enabled);
  }

  void writeEnvironmentRain(int rainType){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Rain);
    writeByte(rainType);
  }

  void writeEnvironmentBreeze(bool value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Breeze);
    writeBool(value);
  }

  void writeEnvironmentLightningFlashing(){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Lightning_Flashing);
    writeBool(game.environment.lightningFlashing);
    writePercentage(game.environment.lightningFlash01);
  }

  void writeNode(int index){
    assert (index >= 0);
    assert (index < scene.volume);
    writeByte(ServerResponse.Node);
    writeUInt24(index);
    writeByte(scene.types[index]);
    writeByte(scene.shapes[index]);
  }

  void writeDouble(double value){
    writeInt16(value.toInt());
  }

  void writeGameObject(GameObject gameObject){
    writeByte(ServerResponse.GameObject);
    writeUInt16(gameObject.id);
    writeBool(gameObject.active);
    writeByte(gameObject.type);
    writeByte(gameObject.subType);
    writeUInt16(gameObject.health);
    writeUInt16(gameObject.healthMax);
    writeIsometricPosition(gameObject);
  }

  void writeMap(Map<int, int> map){
    final entries = map.entries;
    writeUInt16(entries.length);
    for (final entry in entries) {
      writeUInt16(entry.key);
      writeUInt16(entry.value);
    }
  }

  void writeMapListInt(Map<int, List<int>> value){
    final entries = value.entries;
    writeUInt16(entries.length);
    for (final entry in entries) {
      writeUInt16(entry.key);
      writeUInt16(entry.value.length);
      writeUint16List(entry.value);
    }
  }

  writePlayerApiId(){
    writeUInt8(ServerResponse.Api_Player);
    writeUInt8(ApiPlayer.Id);
    writeUInt24(id);
  }

  void writeGameEventGameObjectDestroyed(GameObject gameObject){
    writeGameEvent(
      type: GameEventType.Game_Object_Destroyed,
      x: gameObject.x,
      y: gameObject.y,
      z: gameObject.z,
      angle: gameObject.velocityAngle,
    );
    writeUInt16(gameObject.type);
  }

  void writePlayerTeam(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Team);
    writeByte(team);
  }

  void writeGameError(GameError value){
    writeByte(ServerResponse.Game_Error);
    writeByte(value.index);
  }

  void onMouseLeftReleased(){

  }

  void onMouseLeftClicked(){

  }

  void onMouseLeftHeld(){

  }

  void setPathToMouse() => pathTargetIndex = mouseIndex;

  void setDestinationToMouse() =>
      setRunDestination(mouseSceneX, mouseSceneY, mouseSceneZ);

  void writeSelectedCollider() {
    final selectedCollider = this.selectedCollider;

    if (selectedCollider == null) {
      if (!selectedColliderDirty) return;
      selectedColliderDirty = false;
      writeByte(ServerResponse.Isometric);
      writeByte(IsometricResponse.Selected_Collider);
      writeBool(false);
      return;
    }
    selectedColliderDirty = true;

    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.Selected_Collider);
    writeBool(true);

    if (selectedCollider is GameObject) {
      final gameObject = selectedCollider;
      writeByte(IsometricType.GameObject);
      writeString(gameObject.runtimeType.toString());
      writeUInt16(gameObject.team);
      writeUInt16(gameObject.radius.toInt());
      writeUInt16(gameObject.health);
      writeUInt16(gameObject.healthMax);
      writeIsometricPosition(gameObject);
      writeByte(gameObject.type);
      writeByte(gameObject.subType);
      return;
    }

    if (selectedCollider is Character) {
      final character = selectedCollider;
      writeByte(IsometricType.Character);
      writeString(character.runtimeType.toString());
      writeByte(character.action);
      writeByte(character.goal);
      writeUInt16(character.team);
      writeUInt16(character.radius.toInt());
      writeUInt16(selectedCollider.health);
      writeUInt16(selectedCollider.maxHealth);;
      writeIsometricPosition(character);
      writeInt16(character.runX.toInt());
      writeInt16(character.runY.toInt());
      writeCharacterPath(character);

      writeByte(character.characterType);
      writeByte(character.state);
      writeClampUInt16(character.actionDuration);
      writeClampUInt16(character.frame);
      writeUInt16(character.weaponType);
      writeUInt16(character.weaponDamage);
      writeUInt16(character.weaponRange.toInt());
      writeByte(0); // TODO
      writeUInt16(0); // TODO
      writeBool(character.autoTarget);
      writeBool(character.pathFindingEnabled);
      writeBool(character.runToDestinationEnabled);
      writeBool(character.arrivedAtDestination);

      final selectedCharacterTarget = character.target;
      if (selectedCharacterTarget == null){
        writeBool(false);
      } else {
        writeBool(true);
        writeString(selectedCharacterTarget.runtimeType.toString());
        writeIsometricPosition(selectedCharacterTarget);
      }
    }
  }

  void writeCharacterPath(Character character){
    writeInt16(character.pathCurrent);
    writeInt16(character.pathStart);
    writeInt16(character.pathTargetIndex);
    for (var j = 0; j < character.pathStart; j++){
      writeUInt16(character.path[j]);
    }
  }

  void selectNearestColliderToMouse({double maxRadius = 75}) =>
      selectedCollider = getNearestColliderToMouse(maxRadius: maxRadius);

  Collider? getNearestColliderToMouse({
    required double maxRadius
  }) => game.getNearestCollider(
      x: mouseSceneX,
      y: mouseSceneY,
      z: z,
      maxRadius: maxRadius,
    );

  void debugCommand() {
    final selectedCollider = this.selectedCollider;
    if (selectedCollider is! Character)
      return;

    final nearestMouseCollider = getNearestColliderToMouse(maxRadius: 75);
    if (nearestMouseCollider == selectedCollider)
      return;

    if (nearestMouseCollider != null) {
      selectedCollider.target = nearestMouseCollider;
      return;
    }

    selectedCollider.target = null;

    if (selectedCollider.pathFindingEnabled) {
      selectedCollider.pathTargetIndex = mouseIndex;
      return;
    }

    if (selectedCollider.runToDestinationEnabled) {
      selectedCollider.setRunDestination(
          mouseSceneX,
          mouseSceneY,
          mouseSceneZ,
      );
      return;
    }
  }

  void lookAtMouse(){
    if (deadOrBusy) return;
    angle = mouseAngle;
  }

  void onChangedAimTarget(){
     aimTargetCategory = getTargetAction(aimTarget);
     writePlayerAimTarget();
  }

  void writePlayerAimTarget(){
    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.Player_Aim_Target);

    writeBool(aimTarget != null);
    if (aimTarget == null) {
      return;
    }
    writeString(aimTarget!.name);
  }

  void writePlayerInitialized() {
    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.Player_Initialized);
  }

  void performPrimaryAction() {
    if (deadOrBusy)
      return;

    if (aimTarget == null) {
      setDestinationToMouse();
      runToDestinationEnabled = true;
      pathFindingEnabled = false;
      target = null;
      return;
    }

    setTargetToAimTarget();
  }

  void setTargetToAimTarget() {
    target = aimTarget;
    runToDestinationEnabled = true;
    pathFindingEnabled = false;
  }

  void writeRunToDestinationEnabled() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Run_To_Destination_Enabled);
    writeBool(runToDestinationEnabled);
  }

  void writeDebugging() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Debugging);
    writeBool(debugging);
  }

  void toggleDebugging() {
    debugging = !debugging;
  }

  void writePower(Power power) {
    writeByte(power.type.index);
    writeUInt16(power.cooldown);
    writeUInt16(power.cooldownRemaining);
    // writeBool(powerActivated.value == power);
    writeByte(power.level);
  }

  void onActivatedPowerChanged(Power? value){
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Activated_Power);
    if (value == null) {
      writeBool(false);
      return;
    }
    writeBool(true);
    writeByte(value.type.index);
    writeUInt16(value.range.toInt());
  }

  void writePlayerControls(){
    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.Player_Controls);
    writeBool(controlsCanTargetEnemies);
    writeBool(false); // TODO delete on client
  }

  void toggleControlsCanTargetEnemies() {
    controlsCanTargetEnemies = !controlsCanTargetEnemies;
    writePlayerControls();
  }

  @override
  void update() {
    super.update();

    framesSinceClientRequest++;

    if (dead) return;
    if (!active) return;

    game.updatePlayerAimTarget(this);

    // if (idling && !weaponStateBusy) {
    //   final diff = IsometricDirection.getDifference(
    //       lookDirection, direction);
    //   if (diff >= 2) {
    //     angle += piQuarter;
    //   } else if (diff <= -3) {
    //     angle -= piQuarter;
    //   }
    // }
  }

  double getMouseDistance() => this.getDistanceXYZ(mouseSceneX, mouseSceneY, mouseSceneZ);

  double getMouseAngle() => getAngleXY(mouseSceneX, mouseSceneY);

  @override
  void handleRequestException(Object exception) {
    // TODO: implement writeError
  }

  @override
  set helmType(int value) {
    if (helmType == value)
      return;

    super.helmType = value;
    writeHeadType();
  }

  @override
  set bodyType(int value) {
    if (bodyType == value)
      return;

    super.bodyType = value;
    writeBodyType();
  }

  @override
  set legsType(int value) {
    if (legsType == value)
      return;

    super.legsType = value;
    writeLegsType();
  }

  @override
  set handTypeLeft(int value){
    if (handTypeLeft == value)
      return;

    super.handTypeLeft = value;
    writeHandTypeLeft();
  }

  @override
  set handTypeRight(int value){
    if (handTypeRight == value)
      return;

    super.handTypeRight = value;
    writeHandTypeRight();
  }

  void writeHeadType() {
    writeByte(ServerResponse.Player);
    writeByte(PlayerResponse.HeadType);
    writeByte(helmType);
  }

  void writeBodyType() {
    writeByte(ServerResponse.Player);
    writeByte(PlayerResponse.BodyType);
    writeByte(bodyType);
  }

  void writeLegsType() {
    writeByte(ServerResponse.Player);
    writeByte(PlayerResponse.LegsType);
    writeByte(legsType);
  }

  void writeHandTypeLeft() {
    writeByte(ServerResponse.Player);
    writeByte(PlayerResponse.LegsType);
    writeByte(handTypeLeft);
  }

  void writeHandTypeRight() {
    writeByte(ServerResponse.Player);
    writeByte(PlayerResponse.LegsType);
    writeByte(handTypeRight);
  }

  void downloadSceneMarks() {
    writeByte(ServerResponse.Scene);
    writeByte(SceneResponse.Marks);
    final marks = scene.marks;
    writeUInt16(marks.length);
    for (final mark in marks){
      writeUInt32(mark);
    }
  }

  writeClampUInt16(int value) => writeUInt16(value.clamp(0, 65535));
}
