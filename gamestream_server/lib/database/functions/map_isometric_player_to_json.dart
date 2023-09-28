

import 'package:gamestream_server/amulet.dart';
import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/packages/utils/generate_uuid.dart';

Map<String, dynamic> mapIsometricPlayerToJson(IsometricPlayer player){
  final json = Map<String, dynamic>();

  if (player.uuid.isEmpty){
    player.uuid = generateUUID();
  }
  json['uuid'] = player.uuid;

  if (player is AmuletPlayer) {
    json['name'] = player.name;
    json['equipped_helm'] = getSlotType(player.equippedHelm);
    json['equipped_body'] = getSlotType(player.equippedBody);
    json['equipped_legs'] = getSlotType(player.equippedLegs);
    json['complexion'] = player.complexion;
  }

  return json;
}

int getSlotType(ItemSlot slot) => slot.item?.subType ?? 0;