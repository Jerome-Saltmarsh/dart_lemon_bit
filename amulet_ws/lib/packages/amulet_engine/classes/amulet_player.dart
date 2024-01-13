
import 'dart:math';

import 'package:amulet_engine/classes/amulet_fiend.dart';

import '../packages/isomeric_engine.dart';
import '../mixins/src.dart';
import '../packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';
import '../json/src.dart';
import '../packages/isometric_engine/packages/common/src/amulet/quests/quest_tutorials.dart';
import 'amulet.dart';
import 'amulet_game.dart';
import 'amulet_item_slot.dart';
import 'amulet_npc.dart';
import 'games/amulet_game_tutorial.dart';
import 'talk_option.dart';

class AmuletPlayer extends IsometricPlayer with
    Equipment,
    Elemental,
    Experience,
    Level,
    ElementPoints
{

  static const healthBase = 10;

  var activePowerX = 0.0;
  var activePowerY = 0.0;
  var activePowerZ = 0.0;

  var admin = false;
  var previousCameraTarget = false;
  Position? cameraTarget;
  AmuletGame amuletGame;
  var equipmentDirty = true;

  var npcText = '';
  var npcName = '';
  var npcOptions = <TalkOption>[];
  Function? onInteractionOver;

  final weaponUnarmed = AmuletItemSlot();
  final weapons = List<AmuletItemSlot>.generate(4, (index) => AmuletItemSlot());
  final treasures = List<AmuletItemSlot>.generate(4, (index) => AmuletItemSlot());

  late List<AmuletItemSlot> items;

  var _inventoryOpen = false;
  SlotType? activeSlotType;

  AmuletPlayer({
    required this.amuletGame,
    required int itemLength,
    required super.x,
    required super.y,
    required super.z,
  }) : super(game: amuletGame, health: 10, team: AmuletTeam.Human) {
    respawnDurationTotal = -1;
    controlsCanTargetEnemies = true;
    characterType = CharacterType.Human;
    hurtable = false;
    hurtStateBusy = false;
    regainFullHealth();
    // equippedWeaponIndex = 0;
    active = false;
    equipmentDirty = true;
    spawnLootOnDeath = false;
    setItemsLength(itemLength);
    setControlsEnabled(true);
    writeWorldMapBytes();
    writeWorldMapLocations();
    writeAmuletElements();
    writeElementPoints();
    writeWeapons();
    writeTreasures();
    writeInteracting();
    writePlayerLevel();
    writePlayerExperience();
    writeGender();
    writePlayerComplexion();
  }

  QuestMain get questMain {
    final questMainIndex = data.tryGetInt('quest_main') ?? 0;
    return QuestMain.values[questMainIndex];
  }

  AmuletItemSlot? get activeAmuletItemSlot {
     switch (activeSlotType){
       case SlotType.Helm:
         return equippedHelm;
       case SlotType.Body:
         return equippedBody;
       case SlotType.Shoes:
         return equippedShoe;
       case SlotType.Legs:
         return equippedLegs;
       case SlotType.Hand_Left:
         return equippedHandLeft;
       case SlotType.Hand_Right:
         return equippedHandRight;
       default:
         return null;
     }
  }

  set questMain (QuestMain value){
    data.setInt('quest_main', value.index);
    writeQuestMain(value);
  }

  @override
  set aimTarget(Collider? value) {
    if (
    noWeaponEquipped &&
        value is GameObject &&
        value.hitable
    ){
      return;
    }
    super.aimTarget = value;
  }

  bool get noWeaponEquipped => equippedWeapon.amuletItem == null;

  @override
  set elementAir(int value){
    super.elementAir = value;
    writeAmuletElements();
  }

  @override
  set elementFire(int value) {
    super.elementFire = value;
    writeAmuletElements();
  }

  @override
  set elementWater(int value) {
    super.elementWater = value;
    writeAmuletElements();
  }

  Amulet get amulet => amuletGame.amulet;

  @override
  set elementPoints(int value) {
    super.elementPoints = value;
    writeElementPoints();
  }

  @override
  int get weaponType {
    final weapon = equippedWeapon;
    final item = weapon.amuletItem;
    return item?.subType ?? WeaponType.Unarmed;
  }

  int get experienceRequired => (level * level * 2) + (level * 10);

  bool get inventoryOpen => _inventoryOpen;

  // int get equippedWeaponLevel {
  //   final weapon = itemSlotWeapon;
  //   final item = weapon.amuletItem;
  //
  //   if (item == null){
  //     throw Exception('item == null');
  //   }
  //
  //   return getLevelForAmuletItem(item);
  // }

  @override
  int get weaponCooldown => equippedWeapon.cooldown;

  @override
  int get weaponDamage {

    final amuletItem = equippedWeapon.amuletItem;

    if (amuletItem == null) {
      return 0;
    }

    final damageMin = amuletItem.damageMin;
    final damageMax = amuletItem.damageMax;

    if (damageMin == null){
      throw Exception('${amuletItem.name} damageMin is null');
    }
    if (damageMax == null){
      throw Exception('${amuletItem.name} damageMax is null');
    }

    return randomInt(damageMin, damageMax + 1);
  }

  @override
  double get weaponRange => (activeAmuletItemSlot ?? equippedWeapon).amuletItem?.range ?? 0;

  @override
  int get helmType => equippedHelm.amuletItem?.subType ?? HelmType.None;

  @override
  int get maxHealth {
    var health = healthBase;
    // health += getAmuletItemStatsForItemSlot(equippedHandLeft)?.health ?? 0;
    // health += getAmuletItemStatsForItemSlot(equippedHandRight)?.health ?? 0;
    // health += getAmuletItemStatsForItemSlot(equippedHelm)?.health ?? 0;
    // health += getAmuletItemStatsForItemSlot(equippedBody)?.health ?? 0;
    // health += getAmuletItemStatsForItemSlot(equippedLegs)?.health ?? 0;
    return health;
  }

  @override
  double get runSpeed {
    var base = 1.0;
    // base += getAmuletItemStatsForItemSlot(equippedHandLeft)?.movement ?? 0;
    // base += getAmuletItemStatsForItemSlot(equippedHandRight)?.movement ?? 0;
    // base += getAmuletItemStatsForItemSlot(equippedHelm)?.movement ?? 0;
    // base += getAmuletItemStatsForItemSlot(equippedBody)?.movement ?? 0;
    // base += getAmuletItemStatsForItemSlot(equippedLegs)?.movement ?? 0;
    return base;
  }

  @override
  set experience(int value){
    if (value < 0){
      value = 0;
    }
    super.experience = value;
    writePlayerExperience();
  }

  @override
  set level(int value) {
    super.level = value;
    writePlayerLevel();
  }

  set inventoryOpen(bool value){
    _inventoryOpen = value;
    writePlayerInventoryOpen();
    amuletGame.onPlayerInventoryOpenChanged(this, value);
  }

  @override
  set target(Position? value){
    if (super.target == value) {
      return;
    }

    if (interacting) {
      endInteraction();
    }
    super.target = value;
  }

  set interacting(bool value){
    if (super.interacting == value) {
      return;
    }
    super.interacting = value;

    if (!value){
      onInteractionOver?.call();
      onInteractionOver = null;
      cameraTarget = null;
    }

    writeInteracting();
  }

  set tutorialObjective(QuestTutorial tutorialObjective){
    data['tutorial_objective'] = tutorialObjective.name;
  }

  QuestTutorial get tutorialObjective {
    final index = data['tutorial_objective'];

    if (index == null) {
      return QuestTutorial.values.first;
    }

    if (index is int) {
      return QuestTutorial.values[index];
    }

    if (index is String) {
      for (final objective in QuestTutorial.values) {
        if (objective.name == index) {
          return objective;
        }
      }
      throw Exception('could not find objective $name');
    }

    throw Exception();
  }

  // @override
  // set equippedWeaponIndex(int value){
  //   if (equippedWeaponIndex == value){
  //     return;
  //   }
  //
  //   if (controlsCanTargetEnemies){
  //     setCharacterStateChanging();
  //   }
  //
  //   if (value == -1){
  //     super.equippedWeaponIndex = value;
  //     weaponType = equippedWeaponType;
  //     writeEquippedWeaponIndex();
  //     return;
  //   }
  //   if (!isValidWeaponIndex(value)){
  //     return;
  //   }
  //   final weapon = weapons[value];
  //
  //   final item = weapon.amuletItem;
  //
  //   if (item == null || item.type != ItemType.Weapon){
  //     return;
  //   }
  //
  //   super.equippedWeaponIndex = value;
  //   weaponType = equippedWeaponType;
  //   game.dispatchGameEvent(
  //       GameEvent.Weapon_Type_Equipped,
  //       x,
  //       y,
  //       z,
  //   );
  //   game.dispatchByte(weaponType);
  //
  //   writeEquippedWeaponIndex();
  // }

  // @override
  // void initialize() {
  //   super.initialize();
  //   writeEquippedWeaponIndex();
  // }

  @override
  void writePlayerGame() {
    cleanEquipment();
    writeCameraTarget();
    // writeDebug();
    super.writePlayerGame();
  }

  void writeDebug() {
    if (!debugging) return;

    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Debug);
    var total = 0;
    final characters = game.characters;
    for (final character in characters) {
      if (character is AmuletPlayer && onScreenPosition(character)) {
        total++;
      }
    }
    writeUInt16(total);

    for (final character in characters) {
      if (character is AmuletPlayer && onScreenPosition(character)) {
         writeIsometricPosition(character);
         writeString(character.name);
      }
    }

  }

  void setItemsLength(int value){
    items = List.generate(value, (index) => AmuletItemSlot());
    writeItemLength(value);
  }

  void addItemToEmptyWeaponSlot(AmuletItem item) {
    final emptyIndex = getEmptyWeaponIndex();
    if (emptyIndex == -1) {
      reportInventoryFull();
      return;
    }
    setWeapon(
      index: emptyIndex,
      amuletItem: item,
      cooldown: 0,
    );
  }


  bool acquireAmuletItem(AmuletItem amuletItem){

    if (deadOrBusy) {
      return false;
    }

    setDestinationToCurrentPosition();
    clearPath();

    if (amuletItem.isWeapon || amuletItem.isSpell){
      if (equippedWeapon.amuletItem == null) {
        equipWeapon(amuletItem);
        // availableWeaponSlot.amuletItem = amuletItem;
        // refillItemSlot(availableWeaponSlot);
        // amuletGame.onAmuletItemAcquired(this, amuletItem);
        // notifyEquipmentDirty();
        return true;
      }
    }

    final emptyItemSlot = tryGetEmptyItemSlot();
    if (emptyItemSlot == null) {
      reportInventoryFull();
      return false;
    }

    emptyItemSlot.amuletItem = amuletItem;
    emptyItemSlot.cooldown = 0;
    amuletGame.onAmuletItemAcquired(this, amuletItem);
    notifyEquipmentDirty();
    return true;
  }

  int getEmptyItemIndex()=> getEmptyIndex(items);

  int getEmptyWeaponIndex() => getEmptyIndex(weapons);

  int getEmptyIndexTreasure() => getEmptyIndex(treasures);

  void setWeapon({
    required int index,
    required AmuletItem? amuletItem,
    int cooldown = 0,
  }){

    if (!isValidWeaponIndex(index)) {
      writeAmuletError('Invalid weapon index $index');
      return;
    }

    if (amuletItem != null && !amuletItem.isWeapon && !amuletItem.isSpell){
      return;
    }

    weapons[index].amuletItem = amuletItem;
    weapons[index].cooldown = cooldown;
    writePlayerWeapon(index);
  }

  void setTreasure({required int index, required AmuletItem? item}){
    if (deadOrBusy) {
      return;
    }

    if (!isValidIndexTreasure(index)) {
      writeAmuletError('Invalid treasure index $index');
      return;
    }
    if (item != null && !item.isTreasure) {
      return;
    }

    treasures[index].amuletItem = item;
    writePlayerTreasure(index);
    notifyEquipmentDirty();
  }

  void setItem({
    required int index,
    required AmuletItem? item,
    required int cooldown,
  }){
    if (!isValidItemIndex(index)) {
      writeAmuletError('Invalid item index $index');
      return;
    }
    final slot = items[index];
    slot.amuletItem = item;
    slot.cooldown = cooldown;
    notifyEquipmentDirty();
    setCharacterStateChanging();
  }

  @override
  int getTargetAction(Position? value){
    if (value == null) {
      return TargetAction.Run;
    }
    if (value is GameObject) {
      if (value.interactable) {
        return TargetAction.Talk;
      }
      if (value.collectable) {
        return TargetAction.Collect;
      }
      return TargetAction.Run;
    }

    if (isAlly(value)) {
      if (value is AmuletNpc && value.interact != null) {
        return TargetAction.Talk;
      }
    }
    if (isEnemy(value)) {
      return TargetAction.Attack;
    }
    return TargetAction.Run;
  }

  void talk(
      Collider speaker,
      String text, {
        List<TalkOption>? options,
        Function? onInteractionOver,
      }) {

    cameraTarget = speaker;
    this.onInteractionOver = onInteractionOver;

    if (text.isNotEmpty){
      interacting = true;
    }
     npcText = text;
     npcName = speaker.name;
     if (options != null){
       this.npcOptions = options;
     } else {
       this.npcOptions.clear();
     }
     writeNpcTalk();
  }

  void endInteraction() {
    if (!interacting) return;
    interacting = false;
    npcName = '';
    npcText = '';
    npcOptions.clear();
    writeByte(NetworkResponse.Amulet_Player);
    writeByte(NetworkResponseAmuletPlayer.End_Interaction);
    clearTarget();
  }

  void dropTreasure(int index){
    if (!isValidIndexTreasure(index)) {
      return;
    }
    final item = treasures[index].amuletItem;
    if (item == null) {
      return;
    }

    clearTreasure(index);
    spawnAmuletItem(item);
  }

  void spawnAmuletItem(AmuletItem item){
    const spawnDistance = 40.0;
    final spawnAngle = randomAngle();
    amuletGame.spawnAmuletItem(
      x: x + adj(spawnAngle, spawnDistance),
      y: y + opp(spawnAngle, spawnDistance),
      z: z,
      item: item,
    );
  }

  void clearWeapon(int index) => setWeapon(
      index: index,
      amuletItem: null,
      cooldown: 0,
  );

  void clearTreasure(int index) => setTreasure(index: index, item: null);

  void clearItem(int index) => setItem(
      index: index,
      item: null,
      cooldown: 0,
  );

  bool isValidWeaponIndex(int index) => index >= 0 && index < weapons.length;

  bool isValidItemIndex(int index) => index >= 0 && index < items.length;

  bool isValidIndexTreasure(int index) => index >= 0 && index < treasures.length;

  void deactivateSlotType() => setActiveSlotType(null);

  void setActiveSlotType(SlotType? value) {
    activeSlotType = value;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Active_Slot_Type);
    if (value == null) {
      writeFalse();
      return;
    }
    writeTrue();
    writeByte(value.index);
  }

  void selectItem(int index) {
    if (deadOrBusy) {
      return;
    }

    if (!isValidItemIndex(index)) {
      return;
    }

    final itemSlot = items[index];
    final amuletItem = itemSlot.amuletItem;

    if (amuletItem == null) {
      return;
    }

    // final itemType = item.type;
    // final subType = item.subType;

    // if (item.isTreasure) {
    //   addToEmptyTreasureSlot(selected);
    //   return;
    // }

    // if (itemType == ItemType.Consumable){
    //   if (subType == ConsumableType.){
    //     regainFullHealth();
    //     setCharacterStateChanging();
    //     clearItem(index);
    //     writePlayerEvent(PlayerEvent.Drink);
    //   }
    //   return;
    // }

    switch (amuletItem.type) {
      case ItemType.Treasure:
        addToEmptyTreasureSlot(itemSlot);
        break;
      case ItemType.Consumable:
        throw Exception('not implemented');
      case ItemType.Weapon:
        swapAmuletItemSlots(itemSlot, equippedWeapon);
        break;
      case ItemType.Helm:
        swapAmuletItemSlots(equippedHelm, itemSlot);
        break;
      case ItemType.Body:
        swapAmuletItemSlots(equippedBody, itemSlot);
        break;
      case ItemType.Legs:
        swapAmuletItemSlots(equippedLegs, itemSlot);
        break;
      case ItemType.Hand:
        if (equippedHandLeft.amuletItem == null){
          swapAmuletItemSlots(equippedHandLeft, itemSlot);
        } else {
          swapAmuletItemSlots(equippedHandRight, itemSlot);
        }
        break;
    }
  }

  void selectTreasure(int index) {
    if (!isValidIndexTreasure(index)) {
      return;
    }
    swapWithAvailableItemSlot(treasures[index]);
  }

  void selectNpcTalkOption(int index) {
     if (index < 0 || index >= npcOptions.length){
       writeAmuletError('Invalid talk option index $index');
       return;
     }
     npcOptions[index].action(this);
  }

  void equipWeapon(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedWeapon.amuletItem == item){
      return;
    }

    if (item == null){
      clearSlot(equippedWeapon);
      return;
    }

    if (!item.isWeapon) {
      throw Exception();
    }

    setSlot(
      slot: equippedWeapon,
      item: item,
      cooldown: 0,
    );
  }

  void equipHelm(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedHelm.amuletItem == item){
      return;
    }

    if (item == null){
      clearSlot(equippedHelm);
      return;
    }

    if (!item.isHelm) {
      throw Exception();
    }

    setSlot(
      slot: equippedHelm,
      item: item,
      cooldown: 0,
    );
  }

  void equipBody(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedBody == item) {
      return;
    }

    if (item == null){
      clearSlot(equippedBody);
      bodyType = 0;
      return;
    }

    if (!item.isBody){
      throw Exception();
    }

    setSlot(
      slot: equippedBody,
      item: item,
      cooldown: 0,
    );

    bodyType = item.subType;
  }

  void equipLegs(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedLegs.amuletItem == item) {
      return;
    }

    if (item == null){
      clearSlot(equippedLegs);
      legsType = LegType.None;
      return;
    }

    if (!item.isLegs) {
      throw Exception();
    }

    setSlot(
        slot: equippedLegs,
        item: item,
        cooldown: 0,
    );
    legsType = item.subType;
  }

  void equipHandLeft(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedHandLeft.amuletItem == item) {
      return;
    }

    if (item == null){
      clearSlot(equippedHandLeft);
      handTypeLeft = HandType.None;
      return;
    }

    if (!item.isHand) {
      throw Exception();
    }

    setSlot(
      slot: equippedHandLeft,
      item: item,
      cooldown: 0,
    );

    handTypeLeft = item.subType;
  }

  void equipHandRight(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedHandRight.amuletItem == item) {
      return;
    }

    if (item == null){
      clearSlot(equippedHandRight);
      handTypeRight = HandType.None;
      return;
    }

    if (!item.isHand) {
      throw Exception();
    }

    setSlot(
      slot: equippedHandRight,
      item: item,
      cooldown: 0,
    );

    handTypeRight = item.subType;
  }

  void equipShoes(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedShoe.amuletItem == item) {
      return;
    }

    if (item == null){
      clearSlot(equippedShoe);
      shoeType = ShoeType.None;
      return;
    }

    if (!item.isShoes) {
      throw Exception();
    }

    setSlot(
      slot: equippedShoe,
      item: item,
      cooldown: 0,
    );

    shoeType = item.subType;
  }

  // void pickupItem(AmuletItem item) {
  //
  //   final stats = getAmuletItemLevel(item);
  //
  //   if (stats == null){
  //     return;
  //   }
  //
  //   if (stats.health > 0){
  //     health += stats.health;
  //     writePlayerEvent(PlayerEvent.Eat);
  //   }
  // }

  void cleanEquipment(){
    if (!equipmentDirty) {
      return;
    }

    // assert (equippedHelm.amuletItem?.isHelm ?? true);
    // assert (equippedBody.amuletItem?.isBody ?? true);
    // assert (equippedLegs.amuletItem?.isLegs ?? true);
    // assert (equippedWeapon?.amuletItem?.isWeapon ?? true);
    // assert (equippedShoe.amuletItem?.isShoes ?? true);

    health = clamp(health, 0, maxHealth);
    weaponType = equippedWeapon.amuletItem?.subType ?? WeaponType.Unarmed;
    equipmentDirty = false;
    helmType = equippedHelm.amuletItem?.subType ?? HelmType.None;
    bodyType = equippedBody.amuletItem?.subType ?? 0;
    legsType = equippedLegs.amuletItem?.subType ?? LegType.None;
    handTypeLeft = equippedHandLeft.amuletItem?.subType ?? HandType.None;
    handTypeRight = equippedHandRight.amuletItem?.subType ?? HandType.None;
    shoeType = equippedShoe.amuletItem?.subType ?? HandType.None;

    // if (itemSlotWeapon.amuletItem?.selectAction != AmuletItemAction.Equip){
    //    equippedWeaponIndex = -1;
    // }

    writeEquipped();
    writePlayerHealth();
    writeWeapons();
    writeItems();
    writeTreasures();
  }

  void writeItems() {
     for (var i = 0; i < items.length; i++){
       writePlayerItem(i, items[i].amuletItem);
     }
  }

  void writeEquipped(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Equipped);
    writeAmuletItem(equippedWeapon.amuletItem);
    writeAmuletItem(equippedHelm.amuletItem);
    writeAmuletItem(equippedBody.amuletItem);
    writeAmuletItem(equippedLegs.amuletItem);
    writeAmuletItem(equippedHandLeft.amuletItem);
    writeAmuletItem(equippedHandRight.amuletItem);
    writeAmuletItem(equippedShoe.amuletItem);
  }

  void writeAmuletItem(AmuletItem? value){
    if (value == null){
      writeInt16(-1);
    } else{
      writeInt16(value.index);
    }
  }

  void writeWeapons() {
    final length = weapons.length;
    for (var i = 0; i < length; i++){
      writePlayerWeapon(i);
    }
  }

  void writeTreasures() {
    final length = treasures.length;
    for (var i = 0; i < length; i++){
      writePlayerTreasure(i);
    }
  }

  void writeInteracting() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Interacting);
    writeBool(interacting);
  }

  // void writeEquippedWeaponIndex() {
  //   writeByte(NetworkResponse.Amulet);
  //   writeByte(NetworkResponseAmulet.Player_Equipped_Weapon_Index);
  //   writeInt16(equippedWeaponIndex);
  // }

  void writePlayerWeapon(int index) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Weapon);
    writeUInt16(index);
    final slot = weapons[index];
    final weapon = slot.amuletItem;
    if (weapon == null){
      writeInt16(-1);
      return;
    }
    writeInt16(weapon.index);
    writePercentage(slot.cooldownPercentage);
    writeUInt16(slot.charges);
    writeUInt16(slot.max);
  }

  void writePlayerTreasure(int index) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Treasure);
    writeUInt16(index);
    final treasure = treasures[index].amuletItem;
    if (treasure == null){
      writeInt16(-1);
      return;
    }
    writeInt16(treasure.index);
  }

  void writePlayerItem(int index, AmuletItem? item) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Item);
    writeUInt16(index);
    if (item == null){
      writeInt16(-1);
      return;
    }
    writeInt16(item.index);
  }

  void writeNpcTalk() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Npc_Talk);
    writeString(npcName);
    writeString(npcText);
    writeByte(npcOptions.length);
    for (final option in npcOptions) {
      writeString(option.text);
    }
  }

  void writeItemLength(int value) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Item_Length);
    writeUInt16(value);
  }

  void writePlayerExperience() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Experience);
    writeUInt24(experience);
    writeUInt24(experienceRequired);
  }

  void writePlayerLevel() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Level);
    writeByte(level);
  }

  void writePlayerInventoryOpen() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Inventory_Open);
    writeBool(inventoryOpen);
  }

  static AmuletItemSlot getEmptySlot(List<AmuletItemSlot> items) =>
      tryGetEmptySlot(items) ??
          (throw Exception('AmuletPlayer.getEmptySlot($items)'));

  static AmuletItemSlot? tryGetEmptySlot(List<AmuletItemSlot> items){
    for (final item in items) {
      if (item.amuletItem == null) {
        return item;
      }
    }
    return null;
  }

  static int getEmptyIndex(List<AmuletItemSlot> items){
    for (var i = 0; i < items.length; i++){
      if (items[i].amuletItem == null) {
        return i;
      }
    }
    return -1;
  }

  @override
  void setCharacterStateChanging({int duration = 15}) {
    super.setCharacterStateChanging(duration: duration);
    writePlayerEvent(PlayerEvent.Character_State_Changing);
  }

  void toggleInventoryOpen() {
    inventoryOpen = !inventoryOpen;
    setCharacterStateChanging();
  }

  void assignWeaponTypeToEquippedWeapon() =>
      weaponType = equippedWeapon.amuletItem?.subType ?? WeaponType.Unarmed;

  void unequipHead() =>
      swapWithAvailableItemSlot(equippedHelm);

  void unequipBody() => swapWithAvailableItemSlot(equippedBody);

  void unequipLegs() => swapWithAvailableItemSlot(equippedLegs);

  void unequipHandLeft() => swapWithAvailableItemSlot(equippedHandLeft);

  void unequipHandRight() => swapWithAvailableItemSlot(equippedHandRight);

  void reportInventoryFull() =>
      writeAmuletError('Inventory is full');

  @override
  void update() {
    super.update();
    updateActiveAbility();
  }


  void updateActiveAbility() {

    if (activeAmuletItemSlot == null){
      return;
    }


    final activeAmuletItem = activeAmuletItemSlot?.amuletItem;

    if (activeAmuletItem == null){
      return;
    }

    final skillType = activeAmuletItem.skillType;

    if (skillType == null){
      return;
    }

    if (skillType.casteType == CasteType.Positional) {
      final mouseDistance = getMouseDistance();
      final maxRange = activeAmuletItem.range ?? (throw Exception());
      if (mouseDistance <= maxRange){
        activePowerX = mouseSceneX;
        activePowerY = mouseSceneY;
        activePowerZ = mouseSceneZ;
      } else {
        final mouseAngle = getMouseAngle() + pi;
        activePowerX = x + adj(mouseAngle, maxRange);
        activePowerY = y + opp(mouseAngle, maxRange);
        activePowerZ = z;
      }
      writeActivePowerPosition();
    }
  }

  void writeActivePowerPosition() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Active_Power_Position);
    writeDouble(activePowerX);
    writeDouble(activePowerY);
    writeDouble(activePowerZ);
  }

  AmuletItem? getWeaponAtIndex(int index) =>
      isValidIndex(index, weapons) ? weapons[index].amuletItem : null;


  void addToEmptyTreasureSlot(AmuletItemSlot slot){
    final item = slot.amuletItem;

    if (item == null || !item.isTreasure) {
      throw Exception();
    }

    final emptyTreasureSlot = tryGetEmptySlot(treasures);
    if (emptyTreasureSlot == null){
      writeAmuletError("Treasure slots full");
      return;
    }
    swapAmuletItemSlots(slot, emptyTreasureSlot);
  }

  void swapWithAvailableItemSlot(AmuletItemSlot slot){
    if (slot.amuletItem == null) {
      return;
    }

    final availableItemSlot = tryGetEmptyItemSlot();
    if (availableItemSlot == null){
      reportInventoryFull();
      return;
    }
    swapAmuletItemSlots(availableItemSlot, slot);
  }

  AmuletItemSlot getEmptyItemSlot() => getEmptySlot(items);

  AmuletItemSlot? tryGetEmptyItemSlot() => tryGetEmptySlot(items);

  AmuletItemSlot? getEmptyTreasureSlot() => tryGetEmptySlot(treasures);

  AmuletItemSlot? getEmptyWeaponSlot() => tryGetEmptySlot(weapons);

  void clearSlot(AmuletItemSlot slot){
    slot.clear();
    notifyEquipmentDirty();
  }

  void setSlot({
    required AmuletItemSlot slot,
    required AmuletItem? item,
    required int cooldown,
  }) {
    slot.amuletItem = item;
    slot.cooldown = cooldown;
    notifyEquipmentDirty();
  }


  void notifyEquipmentDirty(){
    if (equipmentDirty) {
      return;
    }

    setCharacterStateChanging();
    equipmentDirty = true;
  }

  void updateItemSlots() {
    final length = equipped.length;
     for (var i = 0; i < length; i++) {
       final amuletItemSlot = equipped[i];
       if (amuletItemSlot.charges >= amuletItemSlot.max) {
         continue;
       }
       amuletItemSlot.incrementCooldown();
       writePlayerWeapon(i);
     }
  }

  @override
  void reportException(Object exception) {
    writeAmuletError(exception.toString());
  }

  void writeAmuletError(String error) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Error);
    writeString(error);
  }

  AmuletItemSlot getItemObjectAtSlotType(SlotType slotType, int index) =>
    switch (slotType) {
      SlotType.Weapon => equippedWeapon,
      SlotType.Hand_Left => equippedHandLeft,
      SlotType.Hand_Right => equippedHandRight,
      SlotType.Body => equippedBody,
      SlotType.Helm => equippedHelm,
      SlotType.Legs => equippedLegs,
      SlotType.Shoes => equippedShoe,
      SlotType.Item => items[index],
      SlotType.Treasure => treasures[index],
      SlotType.Weapons => weapons[index]
    };

  void dropItemSlotItem(AmuletItemSlot itemSlot){
    final amuletItem = itemSlot.amuletItem;

    if (amuletItem == null){
      return;
    }

    spawnAmuletItem(amuletItem);
    itemSlot.clear();
    notifyEquipmentDirty();
  }

  AmuletItemSlot getItemSlot(SlotType slotType, int index) =>
    switch (slotType) {
      SlotType.Item => items[index],
      SlotType.Weapon => equippedWeapon,
      SlotType.Helm => equippedHelm,
      SlotType.Body => equippedBody,
      SlotType.Legs => equippedLegs,
      SlotType.Hand_Left => equippedHandLeft,
      SlotType.Hand_Right => equippedHandRight,
      SlotType.Weapons => weapons[index],
      SlotType.Treasure => treasures[index],
      SlotType.Shoes => equippedShoe
    };

  void inventoryDropSlotType(SlotType slotType, int index) =>
      dropItemSlotItem(getItemSlot(slotType, index));

  void writeAmuletElements() {
    writeByte(NetworkResponse.Amulet_Player);
    writeByte(NetworkResponseAmuletPlayer.Elements);
    writeByte(elementFire);
    writeByte(elementWater);
    writeByte(elementAir);
  }

  void writeElementPoints() {
    writeByte(NetworkResponse.Amulet_Player);
    writeByte(NetworkResponseAmuletPlayer.Element_Points);
    writeUInt16(elementPoints);
  }

  void upgradeAmuletElement(AmuletElement amuletElement) {
    if (elementPoints <= 0){
      writeGameError(GameError.Insufficient_Element_Points);
      return;
    }
    elementPoints--;
    switch (amuletElement) {
      case AmuletElement.fire:
        elementFire++;
        break;
      case AmuletElement.water:
        elementWater++;
        break;
      case AmuletElement.air:
        elementAir++;
        break;
      case AmuletElement.stone:
        elementStone++;
        break;
    }
    writeAmuletElements();
    writeElementUpgraded();
    spawnConfettiAtPosition(this);
  }

  @override
  void clearAction() {
    super.clearAction();
    deactivateSlotType();
  }


  void writeMessage(String message){
    writeByte(NetworkResponse.Amulet_Player);
    writeByte(NetworkResponseAmuletPlayer.Message);
    writeString(message);
  }

  void setPosition({double? x, double? y, double? z}){
    if (x != null){
      this.x = x;
    }
    if (y != null){
      this.y = y;
    }
    if (z != null){
      this.z = z;
    }

    clearPath();
    setDestinationToCurrentPosition();
    writePlayerPositionAbsolute();
    writePlayerEvent(PlayerEvent.Player_Moved);
  }

  bool flagNotSet(String name) => !flagSet(name);

  bool flagSet(String name)=> data.containsKey(name);

  /// to run a piece of code only a single time
  /// the first time a flag name is entered it will return true
  /// however any time after that if the same flag name is entered
  /// the return will be false
  bool readOnce(String name){
    if (!data.containsKey(name)){
      data[name] = true;
      return true;
    }
    return false;
  }

  void refillItemSlotsWeapons(){
    refillItemSlots(weapons);
    equipped.forEach(refillItemSlot);
  }

  void refillItemSlots(List<AmuletItemSlot> itemSlots){

    for (final itemSlot in itemSlots) {
      refillItemSlot(itemSlot);
    }

    equipmentDirty = true;
  }

  int getInt(String name) {
    return data[name] as int;
  }

  void writeCameraTarget() {
    final cameraTarget = this.cameraTarget;

    if (cameraTarget == null && !previousCameraTarget){
      return;
    }

    writeByte(NetworkResponse.Amulet_Player);
    writeByte(NetworkResponseAmuletPlayer.Camera_Target);

    if (cameraTarget == null){
      previousCameraTarget = false;
      writeBool(false);
      return;
    }

    previousCameraTarget = true;
    writeBool(true);
    writePosition(cameraTarget);
  }

  bool objectiveCompleted(String name){
    var objectives = data['objectives'];

    if (objectives == null){
       return false;
    }

    if (objectives is! List){
      throw Exception('objectives is! List');
    }

    return objectives.contains(name);
  }

  SlotType getAmuletItemSlotType(AmuletItemSlot amuletItemSlot){
    if (amuletItemSlot == equippedWeapon){
      return SlotType.Weapon;
    }
    if (amuletItemSlot == equippedHandLeft){
      return SlotType.Hand_Left;
    }
    if (amuletItemSlot == equippedHandRight){
      return SlotType.Hand_Right;
    }
    if (amuletItemSlot == equippedHelm){
      return SlotType.Helm;
    }
    if (amuletItemSlot == equippedBody){
      return SlotType.Body;
    }
    if (amuletItemSlot == equippedLegs){
      return SlotType.Legs;
    }
    if (amuletItemSlot == equippedShoe){
      return SlotType.Shoes;
    }
    if (weapons.contains(amuletItemSlot)){
      return SlotType.Weapons;
    }
    if (items.contains(amuletItemSlot)){
      return SlotType.Item;
    }
    if (treasures.contains(amuletItemSlot)){
      return SlotType.Treasure;
    }
    throw Exception('amuletPlayer.getAmuletItemSlotType($amuletItemSlot)');
  }

  void swapAmuletItemSlots(
      AmuletItemSlot amuletItemSlotA,
      AmuletItemSlot amuletItemSlotB,
  ) {

    final aSlotType = getAmuletItemSlotType(amuletItemSlotA);
    final bSlotType = getAmuletItemSlotType(amuletItemSlotB);

    final aAmuletItem = amuletItemSlotA.amuletItem;
    final bAmuletItem = amuletItemSlotB.amuletItem;

    if (!aSlotType.supportsItemType(bAmuletItem?.type)){
      writeAmuletError('cannot perform move');
      return;
    }

    if (!bSlotType.supportsItemType(aAmuletItem?.type)){
      writeAmuletError('cannot perform move');
      return;
    }

    amuletItemSlotA.swap(amuletItemSlotB);

    notifyEquipmentDirty();
    amuletGame.onPlayerInventoryMoved(
      this,
      amuletItemSlotA,
      amuletItemSlotB,
    );
  }

  void changeGame(AmuletGame targetAmuletGame) =>
    amuletGame.amulet.playerChangeGame(
      player: this,
      target: targetAmuletGame,
    );

  void clearCameraTarget() {
    setCameraTarget(null);
  }

  void setCameraTarget(Position? target) {
    this.cameraTarget = target;
  }


  void playAudioType(AudioType audioType){
     writeByte(NetworkResponse.Amulet);
     writeByte(NetworkResponseAmulet.Play_AudioType);
     writeByte(audioType.index);
  }

  void reduceAmuletItemSlotCharges(AmuletItemSlot amuletItemSlot) {
    amuletItemSlot.reduceCharges();
    writeWeapons();
  }

  @override
  void attack() {

    if (deadInactiveOrBusy){
      return;
    }

    if (noWeaponEquipped){
      return;
    }

    // if (equippedWeapon.chargesEmpty) {
    //   writeGameError(GameError.Insufficient_Weapon_Charges);
    //   return;
    // }

    final amuletItem = equippedWeapon.amuletItem;

    if (amuletItem == null){
      return;
    }

    final performDuration = amuletItem.performDuration;

    if (performDuration == null){
      throw Exception('performDuration is null: $amuletItem');
    }

    final subType = amuletItem.subType;
    this.weaponDamage = AmuletGame.getAmuletItemDamage(amuletItem);

    useWeaponType(
      weaponType: subType,
      duration: performDuration,
    );
  }

  void useWeaponType({
    required int weaponType,
    required int duration,
  }) {

    if (const[
      WeaponType.Shortsword,
      WeaponType.Broadsword,
      WeaponType.Staff,
      WeaponType.Sword_Heavy_Sapphire,
    ].contains(weaponType)) {
      setCharacterStateStriking(
        duration: duration,
      );
      return;
    }

    if (const[
      WeaponType.Bow,
    ].contains(weaponType)){
      setCharacterStateFire(
        duration: duration,
      );
      return;
    }

    throw Exception(
        'amuletPlayer.attack() - weapon type not implemented ${WeaponType
            .getName(weaponType)}'
    );
  }

  void useActivatedPower() {
    if (deadInactiveOrBusy) {
      return;
    }

    final amuletItemSlot = this.activeAmuletItemSlot;

    if (amuletItemSlot == null){
      return;
    }

    final amuletItem = amuletItemSlot.amuletItem;

    if (amuletItem == null) {
      throw Exception();
    }

    amuletItemSlot.cooldown = amuletItem.cooldown ?? 0;
    onAmuletItemUsed(amuletItem);
  }

  void onAmuletItemUsed(AmuletItem amuletItem) {

    final dependency = amuletItem.dependency;

    if (dependency != null){
      final equippedWeaponAmuletItem = equippedWeapon.amuletItem;

      if (equippedWeaponAmuletItem == null || equippedWeaponAmuletItem.subType != dependency) {
        writeGameError(GameError.Weapon_Required);
        return;
      }
    }

    final performDuration = amuletItem.performDuration;

    if (performDuration == null){
      throw Exception('performDuration == null: ${amuletItem}');
    }

    switch (amuletItem.skillType?.casteType) {
      case CasteType.Self:
        setCharacterStateCasting(
          duration: performDuration,
        );
        break;
      case CasteType.Targeted_Enemy:
        if (target == null) {
          deactivateSlotType();
          return;
        }
        useWeaponType(
          weaponType: dependency ?? amuletItem.subType,
          duration: performDuration,
        );
        break;
      case CasteType.Targeted_Ally:
        if (target == null) {
          deactivateSlotType();
          return;
        }
        setCharacterStateCasting(
          duration: performDuration,
        );
        break;
      case CasteType.Positional:
        // useWeaponType(
        //   weaponType: dependency ?? amuletItem.subType,
        //   duration: performDuration,
        // );
        setCharacterStateCasting(
          duration: performDuration,
        );
        break;
      case CasteType.Instant:
        break;
      case CasteType.Directional:
        lookAtMouse();
        setCharacterStateCasting(
          duration: performDuration,
        );
        // useWeaponType(
        //   weaponType: dependency ?? amuletItem.subType,
        //   duration: performDuration,
        // );
        break;
      case null:
        break;
      case CasteType.Passive:
        break;
    }
  }

  void useSlotTypeAtIndex(SlotType slotType, int index) {
    if (index < 0) {
      return;
    }

    switch (slotType){

      case SlotType.Weapons:
        // selectWeaponAtIndex(index);
        return;
      case SlotType.Item:
        if (index >= items.length) {
          return;
        }

        final inventorySlot = items[index];
        final item = inventorySlot.amuletItem;

        if (item == null) {
          return;
        }

        if (item.isWeapon) {
          // inventorySlot.swap(equippedWeapon);
          // notifyEquipmentDirty();
          swapAmuletItemSlots(inventorySlot, equippedWeapon);
        } else
        if (item.isTreasure) {
          final emptyTreasureSlot = getEmptyTreasureSlot();
          if (emptyTreasureSlot != null){
            swapAmuletItemSlots(inventorySlot, emptyTreasureSlot);
          }
        } else
        if (item.isHelm){
          swapAmuletItemSlots(inventorySlot, equippedHelm);
        } else
        if (item.isLegs){
          swapAmuletItemSlots(inventorySlot, equippedLegs);
        } else
        if (item.isBody){
          swapAmuletItemSlots(inventorySlot, equippedBody);
        } else
        if (item.isShoes){
          swapAmuletItemSlots(inventorySlot, equippedShoe);
        }
        if (item.isHand){
          if (equippedHandLeft.amuletItem == null){
            swapAmuletItemSlots(inventorySlot, equippedHandLeft);
          } else {
            swapAmuletItemSlots(inventorySlot, equippedHandRight);
          }
        }

        if (item.isConsumable){
          throw Exception('not implemented');
        }
        break;
      default:
        setActiveSlotType(slotType);
        break;
    }
  }

  void clearActivatedPowerIndex(){
    // activatedPowerIndex = -1;
    deactivateSlotType();
  }

  writeHighlightAmuletItems(AmuletItem amuletItem){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Highlight_Amulet_Item);
    writeByte(amuletItem.index);
  }

  void writeClearHighlightedAmuletItem(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Highlight_Amulet_Item_Clear);
  }

  @override
  void downloadScene() {
    super.downloadScene();
    writeSceneName();
    // writeEquippedWeaponIndex();
    writeOptionsSetTimeVisible(game is! AmuletGameTutorial);
    writeOptionsSetHighlightIconInventory(false);
  }

  void writeSceneName() {
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Name);
    writeString(amuletGame.name);
  }

  void gainLevel(){
    level++;
    elementPoints++;
    regainFullHealth();
    writePlayerLevelGained();
    amuletGame.onPlayerLevelGained(this);
  }

  void writePlayerLevelGained() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Level_Gained);
  }

  void regainFullHealth() {
    health = maxHealth;
  }

  void spawnConfettiAtPosition(Position position) =>
    spawnConfetti(
      x: position.x,
      y: position.y,
      z: position.z,
    );

  void spawnConfetti({
    required double x,
    required double y,
    required double z,
  }) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Spawn_Confetti);
    writeDouble(x);
    writeDouble(y);
    writeDouble(z);
  }

  void writeElementUpgraded() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Element_Upgraded);
  }

  void writeOptionsSetTimeVisible(bool value){
    writeByte(NetworkResponse.Options);
    writeByte(NetworkResponseOptions.setTimeVisible);
    writeBool(value);
  }

  void writeOptionsSetHighlightIconInventory(bool value){
    writeByte(NetworkResponse.Options);
    writeByte(NetworkResponseOptions.setHighlightIconInventory);
    writeBool(value);
  }

  void setGame(AmuletGame game){
    endInteraction();
    clearPath();
    clearTarget();
    clearCache();
    setDestinationToCurrentPosition();
    this.game = game;
    this.amuletGame = game;
  }

  void writeWorldMapBytes(){
    print("amuletPlayer.writeWorldMapBytes()");
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.World_Map_Bytes);
    writeByte(amulet.worldRows);
    writeByte(amulet.worldColumns);
    writeUInt16(amulet.worldMapBytes.length);
    writeBytes(amulet.worldMapBytes);
  }

  void writeWorldMapLocations(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.World_Map_Locations);
    writeUInt16(amulet.worldMapLocations.length);
    writeBytes(amulet.worldMapLocations);
  }

  void writeWorldIndex(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_World_Index);
    writeByte(amuletGame.worldRow);
    writeByte(amuletGame.worldColumn);
  }

  void writeQuestMain(QuestMain value){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Quest_Main);
    writeByte(value.index);
  }

  void gainExperience(int experience){
    this.experience += experience;
    while (this.experience > experienceRequired) {
      gainLevel();
      this.experience -= experienceRequired;
    }
  }

  void completeQuestMain(QuestMain quest) {
    if (questMain.index > quest.index){
      return;
    }
    if (quest == QuestMain.values.last){
      return;
    }
    questMain = QuestMain.values[quest.index + 1];
  }

  @override
  void onChangedAimTarget() {
    super.onChangedAimTarget();
    writeAimTargetAmuletElement();
    writeAimTargetFiendType();
  }

  void writeAimTargetAmuletElement() {
    final aimTarget = this.aimTarget;
    if (aimTarget is! Elemental) return;
    final elemental = aimTarget as Elemental;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Aim_Target_Element);
    writeByte(elemental.elementWater);
    writeByte(elemental.elementFire);
    writeByte(elemental.elementAir);
    writeByte(elemental.elementStone);
  }

  void writeAimTargetFiendType() {
    final aimTarget = this.aimTarget;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Aim_Target_Fiend_Type);

    if (aimTarget is! AmuletFiend) {
      writeBool(false);
      return;
    }

    writeBool(true);
    writeByte(aimTarget.fiendType.index);
  }

  void writeFalse() => writeBool(false);

  void writeTrue() => writeBool(true);
}
