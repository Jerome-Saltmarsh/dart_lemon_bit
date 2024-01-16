
import 'dart:math';

import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/classes/amulet_gameobject.dart';

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
    Experience,
    Level,
    Magic
{
  static const Data_Key_Dead_Count = 'dead';

  var baseHealth = 10;
  var baseMagic = 10;
  var baseRegenMagic = 1;
  var baseRegenHealth = 1;
  var baseRunSpeed = 1.0;

  var activePowerX = 0.0;
  var activePowerY = 0.0;
  var activePowerZ = 0.0;

  var admin = false;
  var previousCameraTarget = false;
  var equipmentDirty = true;

  var cacheRegenMagic = 0;
  var cacheRegenHealth = 0;
  var cacheRunSpeed = 0.0;
  var cacheWeaponDamageMin = 0;
  var cacheWeaponDamageMax = 0;
  var cacheWeaponRange = 0;

  var npcText = '';
  var npcName = '';
  var npcOptions = <TalkOption>[];
  final weaponUnarmed = AmuletItemSlot();

  Function? onInteractionOver;
  Position? cameraTarget;
  AmuletGame amuletGame;

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
    regainFullMagic();
    active = false;
    equipmentDirty = true;
    setItemsLength(itemLength);
    setControlsEnabled(true);
    writeWorldMapBytes();
    writeWorldMapLocations();
    // writeAmuletElements();
    // writeElementPoints();
    writeInteracting();
    writePlayerLevel();
    writePlayerExperience();
    writeGender();
    writePlayerComplexion();
  }

  @override
  set magic(int value) {
    value = value.clamp(0, maxMagic);
    super.magic = value;
    writePlayerMagic();
  }

  int get deathCount => data.tryGetInt(Data_Key_Dead_Count) ?? 0;

  set deathCount(int value) => data.setInt(Data_Key_Dead_Count, value);

  QuestMain get questMain {
    final questMainIndex = data.tryGetInt('quest_main') ?? 0;
    return QuestMain.values[questMainIndex];
  }

  AmuletItemSlot? get activeAmuletItemSlot {
     switch (activeSlotType){
       case SlotType.Helm:
         return equippedHelm;
       case SlotType.Body:
         return equippedArmor;
       case SlotType.Shoes:
         return equippedShoes;
       // case SlotType.Legs:
       //   return equippedLegs;
       // case SlotType.Hand_Left:
       //   return equippedHandLeft;
       // case SlotType.Hand_Right:
       //   return equippedHandRight;
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

  Amulet get amulet => amuletGame.amulet;

  @override
  int get weaponType {
    final weapon = equippedWeapon;
    final item = weapon.amuletItem;
    return item?.subType ?? WeaponType.Unarmed;
  }

  int get experienceRequired => (level * level * 2) + (level * 10);

  bool get inventoryOpen => _inventoryOpen;

  @override
  int get weaponCooldown => equippedWeapon.cooldown;

  @override
  int get weaponDamage => randomInt(weaponDamageMin, weaponDamageMax + 1);

  @override
  double get weaponRange => (activeAmuletItemSlot ?? equippedWeapon).amuletItem?.range ?? 0;

  @override
  int get helmType => equippedHelm.amuletItem?.subType ?? HelmType.None;

  @override
  int get maxHealth {
    var health = baseHealth;
    for (final item in equipped){
      health += item.amuletItem?.defense ?? 0;
    }
    return health;
  }

  @override
  int get maxMagic {
    var amount = baseMagic;
    for (final item in equipped){
      amount += item.amuletItem?.magic ?? 0;
    }
    return amount;
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

  @override
  void writePlayerGame() {
    cleanEquipment();
    writeCameraTarget();
    writeRegenMagic();
    writeRegenHealth();
    writeRunSpeed();
    writeWeaponDamage();

    super.writePlayerGame();
  }

  void writeRegenMagic() {
    if (cacheRegenMagic == regenMagic) return;
    cacheRegenMagic = regenMagic;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Regen_Magic);
    writeUInt16(regenMagic);
  }

  void writeRegenHealth() {
    if (cacheRegenHealth == regenHealth) return;
    cacheRegenHealth = regenHealth;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Regen_Health);
    writeUInt16(regenHealth);
  }

  void writeRunSpeed() {
    if (cacheRunSpeed == runSpeed) return;
    cacheRunSpeed = runSpeed;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Run_Speed);
    writeUInt16((runSpeed * 10).toInt());
  }

  void writeWeaponDamage() {
    if (
      cacheWeaponDamageMin == weaponDamageMin &&
      cacheWeaponDamageMax == weaponDamageMax &&
      cacheWeaponRange == weaponRange
    ) return;
    cacheWeaponDamageMin = cacheWeaponDamageMin;
    cacheWeaponDamageMax = cacheWeaponDamageMax;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Weapon_Damage);
    writeUInt16(weaponDamageMin);
    writeUInt16(weaponDamageMax);
    writeUInt16(weaponRange.toInt());
  }

  int get weaponDamageMin {
    return equippedWeapon.amuletItem?.damageMin ?? 0;
  }

  int get weaponDamageMax {
    return equippedWeapon.amuletItem?.damageMax ?? 0;
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

  bool acquireAmuletItem(AmuletItem amuletItem){

    if (deadOrBusy) {
      return false;
    }

    setDestinationToCurrentPosition();
    clearPath();

    switch (amuletItem.type) {
      case ItemType.Weapon:
        equipWeapon(amuletItem);
        return true;
      case ItemType.Helm:
        equipHelm(amuletItem);
        return true;
      case ItemType.Armor:
        equipBody(amuletItem);
        return true;
      // case ItemType.Legs:
      //   equipLegs(amuletItem);
      //   return true;
      case ItemType.Shoes:
        equipShoes(amuletItem);
        return true;
    }

    return false;
  }

  int getEmptyItemIndex()=> getEmptyIndex(items);

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
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.End_Interaction);
    clearTarget();
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

  void clearItem(int index) => setItem(
      index: index,
      item: null,
      cooldown: 0,
  );

  bool isValidItemIndex(int index) => index >= 0 && index < items.length;

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

    switch (amuletItem.type) {
      case ItemType.Consumable:
        throw Exception('not implemented');
      case ItemType.Weapon:
        swapAmuletItemSlots(itemSlot, equippedWeapon);
        break;
      case ItemType.Helm:
        swapAmuletItemSlots(equippedHelm, itemSlot);
        break;
      case ItemType.Armor:
        swapAmuletItemSlots(equippedArmor, itemSlot);
        break;
      // case ItemType.Legs:
      //   swapAmuletItemSlots(equippedLegs, itemSlot);
      //   break;
      // case ItemType.Hand:
      //   if (equippedHandLeft.amuletItem == null){
      //     swapAmuletItemSlots(equippedHandLeft, itemSlot);
      //   } else {
      //     swapAmuletItemSlots(equippedHandRight, itemSlot);
      //   }
      //   break;
    }
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

  void equipHelm(AmuletItem? amuletItem, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedHelm.amuletItem == amuletItem){
      return;
    }

    if (amuletItem == null){
      clearSlot(equippedHelm);
      return;
    }

    if (!amuletItem.isHelm) {
      throw Exception();
    }

    setSlot(
      slot: equippedHelm,
      item: amuletItem,
      cooldown: 0,
    );
  }

  void equipBody(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedArmor == item) {
      return;
    }

    if (item == null){
      clearSlot(equippedArmor);
      armorType = 0;
      return;
    }

    if (!item.isBody){
      throw Exception();
    }

    setSlot(
      slot: equippedArmor,
      item: item,
      cooldown: 0,
    );

    armorType = item.subType;
  }

  // void equipLegs(AmuletItem? item, {bool force = false}){
  //   if (deadOrBusy && !force) {
  //     return;
  //   }
  //
  //   if (equippedLegs.amuletItem == item) {
  //     return;
  //   }
  //
  //   if (item == null){
  //     clearSlot(equippedLegs);
  //     legsType = LegType.None;
  //     return;
  //   }
  //
  //   if (!item.isLegs) {
  //     throw Exception();
  //   }
  //
  //   setSlot(
  //       slot: equippedLegs,
  //       item: item,
  //       cooldown: 0,
  //   );
  //   legsType = item.subType;
  // }

  // void equipHandLeft(AmuletItem? item, {bool force = false}){
  //   if (deadOrBusy && !force) {
  //     return;
  //   }
  //
  //   if (equippedHandLeft.amuletItem == item) {
  //     return;
  //   }
  //
  //   if (item == null){
  //     clearSlot(equippedHandLeft);
  //     handTypeLeft = HandType.None;
  //     return;
  //   }
  //
  //   if (!item.isHand) {
  //     throw Exception();
  //   }
  //
  //   setSlot(
  //     slot: equippedHandLeft,
  //     item: item,
  //     cooldown: 0,
  //   );
  //
  //   handTypeLeft = item.subType;
  // }

  // void equipHandRight(AmuletItem? item, {bool force = false}){
  //   if (deadOrBusy && !force) {
  //     return;
  //   }
  //
  //   // if (equippedHandRight.amuletItem == item) {
  //   //   return;
  //   // }
  //
  //   // if (item == null){
  //   //   clearSlot(equippedHandRight);
  //   //   handTypeRight = HandType.None;
  //   //   return;
  //   // }
  //
  //   if (!item.isHand) {
  //     throw Exception();
  //   }
  //
  //   setSlot(
  //     slot: equippedHandRight,
  //     item: item,
  //     cooldown: 0,
  //   );
  //
  //   handTypeRight = item.subType;
  // }

  void equipShoes(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force) {
      return;
    }

    if (equippedShoes.amuletItem == item) {
      return;
    }

    if (item == null){
      clearSlot(equippedShoes);
      shoeType = ShoeType.None;
      return;
    }

    if (!item.isShoes) {
      throw Exception();
    }

    setSlot(
      slot: equippedShoes,
      item: item,
      cooldown: 0,
    );

    shoeType = item.subType;
  }

  void cleanEquipment(){
    if (!equipmentDirty) {
      return;
    }

    health = clamp(health, 0, maxHealth);
    weaponType = equippedWeapon.amuletItem?.subType ?? WeaponType.Unarmed;
    equipmentDirty = false;
    helmType = equippedHelm.amuletItem?.subType ?? HelmType.None;
    armorType = equippedArmor.amuletItem?.subType ?? 0;
    shoeType = equippedShoes.amuletItem?.subType ?? ShoeType.None;

    writeEquipped();
    writePlayerHealth();
    writeItems();
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
    writeAmuletItem(equippedArmor.amuletItem);
    // writeAmuletItem(equippedLegs.amuletItem);
    // writeAmuletItem(equippedHandLeft.amuletItem);
    // writeAmuletItem(equippedHandRight.amuletItem);
    writeAmuletItem(equippedShoes.amuletItem);
  }

  void writeAmuletItem(AmuletItem? value){
    if (value == null){
      writeInt16(-1);
    } else{
      writeInt16(value.index);
    }
  }

  void writeInteracting() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Interacting);
    writeBool(interacting);
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

  void unequipBody() => swapWithAvailableItemSlot(equippedArmor);

  // void unequipLegs() => swapWithAvailableItemSlot(equippedLegs);

  // void unequipHandLeft() => swapWithAvailableItemSlot(equippedHandLeft);

  // void unequipHandRight() => swapWithAvailableItemSlot(equippedHandRight);

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

  void clearSlot(AmuletItemSlot slot){
    slot.clear();
    notifyEquipmentDirty();
  }

  void setSlot({
    required AmuletItemSlot slot,
    required AmuletItem? item,
    required int cooldown,
  }) {
    final currentlyEquipped = slot.amuletItem;
    if (currentlyEquipped != null) {
      dropItemSlotItem(slot);
    }

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
      // SlotType.Hand_Left => equippedHandLeft,
      // SlotType.Hand_Right => equippedHandRight,
      SlotType.Body => equippedArmor,
      SlotType.Helm => equippedHelm,
      // SlotType.Legs => equippedLegs,
      SlotType.Shoes => equippedShoes,
      SlotType.Item => items[index],
    };

  void dropItemSlotItem(AmuletItemSlot itemSlot){
    final amuletItem = itemSlot.amuletItem;

    if (amuletItem == null){
      return;
    }

    spawnAmuletItem(amuletItem);
    itemSlot.clear();
    writePlayerEvent(PlayerEvent.Item_Dropped);
    notifyEquipmentDirty();
  }

  AmuletItemSlot getItemSlot(SlotType slotType, int index) =>
    switch (slotType) {
      SlotType.Item => items[index],
      SlotType.Weapon => equippedWeapon,
      SlotType.Helm => equippedHelm,
      SlotType.Body => equippedArmor,
      SlotType.Shoes => equippedShoes
    };

  void dropItemType(int itemType){
      final slot = getEquippedItemSlot(itemType: itemType);
      if (slot == null){
        return;
      }
      dropItemSlotItem(slot);
  }


  AmuletItemSlot? getEquippedItemSlot({required int itemType}) =>
      switch (itemType){
        ItemType.Weapon => equippedWeapon,
        ItemType.Helm => equippedHelm,
        ItemType.Armor => equippedArmor,
        ItemType.Shoes => equippedShoes,
        _ => null
    };

  void dropSlotTypeAtIndex(SlotType slotType, int index) =>
      dropItemSlotItem(getItemSlot(slotType, index));

  @override
  void clearAction() {
    super.clearAction();
    deactivateSlotType();
  }

  void writeMessage(String message){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Message);
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

  // void refillItemSlotsWeapons(){
  //   equipped.forEach(refillItemSlot);
  // }

  // void refillItemSlots(List<AmuletItemSlot> itemSlots){
  //
  //   for (final itemSlot in itemSlots) {
  //     refillItemSlot(itemSlot);
  //   }
  //
  //   equipmentDirty = true;
  // }

  int getInt(String name) {
    return data[name] as int;
  }

  void writeCameraTarget() {
    final cameraTarget = this.cameraTarget;

    if (cameraTarget == null && !previousCameraTarget){
      return;
    }

    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Camera_Target);

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
    // if (amuletItemSlot == equippedHandLeft){
    //   return SlotType.Hand_Left;
    // }
    // if (amuletItemSlot == equippedHandRight){
    //   return SlotType.Hand_Right;
    // }
    if (amuletItemSlot == equippedHelm){
      return SlotType.Helm;
    }
    if (amuletItemSlot == equippedArmor){
      return SlotType.Body;
    }
    // if (amuletItemSlot == equippedLegs){
    //   return SlotType.Legs;
    // }
    if (amuletItemSlot == equippedShoes){
      return SlotType.Shoes;
    }
    if (items.contains(amuletItemSlot)){
      return SlotType.Item;
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
  }

  @override
  void attack() {

    if (deadInactiveOrBusy) {
      return;
    }

    if (noWeaponEquipped){
      return;
    }

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

    if (dependency != null) {
      final equippedWeaponAmuletItem = equippedWeapon.amuletItem;

      if (equippedWeaponAmuletItem == null || equippedWeaponAmuletItem.subType != dependency) {
        writeGameError(GameError.Weapon_Required);
        return;
      }
    }

    final performDuration = amuletItem.performDuration;

    if (performDuration == null) {
      throw Exception('performDuration == null: ${amuletItem}');
    }

    final magicCost = amuletItem.skillMagicCost;

    if (magicCost != null) {
      if (magicCost > magic){
        writeGameError(GameError.Insufficient_Magic);
      }
      magic -= magicCost;
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
          swapAmuletItemSlots(inventorySlot, equippedWeapon);
        } else
        if (item.isHelm){
          swapAmuletItemSlots(inventorySlot, equippedHelm);
        } else
        // if (item.isLegs){
        //   swapAmuletItemSlots(inventorySlot, equippedLegs);
        // } else
        if (item.isBody){
          swapAmuletItemSlots(inventorySlot, equippedArmor);
        } else
        if (item.isShoes){
          swapAmuletItemSlots(inventorySlot, equippedShoes);
        }
        // if (item.isHand){
        //   if (equippedHandLeft.amuletItem == null){
        //     swapAmuletItemSlots(inventorySlot, equippedHandLeft);
        //   } else {
        //     swapAmuletItemSlots(inventorySlot, equippedHandRight);
        //   }
        // }

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
    // elementPoints++;
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

  void regainFullMagic(){
    magic = maxMagic;
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
    // writeAimTargetAmuletElement();
    writeAimTargetFiendType();
    writeAimTargetItemType();
  }

  // void writeAimTargetAmuletElement() {
  //   final aimTarget = this.aimTarget;
  //   if (aimTarget is! Elemental) return;
  //   final elemental = aimTarget as Elemental;
  //   writeByte(NetworkResponse.Amulet);
  //   writeByte(NetworkResponseAmulet.Aim_Target_Element);
  //   writeByte(elemental.elementWater);
  //   writeByte(elemental.elementFire);
  //   writeByte(elemental.elementAir);
  //   writeByte(elemental.elementStone);
  // }

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

  void writeAimTargetItemType() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Aim_Target_Item_Type);

     if (aimTarget is! AmuletGameObject){
       writeFalse();
       return;
     }

    writeTrue();
    final gameObject = aimTarget as AmuletGameObject;
    writeAmuletItem(gameObject.amuletItem);
  }

  void writePlayerMagic() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Magic);
    writeUInt16(maxMagic);
    writeUInt16(magic);
  }

  void regenHealthAndMagic() {
     health += regenHealth;
     magic += regenMagic;
  }

  int get regenMagic {
     var total = baseRegenMagic;
     for (final item in equipped){
        total += item.amuletItem?.regenMagic ?? 0;
     }
     return total;
  }

  int get regenHealth {
     var total = baseRegenHealth;
     for (final item in equipped){
        total += item.amuletItem?.regenHealth ?? 0;
     }
     return total;
  }

  @override
  double get runSpeed {
     var total = baseRunSpeed;
     for (final item in equipped){
        total += item.amuletItem?.runSpeed ?? 0;
     }
     return total;
  }
}
