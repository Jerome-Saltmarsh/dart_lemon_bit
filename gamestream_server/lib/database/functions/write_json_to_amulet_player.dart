
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

  final weaponNames = (json['weapons'] as List).cast<String>();
  for (var i = 0; i < weaponNames.length; i++){
    final weaponName =  weaponNames[i];
    if (weaponName != '-'){
      player.weapons[i].item = AmuletItem.findByName(weaponName);
    } else {
      player.weapons[i].item = null;
    }
  }

  final itemNames = (json['items'] as List).cast<String>();
  for (var i = 0; i < itemNames.length; i++){
    final itemName =  itemNames[i];
    if (itemName != '-'){
      player.items[i].item = AmuletItem.findByName(itemName);
    } else {
      player.items[i].item = null;
    }
  }

  player.equippedWeaponIndex = json['equipped_weapon_index'] ?? 0;
  player.gender = json['gender'] ?? 0;
  player.hairType = json['hair_type'] ?? 0;
  player.hairColor = json['hair_color'] ?? 0;
  player.experience = json['experience'] ?? 0;
  player.level = json['level'] ?? 0;
  player.healthBase = 100;
  player.characterCreated = true;
  player.active = true;
  player.writePlayerHealth();
  player.notifyEquipmentDirty();
}
