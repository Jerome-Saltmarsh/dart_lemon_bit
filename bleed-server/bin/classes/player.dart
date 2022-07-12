
import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../common/quest.dart';
import '../convert/convert_card_type_to_card.dart';
import '../dark_age/game_dark_age.dart';
import '../engine.dart';
import '../utilities.dart';
import 'enemy_spawn.dart';
import 'position3.dart';
import 'library.dart';

class Player extends Character with ByteWriter {
  var designed = false;
  CharacterSelection? selection;
  final mouse = Vector2(0, 0);
  final _runTarget = Position3();
  var characterSelectRequired = false;
  var debug = false;
  var score = 0;
  var sceneChanged = false;
  var characterState = CharacterState.Idle;
  var framesSinceClientRequest = 0;
  var pointsRecord = 0;
  var textDuration = 0;
  var experience = 0;
  var level = 1;
  var skillPoints = 0;
  var _magic = 0;
  var maxMagic = 100;
  var magicRegen = 1;
  var healthRegen = 1;
  var message = "";
  var text = "";
  var name = 'anon';
  var storeVisible = false;
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var wood = 0;
  var stone = 0;
  var gold = 0;
  var sceneDownloaded = false;
  Game game;
  Collider? aimTarget; // the currently highlighted character
  Account? account;

  final weapons = <Weapon>[];
  var storeItems = <Weapon>[];

  final cardChoices = <CardType>[];
  final deck = <Card>[];

  final questsInProgress = <Quest>[];
  final questsCompleted = <Quest>[];

  var options = <String, Function> {};
  var interactingWithNpc = false;

  bool get ownsGame => game.owner == this;

  void stopInteractingWithNpc(){
    if (!interactingWithNpc) return;
    closeStore();
    closeDialog();
    interactingWithNpc = false;
    writePlayerEvent(PlayerEvent.Interaction_Finished);
  }

  void setStoreItems(List<Weapon> values){
    this.storeItems = values;
    writeStoreItems();
  }

  void closeStore(){
    if (storeItems.isEmpty) return;
    storeItems = [];
    writeStoreItems();
  }

  void closeDialog(){
    if (options.isEmpty) return;
    options.clear();
    writeNpcTalk(text: "", options: {});
  }

  void runToMouse(){
    setRunTarget(mouse.x, mouse.y);
  }

  void setRunTarget(double x, double y){
    _runTarget.x = x;
    _runTarget.y = y;
    target = _runTarget;
  }

  void setCardAbility(CardAbility value){
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

  double get mouseAngle {
    return getAngleBetween(x, y, mouse.x, mouse.y);
  }

  Scene get scene => game.scene;

  int get magic => _magic;

  double get magicPercentage {
    if (_magic == 0) return 0;
    if (maxMagic == 0) return 0;
    return _magic / maxMagic;
  }

  int get experienceRequiredForNextLevel => getExperienceForLevel(level + 1);

  double get experiencePercentage {
    if (experience == 0) return 0.0;
    return experience / experienceRequiredForNextLevel;
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
            equippedWeapon: weapon,

  ){
    maxMagic = magic;
    _magic = maxMagic;
    engine.onPlayerCreated(this);
  }

  void writeLivesRemaining(int lives){
    writeByte(ServerResponse.Lives_Remaining);
    writeByte(lives);
  }

  void writeGameStatus(){
    writeByte(ServerResponse.Game_Status);
    writeByte(game.status.index);
  }

  void toggleDebug(){
    debug = !debug;
    writeByte(ServerResponse.Debug_Mode);
    writeBool(debug);
  }

  void equipPickaxe(){
    // equippedType = TechType.Pickaxe;
    setCharacterStateChanging();
  }

  void equipAxe(){
    // equippedType = TechType.Axe;
    setCharacterStateChanging();
  }

  void equipUnarmed(){
    equippedWeapon = Weapon(type: WeaponType.Unarmed, damage: 1);
    setCharacterStateChanging();
  }

  void setCharacterStateChanging(){
    if (deadOrBusy) return;
    dispatchGameEvent(GameEventType.Character_Changing);
    setCharacterState(value: CharacterState.Changing, duration: 30);
  }

  void dispatchGameEvent(int type){
    game.dispatchV2(GameEventType.Character_Changing, this);
  }

  void setCharacterSelectionRequired(bool value){
    characterSelectRequired = value;
    writeCharacterSelectRequired();
  }

  void writeCharacterSelectRequired(){
    writeByte(ServerResponse.Character_Select_Required);
    writeBool(characterSelectRequired);
  }

  void gainExperience(int amount){
      experience += amount;
      while (experience > experienceRequiredForNextLevel) {
        experience -= experienceRequiredForNextLevel;
        level++;
        skillPoints++;
        game.onPlayerLevelGained(this);
      }
  }

  void setBlock(int z, int row, int column, int type) {
    if (scene.outOfBounds(z, row, column)) return;
    final previousType = scene.getGridType(z, row, column);

    if (previousType == GridNodeType.Enemy_Spawn){
      scene.enemySpawns.removeWhere((enemySpawn) =>
      enemySpawn.z == z &&
          enemySpawn.row == row &&
          enemySpawn.column == column
      );
    };

    if (previousType == type) return;
    scene.dirty = true;
    scene.grid[z][row][column].type = type;
    game.players.forEach((player) {
      player.writeByte(ServerResponse.Block_Set);
      player.writeInt(z);
      player.writeInt(row);
      player.writeInt(column);
      player.writeInt(type);
    });

    if (type == GridNodeType.Enemy_Spawn){
      scene.enemySpawns.add(EnemySpawn(z: z, row: row, column: column, health: 5));
    }
  }

  void changeGame(Game to){
    game.removePlayer(this);
    to.players.add(this);
    sceneDownloaded = false;
    game = to;
  }
}


extension PlayerProperties on Player {

  bool get unarmed => equippedWeapon == TechType.Unarmed;

  void writePlayerDebug(){
    writeByte(state);
    writeInt(angle * 100);
    writeInt(mouseAngle * 100);
  }

  void writePlayerGame() {
    writeByte(ServerResponse.Player);
    writeInt(x);
    writeInt(y);
    writeInt(z);
    writeInt(health); // 2
    writeInt(maxHealth); // 2
    writeByte(equippedWeapon.type);
    writeByte(equippedWeapon.damage);
    writeByte(equippedArmour); // armour
    writeByte(equippedHead); // helm
    writeByte(equippedPants); // helm
    writeBool(alive); // 1
    writePercentage(experiencePercentage);
    writeByte(level);
    writeCollectables();
    writePlayers();
    writeAttackTarget();
    writeProjectiles();
    writeNpcs(this);
    writePlayerTarget();
    writeGameTime(game);
    writeZombies();

    if (!sceneDownloaded){
      downloadScene();
    }

    if (debug)
      writePaths();
  }

  void downloadScene(){
    writeGrid();
    writeWeather();
    writeGameObjects();
    writeGameStatus();
    writeSceneMetaData();
    writePlayerDesigned();

    options.clear();
    writeNpcTalk(text: "", options: {});

    storeItems = [];
    writeStoreItems();

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
    writePosition(mouseTarget);

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
    writePercentage(health);
  }

  void writeProjectiles(){
    writeByte(ServerResponse.Projectiles);
    final projectiles = game.projectiles;
    writeTotalActive(projectiles);
    projectiles.forEach(writeProjectile);
  }

  void writePlayers(){
    writeByte(ServerResponse.Players);
    final players = game.players;
    for (final otherPlayer in players) {
      if (otherPlayer.dead) continue;
      if (otherPlayer.renderY < screenTop) continue;
      if (otherPlayer.renderX < screenLeft) continue;
      if (otherPlayer.renderX > screenRight) continue;
      if (otherPlayer.renderY > screenBottom) break;
      writePlayer(otherPlayer);
      writeString(otherPlayer.text);
    }
    writeByte(END);
  }

  void writeCollectables() {
    writeByte(ServerResponse.Collectables);
    final collectables = game.collectables;
    for (final collectable in collectables) {
      if (collectable.inactive) continue;
      writeByte(collectable.type);
      writePosition(collectable);
    }
    writeByte(END);
  }


  void writeZombies() {
    writeByte(ServerResponse.Zombies);
    final zombies = game.zombies;
    for (final zombie in zombies){
      if (zombie.dead) continue;
      if (zombie.renderY < screenTop) continue;
      if (zombie.renderX < screenLeft) continue;
      if (zombie.renderX > screenRight) continue;
      if (zombie.renderY > screenBottom) break;
      writeCharacter(this, zombie);
    }
    writeByte(END);
  }

  void writeGameObjects() {
    writeByte(ServerResponse.Game_Objects);
    final gameObjects = game.gameObjects;
    for (final gameObject in gameObjects) {
       writeByte(gameObject.type);
       writePosition(gameObject);
       // writePositiveInt(gameObject.id);
    }
    writeByte(END);
  }

  void writeGameEvent({
    required int type,
    required double x,
    required double y,
    required double z,
    required double angle,
  }){
    writeByte(ServerResponse.Game_Events);
    writeByte(type);
    writeInt(x);
    writeInt(y);
    writeInt(z);
    writeInt(angle * radiansToDegrees);
  }

  void writeDynamicObjectDestroyed(GameObject dynamicObject){
    writeByte(ServerResponse.Dynamic_Object_Destroyed);
    writeInt(dynamicObject.id);
  }

  void writeDynamicObjectSpawned(GameObject dynamicObject){
    writeByte(ServerResponse.Dynamic_Object_Spawned);
    writeByte(dynamicObject.type);
    writePosition(dynamicObject);
    writeInt(dynamicObject.id);
  }


  void writePaths() {
    writeByte(ServerResponse.Paths);
    final zombies = game.zombies;
    for (final zombie in zombies) {
      if (zombie.dead) continue;
      if (zombie.y < screenTop) continue;
      if (zombie.x < screenLeft) continue;
      if (zombie.x > screenRight) continue;
      if (zombie.y > screenBottom) break;
      final pathIndex = zombie.pathIndex;
      if (pathIndex < 0) continue;
      writeInt(pathIndex + 1);
      for (var i = pathIndex; i >= 0; i--) {
        writeInt(zombie.pathX[i]);
        writeInt(zombie.pathY[i]);
      }
    }
    writeInt(250);

    for (final zombie in zombies) {
      if (zombie.dead) continue;
      if (zombie.y < screenTop) continue;
      if (zombie.x < screenLeft) continue;
      if (zombie.x > screenRight) continue;
      if (zombie.y > screenBottom) break;
      final aiTarget = zombie.target;
      if (aiTarget is Character) {
        writeByte(1);
        writePosition(zombie);
        writePosition(aiTarget);
      }
    }
    writeByte(0);
  }

  void writeItems(Player player){
    writeByte(ServerResponse.Items);
    final items = player.game.items;
    for(final item in items){
      if (!item.collidable) continue;
      if (item.left < player.screenLeft) continue;
      if (item.right > player.screenRight) continue;
      if (item.top < player.screenTop) continue;
      if (item.bottom > player.screenBottom) break;
      writeByte(item.type);
      writePosition(item);
    }
    writeByte(END);
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

  void writeTotalAlive(List<Health> values){
    var total = 0;
    for (final gameObject in values) {
      if (gameObject.dead) continue;
      total++;
    }
    writeInt(total);
  }

  void writeProjectile(Projectile projectile){
    if (!projectile.active) return;
    writePosition(projectile);
    writeInt(projectile.z);
    writeByte(projectile.type);
    writeAngle(projectile.angle);
  }

  void writeDamageApplied(Position target, int amount) {
    if (amount <= 0) return;
    writeByte(ServerResponse.Damage_Applied);
    writePosition(target);
    writeInt(amount);
  }

  void writePlayer(Player player) {
    writeCharacter(player, player);
    writePercentage(player.magicPercentage);
    writeCharacterEquipment(player);
    writeString(player.name);
    writeInt(player.score);
  }

  void writeNpcs(Player player){
    writeByte(ServerResponse.Npcs);
    final npcs = game.npcs;
    for (final npc in npcs){
      if (npc.dead) continue;
      if (npc.renderY < screenTop) continue;
      if (npc.renderX < screenLeft) continue;
      if (npc.renderX > screenRight) continue;
      if (npc.renderY > screenBottom) break;
      writeNpc(this, npc);
    }
    writeByte(END);
  }

  void writeNpc(Player player, Character npc) {
    if (npc.dead) return;
    writeCharacter(player, npc);
    writeCharacterEquipment(npc);
  }

  void writeCharacter(Player player, Character character) {
    writeByte((onSameTeam(player, character) ? 100 : 0) + (character.direction * 10) + character.state); // 1
    writePosition(character);
    writeInt(character.z);
    writeByte((((character.health / character.maxHealth) * 24).toInt() * 10) + character.animationFrame);
  }

  void writeCharacterEquipment(Character character) {
    writeByte(character.equippedWeapon.type);
    writeByte(character.equippedArmour); // armour
    writeByte(character.equippedHead); // helm
    writeByte(character.equippedPants); // helm
  }

  void writeWeather() {
    if (game is GameDarkAge == false) return;
    final universe = (game as GameDarkAge).universe;
    writeByte(ServerResponse.Weather);
    writeByte(universe.raining.index);
    writeBool(universe.breezy);
    writeByte(universe.lightning.index);
    writeBool(universe.timePassing);
    writeByte(universe.wind);
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
    for (var z = 0; z < totalZ; z++){
      for (var row = 0; row < totalRows; row++){
        for (var column = 0; column < totalColumns; column++){
           writeByte(grid[z][row][column].type);
        }
      }
    }
  }

  Card? getCardByType(CardType type){
    for (final card in deck) {
      if (card.type != type) continue;
      return card;
    }
    return null;
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

  List<CardType> getCardOptions(){
    if (selection == null) return [];
    switch(selection){
      case CharacterSelection.Archer:
        return cardTypeChoicesBow;
      case CharacterSelection.Warrior:
        return cardTypeChoicesWarrior;
      case CharacterSelection.Wizard:
        return cardTypeChoicesStaff;
      default:
        return [];
    }
  }

  void generatedCardChoices(){
    if (cardChoices.isNotEmpty) return;

    final options = getCardOptions();

    while (cardChoices.length < 3 && options.length > cardChoices.length) {
        final cardChoice = randomItem(options);
        if (cardChoices.contains(cardChoice)) continue;
        cardChoices.add(cardChoice);
    }
    writeCardChoices();
  }

  int getDamage(){
    return 5;
  }

  void writeDeckCooldown(){
    writeByte(ServerResponse.Player_Deck_Cooldown);
    writeByte(deck.length);
    for (final card in deck) {
      if (card is CardAbility){
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

  void writeWeapon(Weapon weapon){
    writeByte(weapon.type);
    writeInt(weapon.damage);
    writeString(weapon.uuid);
  }

  void writeEquippedWeapon(){
    writeByte(ServerResponse.Player_Equipped_Weapon);
    writeByte(equippedWeapon.type);
    writeInt(equippedWeapon.damage);
    writeString(equippedWeapon.uuid);
  }

  void writePlayerTarget() {
    if (ability == null) return;
    if (ability!.isModeArea) return;
    writeByte(ServerResponse.Player_Target);
    writePosition(target != null ? target! : mouse);
  }

  void writeAngle(double radians){
    writeInt(radians * radiansToDegrees);
  }

  void writeStoreItems(){
     writeByte(ServerResponse.Store_Items);
     writeInt(storeItems.length);
     storeItems.forEach(writeWeapon);
  }

  void writeNpcTalk({required String text, required Map<String, Function> options}){
    if (text.isNotEmpty || options.isNotEmpty){
      this.interactingWithNpc = true;
    }
    this.options = options;

    if (options.isNotEmpty){
      // options.add(MapEntry("Goodbye",  stopInteractingWithNpc,))
          // o
      options['Goodbye'] = stopInteractingWithNpc;
    }

    writeByte(ServerResponse.Npc_Talk);
    writeString(text);
    writeByte(options.length);
    for (final option in options.keys){
       writeString(option);
    }
  }

  void writeSceneMetaData() {
    writeByte(ServerResponse.Scene_Meta_Data);
    writeBool(game.owner == this);
    writeString(game.scene.name);
  }

  void writePlayerDesigned(){
    writeByte(ServerResponse.Player_Designed);
    writeBool(designed);
  }
}

int getExperienceForLevel(int level){
  return (((level - 1) * (level - 1))) * 6;
}

