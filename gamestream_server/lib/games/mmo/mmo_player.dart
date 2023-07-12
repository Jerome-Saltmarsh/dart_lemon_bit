
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/games.dart';
import 'package:gamestream_server/games/mmo/mmo_item.dart';
import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/lemon_math.dart';

import 'mmo_npc.dart';

class MmoPlayer extends IsometricPlayer {

  static const Interact_Radius = 80.0;

  final MmoGame game;

  var interacting = false;
  var npcText = '';
  var npcOptions = <TalkOption>[];

  MMOItem? _equippedWeapon;

  MMOItem? get equippedWeapon => _equippedWeapon;

  late ItemList items;

  MmoPlayer({
    required this.game,
    required int itemLength,
    required super.x,
    required super.y,
    required super.z,
  })
      : super(game: game, health: 10, team: MmoTeam.Human) {
    equipWeapon(WeaponType.Unarmed);
    setItemLength(itemLength);

    setItem(
        index: 0,
        type: GameObjectType.Weapon,
        subType: WeaponType.Handgun,
    );

    setItem(
        index: 1,
        type: GameObjectType.Consumable,
        subType: ConsumableType.Health_Potion,
    );
  }

  bool get targetWithinInteractRadius => targetWithinRadius(Interact_Radius);

  set equippedWeapon(MMOItem? value){
    if (_equippedWeapon == value) return;
    _equippedWeapon = value;
    // weaponType = value.subType;
  }

  void setItemLength(int value){
    items = ItemList(value);
    writeItemLength(value);
  }

  bool addGameObject(IsometricGameObject gameObject) =>
      addItem(type: gameObject.type, subType: gameObject.subType);

  bool addItem({required int type, required int subType}){
    final emptyIndex = items.getEmptyIndex();
    if (emptyIndex == -1){
      writeGameError(GameError.Inventory_Full);
      return false;
    }
    setItem(index: emptyIndex, type: type, subType: subType);
    return true;
  }

  void setItem({required int index, required int type, required int subType}){
    items.set(index: index, type: type, subType: subType);
    writePlayerItem(index, type, subType);
  }

  void writePlayerItem(int index, int type, int subType) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Item);
    writeByte(index);
    writeByte(type);
    writeByte(subType);
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

  void dropItem(int index){
    if (!items.isValidItemIndex(index)) {
      writeGameError(GameError.Invalid_Item_Index);
      return;
    }
    final itemType = items.types[index];
    final subType = items.subTypes[index];

    if (itemType == 0)
      return;

    clearItem(index);

    const spawnDistance = 40.0;
    final spawnAngle = randomAngle();


    game.spawnLoot(
        x: x + adj(spawnAngle, spawnDistance),
        y: y + opp(spawnAngle, spawnDistance),
        z: z,
        type: itemType,
        subType: subType,
    );

  }

  void clearItem(int index) => setItem(index: index, type: 0, subType: 0);

  void selectItem(int index) {
    if (!items.isValidItemIndex(index)) {
      writeGameError(GameError.Invalid_Item_Index);
      return;
    }

    final itemType = items.types[index];

    if (itemType == 0)
      return;

    final subType = items.subTypes[index];

    if (itemType == GameObjectType.Consumable){
      if (subType == ConsumableType.Health_Potion){
         health = maxHealth;
         clearItem(index);
      }
      return;
    }

    equip(type: itemType, subType: subType);
  }

  void selectNpcTalkOption(int index) {
     if (index < 0 || index >= npcOptions.length){
       writeGameError(GameError.Invalid_Talk_Option);
       return;
     }
     npcOptions[index].action();
  }

  void equip({required int type, required int subType}) {
    switch (type) {
      case GameObjectType.Weapon:
        equipWeapon(subType);
        break;
      case GameObjectType.Head:
        equipHead(subType);
        break;
      case GameObjectType.Body:
        equipBody(subType);
        break;
      case GameObjectType.Legs:
        setLegsType(subType);
        break;
    }
  }

  void equipWeapon(int weaponType){
    if (deadBusyOrWeaponStateBusy)
      return;
    this.weaponType = weaponType;
    weaponDamage = getWeaponDamage(weaponType);
    weaponRange = getWeaponRange(weaponType);
    weaponCooldown = getWeaponCooldown(weaponType);
    weaponAccuracy = getWeaponAccuracy(weaponType);
  }

  void equipHead(int value){
    if (deadBusyOrWeaponStateBusy)
      return;
    headType = value;
    setCharacterStateChanging();
  }

  void equipBody(int value){
    if (deadBusyOrWeaponStateBusy)
      return;
    bodyType = value;
    setCharacterStateChanging();
  }

  void setLegsType(int value){
    legsType = value;
    setCharacterStateChanging();
  }

  int getWeaponDamage(int weaponType) => const {
        WeaponType.Unarmed: 1,
        WeaponType.Shotgun: 2,
        WeaponType.Machine_Gun: 2,
        WeaponType.Sniper_Rifle: 5,
        WeaponType.Handgun: 2,
        WeaponType.Smg: 1,
        WeaponType.Grenade: 10,
        WeaponType.Staff: 1,
     // }[weaponType] ?? (throw Exception('getWeaponDamage(${GameObjectType.getNameSubType(GameObjectType.Weapon, weaponType)})'));
     }[weaponType] ?? 1;

  double getWeaponRange(int weaponType) => const <int, double> {
        WeaponType.Unarmed: 50,
        WeaponType.Shotgun: 200,
        WeaponType.Machine_Gun: 250,
        WeaponType.Sniper_Rifle: 300,
        WeaponType.Handgun: 200,
        WeaponType.Smg: 180,
     }[weaponType] ?? (throw Exception('getWeaponDamage(${GameObjectType.getNameSubType(GameObjectType.Weapon, weaponType)})'));

  int getWeaponCooldown(int weaponType) => {
        WeaponType.Unarmed: 14,
        WeaponType.Shotgun: 25,
        WeaponType.Machine_Gun: 5,
        WeaponType.Sniper_Rifle: 35,
        WeaponType.Handgun: 15,
        WeaponType.Smg: 10,
     }[weaponType] ?? (throw Exception('getWeaponDamage(${GameObjectType.getNameSubType(GameObjectType.Weapon, weaponType)})'));

  double getWeaponAccuracy(int weaponType) {
    return 0.5;
  }
}