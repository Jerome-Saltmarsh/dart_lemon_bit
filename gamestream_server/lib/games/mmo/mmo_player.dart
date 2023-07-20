
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games.dart';
import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/lemon_math.dart';

import 'mmo_npc.dart';

class MmoPlayer extends IsometricPlayer {

  static const Interact_Radius = 80.0;

  final MmoGame game;

  var healthBase = 10;
  var npcText = '';
  var npcOptions = <TalkOption>[];
  var performingActivePower = false;

  final weapons = List<MMOItem?>.generate(4, (index) => null);
  final treasures = List<MMOItem?>.generate(4, (index) => null);
  final talents = List.generate(MMOTalentType.values.length, (index) => false, growable: false);

  MMOItem? equippedHead;
  MMOItem? equippedBody;
  MMOItem? equippedLegs;

  late List<MMOItem?> items;


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
    addItem(MMOItem.Old_Bow);
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
    writePlayerSkillPoints();
    writePlayerSkillsDialogOpen();
    writePlayerTalents();
  }

  int get equippedWeaponType {
    final weapon = equippedWeapon;
    if (weapon == null)
      return WeaponType.Unarmed;
    return weapon.subType;
  }

  int get experience => _experience;

  int get experienceRequired => _experienceRequired;

  int get level => _level;

  int get skillPoints => _skillPoints;

  bool get skillsDialogOpen => _skillsDialogOpen;

  bool get inventoryOpen => _inventoryOpen;

  @override
  int get weaponCooldown => equippedWeapon != null ? equippedWeapon!.cooldown : -1;

  @override
  int get weaponDamage => equippedWeapon != null ? equippedWeapon!.damage : 1;

  @override
  double get weaponRange => equippedWeapon != null ? equippedWeapon!.range : 30;

  @override
  int get headType => equippedHead != null ? equippedHead!.subType : HeadType.Plain;

  int get activatedPowerIndex => _activatedPowerIndex;

  @override
  int get maxHealth {
    var health = healthBase;
    if (equippedHead != null){
      health += equippedHead!.health;
    }
    if (equippedBody != null){
      health += equippedBody!.health;
    }
    if (equippedLegs != null){
      health += equippedLegs!.health;
    }
    for (final treasure in treasures){
      if (treasure != null)
        health += treasure.health;
    }

    if (talentUnlocked(MMOTalentType.Healthy_1)){
        health += 10;
    }

    if (talentUnlocked(MMOTalentType.Healthy_2)){
      health += 15;
    }

    if (talentUnlocked(MMOTalentType.Healthy_3)){
      health += 20;
    }

    return health;
  }

  @override
  double get runSpeed {
    var base = 1.0;
    if (equippedHead != null){
      base += equippedHead!.movement;
    }
    if (equippedBody != null){
      base += equippedBody!.movement;
    }
    if (equippedLegs != null){
      base += equippedLegs!.movement;
    }
    return base;
  }

  MMOItem? get equippedWeapon => _equippedWeaponIndex == -1 ? null : weapons[_equippedWeaponIndex];

  bool get targetWithinInteractRadius => targetWithinRadius(Interact_Radius);

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

  set skillPoints(int value){
    _skillPoints = value;
    writePlayerSkillPoints();
  }

  set skillsDialogOpen(bool value){
    _skillsDialogOpen = value;
    writePlayerSkillsDialogOpen();
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

    if (weapon == null || weapon.type != GameObjectType.Weapon){
      return;
    }

    _equippedWeaponIndex = value;
    weaponType = equippedWeaponType;
    actionFrame = weapon.performFrame;
    writeEquippedWeaponIndex(value);
  }

  // void useEquippedWeapon() {
  //
  //   final weapon = equippedWeapon;
  //   if (weapon == null) return;
  //   final attackType = weapon.attackType;
  //   if (attackType == null) return;
  //
  //   setDestinationToCurrentPosition();
  //   setCharacterStateIdle();
  //   game.characterAttack(this);
  // }

  void setItemsLength(int value){
    items = List.generate(value, (index) => null);
    writeItemLength(value);
  }

  bool addItem(MMOItem item){

    if (item.isWeapon) {
      final emptyIndex = getEmptyWeaponIndex();
      if (emptyIndex != -1){
        setWeapon(index: emptyIndex, item: item);
        return true;
      }
    }

    if (item.isHead){
      if (equippedHead == null){
        equipHead(item);
        return true;
      }
    }

    final emptyItemIndex = getEmptyItemIndex();

    if (emptyItemIndex == -1) {
      writeGameError(GameError.Inventory_Full);
      return false;
    }

    setItem(index: emptyItemIndex, item: item);
    return true;
  }

  int getEmptyItemIndex()=> getEmptyIndex(items);

  int getEmptyWeaponIndex() => getEmptyIndex(weapons);

  int getEmptyIndexTreasure() => getEmptyIndex(treasures);

  void setWeapon({required int index, required MMOItem? item}){
    if (!isValidWeaponIndex(index)) {
      writeGameError(GameError.Invalid_Weapon_Index);
      return;
    }
    if (item != null && !item.isWeapon)
      return;

    weapons[index] = item;
    writePlayerWeapon(index);
  }

  void setTreasure({required int index, required MMOItem? item}){
    if (deadBusyOrWeaponStateBusy)
      return;

    if (!isValidIndexTreasure(index)) {
      writeGameError(GameError.Invalid_Treasure_Index);
      return;
    }
    if (item != null && !item.isTreasure)
      return;

    setCharacterStateChanging();
    treasures[index] = item;
    writePlayerTreasure(index);
  }

  void setItem({required int index, required MMOItem? item}){
    if (!isValidItemIndex(index)) {
      writeGameError(GameError.Invalid_Item_Index);
      return;
    }
    items[index] = item;
    writePlayerItem(index, item);
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
    final item = weapons[index];
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
    final item = treasures[index];
    if (item == null) {
      return;
    }

    clearTreasure(index);
    spawnItem(item);
  }

  void dropEquippedHead(){
    if (equippedHead == null)
      return;

    spawnItem(equippedHead!);
    equipHead(null);
  }

  void dropEquippedBody(){
    if (equippedBody == null)
      return;

    spawnItem(equippedBody!);
    equipBody(null);
  }

  void dropEquippedLegs(){
    if (equippedLegs == null)
      return;

    spawnItem(equippedLegs!);
    equipLegs(null);
  }

  void dropItem(int index){
    if (!isValidItemIndex(index)) {
      return;
    }
    final item = items[index];
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

  void clearWeapon(int index) => setWeapon(index: index, item: null);

  void clearTreasure(int index) => setTreasure(index: index, item: null);

  void clearItem(int index) => setItem(index: index, item: null);

  bool isValidWeaponIndex(int index) => index >= 0 && index < weapons.length;

  bool isValidItemIndex(int index) => index >= 0 && index < items.length;

  bool isValidIndexTreasure(int index) => index >= 0 && index < treasures.length;

  void selectWeapon(int index) {
     if (deadBusyOrWeaponStateBusy)
       return;

    if (!isValidWeaponIndex(index)) {
      writeGameError(GameError.Invalid_Item_Index);
      return;
    }

    final weapon = weapons[index];

    if (weapon == null)
      return;

    final attackType = weapon.attackType;

    if (attackType == null)
      throw Exception();

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

    final item = items[index];

    if (item == null)
      return;

    final itemType = item.type;
    final subType = item.subType;

    if (item.isTreasure) {
      final emptyTreasureIndex = getEmptyIndexTreasure();
      if (emptyTreasureIndex == -1){
        writeGameError(GameError.Treasures_Full);
        return;
      }

      setTreasure(index: emptyTreasureIndex, item: item);
      clearItem(index);
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
          setWeapon(index: emptyWeaponIndex, item: item);
          clearItem(index);
          setCharacterStateChanging();
        } else {
          final currentWeapon = equippedWeapon;
          setWeapon(index: _equippedWeaponIndex, item: item);
          setItem(index: index, item: currentWeapon);
          setCharacterStateChanging();
        }
        break;
      case GameObjectType.Head:
        if (equippedHead != null){
          final equipped = equippedHead;
          equipHead(item);
          setItem(index: index, item: equipped);
        } else {
          equipHead(item);
          clearItem(index);
        }
        break;
      case GameObjectType.Body:
        if (equippedHead != null){
          final equipped = equippedHead;
          equipBody(item);
          setItem(index: index, item: equipped);
        } else {
          equipHead(item);
          clearItem(index);
        }
        break;
      case GameObjectType.Legs:
        if (equippedLegs != null){
          final equipped = equippedLegs;
          equipLegs(item);
          setItem(index: index, item: equipped);
        } else {
          equipLegs(item);
          clearItem(index);
        }
        break;
    }
  }

  void selectTreasure(int index) {
    if (!isValidIndexTreasure(index)) {
      return;
    }

    final item = treasures[index];

    if (item == null)
      return;

    final emptyItemIndex = getEmptyItemIndex();

    if (emptyItemIndex == -1){
      writeGameError(GameError.Inventory_Full);
      return;
    }

    clearTreasure(index);
    setItem(index: emptyItemIndex, item: item);
  }

  void selectNpcTalkOption(int index) {
     if (index < 0 || index >= npcOptions.length){
       writeGameError(GameError.Invalid_Talk_Option);
       return;
     }
     npcOptions[index].action();
  }

  void equipHead(MMOItem? item){
    if (deadBusyOrWeaponStateBusy)
      return;

    if (equippedHead == item)
      return;

    if (item == null){
      equippedHead = null;
      onEquipmentChanged();
      return;
    }

    if (!item.isHead)
      return;

    equippedHead = item;
    onEquipmentChanged();
  }

  void equipBody(MMOItem? item){
    if (deadBusyOrWeaponStateBusy)
      return;

    if (equippedBody == item)
      return;

    if (item == null){
      equippedBody = null;
      onEquipmentChanged();
      return;
    }

    if (!item.isBody)
      return;

    equippedBody = item;
    onEquipmentChanged();
  }

  void equipLegs(MMOItem? item){
    if (deadBusyOrWeaponStateBusy)
      return;

    if (equippedLegs == item)
      return;

    if (item == null){
      equippedLegs = null;
      onEquipmentChanged();
      return;
    }

    if (!item.isLegs)
      return;

    equippedLegs = item;
    onEquipmentChanged();
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

  void onEquipmentChanged(){
    setCharacterStateChanging();
    health = clamp(health, 0, maxHealth);
    headType = equippedHead?.subType ?? HeadType.Plain;
    bodyType = equippedBody?.subType ?? BodyType.Nothing;
    legsType = equippedLegs?.subType ?? LegType.Nothing;
    weaponType = equippedWeapon?.subType ?? WeaponType.Unarmed;
    writeEquipped();
  }

  void writeEquipped(){
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Equipped);
    writeMMOItem(equippedHead);
    writeMMOItem(equippedBody);
    writeMMOItem(equippedLegs);
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
    final weapon = weapons[index];
    if (weapon == null){
      writeInt16(-1);
      return;
    }
    writeInt16(weapon.index);
  }

  void writePlayerTreasure(int index) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Treasure);
    writeUInt16(index);
    final treasure = treasures[index];
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

  void writePlayerSkillPoints() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_SkillPoints);
    writeByte(skillPoints);
  }

  void writePlayerSkillsDialogOpen() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Skills_Dialog_Open);
    writeBool(skillsDialogOpen);
  }

  void writePlayerInventoryOpen() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Inventory_Open);
    writeBool(inventoryOpen);
  }

  void toggleSkillsDialog() {
    skillsDialogOpen = !skillsDialogOpen;
  }

  static int getEmptyIndex(List<MMOItem?> items){
    for (var i = 0; i < items.length; i++){
      if (items[i] == null)
        return i;
    }
    return -1;
  }

  bool parentTalentRequiredToUnlock(MMOTalentType talent){
    final parent = talent.parent;
    return parent != null && !talentUnlocked(parent);
  }

  bool talentUnlocked(MMOTalentType talent) => talents[talent.index];

  void unlockTalent(MMOTalentType talent) {

    if (skillPoints <= 0){
      writeGameError(GameError.Insufficient_Skill_Points);
      return;
    }

     if (talentUnlocked(talent)){
       writeGameError(GameError.Talent_Already_Unlocked);
       return;
     }

     if (parentTalentRequiredToUnlock(talent)){
       writeGameError(GameError.Parent_Talent_Required_To_Unlock);
       return;
     }

     assert (!talents[talent.index]);
     talents[talent.index] = true;
     skillPoints--;
     writePlayerTalents();
     writePlayerHealth();
  }

  void writePlayerTalents() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Talents);
    talents.forEach(writeBool);
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

    if (weapon == null){
      throw Exception();
    }

    final attackType = weapon.attackType;

    if (attackType == null)
      throw Exception();

    switch (attackType.mode) {
      case PowerMode.Equip:
        throw Exception();
      case PowerMode.Self:
        setCharacterStatePerforming(
            actionFrame: weapon.performFrame,
            duration: weapon.performDuration,
        );
        break;
      case PowerMode.Targeted_Enemy:
        if (target == null) {
          deselectActivatedPower();
          return;
        }
        actionFrame = weapon.performFrame;
        setCharacterStatePerforming(
            actionFrame: weapon.performFrame,
            duration: weapon.performDuration,
        );
        break;
      case PowerMode.Targeted_Ally:
        if (target == null) {
          deselectActivatedPower();
          return;
        }
        setCharacterStatePerforming(
          actionFrame: weapon.performFrame,
          duration: weapon.performDuration,
        );
        break;
      case PowerMode.Positional:
        weaponState = WeaponState.Performing;
        actionFrame = weapon.performFrame;
        weaponType = weapon.subType;
        performingActivePower = true;
        weaponStateDuration = 0;
        weaponStateDurationTotal = weapon.performDuration;
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

      if (weapon == null)
        throw Exception();

      final attackType = weapon.attackType;

      if (attackType == null){
        throw Exception();
      }

      switch (attackType) {
        case MMOAttackType.Blink:
          x = mouseSceneX;
          y = mouseSceneY;
          z = mouseSceneZ;
          break;
        default:
          throw Exception("Power Not Implemented $attackType");
      }

      if (equippedWeapon != null) {
        weaponType = equippedWeapon!.subType;
      } else {
        weaponType = WeaponType.Unarmed;
      }
      deselectActivatedPower();
      setCharacterStateIdle();
      setDestinationToCurrentPosition();
      clearPath();
  }

  int _weaponStateDuration = 0;

  int get weaponStateDurationTotal => _weaponStateDuration;

  @override
  set weaponStateDurationTotal(int value){
    _weaponStateDuration = value;
  }

  void unequipHead() {
    if (equippedHead == null)
      return;

    final availableItemIndex = getEmptyItemIndex();
    if (availableItemIndex == -1){
      reportInventoryFull();
      return;
    }

    setItem(index: availableItemIndex, item: equippedHead);
    equippedHead = null;
    onEquipmentChanged();
  }

  void unequipBody() {
    if (equippedBody == null)
      return;

    final availableItemIndex = getEmptyItemIndex();
    if (availableItemIndex == -1){
      reportInventoryFull();
      return;
    }

    setItem(index: availableItemIndex, item: equippedBody);
    equippedBody = null;
    onEquipmentChanged();
  }

  void unequipLegs() {
    if (equippedLegs == null)
      return;

    final availableItemIndex = getEmptyItemIndex();
    if (availableItemIndex == -1){
      reportInventoryFull();
      return;
    }

    setItem(index: availableItemIndex, item: equippedLegs);
    equippedLegs = null;
    onEquipmentChanged();
  }

  void reportInventoryFull(){

  }
}