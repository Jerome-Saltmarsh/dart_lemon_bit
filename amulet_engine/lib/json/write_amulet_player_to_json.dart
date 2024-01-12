


import 'character_json.dart';
import '../classes/amulet_item_slot.dart';
import '../classes/amulet_player.dart';
import '../utils/generate_uuid.dart';

CharacterJson writeAmuletPlayerToJson(AmuletPlayer player){
  final json = CharacterJson();

  if (player.uuid.isEmpty){
    player.uuid = generateUUID();
  }

  json.uuid = player.uuid;

  final items = [];

  for (final item in player.items){
    items.add({
      'type': item.amuletItem?.type ?? 0,
      'sub_type': item.amuletItem?.subType ?? 0,
    });
  }

  json.elementPoints = player.elementPoints;
  json.elementElectricity = player.elementAir;
  json.elementFire = player.elementFire;
  json.elementWater = player.elementWater;
  json['data'] = player.data;
  json['name'] = player.name;
  json['equippedWeapon'] = getSlotType(player.equippedWeapon);
  json['equippedHelm'] = getSlotType(player.equippedHelm);
  json['equippedBody'] = getSlotType(player.equippedBody);
  json['equippedLegs'] = getSlotType(player.equippedLegs);
  json['equippedShoe'] = getSlotType(player.equippedShoe);
  json['equippedHandLeft'] = getSlotType(player.equippedHandLeft);
  json['equippedHandRight'] = getSlotType(player.equippedHandRight);
  json['weapons'] = getSlotTypeNames(player.weapons);
  json['items'] = getSlotTypeNames(player.items);
  json['complexion'] = player.complexion;
  json['gender'] = player.gender;
  json['hairType'] = player.hairType;
  json['hairColor'] = player.hairColor;
  json['experience'] = player.experience;
  json['level'] = player.level;
  json['initialized'] = player.initialized;
  return json;
}

List<int> getSlotTypes(List<AmuletItemSlot> slots) => slots.map(getSlotType).toList(growable: false);

int getSlotType(AmuletItemSlot slot) => slot.amuletItem?.subType ?? 0;

List<String> getSlotTypeNames(List<AmuletItemSlot> slots) =>
    slots.map((slotItem) => slotItem.amuletItem?.name ?? '-').toList(growable: false);