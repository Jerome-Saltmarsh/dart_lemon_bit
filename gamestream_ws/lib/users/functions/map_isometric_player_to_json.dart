

import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/isometric.dart';
import 'package:gamestream_ws/packages/utils/generate_uuid.dart';
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
          'type': item.amuletItem?.type ?? 0,
          'sub_type': item.amuletItem?.subType ?? 0,
      });
    }

    json['data'] = player.data;
    json['name'] = player.name;
    json['equippedHelm'] = getSlotType(player.equippedHelm);
    json['equippedBody'] = getSlotType(player.equippedBody);
    json['equippedLegs'] = getSlotType(player.equippedLegs);
    json['equippedShoe'] = getSlotType(player.equippedShoe);
    json['equippedHandLeft'] = getSlotType(player.equippedHandLeft);
    json['equippedHandRight'] = getSlotType(player.equippedHandRight);
    json['weapons'] = getSlotTypeNames(player.weapons);
    json['items'] = getSlotTypeNames(player.items);
    json['complexion'] = player.complexion;
    json['equippedWeaponIndex'] = player.equippedWeaponIndex;
    json['gender'] = player.gender;
    json['hairType'] = player.hairType;
    json['hairColor'] = player.hairColor;
    json['experience'] = player.experience;
    json['level'] = player.level;
    json['initialized'] = player.initialized;
  }

  return json;
}

List<int> getSlotTypes(List<AmuletItemSlot> slots) => slots.map(getSlotType).toList(growable: false);

int getSlotType(AmuletItemSlot slot) => slot.amuletItem?.subType ?? 0;

List<String> getSlotTypeNames(List<AmuletItemSlot> slots) =>
    slots.map((slotItem) => slotItem.amuletItem?.name ?? '-').toList(growable: false);