
import 'package:gamestream_ws/isometric.dart';
import 'package:gamestream_ws/packages.dart';

import 'item_slot.dart';
import 'amulet_game.dart';
import 'mmo_npc.dart';
import 'talk_option.dart';

class AmuletPlayer extends IsometricPlayer {

  final AmuletGame game;

  var equipmentDirty = true;
  var activePowerX = 0.0;
  var activePowerY = 0.0;
  var activePowerZ = 0.0;

  var healthBase = 10;
  var npcText = '';
  var npcOptions = <TalkOption>[];

  var elementFire = 0;
  var elementWater = 0;
  var elementWind = 0;
  var elementEarth = 0;
  var elementElectricity = 0;

  final weapons = List<ItemSlot>.generate(4, (index) => ItemSlot());
  final treasures = List<ItemSlot>.generate(4, (index) => ItemSlot());
  final talents = List.generate(AmuletTalentType.values.length, (index) => 0, growable: false);

  final equippedHelm = ItemSlot();
  final equippedBody = ItemSlot();
  final equippedLegs = ItemSlot();
  final equippedHandLeft = ItemSlot();
  final equippedHandRight = ItemSlot();
  final equippedShoe = ItemSlot();

  late List<ItemSlot> items;

  var _elementPoints = 0;
  var _inventoryOpen = false;
  var _skillsDialogOpen = false;
  var _experience = 0;
  var _experienceRequired = 1;
  var _level = 1;
  var _equippedWeaponIndex = -1;
  var _activatedPowerIndex = -1;
  var _skillPoints = 1;

  AmuletPlayer({
    required this.game,
    required int itemLength,
    required super.x,
    required super.y,
    required super.z,
  }) : super(game: game, health: 10, team: AmuletTeam.Human) {
    controlsCanTargetEnemies = true;
    characterType = CharacterType.Kid;
    hurtable = false;
    hurtStateBusy = false;
    setItemsLength(itemLength);
    addItem(AmuletItem.Health_Potion);
    addItem(AmuletItem.Sapphire_Pendant);
    addItem(AmuletItem.Steel_Helmet);
    addItem(AmuletItem.Shoe_Leather_Boots);
    addItem(AmuletItem.Lightning_Rod);

    addItemToEmptyWeaponSlot(AmuletItem.Rusty_Old_Sword);
    addItemToEmptyWeaponSlot(AmuletItem.Staff_Of_Frozen_Lake);
    addItemToEmptyWeaponSlot(AmuletItem.Holy_Bow);
    addItemToEmptyWeaponSlot(AmuletItem.Blink_Dagger);

    equipBody(AmuletItem.Basic_Leather_Armour);
    equipLegs(AmuletItem.Travellers_Pants);

    elementPoints = 1;
    health = maxHealth;
    equippedWeaponIndex = 0;
    active = false;
    equipmentDirty = true;
    complexion = ComplexionType.fair;
    name = 'new_player';

    writeAmuletElements();
    writeElementPoints();
    writeActivatedPowerIndex();
    writeWeapons();
    writeTreasures();
    writeInteracting();
    writePlayerLevel();
    writePlayerExperience();
    writePlayerExperienceRequired();
    writePlayerTalentPoints();
    writePlayerTalentDialogOpen();
    writePlayerTalents();
    writeGender();
    writePlayerComplexion();
  }

  int get elementPoints => _elementPoints;

  set elementPoints(int value){
    _elementPoints = value;
    writeElementPoints();
  }

  bool get activeAbilitySelected => activatedPowerIndex != -1;

  int get equippedWeaponType {
    final weapon = equippedWeapon;
    if (weapon == null)
      return WeaponType.Unarmed;

    final item = weapon.item;

    if (item == null)
      return WeaponType.Unarmed;

    return item.subType;
  }

  int get experience => _experience;

  int get experienceRequired => _experienceRequired;

  int get level => _level;

  int get talentPoints => _skillPoints;

  bool get talentDialogOpen => _skillsDialogOpen;

  bool get inventoryOpen => _inventoryOpen;

  @override
  int get weaponCooldown => equippedWeapon != null ? equippedWeapon!.cooldown : -1;

  @override
  int get weaponDamage => equippedWeapon?.item?.damage ?? 1;

  @override
  double get weaponRange => equippedWeapon?.item?.range ?? 30;

  @override
  int get helmType => equippedHelm.item?.subType ?? HelmType.None;

  int get activatedPowerIndex => _activatedPowerIndex;

  @override
  int get maxHealth {
    var health = healthBase;
    health += equippedHelm.health;
    health += equippedBody.health;
    health += equippedLegs.health;

    for (final treasure in treasures){
      health += treasure.health;
    }

    final talentHealthLevel = talents[AmuletTalentType.Healthy.index];
    health += talentHealthLevel * AmuletTalentType.Healthy_Health_Per_Level;
    return health;
  }

  @override
  double get runSpeed {
    var base = 1.0;

    base += equippedHelm.movement;
    base += equippedBody.movement;
    base += equippedLegs.movement;
    return base;
  }

  ItemSlot? get equippedWeapon => _equippedWeaponIndex == -1 ? null : weapons[_equippedWeaponIndex];

  set experience(int value){
    _experience = value;
    writePlayerExperience();
  }

  set experienceRequired(int value){
    _experienceRequired = value;
    writePlayerExperienceRequired();
  }

  set level(int value){
    _level = value;
    writePlayerLevel();
  }

  set talentPoints(int value){
    _skillPoints = value;
    writePlayerTalentPoints();
  }

  set talentDialogOpen(bool value){
    _skillsDialogOpen = value;
    writePlayerTalentDialogOpen();
  }

  set inventoryOpen(bool value){
    _inventoryOpen = value;
    writePlayerInventoryOpen();
  }

  @override
  set target(Position? value){
    if (super.target == value)
      return;

    if (interacting) {
      endInteraction();
    }
    super.target = value;
  }

  set interacting(bool value){
    if (super.interacting == value)
      return;
    super.interacting = value;
    writeInteracting();
  }

  set activatedPowerIndex(int value){
    if (_activatedPowerIndex == value)
      return;

    _activatedPowerIndex = value;
    writeActivatedPowerIndex();
  }

  int get equippedWeaponIndex => _equippedWeaponIndex;

  set equippedWeaponIndex(int value){
    if (_equippedWeaponIndex == value){
      return;
    }

    if (controlsCanTargetEnemies){
      setCharacterStateChanging();
    }

    if (value == -1){
      _equippedWeaponIndex = value;
      weaponType = equippedWeaponType;
      writeEquippedWeaponIndex(value);
      return;
    }
    if (!isValidWeaponIndex(value)){
      return;
    }
    final weapon = weapons[value];

    final item = weapon.item;

    if (item == null || item.type != ItemType.Weapon){
      return;
    }

    _equippedWeaponIndex = value;
    weaponType = equippedWeaponType;
    attackActionFrame = item.actionFrame;
    attackDuration = item.performDuration;

    game.dispatchGameEvent(GameEventType.Weapon_Type_Equipped,
        x,
        y,
        z,
        weaponType * degreesToRadians,
    );

    writeEquippedWeaponIndex(value);
  }

  @override
  void writePlayerGame() {
    cleanEquipment();
    super.writePlayerGame();
  }

  void setItemsLength(int value){
    items = List.generate(value, (index) => ItemSlot());
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
      item: item,
      cooldown: 0,
    );
  }

  bool addItem(AmuletItem item){

    if (deadOrBusy)
      return false;

    final emptyItemSlot = getEmptyItemSlot();
    if (emptyItemSlot == null) {
      reportInventoryFull();
      return false;
    }

    emptyItemSlot.item = item;
    emptyItemSlot.cooldown = 0;
    notifyEquipmentDirty();
    return true;
  }

  int getEmptyItemIndex()=> getEmptyIndex(items);

  int getEmptyWeaponIndex() => getEmptyIndex(weapons);

  int getEmptyIndexTreasure() => getEmptyIndex(treasures);

  void setWeapon({
    required int index,
    required AmuletItem? item,
    required int cooldown,
  }){
    if (!isValidWeaponIndex(index)) {
      writeAmuletError('Invalid weapon index $index');
      return;
    }
    if (item != null && !item.isWeapon)
      return;

    weapons[index].item = item;
    weapons[index].cooldown = cooldown;
    writePlayerWeapon(index);
  }

  void setTreasure({required int index, required AmuletItem? item}){
    if (deadOrBusy)
      return;

    if (!isValidIndexTreasure(index)) {
      writeAmuletError('Invalid treasure index $index');
      return;
    }
    if (item != null && !item.isTreasure)
      return;

    treasures[index].item = item;
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
    slot.item = item;
    slot.cooldown = cooldown;
    notifyEquipmentDirty();
    setCharacterStateChanging();
  }

  @override
  int getTargetAction(Position? value){
    if (value == null)
      return TargetAction.Run;
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
      if (value is MMONpc && value.interact != null) {
        return TargetAction.Talk;
      }
    }
    if (isEnemy(value))
      return TargetAction.Attack;
    return TargetAction.Run;
  }

  void talk(String text, {List<TalkOption>? options}) {
     npcText = text;
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
    talk('');
    clearTarget();
  }

  void dropWeapon(int index){
    if (!isValidWeaponIndex(index)) {
      return;
    }
    final item = weapons[index].item;

    if (item == null) {
      return;
    }

    clearWeapon(index);
    spawnItem(item);
  }

  void dropTreasure(int index){
    if (!isValidIndexTreasure(index)) {
      return;
    }
    final item = treasures[index].item;
    if (item == null) {
      return;
    }

    clearTreasure(index);
    spawnItem(item);
  }

  void dropEquippedHelm(){

    final equippedHeadItem = equippedHelm.item;

    if (equippedHeadItem == null)
      return;

    spawnItem(equippedHeadItem);
    equipHelm(null);
  }

  void dropEquippedBody(){

    final item = equippedBody.item;

    if (item == null)
      return;

    spawnItem(item);
    equipBody(null);
  }

  void dropEquippedLegs(){
    final item = equippedLegs.item;
    if (item == null)
      return;
    spawnItem(item);
    equipLegs(null);
  }

  void dropEquippedHandLeft(){
    final item = equippedHandLeft.item;
    if (item == null)
      return;
    spawnItem(item);
    equipHandLeft(null);
  }

  void dropEquippedHandRight(){
    final item = equippedHandRight.item;
    if (item == null)
      return;
    spawnItem(item);
    equipHandRight(null);
  }

  void dropItem(int index){
    if (!isValidItemIndex(index)) {
      return;
    }
    final item = items[index].item;
    if (item == null) {
      return;
    }

    clearItem(index);
    spawnItem(item);
  }

  void spawnItem(AmuletItem item){
    const spawnDistance = 40.0;
    final spawnAngle = randomAngle();
    game.spawnLoot(
      x: x + adj(spawnAngle, spawnDistance),
      y: y + opp(spawnAngle, spawnDistance),
      z: z,
      item: item,
    );
  }

  void clearWeapon(int index) => setWeapon(
      index: index,
      item: null,
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

  void selectWeapon(int index) {
     if (deadOrBusy)
       return;

    if (!isValidWeaponIndex(index)) {
      writeAmuletError('Invalid weapon index $index');
      return;
    }

    final slot = weapons[index];
    final weapon = slot.item;

    if (weapon == null)
      return;

    final attackType = weapon.attackType;

    if (attackType == null) {
      writeAmuletError('selected weapon attack type is null ($index)');
      return;
    }

    if (slot.cooldown > 0) {
      writeAmuletError('${slot.item?.name} is cooling down');
      return;
    }

    switch (attackType.mode) {
      case AmuletPowerMode.Equip:
        equippedWeaponIndex = index;
        deselectActivatedPower();
        if (!controlsCanTargetEnemies){
          // useEquippedWeapon();
        }
        break;
      case AmuletPowerMode.Positional:
        if (activatedPowerIndex == index){
          deselectActivatedPower();
          return;
        }
        activatedPowerIndex = index;
        break;
      case AmuletPowerMode.Targeted_Ally:
        if (activatedPowerIndex == index){
          deselectActivatedPower();
          return;
        }
        activatedPowerIndex = index;
        break;
      case AmuletPowerMode.Targeted_Enemy:
        if (activatedPowerIndex == index){
          deselectActivatedPower();
          return;
        }
        activatedPowerIndex = index;
        break;
      case AmuletPowerMode.Self:
        activatedPowerIndex = index;
        setCharacterStateStriking(
            duration: 20,
            actionFrame: 10,
        );
        break;
    }


  }

  void deselectActivatedPower() {
    // performingActivePower = false;
    activatedPowerIndex = -1;
  }

  void selectItem(int index) {
    if (deadOrBusy)
      return;

    if (!isValidItemIndex(index)) {
      return;
    }

    final selected = items[index];

    final item = items[index].item;

    if (item == null)
      return;

    final itemType = item.type;
    final subType = item.subType;

    if (item.isTreasure) {
      addToEmptyTreasureSlot(selected);
      return;
    }

    if (itemType == ItemType.Consumable){
      if (subType == ConsumableType.Health_Potion){
        health = maxHealth;
        setCharacterStateChanging();
        clearItem(index);
        writePlayerEvent(PlayerEvent.Drink);
      }
      return;
    }

    switch (item.type) {
      case ItemType.Consumable:
        break;
      case ItemType.Weapon:
        final emptyWeaponIndex = getEmptyWeaponIndex();
        if (emptyWeaponIndex != -1){
          setWeapon(
              index: emptyWeaponIndex,
              item: item,
              cooldown: item.cooldown,
          );
          clearItem(index);
          setCharacterStateChanging();
        } else {
          final currentWeapon = equippedWeapon;
          final currentCooldown = equippedWeapon?.cooldown ?? 0;
          setWeapon(
              index: _equippedWeaponIndex,
              item: item,
              cooldown: items[index].cooldown,
          );
          setItem(
              index: index,
              item: currentWeapon?.item,
              cooldown: currentCooldown,
          );
          setCharacterStateChanging();
        }
        break;
      case ItemType.Helm:
        swap(equippedHelm, selected);
        break;
      case ItemType.Body:
        swap(equippedBody, selected);
        break;
      case ItemType.Legs:
        swap(equippedLegs, selected);
        break;
      case ItemType.Hand:
        if (equippedHandLeft.item == null){
          swap(equippedHandLeft, selected);
        } else {
          swap(equippedHandRight, selected);
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
     npcOptions[index].action();
  }

  void equipHelm(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force)
      return;

    if (equippedHelm.item == item)
      return;

    if (item == null){
      clearSlot(equippedHelm);
      helmType = HelmType.None;
      return;
    }

    if (!item.isHelm)
      throw Exception();

    setSlot(
      slot: equippedHelm,
      item: item,
      cooldown: item.cooldown,
    );

    helmType = item.subType;
  }

  void equipBody(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force)
      return;

    if (equippedBody == item)
      return;

    if (item == null){
      clearSlot(equippedBody);
      bodyType = BodyType.None;
      return;
    }

    if (!item.isBody){
      throw Exception();
    }

    setSlot(
      slot: equippedBody,
      item: item,
      cooldown: item.cooldown,
    );

    bodyType = item.subType;
  }

  void equipLegs(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force)
      return;

    if (equippedLegs.item == item)
      return;

    if (item == null){
      clearSlot(equippedLegs);
      legsType = LegType.None;
      return;
    }

    if (!item.isLegs)
      throw Exception();

    setSlot(
        slot: equippedLegs,
        item: item,
        cooldown: item.cooldown,
    );
    legsType = item.subType;
  }

  void equipHandLeft(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force)
      return;

    if (equippedHandLeft.item == item)
      return;

    if (item == null){
      clearSlot(equippedHandLeft);
      handTypeLeft = HandType.None;
      return;
    }

    if (!item.isHand)
      throw Exception();

    setSlot(
      slot: equippedHandLeft,
      item: item,
      cooldown: item.cooldown,
    );

    handTypeLeft = item.subType;
  }

  void equipHandRight(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force)
      return;

    if (equippedHandRight.item == item)
      return;

    if (item == null){
      clearSlot(equippedHandRight);
      handTypeRight = HandType.None;
      return;
    }

    if (!item.isHand)
      throw Exception();

    setSlot(
      slot: equippedHandRight,
      item: item,
      cooldown: item.cooldown,
    );

    handTypeRight = item.subType;
  }

  void equipShoes(AmuletItem? item, {bool force = false}){
    if (deadOrBusy && !force)
      return;

    if (equippedShoe.item == item)
      return;

    if (item == null){
      clearSlot(equippedShoe);
      shoeType = ShoeType.None;
      return;
    }

    if (!item.isShoes)
      throw Exception();

    setSlot(
      slot: equippedShoe,
      item: item,
      cooldown: item.cooldown,
    );

    shoeType = item.subType;
  }

  void pickupItem(AmuletItem item) {

    if (item.health > 0){
      health += item.health;
      writePlayerEvent(PlayerEvent.Eat);
    }

    if (item.experience > 0){
      experience += item.experience;
      writePlayerEvent(PlayerEvent.Experience_Collected);
    }
  }

  void cleanEquipment(){
    if (!equipmentDirty)
      return;

    assert (equippedHelm.item?.isHelm ?? true);
    assert (equippedBody.item?.isBody ?? true);
    assert (equippedLegs.item?.isLegs ?? true);
    assert (equippedWeapon?.item?.isWeapon ?? true);
    assert (equippedShoe.item?.isShoes ?? true);

    health = clamp(health, 0, maxHealth);
    weaponType = equippedWeapon?.item?.subType ?? WeaponType.Unarmed;
    equipmentDirty = false;
    helmType = equippedHelm.item?.subType ?? HelmType.None;
    bodyType = equippedBody.item?.subType ?? BodyType.None;
    legsType = equippedLegs.item?.subType ?? LegType.None;
    handTypeLeft = equippedHandLeft.item?.subType ?? HandType.None;
    handTypeRight = equippedHandRight.item?.subType ?? HandType.None;
    shoeType = equippedShoe.item?.subType ?? HandType.None;

    writeEquipped();
    writePlayerHealth();
    writeWeapons();
    writeItems();
    writeTreasures();
  }

  void writeItems() {
     for (var i = 0; i < items.length; i++){
       writePlayerItem(i, items[i].item);
     }
  }

  void writeEquipped(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Equipped);
    writeAmuletItem(equippedHelm.item);
    writeAmuletItem(equippedBody.item);
    writeAmuletItem(equippedLegs.item);
    writeAmuletItem(equippedHandLeft.item);
    writeAmuletItem(equippedHandRight.item);
    writeAmuletItem(equippedShoe.item);
  }

  void writeAmuletItem(AmuletItem? value){
    if (value == null){
      writeInt16(-1);
    } else{
      writeInt16(value.index);
    }
  }

  void writeWeapons() {
    for (var i = 0; i < weapons.length; i++){
      writePlayerWeapon(i);
    }
  }

  void writeTreasures() {
    for (var i = 0; i < treasures.length; i++){
      writePlayerTreasure(i);
    }
  }

  void writeInteracting() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Interacting);
    writeBool(interacting);
  }

  void writeEquippedWeaponIndex(int value) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Equipped_Weapon_Index);
    writeInt16(value);
  }

  void writePlayerWeapon(int index) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Weapon);
    writeUInt16(index);
    final slot = weapons[index];
    final weapon = slot.item;
    if (weapon == null){
      writeInt16(-1);
      return;
    }
    writeInt16(weapon.index);
    writeUInt16(slot.cooldown);
  }

  void writePlayerTreasure(int index) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Treasure);
    writeUInt16(index);
    final treasure = treasures[index].item;
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
  }

  void writePlayerExperienceRequired() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Experience_Required);
    writeUInt24(experienceRequired);
  }

  void writePlayerLevel() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Level);
    writeByte(level);
  }

  void writePlayerTalentPoints() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Talent_Points);
    writeByte(talentPoints);
  }

  void writePlayerTalentDialogOpen() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Talent_Dialog_Open);
    writeBool(talentDialogOpen);
  }

  void writePlayerInventoryOpen() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Inventory_Open);
    writeBool(inventoryOpen);
  }

  void toggleSkillsDialog() {
    talentDialogOpen = !talentDialogOpen;
  }

  static ItemSlot? getEmptySlot(List<ItemSlot> items){
    for (final item in items) {
      if (item.item == null)
        return item;
    }
    return null;
  }

  static int getEmptyIndex(List<ItemSlot> items){
    for (var i = 0; i < items.length; i++){
      if (items[i].item == null)
        return i;
    }
    return -1;
  }

  void upgradeTalent(AmuletTalentType talent) {

     final currentLevel = talents[talent.index];

     if (currentLevel >= talent.maxLevel){
       writeAmuletError("Maximum talent level reached");
       return;
     }

     final nextLevel = currentLevel + 1;
     final cost = nextLevel * talent.levelCostMultiplier;

     if (talentPoints < cost){
       writeAmuletError('Insufficient talent points');
       return;
     }

     writePlayerEvent(PlayerEvent.Talent_Upgraded);
     talents[talent.index]++;
     talentPoints -= cost;
     writePlayerTalents();

     if (talent == AmuletTalentType.Healthy){
       health = maxHealth;
     }

     writePlayerHealth();
  }

  void writePlayerTalents() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Talents);
    talents.forEach(writeByte);
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

  void writeActivatedPowerIndex() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Activated_Power_Index);
    writeInt8(_activatedPowerIndex);
  }

  void useActivatedPower(){
    if (_activatedPowerIndex == -1)
      return;

    if (!isValidWeaponIndex(_activatedPowerIndex))
      throw Exception();

    final weapon = weapons[_activatedPowerIndex];

    final item = weapon.item;

    if (item == null){
      throw Exception();
    }

    final attackType = item.attackType;

    if (attackType == null)
      throw Exception();

    switch (attackType.mode) {
      case AmuletPowerMode.Equip:
        throw Exception();
      case AmuletPowerMode.Self:
        setCharacterStateStriking(
            actionFrame: item.actionFrame,
            duration: item.performDuration,
        );
        break;
      case AmuletPowerMode.Targeted_Enemy:
        if (target == null) {
          deselectActivatedPower();
          return;
        }
        actionFrame = item.actionFrame;
        setCharacterStateStriking(
            actionFrame: item.actionFrame,
            duration: item.performDuration,
        );
        break;
      case AmuletPowerMode.Targeted_Ally:
        if (target == null) {
          deselectActivatedPower();
          return;
        }
        setCharacterStateStriking(
          actionFrame: item.actionFrame,
          duration: item.performDuration,
        );
        break;
      case AmuletPowerMode.Positional:
        setCharacterStateStriking(
            duration: item.performDuration,
            actionFrame: item.actionFrame,
        );
        weaponType = item.subType;
        break;
    }
  }

  /// Gets called once the animation to perform the power strikes the perform state
  void applyPerformingActivePower() {
      if (activatedPowerIndex == -1)
        throw Exception();

      if (!isValidWeaponIndex(activatedPowerIndex)){
        throw Exception();
      }

      final weapon = weapons[activatedPowerIndex];

      final item = weapon.item;

      if (item == null)
        throw Exception();

      weapon.cooldown = item.cooldown;

      final attackType = item.attackType;

      if (attackType == null){
        throw Exception();
      }

      switch (attackType) {
        case AmuletAttackType.Blink:
          game.performAmuletAttackBlink(this);
          break;
        case AmuletAttackType.Lightning:
          game.performAmuletAttackLightning(this);
          break;
        default:
          throw Exception("Power Not Implemented $attackType");
      }

      assignWeaponTypeToEquippedWeapon();
      deselectActivatedPower();
      setCharacterStateIdle();
      setDestinationToCurrentPosition();
      clearPath();
  }

  void assignWeaponTypeToEquippedWeapon() =>
      weaponType = equippedWeapon?.item?.subType ?? WeaponType.Unarmed;

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
    if (!activeAbilitySelected)
      return;

    final activeAbility = getWeaponAtIndex(activatedPowerIndex) ;

    if (activeAbility == null)
      return;

    final attackType = activeAbility.attackType;

    if (attackType == null)
      return;

    if (attackType.mode == AmuletPowerMode.Positional) {
      final mouseDistance = getMouseDistance();
      final maxRange = activeAbility.range;
      if (mouseDistance <= maxRange){
        activePowerX = mouseSceneX;
        activePowerY = mouseSceneY;
        activePowerZ = mouseSceneZ;
      } else {
        final mouseAngle = getMouseAngle();
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
      isValidIndex(index, weapons) ? weapons[index].item : null;


  void addToEmptyTreasureSlot(ItemSlot slot){
    final item = slot.item;

    if (item == null || !item.isTreasure)
      throw Exception();

    final emptyTreasureSlot = getEmptySlot(treasures);
    if (emptyTreasureSlot == null){
      writeAmuletError("Treasure slots full");
      return;
    }
    swap(slot, emptyTreasureSlot);
  }

  void swapWithAvailableItemSlot(ItemSlot slot){
    if (slot.item == null)
      return;

    final availableItemSlot = getEmptyItemSlot();
    if (availableItemSlot == null){
      reportInventoryFull();
      return;
    }
    swap(availableItemSlot, slot);
  }

  ItemSlot? getEmptyItemSlot() => getEmptySlot(items);


  void clearSlot(ItemSlot slot){
    slot.clear();
    notifyEquipmentDirty();
  }

  void setSlot({
    required ItemSlot slot,
    required AmuletItem? item,
    required int cooldown,
  }) {
    slot.item = item;
    slot.cooldown = cooldown;
    notifyEquipmentDirty();
  }

  void swap(ItemSlot a, ItemSlot b){
     final aItem = a.item;
     final aCooldown = a.cooldown;
     final bItem = b.item;
     final bCooldown = b.cooldown;
     a.item = bItem;
     a.cooldown = bCooldown;
     b.item = aItem;
     b.cooldown = aCooldown;
     a.validate();
     b.validate();
     notifyEquipmentDirty();
  }

  void notifyEquipmentDirty(){
    if (equipmentDirty)
      return;

    setCharacterStateChanging();
    equipmentDirty = true;
  }

  void reduceCooldown() {
     for (var i = 0; i < weapons.length; i++) {
       final weapon = weapons[i];
       if (weapon.cooldown <= 0)
         continue;

       weapon.cooldown--;
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

  ItemSlot getItemObjectAtSlotType(SlotType slotType, int index) =>
    switch (slotType) {
      SlotType.Equipped_Hand_Left => equippedHandLeft,
      SlotType.Equipped_Hand_Right => equippedHandRight,
      SlotType.Equipped_Body => equippedBody,
      SlotType.Equipped_Helm => equippedHelm,
      SlotType.Equipped_Legs => equippedLegs,
      SlotType.Equipped_Shoes => equippedShoe,
      SlotType.Items => items[index],
      SlotType.Treasures => treasures[index],
      SlotType.Weapons => weapons[index]
    };

  void useInventorySlot(SlotType slotType, int index) {
    if (index < 0)
      return;

    switch (slotType){
      case SlotType.Weapons:
        selectWeapon(index);
        // equippedWeaponIndex = index;
        return;

      case SlotType.Items:
        if (index >= items.length)
          return;

        final inventorySlot = items[index];
        final item = inventorySlot.item;

        if (item == null)
          return;

        if (item.isConsumable){
          final consumableType = item.subType;
          consumeItem(consumableType);
          clearSlot(inventorySlot);
          writePlayerEventItemTypeConsumed(consumableType);
          return;
        }
        break;

      default:
        break;
    }
  }

  void consumeItem(int consumableType) {
      switch (consumableType) {
        case ConsumableType.Health_Potion:
          health += 10;
          break;

      }
  }

  void inventoryDrop(SlotType slotType, int index) {
    switch (slotType) {
      case SlotType.Items:
        dropItem(index);
        break;
      case SlotType.Equipped_Helm:
        dropEquippedHelm();
        break;
      case SlotType.Equipped_Body:
        dropEquippedBody();
        break;
      case SlotType.Equipped_Legs:
        dropEquippedLegs();
        break;
      case SlotType.Equipped_Hand_Left:
        dropEquippedHandLeft();
        break;
      case SlotType.Equipped_Hand_Right:
        dropEquippedHandRight();
        break;
      case SlotType.Weapons:
        dropWeapon(index);
        break;
      case SlotType.Treasures:
        dropTreasure(index);
        break;
      case SlotType.Equipped_Shoes:
        dropEquippedShoes(index);
        break;
    }
  }

  void dropEquippedShoes(int index) {
    final item = equippedShoe.item;
    if (item == null)
      return;
    spawnItem(item);
    equipShoes(null);
  }

  void writeAmuletElements() {
    writeByte(NetworkResponse.Amulet_Player);
    writeByte(NetworkResponseAmuletPlayer.Elements);
    writeByte(elementFire);
    writeByte(elementWater);
    writeByte(elementWind);
    writeByte(elementEarth);
    writeByte(elementElectricity);
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
      case AmuletElement.wind:
        elementWind++;
        break;
      case AmuletElement.earth:
        elementEarth++;
        break;
      case AmuletElement.electricity:
        elementElectricity++;
        break;
    }
    writeAmuletElements();
  }
}