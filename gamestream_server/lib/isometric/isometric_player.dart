
import 'dart:math';
import 'dart:typed_data';

import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/utils.dart';

import 'package:gamestream_server/core/player.dart';
import 'package:gamestream_server/games/isometric_editor/isometric_editor.dart';

import 'package:lemon_byte/byte_writer.dart';

import 'package:gamestream_server/lemon_math.dart';

import 'isometric_collider.dart';
import 'isometric_game.dart';
import 'isometric_character.dart';
import 'isometric_gameobject.dart';
import 'isometric_position.dart';
import 'isometric_projectile.dart';
import 'isometric_scene.dart';
import 'isometric_scene_writer.dart';
import 'isometric_settings.dart';


class IsometricPlayer extends IsometricCharacter with ByteWriter implements Player {

  static const Cache_Length = 100;

  var _mouseLeftDown = false;
  var _aimTargetCategory = TargetCategory.Run;
  IsometricCollider? _aimTarget;

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

  var positionCacheX = 0;
  var positionCacheY = 0;
  var positionCacheZ = 0;
  var cacheIndex = 0;

  final cacheStateB = Uint8List(Cache_Length);
  final cacheStateA = Uint32List(Cache_Length);
  final cachePositionX = Int16List(Cache_Length);
  final cachePositionY = Int16List(Cache_Length);
  final cachePositionZ = Int16List(Cache_Length);
  final cacheTemplateA = Uint32List(Cache_Length);
  final cacheTemplateB = Uint8List(Cache_Length);

  IsometricGameObject? editorSelectedGameObject;
  IsometricGame game;
  IsometricCollider? selectedCollider;

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
    this.autoTarget = autoTargetNearbyEnemies;
    aiDelayAfterPerformFinished = false;
    id = game.playerId++;
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

  IsometricCollider? get aimTarget => _aimTarget;

  int get aimTargetCategory => _aimTargetCategory;

  @override
  bool get isPlayer => true;

  set aimTargetCategory(int value){
    if (_aimTargetCategory == value) return;
    _aimTargetCategory = value;
    writePlayerAimTargetCategory();
  }

  set aimTarget(IsometricCollider? value){
    if (value == _aimTarget) return;
    _aimTarget = value;
    onChangedAimTarget();
  }

  int get mouseIndex => game.scene.getIndexXYZ(mouseSceneX, mouseSceneY, mouseSceneZ);

  bool get aimTargetWithinInteractRadius => aimTarget != null
      ? getDistance(aimTarget!) < IsometricSettings.Interact_Radius
      : false;

  int get lookDirection => IsometricDirection.fromRadian(lookRadian);

  double get mouseSceneX => game.clampX((mouseX + mouseY) + z);

  double get mouseSceneY => game.clampY((mouseY - mouseX) + z);

  double get mouseSceneZ => game.clampZ(z);

  /// in radians
  double get mouseAngle => getAngleXY(
      mouseSceneX  + Character_Gun_Height,
      mouseSceneY + Character_Gun_Height,
  );

  IsometricScene get scene => game.scene;

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
    final weaponDurationPercentage = this.weaponDurationPercentage;
    if (weaponDurationPercentagePrevious != weaponDurationPercentage){
      weaponDurationPercentagePrevious = weaponDurationPercentage;
      writeByte(ServerResponse.Isometric);
      writeByte(IsometricResponse.Player_Weapon_Duration_Percentage);
      writePercentage(weaponDurationPercentage);
    }

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
      writeHighScore();
    }

    if (!sceneDownloaded){
      downloadScene();
    }

    writeIsometricPlayer();
    writePlayerTargetPosition();
    writePlayerAimTargetPosition();
    writePlayerAimTargetCategory();

    writeSelectedCollider();

    writeProjectiles();
    writeCharacters();
    writeEditorGameObjectSelected();

    writeGameTime();

  }

  void writeHighScore(){
    writeByte(ServerResponse.High_Score);
    writeUInt24(0);
  }

  void writePlayerStats(){
    writePlayerHealth();
    writePlayerAlive();
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
    cacheIndex = 0;
    writeByte(ServerResponse.Isometric_Characters);
    final characters = game.characters;
    for (final character in characters) {
      if (
        character.deadOrInactive ||
        character.renderY < screenTop ||
        character.renderX < screenLeft ||
        character.renderX > screenRight ||
        character.renderY > screenBottom
      ) continue;


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

      cacheIndex++;
    }
    writeByte(CHARACTER_END);
  }

  void downloadScene(){
    writeGameType();
    writePlayerTeam();
    writeGameProperties();
    writeScene();
    writeWeather();
    writeGameObjects();
    writeGameTime();
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

  void writePlayerAimTargetPosition() {
    if (aimTarget == null) return;
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Aim_Target_Position);
    writeIsometricPosition(aimTarget!);
  }

  void writePlayerAimTargetCategory() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Aim_Target_Category);
    writeByte(_aimTargetCategory);
  }

  void writePlayerAimTargetType() {
    if (aimTarget == null) return;
    if (aimTarget is IsometricGameObject){
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Aim_Target_Type);
      writeUInt16((aimTarget as IsometricGameObject).type);
    }
    if (aimTarget is IsometricCharacter) {
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Aim_Target_Type);
      writeUInt16((aimTarget as IsometricCharacter).characterType);
    }
  }

  void writePlayerAimTargetQuantity() {
    if (aimTarget is IsometricGameObject) {
      writeByte(ServerResponse.Api_Player);
      writeByte(ApiPlayer.Aim_Target_Quantity);
      writeUInt16((aimTarget as IsometricGameObject).quantity);
    }
  }

  int getTargetCategory(IsometricPosition? value){

    if (value == null)
      return TargetCategory.Run;

    if (value is IsometricGameObject) {
      if (value.interactable) {
        return TargetCategory.Talk;
      }
      if (value.collectable){
        return TargetCategory.Collect;
      }
      if (value.physical && value.hitable){
        return TargetCategory.Attack;
      }
      return TargetCategory.Run;
    }

    if (isEnemy(value))
      return TargetCategory.Attack;

    return TargetCategory.Run;
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
    writeUInt16(itemType);
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

  void writeProjectile(IsometricProjectile projectile){
    if (!projectile.active) return;
    writePosition(projectile);
    writeByte(projectile.type);
    writeAngle(projectile.velocityAngle);
  }

  void writeCharacterTemplate(IsometricCharacter character) {

    final compressedA = compressBytesToUInt32(
      character.weaponType,
      character.bodyType,
      character.headType,
      character.legsType,
    );

    final compressedB = character.compressedLookAndWeaponState;

    final writeA = cacheTemplateA[cacheIndex] != compressedA;
    final writeB = cacheTemplateB[cacheIndex] != compressedB;
    final writeC = !character.weaponStateIdle;

    writeByte(
      writeBitsToByte(writeA, writeB, writeC, false, false, false, false, false)
    );

    if (writeA){
      cacheTemplateA[cacheIndex] = compressedA;
      writeByte(character.weaponType);
      writeByte(character.bodyType);
      writeByte(character.headType);
      writeByte(character.legsType);
    }

    if (writeB){
      cacheTemplateB[cacheIndex] = compressedB;
      writeByte(compressedB);
    }

    if (writeC){
      writeByte(character.weaponStateDuration);
    }
  }

  void writeWeather() {
    final environment = game.environment;
    final underground = false;

    writeByte(ServerResponse.Weather);
    writeByte(environment.rainType);
    writeBool(environment.breezy);
    writeByte(environment.lightningType);
    writeByte(environment.windType);

    writeEnvironmentUnderground(underground);
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

  void writePosition(IsometricPosition value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeIsometricPosition(IsometricPosition value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeVector3(IsometricPosition value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeScene() {
    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.Scene);
    var compiled = scene.compiled;
    if (compiled == null){
      compiled = IsometricSceneWriter.compileScene(scene, gameObjects: false);
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

  void writeEnvironmentUnderground(bool underground){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Underground);
    writeBool(underground);
  }

  void writeEnvironmentLightningFlashing(bool value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Lightning_Flashing);
    writeBool(value);
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

  void writeGameObject(IsometricGameObject gameObject){
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

  void writePlayerEquipment(){
     writeByte(ServerResponse.Api_Player);
     writeByte(ApiPlayer.Equipment);
     writeUInt16(weaponType);
     writeUInt16(headType);
     writeUInt16(bodyType);
     writeUInt16(legsType);
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

  void writeGameEventGameObjectDestroyed(IsometricGameObject gameObject){
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

  void setDestinationToMouse() {
    runX = mouseSceneX;
    runY = mouseSceneY;
    runZ = mouseSceneZ;
    arrivedAtDestination = false;
  }

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

    if (selectedCollider is IsometricGameObject) {
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

    if (selectedCollider is IsometricCharacter) {
      final character = selectedCollider;
      writeByte(IsometricType.Character);
      writeString(character.runtimeType.toString());
      writeByte(character.action);
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
      writeUInt16(min(character.stateDuration, 1000));
      writeUInt16(character.stateDurationRemaining);
      writeUInt16(character.weaponType);
      writeUInt16(character.weaponDamage);
      writeUInt16(character.weaponRange.toInt());
      writeByte(character.weaponState);
      writeUInt16(min(character.weaponStateDuration, 1000));
      writeBool(character.autoTarget);
      writeBool(character.pathFindingEnabled);
      writeBool(character.runToDestinationEnabled);

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

  void writeCharacterPath(IsometricCharacter character){
    writeInt16(character.pathCurrent);
    writeInt16(character.pathStart);
    writeInt16(character.pathTargetIndex);
    for (var j = 0; j < character.pathStart; j++){
      writeUInt16(character.path[j]);
    }
  }

  void selectNearestColliderToMouse({double maxRadius = 75}) =>
      selectedCollider = getNearestColliderToMouse(maxRadius: maxRadius);

  IsometricCollider? getNearestColliderToMouse({
    required double maxRadius
  }) => game.getNearestCollider(
      x: mouseSceneX,
      y: mouseSceneY,
      z: z,
      maxRadius: maxRadius,
    );

  void debugCommand() {
    final selectedCollider = this.selectedCollider;
    if (selectedCollider is! IsometricCharacter)
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
      selectedCollider.runX = mouseSceneX;
      selectedCollider.runY = mouseSceneY;
      selectedCollider.runZ = mouseSceneZ;
      selectedCollider.arrivedAtDestination = false;
      return;
    }
  }

  void lookAtMouse(){
    if (deadOrBusy) return;
    lookRadian = mouseAngle;
  }

  void onChangedAimTarget(){
     aimTargetCategory = getTargetCategory(aimTarget);
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

  void writePlayerAimTargetName() {
    final aimTarget = this.aimTarget;
    if (aimTarget is! IsometricCharacter) return;
    writeApiPlayerAimTargetName(aimTarget.name);
  }

  void writeApiPlayerAimTargetName(String value) {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Aim_Target_Name);
    writeString(value);
  }

  void performPrimaryAction() {
    if (deadBusyOrWeaponStateBusy) return;

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

}
