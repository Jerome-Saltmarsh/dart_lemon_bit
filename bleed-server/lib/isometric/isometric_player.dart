
import 'dart:math';

import 'package:bleed_server/common.dart';
import 'package:bleed_server/games/capture_the_flag/capture_the_flag_ai.dart';
import 'package:bleed_server/utils.dart';

import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:bleed_server/core/player.dart';
import 'package:bleed_server/games/isometric_editor/isometric_editor.dart';

import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

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

  final mouse = Vector2(0, 0);

  IsometricGame game;
  IsometricCharacter? debugCharacter;
  IsometricGameObject? editorSelectedGameObject;
  IsometricCollider? _aimTarget; // the currently highlighted character
  Account? account;

  IsometricPlayer({
    required this.game,
  }) : super(
    x: 0,
    y: 0,
    z: 0,
    health: 10,
    team: 0,
    weaponType: 0,
    damage: 1,
  ){
    writeGameType();
    writePlayerTeam();
    id = game.playerId++;
  }

  int get mouseGridIndex => game.scene.getNodeIndexXYZ(mouseGridX, mouseGridY, mouseGridZ);

  bool get aimTargetWithinInteractRadius => aimTarget != null
      ? getDistance3(aimTarget!) < IsometricSettings.Interact_Radius
      : false;

  IsometricCollider? get aimTarget => _aimTarget;

  int get lookDirection => IsometricDirection.fromRadian(lookRadian);

  double get mouseGridX => game.clampX((mouse.x + mouse.y) + z);

  double get mouseGridY => game.clampY((mouse.y - mouse.x) + z);

  double get mouseGridZ => z;

  /// in radians
  double get mouseAngle => getAngleBetween(
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

  void writePlayerPosition(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Position);
    writeIsometricPosition(this);
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
    writePlayerPosition();
    writePlayerWeaponCooldown();
    writePlayerAccuracy();
    writePlayerAimTargetPosition();

    writeDebugCharacter();

    writeProjectiles();
    writePlayerTargetPosition();
    writeCharacters();
    writeEditorGameObjectSelected();

    writeGameTime();

    if (!initialized) {
      initialized = true;
      game.customInitPlayer(this);
      writePlayerPosition();
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

  void writePlayerWeaponCooldown() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Weapon_Cooldown);
    writePercentage(weaponDurationPercentage);
  }

  void writePlayerAccuracy(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Accuracy);
    writePercentage(accuracy);
  }

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
      writeVector3(character);
      writeCharacterHealthAndAnimationFrame(character);

      if (character is IsometricCharacterTemplate) {
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
    writeGrid();
    writeGameProperties();
    writeGameType();
    writeWeather();
    writeGameObjects();
    writeGameTime();
    game.customDownloadScene(this);
    writePlayerEvent(PlayerEvent.Scene_Changed);
    sceneDownloaded = true;
  }

  void writePlayerSpawned(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Spawned);
  }

  // void writeAndSendResponse(){
  //   writePlayerGame();
  //   game.customPlayerWrite(this);
  //   writeByte(ServerResponse.End);
  //   sendBufferToClient();
  // }

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

  void writePlayerAimTargetPosition(){
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
    writeByte(ServerResponse.Projectiles);
    final projectiles = game.projectiles;
    var totalActiveProjectiles = 0;
    for (final gameObject in projectiles) {
      if (!gameObject.active) continue;
      totalActiveProjectiles++;
    }
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
    writePlayerPosition();
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
    writeByte(ServerResponse.Game_Time);
    writeUInt24(game.time.time);
  }

  void writeProjectile(IsometricProjectile projectile){
    if (!projectile.active) return;
    writePosition(projectile);
    writeDouble(projectile.z);
    writeByte(projectile.type);
    writeAngle(projectile.velocityAngle);
  }

  void writeCharacterUpperBody(IsometricCharacterTemplate character) {
    assert (ItemType.isTypeWeapon(character.weaponType) || character.weaponType == ItemType.Empty);
    assert (ItemType.isTypeLegs(character.legsType) || character.legsType == ItemType.Empty);
    assert (ItemType.isTypeBody(character.bodyType) || character.bodyType == ItemType.Empty);
    assert (ItemType.isTypeHead(character.headType) || character.headType == ItemType.Empty);
    writeUInt16(character.weaponType);
    writeUInt16(character.weaponState); // TODO use byte instead
    writeUInt16(character.bodyType);
    writeUInt16(character.headType);
    writeUInt16(character.legsType);
    writeAngle(character.lookRadian);
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

  void writePosition(Position value){
    writeDouble(value.x);
    writeDouble(value.y);
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

  void writeGrid() {
    writeByte(ServerResponse.Grid);
    var compiled = scene.compiled;
    if (compiled == null){
      compiled = IsometricSceneWriter.compileScene(scene, gameObjects: false);
      scene.compiled = compiled;
    }
    writeBytes(compiled);
  }

  void writePlayerTarget() {
    writeByte(ServerResponse.Player_Target);
    writePosition(target != null ? target! : mouse);

    if (target != null){
      writeDouble(target!.z);
    } else{
      writeDouble(z);
    }
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
    assert (index < scene.gridVolume);
    writeByte(ServerResponse.Node);
    writeUInt24(index);
    writeByte(scene.nodeTypes[index]);
    writeByte(scene.nodeOrientations[index]);
  }

  void lookAt(Position position) {
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

  void setPathToMouse() =>
      game.setCharacterPathToNodeIndex(
        character: this,
        targetIndex: mouseGridIndex,
      );

  void setDestinationToMouse() {
    runX = mouseGridX;
    runY = mouseGridY;
    runZ = mouseGridZ;
  }

  void setTargetToAimTarget() => target = aimTarget;

  void writeDebugCharacter() {
    final selectedCharacter = this.debugCharacter;
    writeByte(ServerResponse.Isometric);
    writeByte(IsometricResponse.Debug_Character);

    if (selectedCharacter == null) {
      writeBool(false);
      return;
    }
    writeBool(true);
    writeString(selectedCharacter.runtimeType.toString());
    writeIsometricPosition(selectedCharacter);
    writeInt16(selectedCharacter.runX.toInt());
    writeInt16(selectedCharacter.runY.toInt());
    writeCharacterPath(selectedCharacter);

    writeUInt16(selectedCharacter.weaponType);
    writeByte(selectedCharacter.weaponState);
    writeUInt16(selectedCharacter.weaponStateDuration);

    if (selectedCharacter is CaptureTheFlagAI){
      writeBool(true);
      writeByte(selectedCharacter.decision.index);
      writeByte(selectedCharacter.role.index);
    } else {
      writeBool(false);
    }

    final selectedCharacterTarget = selectedCharacter.target;
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
    for (var j = 0; j < character.pathStart; j++){
      writeUInt16(character.path[j]);
    }
  }

  void selectDebugCharacterNearestToMouse() {
    debugCharacter = game.getNearestCharacter(mouseGridX, mouseGridY, z, maxRadius: 75);
  }
}


