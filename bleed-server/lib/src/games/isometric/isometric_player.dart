
import 'dart:math';

import 'package:bleed_server/common/src/api_player.dart';
import 'package:bleed_server/common/src/compile_util.dart';
import 'package:bleed_server/common/src/direction.dart';
import 'package:bleed_server/common/src/enums/input_mode.dart';
import 'package:bleed_server/common/src/enums/item_group.dart';
import 'package:bleed_server/common/src/enums/perk_type.dart';
import 'package:bleed_server/common/src/environment_response.dart';
import 'package:bleed_server/common/src/game_error.dart';
import 'package:bleed_server/common/src/game_event_type.dart';
import 'package:bleed_server/common/src/interact_mode.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/common/src/node_size.dart';
import 'package:bleed_server/common/src/player_event.dart';
import 'package:bleed_server/common/src/server_response.dart';
import 'package:bleed_server/common/src/target_category.dart';
import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:bleed_server/src/game/player.dart';
import 'package:bleed_server/src/games/game_editor.dart';
import 'package:bleed_server/src/games/isometric/isometric_character_template.dart';
import 'package:bleed_server/src/utilities/generate_random_name.dart';
import 'package:bleed_server/src/utilities/system.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

import 'isometric_ai.dart';
import 'isometric_collider.dart';
import 'isometric_game.dart';
import 'isometric_character.dart';
import 'isometric_gameobject.dart';
import 'isometric_position.dart';
import 'isometric_projectile.dart';
import 'isometric_scene.dart';
import 'isometric_scene_writer.dart';
import 'isometric_settings.dart';
import 'isometric_side.dart';

class IsometricPlayer extends IsometricCharacterTemplate with ByteWriter implements Player {
  /// CONSTANTS
  final mouse = Vector2(0, 0);
  var inputMode = InputMode.Keyboard;
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var framesSinceClientRequest = 0;

  /// Variables
  late IsometricGame game;
  final runTarget = IsometricPosition();
  IsometricGameObject? editorSelectedGameObject;
  /// Frames per energy rejuvenation
  var energyGainRate = 16;
  var debug = false;
  var textDuration = 0;
  var maxEnergy = 10;
  var text = "";
  var name = generateRandomName();
  var sceneDownloaded = false;
  var initialized = false;
  var id = 0;

  var _level = 1;
  var _attributes = 0;
  var _energy = 10;
  var _respawnTimer = 0;

  int get respawnTimer => _respawnTimer;

  int get attributes => _attributes;

  set attributes(int value) {
    _attributes = max(value, 0);
    writeApiPlayerAttributes();
  }

  set respawnTimer(int value){
     if (_respawnTimer == value) return;
     _respawnTimer = value;
     writeApiPlayerRespawnTimer();
  }

  var _perkType = PerkType.None;

  int get perkType => _perkType;

  set perkType(int value) {
     assert (PerkType.values.contains(value));
     if (!PerkType.values.contains(value)) return;
     if (_perkType == value) return;
     _perkType = value;
     game.customOnPlayerPerkTypeChanged(this);
     writeApiPlayerPerkType();
  }

  /// Warning - do not reference
  // GameIsometric game;
  IsometricCollider? _aimTarget; // the currently highlighted character
  var aimTargetWeaponSide = IsometricSide.Left;
  Account? account;
  var storeItems = <int>[];
  var options = <String, Function> {};
  var _interactMode = InteractMode.Inventory;
  var inventoryOpen = true;
  var nextEnergyGain = 0;

  /// the key is the item_type and the value is its level
  final item_level = <int, int> {};
  final item_quantity = <int, int> {};

  var actionItemId = -1;

  ItemGroup get weaponTypeItemGroup => ItemType.getItemGroup(weaponType);

  bool get aimTargetWithinInteractRadius => aimTarget != null
      ? getDistance3(aimTarget!) < IsometricSettings.Interact_Radius
      : false;

  /// CONSTRUCTOR
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
    maxEnergy = energy;
    _energy = maxEnergy;
  }

  /// GETTERS
  ///
  IsometricCollider? get aimTarget => _aimTarget;
  int get level => _level;
  int get lookDirection => Direction.fromRadian(lookRadian);
  int get energy => _energy;
  int get experienceRequiredForNextLevel => game.getExperienceForLevel(level + 1);

  double get mouseGridX => (mouse.x + mouse.y) + z;
  double get mouseGridY => (mouse.y - mouse.x) + z;
  int get interactMode => _interactMode;
  /// in radians
  double get mouseAngle => getAngleBetween(mouseGridX  + Character_Gun_Height, mouseGridY + Character_Gun_Height, x, y);
  IsometricScene get scene => game.scene;
  double get magicPercentage {
    if (_energy == 0) return 0;
    if (maxEnergy == 0) return 0;
    return _energy / maxEnergy;
  }

  set level(int value){
    assert (value >= 1);
    if (_level == value) return;
    _level = value;
    writePlayerLevel();
  }

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

  set energy(int value) {
    final clampedValue = clamp(value, 0, maxEnergy);
    if (_energy == clampedValue) return;
    _energy = clampedValue;
    writePlayerEnergy();
  }

  /// METHODS
  void refreshDamage() {
    weaponDamage = game.getPlayerWeaponDamage(this);
  }

  set interactMode(int value){
    if (_interactMode == value) return;
    _interactMode = value;
    writePlayerInteractMode();
  }

  void endInteraction(){
    if (interactMode == InteractMode.None) return;
    if (storeItems.isNotEmpty) {
      storeItems = [];
      writeStoreItems();
    }
    if (options.isNotEmpty) {
      options.clear();
    }
    if (inventoryOpen) {
      interactMode = InteractMode.Inventory;
    } else {
      interactMode = InteractMode.None;
    }
  }

  void interact({required String message, Map<String, Function>? responses}){
    writeNpcTalk(text: message, options: responses);
  }

  void setStoreItems(List<int> values){
    if (values.isNotEmpty){
      interactMode = InteractMode.Trading;
    }
    this.storeItems = values;
    writeStoreItems();
  }

  void runToMouse(){
    setRunTarget(mouseGridX - 16, mouseGridY - 16);
  }

  void setRunTarget(double x, double y){
    runTarget.x = x;
    runTarget.y = y;
    runTarget.z = z;
    game.setCharacterTarget(this, runTarget);
  }

  void dropItemType({required int itemType, required int quantity}){
    if (itemType == ItemType.Empty) return;
    game.spawnGameObjectItemAtPosition(
      position: this,
      type: itemType,
      quantity: quantity,
    );
    writePlayerEvent(PlayerEvent.Item_Dropped);
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

  void writePlayerLevel(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Level);
    writeUInt16(level);
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
      writePlayerLevel();
      writePlayerHealth();
      writePlayerAlive();
      writePlayerInteractMode();
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
    writePlayerLevel();
    writePlayerHealth();
    writePlayerEnergy();
    writePlayerAlive();
    writePlayerInteractMode();
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

      if (character.buffInvisible && !IsometricCollider.onSameTeam(this, character)){
        continue;
      }

      writeByte(character.characterType);
      writeCharacterTeamDirectionAndState(character);
      writeVector3(character);
      writeCharacterHealthAndAnimationFrame(character);

      if (character is IsometricCharacterTemplate) {
        writeCharacterUpperBody(character);
      }

      writeByte(character.buffByte);
    }
    writeByte(END);
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
    if (aimTarget == null) return;

    if (aimTarget is IsometricPlayer) {
      writeApiPlayerAimTargetName((aimTarget as IsometricPlayer).name);
      return;
    }

    if (aimTarget is IsometricAI) {
      writeApiPlayerAimTargetName((aimTarget as IsometricAI).name);
      return;
    }
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
    if (isAlly(value)) return TargetCategory.Allie;
    if (isEnemy(value)) return TargetCategory.Enemy;
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

  void writePlayerItems() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Items);
    writeMap(item_level);
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

  void writeStoreItems(){
    writeByte(ServerResponse.Store_Items);
    writeUInt16(storeItems.length);
    storeItems.forEach(writeUInt16);
  }

  void writePlayerInteractMode() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Interact_Mode);
    writeByte(interactMode);
  }

  void writeNpcTalk({required String text, Map<String, Function>? options}){
    interactMode = InteractMode.Talking;
    this.options = options ?? {'Goodbye' : endInteraction};
    writeByte(ServerResponse.Npc_Talk);
    writeString(text);
    writeByte(this.options.length);
    for (final option in this.options.keys){
      writeString(option);
    }
  }

  void writeGameProperties() {
    writeByte(ServerResponse.Game_Properties);
    writeBool((game is GameEditor || isLocalMachine));
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

  void writeGameStatus(int gameStatus){
    writeByte(ServerResponse.Game_Status);
    writeByte(gameStatus);
  }

  void writeDouble(double value){
    writeInt16(value.toInt());
  }

  void writePlayerEnergy() {
    writeUInt8(ServerResponse.Api_Player);
    writeUInt8(ApiPlayer.Energy);
    if (maxEnergy == 0) return writeByte(0);
    writePercentage(energy / maxEnergy);
    // if (maxEnergy <= 0) {
    //   writeByte(0);
    // }
    // writePercentage(value)
    // writeUInt16(energy);
    // writeUInt16(maxEnergy);
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

  int getItemIndex(int itemType) {
    final itemEntries = item_level.entries;
    var index = 0;
    for (var item in itemEntries){
      if (item.key == itemType) return index;
      index++;
    }
    return -1;
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

  int getItemLevel(int itemType) => item_level[itemType] ?? 0;

  int getItemQuantity(int itemType) => item_quantity[itemType] ?? 0;

  writePlayerApiId(){
    writeUInt8(ServerResponse.Api_Player);
    writeUInt8(ApiPlayer.Id);
    writeUInt24(id);
  }

  @override
  bool get isPlayer => true;

  void writeApiPlayerAttributes(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Attributes);
    writeUInt16(_attributes);
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

  void writeApiPlayerPerkType(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.PerkType);
    writeByte(perkType);
  }

  void writeApiPlayerRespawnTimer(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Respawn_Timer);
    writeUInt16(_respawnTimer);
  }

  @override
  void onTeamChanged() => writePlayerTeam();


  void writePlayerTeam(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Team);
    writeByte(team);
  }
}


