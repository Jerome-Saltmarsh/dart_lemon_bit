

import 'package:gamestream_server/amulet.dart';
import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/packages/utils/generate_uuid.dart';
import 'package:typedef/json.dart';

Json mapIsometricPlayerToJson(IsometricPlayer player){
  final json = Json();

  if (player.uuid.isEmpty){
    player.uuid = generateUUID();
  }
  json['uuid'] = player.uuid;

  if (player is AmuletPlayer) {
    json['name'] = player.name;
    json['equipped_helm'] = getSlotType(player.equippedHelm);
    json['equipped_body'] = getSlotType(player.equippedBody);
    json['equipped_legs'] = getSlotType(player.equippedLegs);
    json['equipped_shoes'] = getSlotType(player.equippedShoe);
    json['complexion'] = player.complexion;
    json['weapons'] = player.weapons.map(getSlotType).toList(growable: false);

    json['equipped_weapon_index'] = player.equippedWeaponIndex;
  }

  return json;
}

int getSlotType(ItemSlot slot) => slot.item?.subType ?? 0;