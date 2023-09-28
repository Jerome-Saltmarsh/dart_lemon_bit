
import 'package:gamestream_server/amulet.dart';
import 'package:gamestream_server/packages/common.dart';
import 'package:typedef/json.dart';

void writeJsonToAmuletPlayer(Json json, AmuletPlayer player){
  player.uuid = json['uuid'];
  player.name = json['name'];

  final equippedHelm = json['equipped_helm'] ?? 0;
  if (equippedHelm != HelmType.None) {
    player.equipHelm(AmuletItem.getHelm(equippedHelm), force: true);
  } else {
    player.equipHelm(null, force: true);
  }

  final equippedBody = json['equipped_body'] ?? 0;
  if (equippedBody != BodyType.None){
    player.equipBody(AmuletItem.getBody(equippedBody), force: true);
  } else {
    player.equipBody(null, force: true);
  }

  final equippedLegs = json['equipped_legs'] ?? 0;
  if (equippedLegs != LegType.None){
    player.equipLegs(AmuletItem.getLegs(equippedLegs), force: true);
  } else {
    player.equipLegs(null, force: true);
  }

  final equippedShoes = json['equipped_shoes'] ?? 0;
  if (equippedShoes != BodyType.None) {
    player.equipShoes(AmuletItem.getShoe(equippedShoes), force: true);
  } else {
    player.equipShoes(null, force: true);
  }

  final equippedHandLeft = json['equipped_hand_left'] ?? 0;
  if (equippedHandLeft != HandType.None) {
    player.equipHandLeft(AmuletItem.getHand(equippedHandLeft), force: true);
  } else {
    player.equipHandLeft(null, force: true);
  }

  final equippedHandRight = json['equipped_hand_right'] ?? 0;
  if (equippedHandRight != HandType.None) {
    player.equipHandRight(AmuletItem.getHand(equippedHandRight), force: true);
  } else {
    player.equipHandRight(null, force: true);
  }

  final weapons = (json['weapons'] as List).cast<int>();

  for (var i = 0; i < weapons.length; i++){
    final weaponType =  weapons[i];
    if (weaponType != WeaponType.Unarmed){
      player.weapons[i].item = AmuletItem.getWeapon(weapons[i]);
    } else {
      player.weapons[i].item = null;
    }
  }

  final itemTypes = (json['item_types'] as List).cast<int>();
  final itemSubTypes = (json['item_sub_types'] as List).cast<int>();

  for (var i = 0; i < itemTypes.length; i++){
    final itemType =  itemTypes[i];
    final itemSubType =  itemSubTypes[i];
    if (itemType == 0 || itemSubType == 0){
      player.items[i].item = null;
    } else {
      player.items[i].item = AmuletItem.get(
          type: itemType,
          subType: itemSubType,
      );
    }
  }

  player.equippedWeaponIndex = json['equipped_weapon_index'] ?? 0;
  player.healthBase = 100;
  player.experience = 20;
  player.characterCreated = true;
  player.active = true;
  player.writePlayerHealth();
  player.notifyEquipmentDirty();
}