
import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:bleed_server/system.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

import '../common/flag.dart';
import '../common/library.dart';
import '../dark_age/areas/dark_age_area.dart';
import '../dark_age/game_dark_age.dart';
import '../dark_age/game_dark_age_editor.dart';
import '../utilities.dart';
import 'gameobject.dart';
import 'library.dart';
import 'rat.dart';
import 'zombie.dart';

class Player extends Character with ByteWriter {
  final mouse = Vector2(0, 0);
  final runTarget = Position3();
  late Function sendBufferToClient;
  GameObject? editorSelectedGameObject;
  var debug = false;
  var characterState = CharacterState.Idle;
  var framesSinceClientRequest = 0;
  var textDuration = 0;
  var _experience = 0;
  var level = 1;
  var _points = 0;
  var _magic = 0;
  var maxMagic = 100;
  var message = "";
  var text = "";
  var name = 'anon';
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var sceneDownloaded = false;
  var initialized = false;
  var lookRadian = 0.0;
  /// Warning - do not reference
  Game game;
  Collider? _aimTarget; // the currently highlighted character
  Account? account;

  Collider? get aimTarget => _aimTarget;

  set aimTarget(Collider? collider) {
    if (_aimTarget == collider) return;
    if (collider == this) return;
    _aimTarget = collider;
    writePlayerAimTargetCategory();
    writePlayerAimTargetType();
    writePlayerAimTargetPosition();
    writePlayerAimTargetName();
  }

  static const InventorySize = 40;
  final inventory = Uint16List(InventorySize);
  var storeItems = <int>[];

  final questsInProgress = <Quest>[];
  final questsCompleted = <Quest>[];
  final flags = <Flag>[];

  var options = <String, Function> {};
  var _interactMode = InteractMode.None;
  var npcName = "";

  var mapX = 0;
  var mapY = 0;

  int get interactMode => _interactMode;

  set interactMode(int value){
    if (_interactMode == value) return;
    _interactMode = value;
    writeInteractMode();
  }

  double get mouseGridX => (mouse.x + mouse.y) + z;
  double get mouseGridY => (mouse.y - mouse.x) + z;

  int get lookDirection => Direction.fromRadian(lookRadian);

  int get experience => _experience;

  int get points => _points;

  int? getEmptyInventoryIndex(){
    for (var i = 0; i < inventory.length; i++){
      if (inventory[i] != ItemType.Empty) continue;
      return i;
    }
    return null;
  }

  set points(int value){
    if (_points == value) return;
    _points = value >= 0 ? value : 0;
    writePoints();
  }

  set experience(int value){
    if (value < 0) {
      _experience = 0;
      return;
    }
    _experience = value;
    while (value >= experienceRequiredForNextLevel) {
      value -= experienceRequiredForNextLevel;
      level++;
      points++;
      game.customOnPlayerLevelGained(this);
    }
  }

  bool questToDo(Quest quest) => !questCompleted(quest) && !questInProgress(quest);
  bool questInProgress(Quest quest) => questsInProgress.contains(quest);
  bool questCompleted(Quest quest) => questsCompleted.contains(quest);
  bool flag(Flag flag) {
    if (flagged(flag)) return false;
    flags.add(flag);
    return true;
  }
  bool flagged(Flag flag) => flags.contains(flag);


  void beginQuest(Quest quest){
    assert (!questsInProgress.contains(quest));
    assert (!questsCompleted.contains(quest));
    questsInProgress.add(quest);
    writePlayerQuests();
    writePlayerEvent(PlayerEvent.Quest_Started);
  }

  void setInteractingNpcName(String value){
     this.npcName = value;
     writeByte(ServerResponse.Interacting_Npc_Name);
     writeString(value);
  }

  void completeQuest(Quest quest){
    assert (questsInProgress.contains(quest));
    assert (!questsCompleted.contains(quest));
    questsInProgress.remove(quest);
    questsCompleted.add(quest);
    writePlayerQuests();
    writePlayerEvent(PlayerEvent.Quest_Completed);
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
    interactMode = InteractMode.None;
    npcName = "";
  }

  void interact({required String message, Map<String, Function>? responses}){
    writeNpcTalk(text: message, options: responses);
  }

  bool isValidInventoryIndex(int? index) =>
      index != null &&
      index >= 0 &&
      (
          ItemType.isTypeEquipped(index) ||
          index < inventory.length
      );


  void setStoreItems(List<int> values){
    if (values.isNotEmpty){
      interactMode = InteractMode.Trading;
    }
    this.storeItems = values;
    writeStoreItems();
  }

  void runToMouse(){
    setRunTarget(mouseGridX, mouseGridY);
  }

  void setRunTarget(double x, double y){
    runTarget.x = x;
    runTarget.y = y;
    runTarget.z = z;
    game.setCharacterTarget(this, runTarget);
  }

  /// in radians
  double get mouseAngle => getAngleBetween(mouseGridX, mouseGridY, x, y);

  Scene get scene => game.scene;

  int get magic => _magic;

  double get magicPercentage {
    if (_magic == 0) return 0;
    if (maxMagic == 0) return 0;
    return _magic / maxMagic;
  }

  int get experienceRequiredForNextLevel => getExperienceForLevel(level + 1);

  double get experiencePercentage {
    return _experience / experienceRequiredForNextLevel;
  }

  set magic(int value){
    _magic = clampInt(value, 0, maxMagic);
  }

  Player({
    required this.game,
    required int weaponType,
    int team = 0,
    int magic = 10,
    int health = 10,
  }) : super(
            x: 0,
            y: 0,
            z: 0,
            health: health,
            speed: 4.25,
            team: team,
            weaponType: weaponType,
            bodyType: ItemType.Body_Tunic_Padded,
            headType: ItemType.Head_Rogues_Hood,
  ){
    maxMagic = magic;
    _magic = maxMagic;
    game.players.add(this);
    game.characters.add(this);
  }

  void inventoryDrop(int index) {
    assert (isValidInventoryIndex(index));
    final itemType = inventoryGetItemTypeAtIndex(index);
    if (itemType == ItemType.Empty) return;
    game.spawnGameObjectItemAtPosition(
      position: this,
      type: itemType,
    );
    inventorySetItemTypeAtIndex(index, ItemType.Empty);
    writePlayerEvent(PlayerEvent.Item_Dropped);
  }

  int inventoryGetItemTypeAtIndex(int index){
    assert (index >= 0);
    if (index == ItemType.Equipped_Weapon)
      return weaponType;
    if (index == ItemType.Equipped_Body)
      return bodyType;
    if (index == ItemType.Equipped_Head)
      return headType;
    if (index == ItemType.Equipped_Legs)
      return legsType;

    assert(index < inventory.length);
    return inventory[index];
  }

  void inventorySetItemTypeAtIndex(int index, int itemType){
    assert (index >= 0);
    if (index == ItemType.Equipped_Weapon) {
      if (weaponType == itemType) return;
      weaponType = itemType;
      writePlayerInventory();
      game.setCharacterStateChanging(this);
      return;
    }
    if (index == ItemType.Equipped_Body) {
      if (bodyType == itemType) return;
      bodyType = itemType;
      writePlayerInventory();
      game.setCharacterStateChanging(this);
      return;
    }
    if (index == ItemType.Equipped_Head) {
      if (headType == itemType) return;
      headType = itemType;
      writePlayerInventory();
      game.setCharacterStateChanging(this);
      return;
    }
    if (index == ItemType.Equipped_Legs) {
      if (legsType == itemType) return;
      legsType = itemType;
      writePlayerInventory();
      game.setCharacterStateChanging(this);
      return;
    }
    assert(index < inventory.length);
    if (inventory[index] == itemType) return;
    inventory[index] = itemType;
    writePlayerInventory();
  }

  void inventoryMove(int indexFrom, int indexTo){

    if (indexFrom == ItemType.Equipped_Weapon) {
      if (indexTo >= inventory.length) return;

      if (inventory[indexTo] == ItemType.Empty) {
        inventory[indexTo] = weaponType;
        weaponType = ItemType.Empty;
        writePlayerInventory();
        writePlayerWeaponType();
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      if (ItemType.isTypeWeapon(inventory[indexTo])) {
        final typeTo = inventory[indexTo];
        inventory[indexTo] = weaponType;
        weaponType = typeTo;
        writePlayerInventory();
        writePlayerWeaponType();
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      final availableIndex = getEmptyInventoryIndex();
      if (availableIndex != null){
        inventory[availableIndex] = weaponType;
        weaponType = ItemType.Empty;
        writePlayerInventory();
        writePlayerWeaponType();
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      return;
    }

    if (indexFrom == ItemType.Equipped_Head) {
      if (indexTo >= inventory.length) return;

      if (inventory[indexTo] == ItemType.Empty) {
        inventory[indexTo] = headType;
        headType = ItemType.Empty;
        writePlayerInventory();
        // writePlayerT(); TODO writePlayerHead()
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      if (ItemType.isTypeHead(inventory[indexTo])) {
        final typeTo = inventory[indexTo];
        inventory[indexTo] = headType;
        headType = typeTo;
        writePlayerInventory();
        // writePlayerWeaponType();
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      final availableIndex = getEmptyInventoryIndex();
      if (availableIndex != null){
        inventory[availableIndex] = headType;
        headType = ItemType.Empty;
        writePlayerInventory();
        // writePlayerWeaponType();
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      return;
    }

    if (indexFrom == ItemType.Equipped_Body) {
      if (indexTo >= inventory.length) return;

      if (inventory[indexTo] == ItemType.Empty) {
        inventory[indexTo] = bodyType;
        bodyType = ItemType.Empty;
        writePlayerInventory();
        // writePlayerT(); TODO writePlayerHead()
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      if (ItemType.isTypeBody(inventory[indexTo])) {
        final typeTo = inventory[indexTo];
        inventory[indexTo] = bodyType;
        bodyType = typeTo;
        writePlayerInventory();
        // writePlayerWeaponType();
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      final availableIndex = getEmptyInventoryIndex();
      if (availableIndex != null){
        inventory[availableIndex] = bodyType;
        bodyType = ItemType.Empty;
        writePlayerInventory();
        // writePlayerWeaponType();
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      return;
    }

    if (indexFrom == ItemType.Equipped_Legs) {
      if (indexTo >= inventory.length) return;

      if (inventory[indexTo] == ItemType.Empty) {
        inventory[indexTo] = legsType;
        legsType = ItemType.Empty;
        writePlayerInventory();
        // writePlayerT(); TODO writePlayerHead()
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      if (ItemType.isTypeLegs(inventory[indexTo])) {
        final typeTo = inventory[indexTo];
        inventory[indexTo] = legsType;
        legsType = typeTo;
        writePlayerInventory();
        // writePlayerWeaponType();
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      final availableIndex = getEmptyInventoryIndex();
      if (availableIndex != null){
        inventory[availableIndex] = legsType;
        legsType = ItemType.Empty;
        writePlayerInventory();
        // writePlayerWeaponType();
        writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
        return;
      }
      return;
    }

    if (indexFrom >= inventory.length) return;
    if (indexTo >= inventory.length) return;
    final typeFrom = inventory[indexFrom];
    final typeTo = inventory[indexTo];
    if (typeFrom == ItemType.Empty && typeTo == ItemType.Empty) return;
    inventory[indexFrom] = typeTo;
    inventory[indexTo] = typeFrom;
    writePlayerInventory();
    writePlayerEvent(PlayerEvent.Inventory_Item_Moved);
  }
  
  void inventoryUnequipWeapon(){
    if (weaponType == ItemType.Empty) return;
    for (var i = 0; i < inventory.length; i++){
      if (inventory[i] != ItemType.Empty) continue;
      inventory[i] = weaponType;
      weaponType = ItemType.Empty;
      writePlayerWeaponType();
      writePlayerInventory();
      game.setCharacterStateChanging(this);
      break;
    }
  }
  
  void inventoryUnequipHead(){
    if (headType == ItemType.Empty) return;
    final emptyIndex = getEmptyInventoryIndex();
    if (emptyIndex == null) return;
    inventory[emptyIndex] = headType;
    headType = ItemType.Empty;
    game.setCharacterStateChanging(this);
    writePlayerInventory();
  }
  
  void inventoryUnequipBody(){
    if (bodyType == ItemType.Empty) return;
    final emptyIndex = getEmptyInventoryIndex();
    if (emptyIndex == null) return;
    inventory[emptyIndex] = bodyType;
    bodyType = ItemType.Empty;
    game.setCharacterStateChanging(this);
    writePlayerInventory();
  }

  void inventoryUnequipLegs(){
    if (legsType == ItemType.Empty) return;
    final emptyIndex = getEmptyInventoryIndex();
    if (emptyIndex == null) return;
    inventory[emptyIndex] = legsType;
    legsType = ItemType.Empty;
    game.setCharacterStateChanging(this);
    writePlayerInventory();
  }
  
  void inventoryEquip(int index){
    final itemType = inventory[index];
    var swapped = false;

    if (ItemType.isTypeWeapon(itemType)){
      final currentWeapon = weaponType;
      weaponType = itemType;
      inventory[index] = currentWeapon;
      swapped = true;
      writePlayerWeaponType();
    }

    if (ItemType.isTypeBody(itemType)){
      final current = bodyType;
      bodyType = itemType;
      inventory[index] = current;
      swapped = true;
    }

    if (ItemType.isTypeHead(itemType)){
      final current = headType;
      headType = itemType;
      inventory[index] = current;
      swapped = true;
    }

    if (ItemType.isTypeLegs(itemType)){
      final current = legsType;
      legsType = itemType;
      inventory[index] = current;
      swapped = true;
    }

    if (swapped) {
      game.setCharacterStateChanging(this);
      writePlayerInventory();
    }
  }

  void toggleDebug(){
    debug = !debug;
    writeByte(ServerResponse.Debug_Mode);
    writeBool(debug);
  }

  @override
  void write(Player player) {
    player.writePlayer(this);
  }

  @override
  int get type => CharacterType.Template;

  void writePlayerDebug(){
    writeByte(state);
    writeInt(faceAngle * 100);
    writeInt(mouseAngle * 100);
  }

  void writePlayerPosition(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Position);
    writePosition3(this);
  }

  void writePlayerHealth(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Health);
    writeInt(health);
  }

  void writePlayerMaxHealth(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Max_Health);
    writeInt(maxHealth); // 2
  }

  // void writePlayerBodyType(){
  //   writeByte(ServerResponse.Player);
  //   writeByte(ApiPlayer.Body_Type);
  //   writeUInt16(bodyType);
  // }
  //
  // void writePlayerHeadType(){
  //   writeByte(ServerResponse.Player);
  //   writeByte(ApiPlayer.Head_Type);
  //   writeUInt16(headType);
  // }
  //
  // void writePlayerLegsType(){
  //   writeByte(ServerResponse.Player);
  //   writeByte(ApiPlayer.Legs_Type);
  //   writeUInt16(legsType);
  // }

  void writePlayerAlive(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Alive);
    writeBool(alive);
  }

  void writePlayerExperiencePercentage(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Experience_Percentage);
    writePercentage(experiencePercentage);
  }

  void writePlayerLevel(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Level);
    writeInt(level);
  }

  void writePlayerAimAngle(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Aim_Angle);
    writeAngle(mouseAngle);
  }

  void writePlayerGame() {
    writePlayerPosition();
    writePlayerWeaponCooldown();
    writePlayerHealth();
    writePlayerMaxHealth();
    // writePlayerBodyType();
    // writePlayerHeadType();
    // writePlayerLegsType();
    writePlayerExperiencePercentage();
    writePlayerLevel();
    writePlayerAimAngle();
    writePlayerAimTargetPosition();

    writeProjectiles();
    writePlayerTargetPosition();
    writeCharacters();
    writeGameObjects();
    writeEditorGameObjectSelected();

    if (!initialized) {
      game.customInitPlayer(this);
      initialized = true;
      // runningToTarget = false;
      writePlayerWeaponType();
      writePlayerWeaponCapacity();
      writePlayerWeaponRounds();
      writePlayerPosition();
      writePlayerSpawned();
      writePlayerInventory();
    }

    if (!sceneDownloaded){
      downloadScene();
    }
  }

  void writePlayerWeaponType(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Weapon_Type);
    writeUInt16(weaponType);
  }

  void writePlayerWeaponRounds(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Weapon_Rounds);
    writeInt(0);
  }

  void writePlayerWeaponCapacity(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Weapon_Capacity);
    writeInt(0);
  }

  void writePlayerWeaponCooldown() {
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Weapon_Cooldown);
    writePercentage(weaponDurationPercentage);
  }

  void writeGameObjects(){
    final gameObjects = game.gameObjects;
    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (gameObject.renderY < screenTop) continue;
      if (gameObject.renderX < screenLeft) continue;
      if (gameObject.renderX > screenRight) continue;
      if (gameObject.renderY > screenBottom) continue;
      writeByte(ServerResponse.GameObject);
      writeByte(gameObject.type);
      if (gameObject.type == GameObjectType.Item){
        writeUInt16(gameObject.subType);
      }
      writePosition3(gameObject);
    }
  }

  void writeCharacters(){
    final characters = game.characters;
    for (final character in characters) {
      if (character.dead) continue;
      if (character.renderY < screenTop) continue;
      if (character.renderX < screenLeft) continue;
      if (character.renderX > screenRight) continue;
      if (character.renderY > screenBottom) return;
      character.write(this);
    }
  }

  void downloadScene(){
    writeGrid();
    writeSceneMetaData();
    writeMapCoordinate();
    writeRenderMap(game.customPropMapVisible);
    writeGameType(game.gameType);
    game.customDownloadScene(this);
    writePlayerEvent(PlayerEvent.Scene_Changed);
    sceneDownloaded = true;
  }

  void writeRenderMap(bool value){
    writeByte(ServerResponse.Render_Map);
    writeBool(value);
  }

  void writeGameType(int value){
    writeByte(ServerResponse.Game_Type);
    writeByte(value);
  }

  void writePlayerSpawned(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Spawned);
  }

  void writeAndSendResponse(){
    writePlayerGame();
    game.customPlayerWrite(this);
    writeByte(ServerResponse.End);
    sendBufferToClient();
  }

  void writePlayerTargetPosition(){
    if (target == null) return;
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Target_Position);
    writePosition3(target!);
  }

  void writePlayerTargetCategory(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Target_Category);
    writeByte(getCategory(target));
  }

  void writePlayerAimTargetPosition(){
    if (aimTarget == null) return;
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Aim_Target_Position);
    writePosition3(aimTarget!);
  }

  void writePlayerAimTargetCategory() {
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Aim_Target_Category);
    writeByte(getCategory(aimTarget));
  }

  void writePlayerAimTargetType() {
    if (aimTarget == null) return;
    if (aimTarget is GameObject){
      writeByte(ServerResponse.Player);
      writeByte(ApiPlayer.Aim_Target_Type);
       if ((aimTarget as GameObject).isItem) {
          writeUInt16((aimTarget as GameObject).subType);
       } else {
         writeUInt16((aimTarget as GameObject).type);
       }
    }
    if (aimTarget is Character) {
      writeByte(ServerResponse.Player);
      writeByte(ApiPlayer.Aim_Target_Type);
      writeUInt16((aimTarget as Character).type);
    }
  }

  void writePlayerAimTargetName() {
    if (aimTarget == null) return;

    if (aimTarget is Player){
      writeByte(ServerResponse.Player);
      writeByte(ApiPlayer.Aim_Target_Name);
      writeString((aimTarget as Player).name);
      return;
    }
    if (aimTarget is Npc){
      writeByte(ServerResponse.Player);
      writeByte(ApiPlayer.Aim_Target_Name);
      writeString((aimTarget as Npc).name);
      return;
    }
  }

  int getCategory(Position3? value){
    if (value == null) return TargetCategory.Nothing;
    if (isAllie(value)) return TargetCategory.Allie;
    if (isEnemy(value)) return TargetCategory.Enemy;
    if (value is GameObject) {
       if (value.isItem) return TargetCategory.Item;
       return TargetCategory.GameObject;
    }
    return TargetCategory.Run;
  }

  bool isAllie(Position3? value){
    if (value == null) return false;
    if (value == this) return true;
    if (value is Team == false) return false;
    final targetTeam = (value as Team).team;
    if (targetTeam == 0) return false;
    return team == targetTeam;
  }

  bool isEnemy(Position3? value) {
    if (value == null) return false;
    if (value is Team == false) return false;
    final targetTeam = (value as Team).team;
    if (targetTeam == 0) return true;
    return team != targetTeam;
  }

  void writeProjectiles(){
    writeByte(ServerResponse.Projectiles);
    final projectiles = game.projectiles;
    writeTotalActive(projectiles);
    projectiles.forEach(writeProjectile);
  }

  void writeZombie(Zombie zombie){
    writeByte(ServerResponse.Character_Zombie);
    writeCharacter(this, zombie);
  }

  void writeRat(Rat rat){
    writeByte(ServerResponse.Character_Rat);
    writeCharacter(this, rat);
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
    writeInt(x);
    writeInt(y);
    writeInt(z);
    writeInt(angle * radiansToDegrees);
  }

  void writeGameEventGameObjectDestroyed(GameObject gameObject){
      writeGameEvent(
        type: GameEventType.Game_Object_Destroyed,
        x: gameObject.x,
        y: gameObject.y,
        z: gameObject.z,
        angle: 0,
      );
      writeByte(gameObject.type);
  }

  void dispatchEventLootCollected(){
    writePlayerEvent(PlayerEvent.Loot_Collected);
  }

  void writePlayerEvent(int value){
    writeByte(ServerResponse.Player_Event);
    writeByte(value);
  }

  void writePlayerMoved(){
    writePlayerPosition();
    writePlayerEvent(PlayerEvent.Player_Moved);
  }

  void writePlayerEventItemEquipped(int itemType){
    writePlayerEvent(PlayerEvent.Item_Equipped);
    writeByte(itemType);
  }

  void writePlayerMessage(String message){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Message);
    writeString(message);
  }

  void writeGameTime(int time){
    writeByte(ServerResponse.Game_Time);
    final totalMinutes = time ~/ 60;
    writeByte(totalMinutes ~/ 60);
    writeByte(totalMinutes % 60);
  }

  void writeTotalActive(List<Active> values){
    var total = 0;
    for (final gameObject in values) {
      if (!gameObject.active) continue;
      total++;
    }
    writeInt(total);
  }

  void writeProjectile(Projectile projectile){
    if (!projectile.active) return;
    writePosition(projectile);
    writeInt(projectile.z);
    writeByte(projectile.type);
    writeAngle(projectile.faceAngle);
  }

  void writeDamageApplied(Position target, int amount) {
    if (amount <= 0) return;
    writeByte(ServerResponse.Damage_Applied);
    writePosition(target);
    writeInt(amount);
  }

  void writePlayer(Player player) {
    writeByte(ServerResponse.Character_Player);
    writeCharacter(player, player);
    writeCharacterEquipment(player);
    writeString(player.name);
    writeString(player.text);
    writeAngle(player.lookRadian);
    writeByte(player.weaponFrame);
  }

  void writeNpc(Player player, Character npc) {
    writeByte(ServerResponse.Character_Template);
    writeCharacter(player, npc);
    writeCharacterEquipment(npc);
  }

  void writeCharacter(Player player, Character character) {
    writeByte((onSameTeam(player, character) ? 100 : 0) + (character.faceDirection * 10) + character.state); // 1
    writePosition(character);
    writeInt(character.z);
    writeByte((((character.health / character.maxHealth) * 24).toInt() * 10) + character.animationFrame);
  }

  void writeCharacterEquipment(Character character) {
    assert (ItemType.isTypeWeapon(character.weaponType) || character.weaponType == ItemType.Empty);
    assert (ItemType.isTypeLegs(character.legsType) || character.legsType == ItemType.Empty);
    assert (ItemType.isTypeBody(character.bodyType) || character.bodyType == ItemType.Empty);
    assert (ItemType.isTypeHead(character.headType) || character.headType == ItemType.Empty);
    writeUInt16(character.weaponType);
    writeUInt16(character.weaponState);
    writeUInt16(character.bodyType); // armour
    writeUInt16(character.headType); // helm
    writeUInt16(character.legsType); // helm
  }

  void writeWeather() {
    if (game is GameDarkAge == false) return;
    final environment = (game as GameDarkAge).environment;
    writeByte(ServerResponse.Weather);
    writeByte(environment.raining.index);
    writeBool(environment.breezy);
    writeByte(environment.lightning.index);
    writeBool(environment.timePassing);
    writeByte(environment.wind);
    writeByte(environment.shade);
  }

  void writePercentage(double value){
    if (value.isNaN) {
      writeByte(0);
      return;
    }
    writeByte((value * 256).toInt());
  }

  void writePosition(Position value){
    writeInt(value.x);
    writeInt(value.y);
  }

  void writePosition3(Position3 value){
    writeInt(value.x);
    writeInt(value.y);
    writeInt(value.z);
  }

  void writeGrid() {
    writeByte(ServerResponse.Grid);
    writeInt(scene.gridHeight);
    writeInt(scene.gridRows);
    writeInt(scene.gridColumns);
    var previousType = scene.nodeTypes[0];
    var previousOrientation = scene.nodeOrientations[0];
    var count = 0;
    final nodeTypes = scene.nodeTypes;
    final nodeOrientations = scene.nodeOrientations;
    for (var z = 0; z < scene.gridHeight; z++){
      for (var row = 0; row < scene.gridRows; row++){
        for (var column = 0; column < scene.gridColumns; column++) {
          final nodeIndex = scene.getNodeIndex(z, row, column);
          final nodeType = nodeTypes[nodeIndex];
          final nodeOrientation = nodeOrientations[nodeIndex];

          if (nodeType == previousType && nodeOrientation == previousOrientation){
            count++;
          } else {
            writeByte(previousType);
            writeByte(previousOrientation);
            writeUInt16(count);
            previousType = nodeType;
            previousOrientation = nodeOrientation;
            count = 1;
          }
        }
      }
    }

    writeByte(previousType);
    writeByte(previousOrientation);
    writeUInt16(count);
  }

  void writePlayerInventory() {
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Inventory);
    writeUInt16(headType);
    writeUInt16(bodyType);
    writeUInt16(legsType);
    writeUInt16(weaponType);
    writeUInt16(inventory.length);
    for (final item in inventory) {
       writeUInt16(item);
    }
  }

  void writePlayerTarget() {
    writeByte(ServerResponse.Player_Target);
    writePosition(target != null ? target! : mouse);

    if (target != null){
      writeInt(target!.z);
    } else{
      writeInt(z);
    }
  }

  void writeAngle(double radians){
    writeInt(radians * radiansToDegrees);
  }

  void writeStoreItems(){
    writeByte(ServerResponse.Store_Items);
    writeUInt16(storeItems.length);
    storeItems.forEach(writeUInt16);
  }

  void writeInteractMode() {
    writeByte(ServerResponse.Player);
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

  void writeSceneMetaData() {
    writeByte(ServerResponse.Scene_Meta_Data);
    writeBool((game is GameDarkAgeEditor || isLocalMachine));
    writeString(game.scene.name);
  }

  void writePlayerQuests(){
    writeByte(ServerResponse.Player_Quests);
    writeInt(questsInProgress.length);
    for (final quest in questsInProgress){
      writeByte(quest.index);
    }
    writeInt(questsCompleted.length);
    for (final quest in questsCompleted){
      writeByte(quest.index);
    }
  }

  void writeMapCoordinate() {
    if (game is DarkAgeArea == false) return;
    final area = game as DarkAgeArea;
    writeByte(ServerResponse.Map_Coordinate);
    writeByte(area.mapTile);
  }

  void writeEditorGameObjectSelected() {
    final selectedGameObject = editorSelectedGameObject;
    if (selectedGameObject == null) return;
    writeByte(ServerResponse.Editor_GameObject_Selected);
    writePosition3(selectedGameObject);
    writeByte(selectedGameObject.type);
  }

  // void writePlayerSlots() {
  //   writeByte(ServerResponse.Player_Slots);
  //
  //   writeByte(weaponSlot1.type);
  //   writeInt(weaponSlot1.capacity);
  //   writeInt(weaponSlot1.rounds);
  //
  //   writeByte(weaponSlot2.type);
  //   writeInt(weaponSlot2.capacity);
  //   writeInt(weaponSlot2.rounds);
  //
  //   writeByte(weaponSlot3.type);
  //   writeInt(weaponSlot3.capacity);
  //   writeInt(weaponSlot3.rounds);
  // }

  void writePoints(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Points);
    writeInt(points);
  }

  void writeEnvironmentShade(int value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Shade);
    writeByte(value);
  }

  void writeEnvironmentLightning(Lightning value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Lightning);
    writeByte(value.index);
  }

  void writeEnvironmentWind(Wind wind){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Wind);
    writeByte(wind.index);
  }

  void writeEnvironmentRain(Rain rain){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Rain);
    writeByte(rain.index);
  }

  void writeEnvironmentTime(int value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Time);
    writeByte(value);
  }

  void writeEnvironmentBreeze(bool value){
    writeByte(ServerResponse.Environment);
    writeByte(EnvironmentResponse.Breeze);
    writeBool(value);
  }

  void writeNode(int index){
    assert (index >= 0);
    assert (index < scene.gridVolume);
    writeByte(ServerResponse.Node);
    writeUInt16(index);
    writeByte(scene.nodeTypes[index]);
    writeByte(scene.nodeOrientations[index]);
  }

  void lookAt(Position position) {
    assert(!deadOrDying);
    lookRadian = this.getAngle(position) + pi;
  }

  // void writePlayerAimTarget(){
  //   final aimTarget = _aimTarget;
  //   if (aimTarget is GameObject) {
  //     writeByte(ServerResponse.Player);
  //     writeByte(ApiPlayer.Aim_Target);
  //     writeByte(TargetCategory.GameObject);
  //     writeByte(aimTarget.type);
  //     writeUInt16(aimTarget.subType);
  //     writePosition3(aimTarget);
  //     return;
  //   }
  //   if (aimTarget is Character) {
  //     writeByte(ServerResponse.Player);
  //     writeByte(ApiPlayer.Aim_Target);
  //
  //     if (onSameTeam(this, aimTarget)) {
  //       writeByte(TargetCategory.Allie);
  //       if (aimTarget is Npc){
  //         writeString(aimTarget.name);
  //       } else if (aimTarget is Player){
  //         writeString(aimTarget.name);
  //       } else {
  //         writeString("");
  //       }
  //     } else {
  //       writeByte(TargetCategory.Enemy);
  //     }
  //     writePosition3(aimTarget);
  //     return;
  //   }
  //
  //   _aimTarget = null;
  //   writeByte(ServerResponse.Player);
  //   writeByte(ApiPlayer.Aim_Target);
  //   writeByte(TargetCategory.Nothing);
  // }

}

int getExperienceForLevel(int level){
  return (((level - 1) * (level - 1))) * 6;
}
