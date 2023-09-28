
import 'package:gamestream_server/amulet.dart';
import 'package:gamestream_server/packages/common.dart';
import 'package:typedef/json.dart';

void writeJsonToAmuletPlayer(Json json, AmuletPlayer player){
  player.uuid = json['uuid'];
  player.name = json['name'];

  final equippedBody = json['equipped_body'] ?? 0;
  if (equippedBody != BodyType.None){
    player.equipBody(AmuletItem.getBody(equippedBody), force: true);
  } else {
    player.equipBody(null, force: true);
  }

  final equippedShoes = json['equipped_shoes'] ?? 0;
  if (equippedShoes != BodyType.None) {
    player.equipShoes(AmuletItem.getShoe(equippedShoes), force: true);
  } else {
    player.equipShoes(null, force: true);
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

  player.healthBase = 100;
  player.experience = 20;
  player.characterCreated = true;
  player.active = true;
  player.writePlayerHealth();
  player.notifyEquipmentDirty();
}