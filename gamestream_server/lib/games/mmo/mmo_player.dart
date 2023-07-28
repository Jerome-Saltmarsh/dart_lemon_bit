
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games.dart';
import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/lemon_math.dart';
import 'package:gamestream_server/utils/is_valid_index.dart';

class MmoPlayer extends IsometricPlayer {

  final MmoGame game;

  var equipmentDirty = true;
  var activePowerX = 0.0;
  var activePowerY = 0.0;
  var activePowerZ = 0.0;

  var healthBase = 10;
  var npcText = '';
  var npcOptions = <TalkOption>[];
  var performingActivePower = false;

  final weapons = List<MMOItemObject>.generate(4, (index) => MMOItemObject());
  final treasures = List<MMOItemObject>.generate(4, (index) => MMOItemObject());
  final talents = List.generate(MMOTalentType.values.length, (index) => 0, growable: false);

  final equippedHead = MMOItemObject();
  final equippedBody = MMOItemObject();
  final equippedLegs = MMOItemObject();

  late List<MMOItemObject> items;

  var _inventoryOpen = false;
  var _skillsDialogOpen = false;
  var _experience = 0;
  var _experienceRequired = 1;
  var _level = 1;
  var _equippedWeaponIndex = -1;
  var _activatedPowerIndex = -1;
  var _skillPoints = 1;

  MmoPlayer({
    required this.game,
    required int itemLength,
    required super.x,
    required super.y,
    required super.z,
  }) : super(game: game, health: 10, team: MmoTeam.Human) {
    controlsRunInDirectionEnabled = false;
    controlsCanTargetEnemies = true;
    defaultAction = false;
    hurtStateBusy = false;
    setItemsLength(itemLength);
    addItem(MMOItem.Rusty_Old_Sword);
    addItem(MMOItem.Staff_Of_Frozen_Lake);
    addItem(MMOItem.Holy_Bow);
    addItem(MMOItem.Health_Potion);
    addItem(MMOItem.Steel_Helmet);
    addItem(MMOItem.Blink_Dagger);
    addItem(MMOItem.Sapphire_Pendant);
    equipHead(MMOItem.Steel_Helmet);
    equipBody(MMOItem.Basic_Padded_Armour);
    equipLegs(MMOItem.Travellers_Pants);
    health = maxHealth;
    equippedWeaponIndex = 0;

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
  int get headType => equippedHead.item?.subType ?? HeadType.Plain;

  int get activatedPowerIndex => _activatedPowerIndex;

  @override
  int get maxHealth {
    var health = healthBase;
    health += equippedHead.health;
    health += equippedBody.health;
    health += equippedLegs.health;

    for (final treasure in treasures){
      health += treasure.health;
    }

    final talentHealthLevel = talents[MMOTalentType.Healthy.index];
    health += talentHealthLevel * MMOTalentType.Healthy_Health_Per_Level;
    return health;
  }

  @override
  double get runSpeed {
    var base = 1.0;

    base += equippedHead.movement;
    base += equippedBody.movement;
    base += equippedLegs.movement;
    return base;
  }

  MMOItemObject? get equippedWeapon => _equippedWeaponIndex == -1 ? null : weapons[_equippedWeaponIndex];

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
  set target(IsometricPosition? value){
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

    if (item == null || item.type != GameObjectType.Weapon){
      return;
    }

    _equippedWeaponIndex = value;
    weaponType = equippedWeaponType;
    actionFrame = item.performFrame;
    writeEquippedWeaponIndex(value);
  }

  @override
  void writePlayerGame() {
    cleanEquipment();
    super.writePlayerGame();
  }

  void setItemsLength(int value){
    items = List.generate(value, (index) => MMOItemObject());
    writeItemLength(value);
  }

  bool addItem(MMOItem item){

    if (deadBusyOrWeaponStateBusy)
      return false;

    if (item.isWeapon) {
      final emptyIndex = getEmptyWeaponIndex();
      if (emptyIndex != -1){
        setWeapon(
            index: emptyIndex,
            item: item,
            cooldown: 0,
        );
        return true;
      }
    }

    if (item.isHead && equippedHead.item == null){
      equipHead(item);
      return true;
    }

    if (item.isBody && equippedBody.item == null){
      equipBody(item);
      return true;
    }

    if (item.isLegs && equippedLegs.item == null) {
      equipLegs(item);
      return true;
    }

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
    required MMOItem? item,
    required int cooldown,
  }){
    if (!isValidWeaponIndex(index)) {
      writeMMOError('Invalid weapon index $index');
      return;
    }
    if (item != null && !item.isWeapon)
      return;

    weapons[index].item = item;
    weapons[index].cooldown = cooldown;
    writePlayerWeapon(index);
  }

  void setTreasure({required int index, required MMOItem? item}){
    if (deadBusyOrWeaponStateBusy)
      return;

    if (!isValidIndexTreasure(index)) {
      writeMMOError('Invalid treasure index $index');
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
    required MMOItem? item,
    required int cooldown,
  }){
    if (!isValidItemIndex(index)) {
      writeMMOError('Invalid item index $index');
      return;
    }
    final slot = items[index];
    slot.item = item;
    slot.cooldown = cooldown;
    notifyEquipmentDirty();
    setCharacterStateChanging();
  }

  @override
  int getTargetCategory(IsometricPosition? value){
    if (value == null) return TargetCategory.Nothing;
    if (value is IsometricGameObject) {
      if (value.interactable) {
        return TargetCategory.Talk;
      }
      if (value.collectable) {
        return TargetCategory.Collect;
      }
      return TargetCategory.Nothing;
    }

    if (isAlly(value)) {
      if (value is MMONpc && value.interact != null) {
        return TargetCategory.Talk;
      }
    }
    if (isEnemy(value)) return TargetCategory.Attack;
    return TargetCategory.Run;
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

  void dropEquippedHead(){

    final equippedHeadItem = equippedHead.item;

    if (equippedHeadItem == null)
      return;

    spawnItem(equippedHeadItem);
    equipHead(null);
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

  void spawnItem(MMOItem item){
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
     if (deadBusyOrWeaponStateBusy)
       return;

    if (!isValidWeaponIndex(index)) {
      writeMMOError('Invalid weapon index $index');
      return;
    }

    final slot = weapons[index];
    final weapon = slot.item;

    if (weapon == null)
      return;

    final attackType = weapon.attackType;

    if (attackType == null) {
      writeMMOError('selected weapon attack type is null ($index)');
      return;
    }

    if (slot.cooldown > 0) {
      writeMMOError('${slot.item?.name} is cooling down');
      return;
    }

    switch (attackType.mode) {
      case PowerMode.Equip:
        equippedWeaponIndex = index;
        deselectActivatedPower();
        if (!controlsCanTargetEnemies){
          // useEquippedWeapon();
        }
        break;
      case PowerMode.Positional:
        if (activatedPowerIndex == index){
          deselectActivatedPower();
          return;
        }
        activatedPowerIndex = index;
        break;
      case PowerMode.Targeted_Ally:
        if (activatedPowerIndex == index){
          deselectActivatedPower();
          return;
        }
        activatedPowerIndex = index;
        break;
      case PowerMode.Targeted_Enemy:
        if (activatedPowerIndex == index){
          deselectActivatedPower();
          return;
        }
        activatedPowerIndex = index;
        break;
      case PowerMode.Self:
        // TODO CASTE STRAIGHT AWAY
        break;
    }


  }

  void deselectActivatedPower() {
    performingActivePower = false;
    activatedPowerIndex = -1;
  }

  void selectItem(int index) {
    if (deadBusyOrWeaponStateBusy)
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

    if (itemType == GameObjectType.Item){
      if (subType == ItemType.Health_Potion){
        health = maxHealth;
        setCharacterStateChanging();
        clearItem(index);
        writePlayerEvent(PlayerEvent.Drink);
      }
      return;
    }

    switch (item.type) {
      case GameObjectType.Item:
        break;
      case GameObjectType.Weapon:
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
      case GameObjectType.Head:
        swap(equippedHead, selected);
        break;
      case GameObjectType.Body:
        swap(equippedBody, selected);
        break;
      case GameObjectType.Legs:
        swap(equippedLegs, selected);
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
       writeMMOError('Invalid talk option index $index');
       return;
     }
     npcOptions[index].action();
  }

  void equipHead(MMOItem? item){
    if (deadBusyOrWeaponStateBusy)
      return;

    if (equippedHead.item == item)
      return;

    if (item == null){
      clearSlot(equippedHead);
      return;
    }

    if (!item.isHead)
      throw Exception();

    setSlot(
      slot: equippedHead,
      item: item,
      cooldown: item.cooldown,
    );
  }

  void equipBody(MMOItem? item){
    if (deadBusyOrWeaponStateBusy)
      return;

    if (equippedBody == item)
      return;

    if (item == null){
      clearSlot(equippedBody);
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
  }

  void equipLegs(MMOItem? item){
    if (deadBusyOrWeaponStateBusy)
      return;

    if (equippedLegs.item == item)
      return;

    if (item == null){
      clearSlot(equippedLegs);
      return;
    }

    if (!item.isLegs)
      throw Exception();

    setSlot(
        slot: equippedLegs,
        item: item,
        cooldown: item.cooldown,
    );
  }

  void pickupItem(MMOItem item) {

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

    assert (equippedHead.item?.isHead ?? true);
    assert (equippedBody.item?.isBody ?? true);
    assert (equippedLegs.item?.isLegs ?? true);
    assert (equippedWeapon?.item?.isWeapon ?? true);

    health = clamp(health, 0, maxHealth);
    headType = equippedHead.item?.subType ?? HeadType.Plain;
    bodyType = equippedBody.item?.subType ?? BodyType.Nothing;
    legsType = equippedLegs.item?.subType ?? LegType.Nothing;
    weaponType = equippedWeapon?.item?.subType ?? WeaponType.Unarmed;
    equipmentDirty = false;

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
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Equipped);
    writeMMOItem(equippedHead.item);
    writeMMOItem(equippedBody.item);
    writeMMOItem(equippedLegs.item);
  }

  void writeMMOItem(MMOItem? value){
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
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Interacting);
    writeBool(interacting);
  }

  void writeEquippedWeaponIndex(int value) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Equipped_Weapon_Index);
    writeInt16(value);
  }

  void writePlayerWeapon(int index) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Weapon);
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
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Treasure);
    writeUInt16(index);
    final treasure = treasures[index].item;
    if (treasure == null){
      writeInt16(-1);
      return;
    }
    writeInt16(treasure.index);
  }

  void writePlayerItem(int index, MMOItem? item) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Item);
    writeUInt16(index);
    if (item == null){
      writeInt16(-1);
      return;
    }
    writeInt16(item.index);
  }

  void writeNpcTalk() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Npc_Talk);
    writeString(npcText);
    writeByte(npcOptions.length);
    for (final option in npcOptions) {
      writeString(option.text);
    }
  }

  void writeItemLength(int value) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Item_Length);
    writeUInt16(value);
  }

  void writePlayerExperience() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Experience);
    writeUInt24(experience);
  }

  void writePlayerExperienceRequired() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Experience_Required);
    writeUInt24(experienceRequired);
  }

  void writePlayerLevel() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Level);
    writeByte(level);
  }

  void writePlayerTalentPoints() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Talent_Points);
    writeByte(talentPoints);
  }

  void writePlayerTalentDialogOpen() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Talent_Dialog_Open);
    writeBool(talentDialogOpen);
  }

  void writePlayerInventoryOpen() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Inventory_Open);
    writeBool(inventoryOpen);
  }

  void toggleSkillsDialog() {
    talentDialogOpen = !talentDialogOpen;
  }

  static MMOItemObject? getEmptySlot(List<MMOItemObject> items){
    for (final item in items) {
      if (item.item == null)
        return item;
    }
    return null;
  }

  static int getEmptyIndex(List<MMOItemObject> items){
    for (var i = 0; i < items.length; i++){
      if (items[i].item == null)
        return i;
    }
    return -1;
  }

  void upgradeTalent(MMOTalentType talent) {

     final currentLevel = talents[talent.index];

     if (currentLevel >= talent.maxLevel){
       writeMMOError("Maximum talent level reached");
       return;
     }

     final nextLevel = currentLevel + 1;
     final cost = nextLevel * talent.levelCostMultiplier;

     if (talentPoints < cost){
       writeMMOError('Insufficient talent points');
       return;
     }

     writePlayerEvent(PlayerEvent.Talent_Upgraded);
     talents[talent.index]++;
     talentPoints -= cost;
     writePlayerTalents();

     if (talent == MMOTalentType.Healthy){
       health = maxHealth;
     }

     writePlayerHealth();
  }

  void writePlayerTalents() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Talents);
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
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Activated_Power_Index);
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
      case PowerMode.Equip:
        throw Exception();
      case PowerMode.Self:
        setCharacterStatePerforming(
            actionFrame: item.performFrame,
            duration: item.performDuration,
        );
        break;
      case PowerMode.Targeted_Enemy:
        if (target == null) {
          deselectActivatedPower();
          return;
        }
        actionFrame = item.performFrame;
        setCharacterStatePerforming(
            actionFrame: item.performFrame,
            duration: item.performDuration,
        );
        break;
      case PowerMode.Targeted_Ally:
        if (target == null) {
          deselectActivatedPower();
          return;
        }
        setCharacterStatePerforming(
          actionFrame: item.performFrame,
          duration: item.performDuration,
        );
        break;
      case PowerMode.Positional:
        weaponState = WeaponState.Performing;
        actionFrame = item.performFrame;
        weaponType = item.subType;
        performingActivePower = true;
        weaponStateDuration = 0;
        weaponStateDurationTotal = item.performDuration;
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
        case MMOAttackType.Blink:
          game.dispatchGameEvent(GameEventType.Blink_Depart, x, y, z);
          x = activePowerX;
          y = activePowerY;
          z = activePowerZ;
          game.dispatchGameEvent(GameEventType.Blink_Arrive, x, y, z);
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
      swapWithAvailableItemSlot(equippedHead);

  void unequipBody() => swapWithAvailableItemSlot(equippedBody);

  void unequipLegs() => swapWithAvailableItemSlot(equippedLegs);

  void reportInventoryFull() =>
      writeMMOError('Inventory is full');

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

    if (attackType.mode == PowerMode.Positional) {
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
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Active_Power_Position);
    writeDouble(activePowerX);
    writeDouble(activePowerY);
    writeDouble(activePowerZ);
  }

  MMOItem? getWeaponAtIndex(int index) =>
      isValidIndex(index, weapons) ? weapons[index].item : null;


  void addToEmptyTreasureSlot(MMOItemObject slot){
    final item = slot.item;

    if (item == null || !item.isTreasure)
      throw Exception();

    final emptyTreasureSlot = getEmptySlot(treasures);
    if (emptyTreasureSlot == null){
      writeMMOError("Treasure slots full");
      return;
    }
    swap(slot, emptyTreasureSlot);
  }

  void swapWithAvailableItemSlot(MMOItemObject slot){
    if (slot.item == null)
      return;

    final availableItemSlot = getEmptyItemSlot();
    if (availableItemSlot == null){
      reportInventoryFull();
      return;
    }
    swap(availableItemSlot, slot);
  }

  MMOItemObject? getEmptyItemSlot() => getEmptySlot(items);


  void clearSlot(MMOItemObject slot){
    slot.clear();
    notifyEquipmentDirty();
  }

  void setSlot({
    required MMOItemObject slot,
    required MMOItem? item,
    required int cooldown,
  }) {
    slot.item = item;
    slot.cooldown = cooldown;
    notifyEquipmentDirty();
  }

  void swap(MMOItemObject a, MMOItemObject b){
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
  void handleRequestException(Object exception) {
    writeMMOError(exception.toString());
  }

  void writeMMOError(String error) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Error);
    writeString(error);
  }
}