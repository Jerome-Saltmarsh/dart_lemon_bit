


import 'character_json.dart';
import '../classes/amulet_player.dart';
import '../utils/generate_uuid.dart';

CharacterJson writeAmuletPlayerToJson(AmuletPlayer player){
  final json = CharacterJson();

  if (player.uuid.isEmpty){
    player.uuid = generateUUID();
  }

  json.uuid = player.uuid;
  json.weapon = player.equippedWeapon?.name ?? '-';
  json.helm = player.equippedHelm?.name ?? '-';
  json.armor = player.equippedArmor?.name ?? '-';
  json.shoes = player.equippedShoes?.name ?? '-';
  json['data'] = player.data;
  json['name'] = player.name;
  json['complexion'] = player.complexion;
  json['gender'] = player.gender;
  json['hairType'] = player.hairType;
  json['hairColor'] = player.hairColor;
  json['initialized'] = player.initialized;
  return json;
}