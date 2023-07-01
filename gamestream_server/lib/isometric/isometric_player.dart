
import 'dart:math';

import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/utils.dart';

import 'package:gamestream_server/core/player.dart';
import 'package:gamestream_server/games/isometric_editor/isometric_editor.dart';

import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/src.dart';

import 'isometric_character_template.dart';
import 'isometric_collider.dart';
import 'isometric_game.dart';
import 'isometric_character.dart';
import 'isometric_gameobject.dart';
import 'isometric_position.dart';
import 'isometric_projectile.dart';
import 'isometric_scene.dart';
import 'isometric_scene_writer.dart';
import 'isometric_settings.dart';

class IsometricPlayer extends IsometricCharacterTemplate with ByteWriter implements Player {

  var _mouseLeftDown = false;

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
  var debugCharacterSelected = false;
  var gameTimeInMinutes = 0;

  final mouse = Vector2(0, 0);

  IsometricGame game;
  IsometricCharacter? debugCharacter;
  IsometricGameObject? editorSelectedGameObject;
  IsometricCollider? _aimTarget; // the currently highlighted character

  IsometricPlayer({
    required this.game,
    bool autoTargetNearbyEnemies = false,
  }) : super(
    x: 0,
    y: 0,
    z: 0,
    health: 10,
    team: 0,
    weaponType: 0,
    weaponRange: 20,
    damage: 1,
  ){
    this.autoTarget = autoTargetNearbyEnemies;
    writeGameType();
    writePlayerTeam();
    id = game.playerId++;
  }

  int get mouseIndex => game.scene.getIndexXYZ(mouseGridX, mouseGridY, mouseGridZ);

  bool get aimTargetWithinInteractRadius => aimTarget != null
      ? getDistance3(aimTarget!) < IsometricSettings.Interact_Radius
      : false;

  IsometricCollider? get aimTarget => _aimTarget;

  int get lookDirection => IsometricDirection.fromRadian(lookRadian);

  double get mouseGridX => game.clampX((mouse.x + mouse.y) + z);

  double get mouseGridY => game.clampY((mouse.y - mouse.x) + z);

  double get mouseGridZ => game.clampZ(z);

  /// in radians
  double get mouseAngle => angleBetween(
      mouseGridX  + Character_Gun_Height,
      mouseGridY + Character_Gun_Height, x, y,
  );

  IsometricScene get scene => game.scene;

  double get mouseDistance => this.getDistanceXY(mouseGridX, mouseGridY);

  set aimTarget(IsometricCollider? collider) {
    if (_aimTarget == collider) return;
    if (collider == this) return;
    _aimTarget = collider;
    writePlayerAimTargetCategory();
    writePlayerAimTargetType();
    writePlayerAimTargetPosition();
    writePlayerAimTargetName();
    writePlayerAimTargetQuantity();
    game.customOnPlayerAimTargetChanged(this, collider);
  }

  void refreshDamage() {
    weaponDamage = game.getPlayerWeaponDamage(this);
  }

  void writeErrorInvalidInventoryIndex(int index){
     writeGameError(GameError.Invalid_Inventory_Index);
  }

  void writeInfo(String info){
    writeByte(ServerResponse.Info);
    writeString(info);
  }

  void writeIsometricPlayer(){
    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.Player);
    writeIsometricPosition(this);
    writePercentage(weaponDurationPercentage);
    writePercentage(accuracy);
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
    writeIsometricPlayer();
    writePlayerAimTargetPosition();
    writePlayerTargetPosition();

    writeDebugCharacter();

    writeProjectiles();
    writeCharacters();
    writeEditorGameObjectSelected();

    writeGameTime();

    if (!initialized) {
      initialized = true;
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
  }

  void writeHighScore(){
    writeByte(ServerResponse.High_Score);
    writeUInt24(0);
  }

  void writePlayerStats(){
    refreshDamage();
    writePlayerHealth();
    writePlayerAlive();
  }

  // void writePlayerWeaponCooldown() {
  //   writeByte(ServerResponse.Api_Player);
  //   writeByte(ApiPlayer.Weapon_Cooldown);
  //   writePercentage(weaponDurationPercentage);
  // }

  void writeGameObjects(){
    final gameObjects = game.gameObjects;
    for (final gameObject in gameObjects) {
      writeGameObject(gameObject);
    }
  }

  void writeCharacters(){
    writeByte(ServerResponse.Characters);
    final characters = game.characters;
    for (final character in characters) {
      if (character.dead) continue;
      if (character.inactive) continue;
      if (character.renderY < screenTop) continue;
      if (character.renderX < screenLeft) continue;
      if (character.renderX > screenRight) continue;
      if (character.renderY > screenBottom) continue;

      writeByte(character.characterType);
      writeCharacterTeamDirectionAndState(character);
      writeIsometricPosition(character);
      writeCharacterHealthAndAnimationFrame(character);

      if (character is IsometricCharacterTemplate && character.characterTypeTemplate) {
        writeCharacterUpperBody(character);
      }
    }
    writeByte(CharactersEnd);
  }

  void writeCharacterTeamDirectionAndState(IsometricCharacter character){
    writeByte((IsometricCollider.onSameTeam(this, character) ? 100 : 0) + (character.faceDirection * 10) + character.state); // 1
  }

  // todo optimize
  void writeCharacterHealthAndAnimationFrame(IsometricCharacter character) =>
    writeByte((((character.health / character.maxHealth) * 24).toInt() * 10) + character.animationFrame);

  void downloadScene(){
    writeScene();
    writeGameProperties();
    writeGameType();
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

  void writePlayerTargetCategory(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Target_Category);
    writeByte(getTargetCategory(target));
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
    writeByte(getTargetCategory(aimTarget));
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


  int getTargetCategory(IsometricPosition? value){
    if (value == null) return TargetCategory.Nothing;
    if (value is IsometricGameObject) {
      if (value.interactable) {
        return TargetCategory.Collect;
      }
      return TargetCategory.Nothing;
    }
    if (isAlly(value)) return TargetCategory.Talk;
    if (isEnemy(value)) return TargetCategory.Attack;
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
    for (final gameObject in projectiles) {
      if (!gameObject.active) continue;
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

  void writeCharacterUpperBody(IsometricCharacterTemplate character) {
    // assert (ItemType.isTypeWeapon(character.weaponType) || character.weaponType == ItemType.Empty);
    // assert (ItemType.isTypeLegs(character.legsType) || character.legsType == ItemType.Empty);
    // assert (ItemType.isTypeBody(character.bodyType) || character.bodyType == ItemType.Empty);
    // assert (ItemType.isTypeHead(character.headType) || character.headType == ItemType.Empty);
    writeUInt16(character.weaponType);
    writeByte(character.weaponState);
    writeUInt16(character.bodyType);
    writeUInt16(character.headType);
    writeUInt16(character.legsType);
    writeByte(character.lookDirection);
    writeByte(character.weaponFrame);
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

  void lookAt(IsometricPosition position) {
    assert(!dead);
    lookRadian = this.getAngle(position) + pi;
  }

  void writeDouble(double value){
    writeInt16(value.toInt());
  }

  void writeGameObject(IsometricGameObject gameObject){
    writeUInt8(ServerResponse.GameObject);
    writeUInt16(gameObject.id);
    writeBool(gameObject.active);
    writeUInt16(gameObject.type);
    writeVector3(gameObject);
  }

  void writeMap(Map<int, int> map){
    final entries = map.entries;
    writeUInt16(entries.length);
    for (final entry in entries) {
      writeUInt16(entry.key);
      writeUInt16(entry.value);
    }
  }

  @override
  void onEquipmentChanged() {
    refreshDamage();
    writePlayerEquipment();
  }

  @override
  void onWeaponTypeChanged() {
    refreshDamage();
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

  @override
  bool get isPlayer => true;

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

  @override
  void onTeamChanged() => writePlayerTeam();


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

  void setPathToMouse() => pathTargetIndex = mouseIndex;

  void setDestinationToMouse() {
    runX = mouseGridX;
    runY = mouseGridY;
    runZ = mouseGridZ;
  }

  void setTargetToAimTarget() => target = aimTarget;

  void writeDebugCharacter() {
    final debugCharacter = this.debugCharacter;

    if (debugCharacter == null) {
      if (!debugCharacterSelected) return;
      debugCharacterSelected = false;
      writeByte(ServerResponse.Isometric);
      writeByte(IsometricResponse.Debug_Character);
      writeBool(debugCharacterSelected);
      return;
    }
    debugCharacterSelected = true;

    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.Debug_Character);
    writeBool(debugCharacterSelected);
    writeString(debugCharacter.runtimeType.toString());
    writeIsometricPosition(debugCharacter);
    writeInt16(debugCharacter.runX.toInt());
    writeInt16(debugCharacter.runY.toInt());
    writeCharacterPath(debugCharacter);

    writeByte(debugCharacter.characterType);
    writeByte(debugCharacter.state);
    writeUInt16(debugCharacter.stateDuration);
    writeUInt16(debugCharacter.stateDurationRemaining);
    writeUInt16(debugCharacter.weaponType);
    writeUInt16(debugCharacter.weaponDamage);
    writeUInt16(debugCharacter.weaponRange.toInt());
    writeByte(debugCharacter.weaponState);
    writeUInt16(debugCharacter.weaponStateDuration);
    writeBool(debugCharacter.autoTarget);
    writeBool(debugCharacter.pathFindingEnabled);
    writeBool(debugCharacter.runToDestinationEnabled);

    final selectedCharacterTarget = debugCharacter.target;
    if (selectedCharacterTarget == null){
      writeBool(false);
    } else {
      writeBool(true);
      writeString(selectedCharacterTarget.runtimeType.toString());
      writeIsometricPosition(selectedCharacterTarget);
    }
  }

  void writeCharacterPath(IsometricCharacter character){
    writeInt16(character.pathIndex);
    writeInt16(character.pathStart);
    writeInt16(character.pathTargetIndex);
    for (var j = 0; j < character.pathStart; j++){
      writeUInt16(character.path[j]);
    }
  }

  void selectDebugCharacterNearestToMouse() {
    debugCharacter = game.getNearestCharacter(mouseGridX, mouseGridY, z, maxRadius: 75);
  }
}


