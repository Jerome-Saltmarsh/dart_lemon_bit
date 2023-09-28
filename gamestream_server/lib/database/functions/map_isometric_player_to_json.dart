

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

    final items = [];

    for (final item in player.items){
      items.add({
          'type': item.item?.type ?? 0,
          'sub_type': item.item?.subType ?? 0,
      });
    }

    json['name'] = player.name;
    json['equipped_helm'] = getSlotType(player.equippedHelm);
    json['equipped_body'] = getSlotType(player.equippedBody);
    json['equipped_legs'] = getSlotType(player.equippedLegs);
    json['equipped_shoes'] = getSlotType(player.equippedShoe);
    json['complexion'] = player.complexion;
    json['weapons'] = getSlotTypes(player.weapons);
    json['item_types'] = player.items.map((e) => e.item?.type ?? 0).toList(growable: false);
    json['item_sub_types'] = player.items.map((e) => e.item?.subType ?? 0).toList(growable: false);
    json['equipped_weapon_index'] = player.equippedWeaponIndex;
  }

  return json;
}

List<int> getSlotTypes(List<ItemSlot> slots) => slots.map(getSlotType).toList(growable: false);

int getSlotType(ItemSlot slot) => slot.item?.subType ?? 0;