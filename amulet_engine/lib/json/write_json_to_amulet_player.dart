
import '../classes/amulet_player.dart';
import '../packages/src.dart';
import 'character_json.dart';

void writeJsonToAmuletPlayer(
    CharacterJson json,
    AmuletPlayer player,
){
  final equippedHelm = json['equippedHelm'] ?? 0;
  if (equippedHelm != HelmType.None) {
    player.equipHelm(AmuletItem.getHelm(equippedHelm), force: true);
  } else {
    player.equipHelm(null, force: true);
  }

  final equippedBody = json['equippedBody'] ?? 0;
  if (equippedBody != BodyType.None){
    player.equipBody(AmuletItem.getBody(equippedBody), force: true);
  } else {
    player.equipBody(null, force: true);
  }

  final equippedLegs = json['equippedLegs'] ?? 0;
  if (equippedLegs != LegType.None){
    player.equipLegs(AmuletItem.getLegs(equippedLegs), force: true);
  } else {
    player.equipLegs(null, force: true);
  }

  final equippedShoe = json['equippedShoe'] ?? 0;
  if (equippedShoe != BodyType.None) {
    player.equipShoes(AmuletItem.getShoe(equippedShoe), force: true);
  } else {
    player.equipShoes(null, force: true);
  }

  final equippedHandLeft = json['equippedHandLeft'] ?? 0;
  if (equippedHandLeft != HandType.None) {
    player.equipHandLeft(AmuletItem.getHand(equippedHandLeft), force: true);
  } else {
    player.equipHandLeft(null, force: true);
  }

  final equippedHandRight = json['equippedHandRight'] ?? 0;
  if (equippedHandRight != HandType.None) {
    player.equipHandRight(AmuletItem.getHand(equippedHandRight), force: true);
  } else {
    player.equipHandRight(null, force: true);
  }

  final weaponNames = json.tryGetList<String>('weapons');
  if (weaponNames != null){
    for (var i = 0; i < weaponNames.length; i++){
      final weaponName =  weaponNames[i];
      player.weapons[i].amuletItem = weaponName == '-'
          ? null
          : AmuletItem.findByName(weaponName);
    }
  }

  final itemNames = json.tryGetList<String>('items');
  if (itemNames != null){
    for (var i = 0; i < itemNames.length; i++){
      final itemName =  itemNames[i];
      if (itemName != '-'){
        player.items[i].amuletItem = AmuletItem.findByName(itemName);
      } else {
        player.items[i].amuletItem = null;
      }
    }
  }

  player.elementPoints = json.elementPoints;
  player.elementAir = json.elementElectricity;
  player.elementFire = json.elementFire;
  player.elementWater = json.elementWater;
  player.data = json['data'] ?? Json();
  player.uuid = json['uuid'] ?? (throw Exception('json[uuid] is null'));
  player.complexion = json['complexion'] ?? 0;
  player.name = json['name'];
  // player.equippedWeaponIndex = json['equippedWeaponIndex'] ?? 0;
  player.gender = json['gender'] ?? 0;
  player.hairType = json['hairType'] ?? 0;
  player.hairColor = json['hairColor'] ?? 0;
  player.experience = json['experience'] ?? 0;
  player.level = json['level'] ?? 1;
  player.initialized = json['initialized'] ?? false;
  player.active = true;
  player.writePlayerHealth();
  player.notifyEquipmentDirty();
}
