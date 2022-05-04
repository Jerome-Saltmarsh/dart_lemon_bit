import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:lemon_math/library.dart';

import '../byte_writer.dart';
import '../common/library.dart';
import '../engine.dart';
import '../functions/generateName.dart';
import '../utilities.dart';
import 'Character.dart';
import 'Collider.dart';
import 'DynamicObject.dart';
import 'Game.dart';
import 'Scene.dart';

class Player extends Character with ByteWriter {
  final mouse = Vector2(0, 0);
  final runTarget = Vector2(0, 0);
  var score = 0;
  var sceneChanged = false;
  var characterState = CharacterState.Idle;
  var lastUpdateFrame = 0;
  var pointsRecord = 0;
  var textDuration = 0;
  var experience = 0;
  var level = 1;
  var abilityPoints = 0;
  var _magic = 0;
  var maxMagic = 100;
  var magicRegen = 1;
  var healthRegen = 1;
  var message = "";
  var text = "";
  var name = generateName();
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
  Position? target;
  Account? account;

  late Function sendBufferToClient;
  late Function(GameError error, {String message}) dispatchError;

  double get mouseAngle => this.getAngle(mouse);

  Scene get scene => game.scene;

  int get magic => _magic;

  double get magicPercentage {
    if (_magic == 0) return 0;
    if (maxMagic == 0) return 0;
    return _magic / maxMagic;
  }

  set magic(int value){
    _magic = clampInt(value, 0, maxMagic);
  }

  Player({
    required this.game,
    required int weapon,
    double x = 0,
    double y = 0,
    int team = 0,
    int magic = 10,
    int health = 10,
  }) : super(
            type: CharacterType.Human,
            x: x,
            y: y,
            health: health,
            speed: 3.5,
            team: team,
            weapon: weapon,

  ){
    maxMagic = magic;
    _magic = maxMagic;
    engine.onPlayerCreated(this);
  }

  void equipPickaxe(){
    equipped = TechType.Pickaxe;
    setStateChanging();
  }

  void equipAxe(){
    equipped = TechType.Axe;
    setStateChanging();
  }

  void equipUnarmed(){
    equipped = TechType.Unarmed;
    setStateChanging();
  }

  void setStateChanging(){
    writePlayerEvent(PlayerEvent.Item_Equipped);
    game.setCharacterState(this, CharacterState.Changing);
  }

  // void useSlot(Slots slots, int index) {
  //     if (deadOrBusy) return;
  //     if (index < 0) return;
  //     if (index > 6) return;
  //
  //     final slot = slots.getSlotAtIndex(index);
  //     if (slot.isEmpty) return;
  //     final slotType = slot.type;
  //
  //     if (SlotType.isWeapon(slotType)) {
  //       final currentWeapon = slots.weapon;
  //       slots.weapon = slot;
  //       slots.assignSlotAtIndex(index, currentWeapon);
  //       onSlotsChanged();
  //       setStateChangingWeapons();
  //       return;
  //     }
  //
  //     if (SlotType.isArmour(slotType)) {
  //       final currentArmourType = slots.armour.type;
  //       slots.armour.swapWith(slot);
  //       onEquipped(slotType);
  //       onUnequipped(currentArmourType);
  //       setStateChangingWeapons();
  //       onSlotsChanged();
  //     }
  //
  //     if (SlotType.isHelm(slotType)) {
  //       final currentArmourType = slots.helm.type;
  //       slots.helm.swapWith(slot);
  //       onEquipped(slotType);
  //       onUnequipped(currentArmourType);
  //       setStateChangingWeapons();
  //       onSlotsChanged();
  //     }
  //
  //     if (slotType == SlotType.Spell_Tome_Fireball) {
  //       final cost = 5;
  //       if (magic < cost) return;
  //       ability = Ability(type: AbilityType.Fireball,
  //           level: 1,
  //           cost: cost,
  //           range: 250,
  //           cooldown: 100,
  //           mode: AbilityMode.Targeted);
  //       return;
  //     }
  //
  //     // if (slotType == SlotType.Spell_Tome_Ice_Ring) {
  //     //   final cost = 5;
  //     //   if (magic < cost) return;
  //     //   magic -= cost;
  //     //   if (!SlotType.isStaff(weapon)) {
  //     //     final index = slots.getSlotIndexWhere(SlotType.isStaff);
  //     //     if (index == null) return;
  //     //     useSlot(index);
  //     //   }
  //     //   game.spawnFreezeRing(src: this);
  //     //   setStateChangingWeapons();
  //     //   onSlotsChanged();
  //     //   return;
  //     // }
  //
  //     // if (slotType == SlotType.Spell_Tome_Split_Arrow) {
  //     //   final cost = 5;
  //     //   if (magic < cost) return;
  //     //   if (!SlotType.isBow(weapon)){
  //     //      final bowIndex = slots.getSlotIndexWhere(SlotType.isBow);
  //     //      if (bowIndex == null) return;
  //     //      useSlot(bowIndex);
  //     //   }
  //     //
  //     //   ability = Ability(type: AbilityType.Split_Arrow,
  //     //       level: 1,
  //     //       cost: cost,
  //     //       range: 250,
  //     //       cooldown: 100,
  //     //       mode: AbilityMode.Directed);
  //     //   return;
  //     // }
  //
  //     if (slotType == SlotType.Potion_Red) {
  //       health = maxHealth;
  //       slots.assignSlotTypeAtIndex(index, SlotType.Empty);
  //       setStateChangingWeapons();
  //       onPlayerEvent(PlayerEvent.Drink_Potion);
  //       onSlotsChanged();
  //     }
  //
  //     if (slotType == SlotType.Potion_Blue) {
  //       magic = maxMagic;
  //       slots.assignSlotTypeAtIndex(index, SlotType.Empty);
  //       setStateChangingWeapons();
  //       onPlayerEvent(PlayerEvent.Drink_Potion);
  //       onSlotsChanged();
  //     }
  // }
  //
  // void sellSlot(Slots slots, int index){
  //   final slotAtIndex = slots.getSlotTypeAtIndex(index);
  //   if (slotAtIndex == SlotType.Empty) return;
  //   slots.assignSlotTypeAtIndex(index, SlotType.Empty);
  //   onPlayerEvent(PlayerEvent.Item_Sold);
  //   onSlotsChanged();
  // }
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

  bool get unarmed => equipped == TechType.Unarmed;

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
    writeInt(health); // 2
    writeInt(maxHealth); // 2
    writeInt(magic); // 2
    writeInt(maxMagic); // 2
    writeByte(equipped); // 3
    writeByte(SlotType.Empty); // armour
    writeByte(SlotType.Empty); // helm
    writeBool(alive); // 1
    writeBool(storeVisible); // 1
    writeInt(wood);
    writeInt(stone);
    writeInt(gold);
    writeStructures();
    writeCollectables();
    writePlayers();
    writeAttackTarget();
    writeProjectiles();
    writeNpcs(this);
    writeGameTime(game);
    writePlayerZombies();

    if (!sceneDownloaded){
      writeTiles();
      writeDynamicObjects();
      writeStaticObjects();
      writeTechTypes();
      sceneDownloaded = true;
    }

    if (game.debugMode)
      writePaths(game);
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
      if (sameTeam(otherPlayer, this)){
        writeString(otherPlayer.text);
      } else {
        writeInt(0);
      }
    }
    writeByte(END);
  }


  void writeStructures() {
    writeByte(ServerResponse.Structures);
    final structures = game.structures;
    for (final structure in structures){
      if (structure.dead) continue;
      writeByte(structure.type);
      writePosition(structure);
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
    final lengthMinusOne = length - 1;

    if (length == 0) {
      writeByte(END);
      return;
    }
    var start = 0;
    for (start = 0; start < lengthMinusOne; start++){
      final zombieY = zombies[start].y;
      if (zombieY > screenTop) {
        if (zombieY > screenBottom){
          writeByte(END);
          return;
        }
        break;
      }
    }

    var end = start;
    for (end = start; end < lengthMinusOne; end++) {
      if (zombies[end].y > screenBottom) break;
    }

    for(var i = start; i <= end; i++){
      final zombie = zombies[i];
      if (zombie.dead) continue;
      if (zombie.x < screenLeft) continue;
      if (zombie.x > screenRight) continue;
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

  void writeStaticObjects() {
    writeByte(ServerResponse.EnvironmentObjects);
    final staticObjects = scene.staticObjects;
    for (final value in staticObjects) {
       if (dynamicObjectTypes.contains(value)) continue;
       writeByte(value.type.index);
       writePosition(value);
    }
    writeByte(END);
  }

  void writeDynamicObjects() {
    writeByte(ServerResponse.Dynamic_Objects);
    final dynamicObjects = scene.dynamicObjects;
    for (final dynamicObject in dynamicObjects) {
      writeByte(dynamicObject.type);
      writePosition(dynamicObject);
      writeInt(dynamicObject.id);
    }
    writeByte(END);
  }

  void writeTiles() {
    final tiles = scene.tiles;
    final rows = scene.rows;
    final columns = scene.columns;
    writeByte(ServerResponse.Tiles);
    writeInt(rows);
    writeInt(columns);
    for (var x = 0; x < rows; x++) {
      for (var y = 0; y < columns; y++) {
        writeByte(tiles[x][y]);
      }
    }
  }

  void writeGameEvent(int type, double x, double y, double angle){
    writeByte(ServerResponse.Game_Events);
    writeByte(type);
    writeInt(x);
    writeInt(y);
    writeInt(angle * radiansToDegrees);
  }

  void writeDynamicObjectDestroyed(DynamicObject dynamicObject){
    writeByte(ServerResponse.Dynamic_Object_Destroyed);
    writeInt(dynamicObject.id);
  }
}
