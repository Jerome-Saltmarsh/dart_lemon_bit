
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
    weaponType = WeaponType.Unarmed;
    weaponRange = 40;
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

    final subType = itemSubTypes[index];

    switch (itemType){
      case GameObjectType.Weapon:
        weaponType = subType;
        break;
    }
  }

  bool isValidItemIndex(int index) => index >= 0 && index < itemLength;
}