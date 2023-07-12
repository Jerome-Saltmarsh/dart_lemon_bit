
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games.dart';
import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/lemon_math.dart';

import 'mmo_npc.dart';

class MmoPlayer extends IsometricPlayer {

  static const Interact_Radius = 80.0;

  final MmoGame game;

  var interacting = false;
  var npcText = '';
  var npcOptions = <TalkOption>[];

  final weapons = List<MMOItem?>.generate(4, (index) => null);

  var _equippedWeaponIndex = -1;

  late List<MMOItem?> items;

  MmoPlayer({
    required this.game,
    required int itemLength,
    required super.x,
    required super.y,
    required super.z,
  }) : super(game: game, health: 10, team: MmoTeam.Human) {
    runInDirectionEnabled = false;
    setItemsLength(itemLength);
    addItem(MMOItem.Rusty_Old_Sword);
    addItem(MMOItem.Old_Bow);
    addItem(MMOItem.Health_Potion);
    equippedWeaponIndex = 0;
  }

  MMOItem? get equippedWeapon => _equippedWeaponIndex == -1 ? null : weapons[_equippedWeaponIndex];

  bool get targetWithinInteractRadius => targetWithinRadius(Interact_Radius);

  set equippedWeaponIndex(int value){
    if (_equippedWeaponIndex == value){
      return;
    }

    if (value == -1){
      _equippedWeaponIndex = value;
      setCharacterStateChanging();
      writeEquippedWeaponIndex(value);
      return;
    }
    if (!isValidWeaponIndex(value)){
      return;
    }
    final item = weapons[value];

    if (item == null || item.type != GameObjectType.Weapon)
      return;

    _equippedWeaponIndex = value;
    writeEquippedWeaponIndex(value);
  }

  void attack() {
    setDestinationToCurrentPosition();
    setCharacterStateIdle();
    game.characterAttack(this);
  }

  void writeEquippedWeaponIndex(int value) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Equipped_Weapon_Index);
    writeInt16(value);
  }

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
    final emptyItemIndex = getEmptyItemIndex();

    if (emptyItemIndex == -1) {
      writeGameError(GameError.Inventory_Full);
      return false;
    }

    setItem(index: emptyItemIndex, item: item);
    return true;
  }

  int getEmptyItemIndex(){
    for (var i = 0; i < items.length; i++){
      if (items[i] == null)
        return i;
    }
    return -1;
  }

  int getEmptyWeaponIndex(){
     for (var i = 0; i < weapons.length; i++){
       if (weapons[i] == null)
         return i;
     }
     return -1;
  }

  void setWeapon({required int index, required MMOItem? item}){
    if (!isValidWeaponIndex(index)) {
      writeGameError(GameError.Invalid_Weapon_Index);
      return;
    }
    if (item != null && !item.isWeapon)
      return;

    weapons[index] = item;
    writePlayerWeapon(index, item);
  }

  void setItem({required int index, required MMOItem? item}){
    if (!isValidItemIndex(index)) {
      writeGameError(GameError.Invalid_Item_Index);
      return;
    }
    items[index] = item;
    writePlayerItem(index, item);
  }

  void writePlayerWeapon(int index, MMOItem? item) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Weapon);
    writeUInt16(index);
    if (item == null){
      writeInt16(-1);
      return;
    }
    writeInt16(item.index);
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

  @override
  void customOnUpdate() {
    updateInteracting();
  }

  void updateInteracting() {
    final target = this.target;
    if (interacting) {
      if (target == null || !targetWithinInteractRadius){
        endInteraction();
      }
      return;
    }

    if (target is! MMONpc)
      return;

    if (!targetWithinInteractRadius)
      return;

    final interact = target.interact;

    if (interact == null)
      return;

    interact(this);
    interacting = true;
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

  void dropWeapon(int index){
    if (!isValidWeaponIndex(index)) {
      return;
    }
    final item = weapons[index];
    if (item == null) {
      return;
    }

    clearWeapon(index);
    const spawnDistance = 40.0;
    final spawnAngle = randomAngle();
    game.spawnLoot(
        x: x + adj(spawnAngle, spawnDistance),
        y: y + opp(spawnAngle, spawnDistance),
        z: z,
        item: item,
    );
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

  void clearItem(int index) => setItem(index: index, item: null);

  bool isValidWeaponIndex(int index) => index >= 0 && index < weapons.length;

  bool isValidItemIndex(int index) => index >= 0 && index < items.length;

  void selectWeapon(int index) {
    if (!isValidWeaponIndex(index)) {
      writeGameError(GameError.Invalid_Item_Index);
      return;
    }

    final item = weapons[index];

    if (item == null)
      return;

    equippedWeaponIndex = index;
    attack();
  }

  void selectItem(int index) {
    if (!isValidItemIndex(index)) {
      return;
    }

    final item = items[index];

    if (item == null)
      return;

    final itemType = item.type;
    final subType = item.subType;

    if (itemType == GameObjectType.Consumable){
      if (subType == ConsumableType.Health_Potion){
         health = maxHealth;
         clearItem(index);
      }
      return;
    }

    switch (item.type) {
      case GameObjectType.Consumable:
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
        equipHead(item);
        break;
      case GameObjectType.Body:
        equipBody(item);
        break;
      case GameObjectType.Legs:
        setLegsType(item);
        break;
    }
  }

  void selectNpcTalkOption(int index) {
     if (index < 0 || index >= npcOptions.length){
       writeGameError(GameError.Invalid_Talk_Option);
       return;
     }
     npcOptions[index].action();
  }

  @override
  int get weaponType => equippedWeapon != null ? equippedWeapon!.subType : WeaponType.Unarmed;

  @override
  int get weaponCooldown => equippedWeapon != null ? equippedWeapon!.cooldown : -1;

  @override
  int get weaponDamage => equippedWeapon != null ? equippedWeapon!.damage : 1;

  @override
  double get weaponRange => equippedWeapon != null ? equippedWeapon!.range : 30;

  void equipHead(MMOItem item){
    if (deadBusyOrWeaponStateBusy)
      return;
    headType = item.subType;
    setCharacterStateChanging();
  }

  void equipBody(MMOItem item){
    if (deadBusyOrWeaponStateBusy)
      return;
    bodyType = item.subType;
    setCharacterStateChanging();
  }

  void setLegsType(MMOItem item){
    legsType = item.subType;
    setCharacterStateChanging();
  }
}