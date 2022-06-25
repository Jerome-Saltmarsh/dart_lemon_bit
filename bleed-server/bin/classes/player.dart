
import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../convert/convert_card_type_to_card.dart';
import '../engine.dart';
import '../utilities.dart';
import 'position3.dart';
import 'library.dart';
import 'weapon.dart';


class Player extends Character with ByteWriter {
  CharacterSelection? selection;
  final mouse = Vector2(0, 0);
  final _runTarget = Position3();
  var characterSelectRequired = false;
  var debug = false;
  var score = 0;
  var sceneChanged = false;
  var characterState = CharacterState.Idle;
  var lastUpdateFrame = 0;
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
            type: CharacterType.Human,
            x: 0,
            y: 0,
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
    setStateChanging();
  }

  void equipAxe(){
    // equippedType = TechType.Axe;
    setStateChanging();
  }

  void equipUnarmed(){
    equippedWeapon = Weapon(type: WeaponType.Unarmed, damage: 1);
    setStateChanging();
  }

  void setStateChanging(){
    writePlayerEvent(PlayerEvent.Item_Equipped);
    game.setCharacterState(this, CharacterState.Changing);
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
}

class Slot {
  var type = SlotType.Empty;
  var amount = -1;

  bool get isEmpty => type == SlotType.Empty;

  bool isType(int value){
    return type == value;
  }

  void swapWith(Slot other){
    final otherType = other.type;
    final otherAmount = other.amount;
    other.type = type;
    other.amount = amount;
    type = otherType;
    amount = otherAmount;
  }
}

class Slots {
  var weapon = Slot();
  var armour = Slot();
  var helm = Slot();

  var slot1 = Slot();
  var slot2 = Slot();
  var slot3 = Slot();
  var slot4 = Slot();
  var slot5 = Slot();
  var slot6 = Slot();

  int? getSlotIndexWhere(bool Function(int slotType) where){
     if (where(slot1.type)) return 1;
     if (where(slot2.type)) return 2;
     if (where(slot3.type)) return 3;
     if (where(slot4.type)) return 4;
     if (where(slot5.type)) return 5;
     if (where(slot6.type)) return 6;
     return null;
  }

  Slot getSlotAtIndex(int index) {
    switch (index) {
      case 1:
        return slot1;
      case 2:
        return slot2;
      case 3:
        return slot3;
      case 4:
        return slot4;
      case 5:
        return slot5;
      case 6:
        return slot6;
      default:
        throw Exception("$index is not a valid slot index (1 - 6 inclusive)");
    }
  }

  int getSlotTypeAtIndex(int index){
    return getSlotAtIndex(index).type;
  }

  void assignSlotAtIndex(int index, Slot value){
    switch(index){
      case 1:
        slot1 = value;
        break;
      case 2:
        slot2 = value;
        break;
      case 3:
        slot3 = value;
        break;
      case 4:
        slot4 = value;
        break;
      case 5:
        slot5 = value;
        break;
      case 6:
        slot6 = value;
        break;
      default:
        throw Exception("cannot assign slot $index it out of bounds");
    }

  }

  void assignSlotTypeAtIndex(int index, int type){
    getSlotAtIndex(index).type = type;
  }

  bool get emptySlotAvailable => getEmptySlot() != null;

  Slot? getEmptySlot(){
    return findSlotByType(SlotType.Empty);
  }

  Slot? getEmptyWeaponSlot(){
    if (weapon.isEmpty) return weapon;
    return findSlotByType(SlotType.Empty);
  }

  Slot? getEmptyArmourSlot(){
    if (armour.isEmpty) return armour;
    return findSlotByType(SlotType.Empty);
  }

  Slot? getEmptyHeadSlot(){
    if (helm.isEmpty) return helm;
    return findSlotByType(SlotType.Empty);
  }

  Slot? findWeaponSlotByType(int type){
    if (SlotType.isWeapon(type)) return weapon;
    if (slot1.isType(type)) return slot1;
    if (slot2.isType(type)) return slot2;
    if (slot3.isType(type)) return slot3;
    if (slot4.isType(type)) return slot4;
    if (slot5.isType(type)) return slot5;
    if (slot6.isType(type)) return slot6;
    return null;
  }


  Slot? findSlotByType(int type){
    if (slot1.isType(type)) return slot1;
    if (slot2.isType(type)) return slot2;
    if (slot3.isType(type)) return slot3;
    if (slot4.isType(type)) return slot4;
    if (slot5.isType(type)) return slot5;
    if (slot6.isType(type)) return slot6;
    return null;
  }

  bool assignToEmpty(int type){
    final empty = getEmptySlot();
    if (empty == null) return false;
    empty.type = type;
    return true;
  }
}

extension PlayerProperties on Player {

  bool get isHuman => type == CharacterType.Human;

  bool get unarmed => equippedWeapon == TechType.Unarmed;

  void onEquipped(int slotType){
    final healthIncrease = SlotType.getHealth(slotType);
    maxHealth += healthIncrease;
    health = clampInt(health + healthIncrease, 1, maxHealth);
    final magicIncrease = SlotType.getMagic(slotType);
    maxMagic += magicIncrease;
    magic = clampInt(magic + magicIncrease, 1, maxMagic);
  }

  void onUnequipped(int slotType){
    final healthAmount = SlotType.getHealth(slotType);
    maxHealth -= healthAmount;
    health = clampInt(health - healthAmount, 1, maxHealth);
    final magicAmount = SlotType.getMagic(slotType);
    maxMagic -= magicAmount;
    magic = clampInt(magic - magicAmount, 1, maxMagic);
  }

  void writePlayerGame() {
    writeByte(ServerResponse.Player);
    writeInt(x);
    writeInt(y);
    writeInt(z);
    writeInt(angle * 100);
    writeInt(mouseAngle * 100);
    writeInt(health); // 2
    writeInt(maxHealth); // 2
    writeInt(magic); // 2
    writeInt(maxMagic); // 2
    writeByte(equippedWeapon.type);
    writeByte(equippedWeapon.damage);
    writeByte(equippedArmour); // armour
    writeByte(equippedHead); // helm
    writeByte(equippedPants); // helm
    writeBool(alive); // 1
    writeBool(storeVisible); // 1
    writeInt(wood);
    writeInt(stone);
    writeInt(gold);
    writePercentage(experiencePercentage);
    writeByte(level);
    writeByte(skillPoints);
    // writeStructures();
    writeCollectables();
    writePlayers();
    writeAttackTarget();
    writeProjectiles();
    writeNpcs(this);

    writePlayerTarget();

    writeGameTime(game);
    writePlayerZombies();

    if (!sceneDownloaded){
      writeGrid();
      writeGameObjects();
      writeTechTypes();
      writeGameStatus();
      sceneDownloaded = true;
    }

    if (debug)
      writePaths();
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

  void writeAttackTarget(){
    if (aimTarget == null){
      writeByte(ServerResponse.Player_Attack_Target_None);
      return;
    }
    writeByte(ServerResponse.Player_Attack_Target);
    writePosition(aimTarget!);
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


  void writePlayerZombies() {
    writeByte(ServerResponse.Zombies);
    final zombies = game.zombies;
    final length = zombies.length;
    for (var i = 0; i < length; i++){
      final zombie = zombies[i];
      if (zombie.dead) continue;
      // if (zombie.y < screenTop) continue;
      // if (zombie.x < screenLeft) continue;
      // if (zombie.x > screenRight) continue;
      // if (zombie.y > screenBottom) {
      //   writeByte(END);
      //   return;
      // }
      writeCharacter(this, zombie);
    }
    writeByte(END);
  }

  void writeTechTypes() {
    writeByte(ServerResponse.Tech_Types);
    writeByte(techTree.pickaxe);
    writeByte(techTree.sword);
    writeByte(techTree.bow);
    writeByte(techTree.axe);
    writeByte(techTree.hammer);
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
    final npcs = player.game.npcs;
    writeByte(ServerResponse.Npcs);
    writeTotalAlive(npcs);
    for(final npc in npcs) {
      writeNpc(player, npc);
    }
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
}

int getExperienceForLevel(int level){
  return (((level -1) * (level - 1))) * 100;
}

