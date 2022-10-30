
import 'dart:math';

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
import 'position3.dart';
import 'rat.dart';
import 'zombie.dart';

class Player extends Character with ByteWriter {
  var autoAim = true;
  final mouse = Vector2(0, 0);
  final runTarget = Position3();
  var runningToTarget = false;
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
  Collider? aimTarget; // the currently highlighted character
  Account? account;

  final weapons = <Weapon>[];
  var storeItems = <Weapon>[];

  var weaponSlot1 = buildWeaponUnarmed();
  var weaponSlot2 = buildWeaponUnarmed();
  var weaponSlot3 = buildWeaponUnarmed();

  final questsInProgress = <Quest>[];
  final questsCompleted = <Quest>[];
  final flags = <Flag>[];

  var options = <String, Function> {};
  var interactingWithNpc = false;
  var npcName = "";

  var mapX = 0;
  var mapY = 0;

  double get mouseGridX => (mouse.x + mouse.y) + z;
  double get mouseGridY => (mouse.y - mouse.x) + z;

  int get lookDirection => Direction.fromRadian(lookRadian);

  int get experience => _experience;

  int get points => _points;

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

  Weapon? getWeaponByUuid(String weaponUuid){
    for (final weapon in weapons){
      if (weapon.uuid != weaponUuid) continue;
      return weapon;
    }
    return null;
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
    if (!interactingWithNpc) return;
    if (storeItems.isNotEmpty) {
      storeItems = [];
      writeStoreItems();
    }
    if (options.isNotEmpty) {
      options.clear();
    }
    interactingWithNpc = false;
    npcName = "";
    writePlayerEvent(PlayerEvent.Interaction_Finished);
  }

  void interact({required String message, Map<String, Function>? responses}){
    writeNpcTalk(text: message, options: responses);
  }

  void setStoreItems(List<Weapon> values){
    if (values.isNotEmpty){
      interactingWithNpc = true;
    }
    this.storeItems = values;
    writeStoreItems();
  }

  void runToMouse(){
    setRunTarget(mouseGridX, mouseGridY);
  }

  void setRunTarget(double x, double y){
    runningToTarget = true;
    endInteraction();
    runTarget.x = x;
    runTarget.y = y;
    runTarget.z = z;
    target = runTarget;
    writeTargetPosition();
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
    required Weapon weapon,
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
            weapon: weapon,
  ){
    maxMagic = magic;
    _magic = maxMagic;
    game.players.add(this);
    game.characters.add(this);
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

  void writePlayerGame() {
    writePlayerPosition();
    writePlayerWeaponCooldown();

    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Health);
    writeInt(health);

    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Max_Health);
    writeInt(maxHealth); // 2

    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Armour_Type);
    writeByte(equippedArmour);

    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Head_Type);
    writeByte(equippedHead);

    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Pants_Type);
    writeByte(equippedLegs);

    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Alive);
    writeBool(alive);

    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Experience_Percentage);
    writePercentage(experiencePercentage);

    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Level);
    writeInt(level);

    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Aim_Angle);
    writeAngle(mouseAngle);

    writePlayerSlots();
    writeAttackTarget();
    writeProjectiles();
    writePlayerTarget();
    writeCharacters();
    writeGameObjects();
    writeEditorGameObjectSelected();

    if (!initialized) {
      writeGameOptionControlScheme();
      game.customInitPlayer(this);
      initialized = true;
      writePlayerWeaponType();
      writePlayerWeaponCapacity();
      writePlayerWeaponRounds();
      writePlayerSpawned();
    }

    if (!sceneDownloaded){
      downloadScene();
    }
  }

  void writePlayerWeaponType(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Weapon_Type);
    writeByte(weapon.type);
  }

  void writePlayerWeaponRounds(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Weapon_Rounds);
    writeInt(weapon.rounds);
  }

  void writePlayerWeaponCapacity(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Weapon_Capacity);
    writeInt(weapon.capacity);
  }

  void writePlayerWeaponCooldown() {
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Weapon_Cooldown);
    writePercentage(weapon.durationPercentage);
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

  void writeTargetPosition(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Target_Position);
    writePosition3(runTarget);
  }

  void writeTargetPositionNone(){
    writeByte(ServerResponse.Player);
    writeByte(ApiPlayer.Target_Position_None);
  }

  void writeAttackTarget() {
    final mouseTarget = aimTarget;
    if (mouseTarget == null) {
      writeByte(ServerResponse.Player_Attack_Target_None);
      return;
    }
    writeByte(ServerResponse.Player_Attack_Target);
    writePosition3(mouseTarget);

    if (mouseTarget is Npc) {
      return writePlayerAttackTargetName(mouseTarget.name, mouseTarget.healthPercentage);
    }
    if (mouseTarget is AI) {
      return writePlayerAttackTargetName("Zombie", mouseTarget.healthPercentage);
    }
  }

  void writePlayerAttackTargetName(String name, double health){
    writeByte(ServerResponse.Player_Attack_Target_Name);
    writeString(name);
    writeBool(onSameTeam(this, aimTarget));
    writePercentage(health);
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
    writeByte(player.weapon.frame);
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
    writeByte(character.weapon.type);
    writeByte(character.weapon.state);
    writeByte(character.equippedArmour); // armour
    writeByte(character.equippedHead); // helm
    writeByte(character.equippedLegs); // helm
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

  void writeGameObject(GameObject gameObject) {
    writeByte(ServerResponse.GameObject);
    writeByte(gameObject.type);
    writePosition3(gameObject);
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
            writePositiveInt(count);
            previousType = nodeType;
            previousOrientation = nodeOrientation;
            count = 1;
          }
        }
      }
    }

    writeByte(previousType);
    writeByte(previousOrientation);
    writePositiveInt(count);
  }

  // void writeNodeData(NodeSpawn node){
  //   writeByte(ServerResponse.Node_Data);
  //   writeByte(node.spawnType);
  //   writeInt(node.spawnAmount);
  //   writeInt(node.spawnRadius);
  // }

  void writePlayerWeapons(){
    writeByte(ServerResponse.Player_Weapons);
    writeInt(weapons.length);
    weapons.forEach(writeWeapon);
  }

  void writeWeapon(Weapon weapon){
    writeByte(weapon.type);
    writeInt(weapon.damage);
    writeString(weapon.uuid);
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
    writeInt(storeItems.length);
    storeItems.forEach(writeWeapon);
  }

  void writeNpcTalk({required String text, Map<String, Function>? options}){
    interactingWithNpc = true;
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

  void writePlayerSlots() {
    writeByte(ServerResponse.Player_Slots);

    writeByte(weaponSlot1.type);
    writeInt(weaponSlot1.capacity);
    writeInt(weaponSlot1.rounds);

    writeByte(weaponSlot2.type);
    writeInt(weaponSlot2.capacity);
    writeInt(weaponSlot2.rounds);

    writeByte(weaponSlot3.type);
    writeInt(weaponSlot3.capacity);
    writeInt(weaponSlot3.rounds);
  }

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

  void writeGameOptionControlScheme(){
    writeByte(ServerResponse.Options);
    writeByte(GameOption.Set_Control_Scheme);
    writeByte(game.controlScheme);
  }

  void writeNode(int index){
    assert (index >= 0);
    assert (index < scene.gridVolume);
    writeByte(ServerResponse.Node);
    writePositiveInt(index);
    writeByte(scene.nodeTypes[index]);
    writeByte(scene.nodeOrientations[index]);
  }

  void lookAt(Position position) {
    assert(!deadOrBusy);
    lookRadian = this.getAngle(position) + pi;
  }
}

int getExperienceForLevel(int level){
  return (((level - 1) * (level - 1))) * 6;
}
