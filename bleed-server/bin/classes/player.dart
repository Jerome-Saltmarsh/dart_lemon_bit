
import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:bleed_server/system.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

import '../common/character_type.dart';
import '../common/flag.dart';
import '../common/library.dart';
import '../common/quest.dart';
import '../convert/convert_card_type_to_card.dart';
import '../dark_age/areas/dark_age_area.dart';
import '../dark_age/game_dark_age.dart';
import '../dark_age/game_dark_age_editor.dart';
import '../utilities.dart';
import 'gameobject.dart';
import 'library.dart';
import 'node.dart';
import 'position3.dart';
import 'rat.dart';
import 'zombie.dart';

class Player extends Character with ByteWriter {

  final mouse = Vector2(0, 0);
  final runTarget = Position3();

  double get mouseGridX => (mouse.x + mouse.y) + z;
  double get mouseGridY => (mouse.y - mouse.x) + z;

  GameObject? editorSelectedGameObject;
  var debug = false;
  var characterState = CharacterState.Idle;
  var framesSinceClientRequest = 0;
  var textDuration = 0;
  var _experience = 0;
  var level = 1;
  var skillPoints = 0;
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
  /// Warning - do not reference
  Game game;
  Collider? aimTarget; // the currently highlighted character
  Account? account;

  final weapons = <Weapon>[];
  var storeItems = <Weapon>[];

  var weaponSlot1 = buildWeaponHandgun();
  var weaponSlot2 = buildWeaponFireball();
  var weaponSlot3 = buildWeaponBlade();

  final cardChoices = <CardType>[];
  final deck = <Card>[];

  final questsInProgress = <Quest>[];
  final questsCompleted = <Quest>[];
  final flags = <Flag>[];

  var options = <String, Function> {};
  var interactingWithNpc = false;
  var npcName = "";

  var mapX = 0;
  var mapY = 0;

  int get experience => _experience;

  set experience(int value){
    if (value < 0) {
      _experience = 0;
      return;
    }
    _experience = value;
    while (value >= experienceRequiredForNextLevel) {
      value -= experienceRequiredForNextLevel;
      level++;
      skillPoints++;
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
    endInteraction();
    runTarget.x = x;
    runTarget.y = y;
    target = runTarget;
  }

  void setCardAbility(Power value){
    if (ability == value) return;
    ability = value;
    writeByte(ServerResponse.Player_Deck_Active_Ability);
    writeByte(deck.indexOf(value));
    writeInt(value.range);
    writeInt(value.radius);
  }

  void clearCardAbility(){
    ability = null;
    writeByte(ServerResponse.Player_Deck_Active_Ability_None);
  }

  int numberOfCardsOfType(CardType type){
    return deck.where((card) => card == type).length;
  }

  late Function sendBufferToClient;
  late Function(GameError error, {String message}) dispatchError;

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

  void changeGame(Game to){
    if (game == to) return;
    game.removePlayer(this);
    for (final character in game.characters) {
      if (character.target != this) continue;
      character.clearTarget();
    }
    to.players.add(this);
    to.characters.add(this);
    sceneDownloaded = false;
    game = to;
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

  void writePlayerGame() {
    writeByte(ServerResponse.Player);
    writeInt(x);
    writeInt(y);
    writeInt(z);
    writeInt(health); // 2
    writeInt(maxHealth); // 2
    writeByte(weapon.type);
    writeByte(weapon.damage);
    writeByte(equippedArmour); // armour
    writeByte(equippedHead); // helm
    writeByte(equippedPants); // helm
    writeBool(alive); // 1
    writePercentage(experiencePercentage);
    writeByte(level);
    writeAngle(mouseAngle);


    writePlayerSlots();
    writeAttackTarget();
    writeProjectiles();
    writePlayerTarget();
    writeGameTime(game);
    writeCharacters();
    writeGameObjects();
    writeEditorGameObjectSelected();


    if (!sceneDownloaded){
      downloadScene();
    }
  }

  void writeGameObjects(){
    final gameObjects = game.gameObjects;
    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (gameObject.renderY < screenTop) continue;
      if (gameObject.renderX < screenLeft) continue;
      if (gameObject.renderX > screenRight) continue;
      if (gameObject.renderY > screenBottom) continue;
      gameObject.write(this);
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
    writeWeather();
    writeSceneMetaData();
    writeMapCoordinate();

    if (game is GameDarkAge) {
      writeByte(ServerResponse.Render_Map);
      writeBool((game as GameDarkAge).mapVisible);
    }

    writePlayerEvent(PlayerEvent.Scene_Changed);
    sceneDownloaded = true;
  }

  void writePlayerSpawned(){
    writeByte(ServerResponse.Player_Spawned);
    writeInt(x);
    writeInt(y);
  }

  void writeAndSendResponse(){
    writePlayerGame();
    writeByte(ServerResponse.End);
    sendBufferToClient();
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

  void dispatchEventLootCollected(){
    writePlayerEvent(PlayerEvent.Loot_Collected);
  }

  void writePlayerEvent(int value){
    writeByte(ServerResponse.Player_Events);
    writeByte(value);
  }

  void writeGameTime(Game game){
    writeByte(ServerResponse.Game_Time);
    final totalMinutes = game.getTime() ~/ 60;
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
    writePercentage(player.magicPercentage);
    writeCharacterEquipment(player);
    writeString(player.name);
    writeString(player.text);
    writeAngle(player.mouseAngle);
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
    writeByte(character.equippedArmour); // armour
    writeByte(character.equippedHead); // helm
    writeByte(character.equippedPants); // helm
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

  void writeCardChoices() {
    writeByte(ServerResponse.Card_Choices);
    writeCardTypes(cardChoices);
  }

  void writeDeck() {
    writeByte(ServerResponse.Player_Deck);
    writeByte(deck.length);
    for (final card in deck) {
      writeByte(card.type.index);
      writeByte(card.level);
    }
  }

  void writeGrid(){
    writeByte(ServerResponse.Grid);
    final grid = game.scene.grid;
    final totalZ = grid.length;
    final totalRows = grid[0].length;
    final totalColumns = grid[0][0].length;
    writeInt(totalZ);
    writeInt(totalRows);
    writeInt(totalColumns);
    var previousType = grid[0][0][0].type;
    var previousOrientation = grid[0][0][0].orientation;
    var count = 0;
    for (var z = 0; z < totalZ; z++){
      final plain = grid[z];
      for (var row = 0; row < totalRows; row++){
        final r = plain[row];
        for (var column = 0; column < totalColumns; column++) {
          final node = r[column];

          if (node.type == previousType && node.orientation == previousOrientation){
            count++;
          } else {
            writeByte(previousType);

            if (NodeType.isOriented(previousType)){
              writeByte(previousOrientation);
            }

            writePositiveInt(count);
            previousType = node.type;
            previousOrientation = node.orientation;
            count = 1;
          }
        }
      }
    }

    writeByte(previousType);
    if (NodeType.isOriented(previousType)){
      writeByte(previousOrientation);
    }
    writePositiveInt(count);
  }

  Card? getCardByType(CardType type){
    for (final card in deck) {
      if (card.type != type) continue;
      return card;
    }
    return null;
  }

  void writeNodeData(NodeSpawn node){
    writeByte(ServerResponse.Node_Data);
    writeByte(node.spawnType);
    writeInt(node.spawnAmount);
    writeInt(node.spawnRadius);
  }

  void addCardToDeck(CardType type){

    final card = getCardByType(type);
    if (card != null){
      card.level++;
    } else {
      deck.add(convertCardTypeToCard(type));
    }
    writeDeck();
    if (type == CardType.Passive_General_Max_HP_10) {
      maxHealth += 10;
      health += 10;
    }
  }

  void writeCardTypes(List<CardType> values){
    writeByte(values.length);
    for (final card in values) {
      writeByte(card.index);
    }
  }

  int getDamage(){
    return 5;
  }

  void writeDeckCooldown(){
    writeByte(ServerResponse.Player_Deck_Cooldown);
    writeByte(deck.length);
    for (final card in deck) {
      if (card is Power){
        if (card.cooldownRemaining > 0){
          card.cooldownRemaining--;
        }
        writeByte(card.cooldownRemaining);
        writeByte(card.cooldown);
      } else {
        writeByte(0);
        writeByte(0);
      }
    }
  }

  void writePlayerWeapons(){
    writeByte(ServerResponse.Player_Weapons);
    writeInt(weapons.length);
    weapons.forEach(writeWeapon);
  }

  void  writeWeapon(Weapon weapon){
    writeByte(weapon.type);
    writeInt(weapon.damage);
    writeString(weapon.uuid);
  }

  void writeEquippedWeapon(){
    writeByte(ServerResponse.Player_Equipped_Weapon);
    writeByte(weapon.type);
    writeInt(weapon.damage);
    writeString(weapon.uuid);
  }

  void writePlayerTarget() {
    if (ability == null) return;
    if (ability!.isModeArea) return;
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
    if (selectedGameObject is GameObjectSpawn) {
      assert(selectedGameObject.type == GameObjectType.Spawn);
      writeByte(selectedGameObject.spawnType);
      writeByte(selectedGameObject.spawnAmount);
      writeInt(selectedGameObject.spawnRadius);
    }
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
}

int getExperienceForLevel(int level){
  return (((level - 1) * (level - 1))) * 6;
}

