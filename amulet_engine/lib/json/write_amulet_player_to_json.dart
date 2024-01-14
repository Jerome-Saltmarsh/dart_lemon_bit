


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

  for (final item in player.items) {
    items.add(getSlotTypeName(item));
  }

  json.elementPoints = player.elementPoints;
  json.elementElectricity = player.elementAir;
  json.elementFire = player.elementFire;
  json.elementWater = player.elementWater;
  json.weapon = getSlotTypeName(player.equippedWeapon);
  json.helm = getSlotTypeName(player.equippedHelm);
  json.body = getSlotTypeName(player.equippedBody);
  json.shoes = getSlotTypeName(player.equippedShoe);
  json['data'] = player.data;
  json['name'] = player.name;
  json['equippedHandLeft'] = getSlotType(player.equippedHandLeft);
  json['equippedHandRight'] = getSlotType(player.equippedHandRight);
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
    slots.map(getSlotTypeName).toList(growable: false);

String getSlotTypeName(AmuletItemSlot amuletItemSlot) =>
    amuletItemSlot.amuletItem?.name ?? '-';