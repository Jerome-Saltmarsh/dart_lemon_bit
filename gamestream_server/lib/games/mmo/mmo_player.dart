
import 'dart:typed_data';

import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/utils.dart';

import 'mmo_npc.dart';

class MmoPlayer extends IsometricPlayer {

  static const Destination_Radius_Interact = 80.0;
  static const Destination_Radius_Run = 50.0;

  var destinationRadius = Destination_Radius_Run;
  var interacting = false;

  late final npcText = ChangeNotifier("", onChangedNpcText);

  late int itemLength;
  late Uint8List itemTypes;
  late Uint8List itemSubTypes;

  MmoPlayer({required super.game, required int itemLength}) {
    setWeaponType(WeaponType.Unarmed);
    setItemLength(itemLength);

    setItem(
        index: 0,
        type: GameObjectType.Weapon,
        subType: WeaponType.Machine_Gun,
    );
    setItem(
        index: 1,
        type: GameObjectType.Weapon,
        subType: WeaponType.Shotgun,
    );
    setItem(
        index: 2,
        type: GameObjectType.Body,
        subType: BodyType.Swat,
    );
  }

  bool get targetWithinInteractRadius => targetWithinRadius(Destination_Radius_Interact);

  void setItemLength(int value){
    itemLength = value;
    itemTypes = Uint8List(value);
    itemSubTypes = Uint8List(value);
    writeItemLength(value);
  }

  bool addGameObject(IsometricGameObject gameObject) =>
      addItem(type: gameObject.type, subType: gameObject.subType);

  bool addItem({required int type, required int subType}){
    final emptyIndex = getEmptyItemIndex();
    if (emptyIndex == -1){
      writeGameError(GameError.Inventory_Full);
      return false;
    }
    setItem(index: emptyIndex, type: type, subType: subType);
    return true;
  }

  int getEmptyItemIndex(){
    for (var i = 0; i < itemLength; i++){
      if (itemTypes[i] == GameObjectType.Nothing)
        return i;
    }
    return -1;
  }

  void setItem({required int index, required int type, required int subType}){
    if (index < 0) throw Exception('invalid index $index');
    if (index >= itemLength) throw Exception('invalid index $index');
    itemTypes[index] = type;
    itemSubTypes[index] = subType;
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

  void setDestinationRadiusToDestinationRadiusInteract() {
    destinationRadius = Destination_Radius_Interact;
  }

  @override
  void customOnUpdate() {
    updateInteracting();
  }

  void updateInteracting() {
    final target = this.target;
    if (interacting) {
      if (target == null){
        interacting = false;
        npcText.value = "";
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

  void talk(String text) {
     npcText.value = text;
  }

  void onChangedNpcText(String value) {
    writeNpcText();
  }


  void endInteraction() {
    if (!interacting) return;
    clearTarget();
  }

  void writeNpcText() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Npc_Text);
    writeString(npcText.value);
  }

  void writeItemLength(int value) {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Player_Item_Length);
    writeUInt16(value);
  }

  void selectItem(int index) {
    if (!isValidItemIndex(index)) {
      writeGameError(GameError.Invalid_Item_Index);
      return;
    }

    final itemType = itemTypes[index];

    if (itemType == GameObjectType.Nothing)
      return;

    equipItem(itemType, itemSubTypes[index]);
  }

  void equipItem(int type, int subType){
    switch (type){
      case GameObjectType.Weapon:
        setWeaponType(subType);
        break;
    }
  }

  void setWeaponType(int weaponType){
    this.weaponType = weaponType;
    weaponDamage = getWeaponDamage(weaponType);
    weaponRange = getWeaponRange(weaponType);
    weaponCooldown = getWeaponCooldown(weaponType);
  }

  int getWeaponDamage(int weaponType) => const {
        WeaponType.Unarmed: 1,
        WeaponType.Shotgun: 2,
        WeaponType.Machine_Gun: 2,
        WeaponType.Sniper_Rifle: 2,
        WeaponType.Handgun: 2,
        WeaponType.Smg: 2,
     }[weaponType] ?? (throw Exception('getWeaponDamage(${GameObjectType.getNameSubType(GameObjectType.Weapon, weaponType)})'));

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

  bool isValidItemIndex(int index) => index >= 0 && index < itemLength;
}