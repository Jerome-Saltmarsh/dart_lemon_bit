


import 'package:amulet_engine/classes/amulet.dart';
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/classes/amulet_game.dart';
import 'package:amulet_engine/packages/isomeric_engine.dart';

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
  json['x'] = player.x.toInt();
  json['y'] = player.y.toInt();
  json['z'] = player.z.toInt();
  json['health'] = player.health;
  json['magic'] = player.magic;
  json.setInt('quest_main', player.questMain.index);
  json['flags'] = player.flags;
  json['name'] = player.name;
  json['complexion'] = player.complexion;
  json['gender'] = player.gender;
  json['hairType'] = player.hairType;
  json['hairColor'] = player.hairColor;
  json['initialized'] = player.initialized;
  json['amulet_scene_name'] = player.amuletGame.amuletScene.name;
  json['amulet'] = writeAmuletToJson(player.amulet);
  return json;
}

Json writeAmuletToJson(final Amulet amulet) {
    final json = Json();
    json['time'] = amulet.amuletTime.time;
    json['scenes'] = amulet.games.map(writeAmuletGameToJson).toList(growable: false);
    return json;
}

Json writeAmuletGameToJson(AmuletGame amuletGame) {
  final json = Json();
  final fiends = <Json>[];
  for (final character in amuletGame.characters) {
    if (character is! AmuletFiend) continue;
    fiends.add(writeAmuletFiendToJson(character));
  }
  json['fiends'] = fiends;
  json['scene_index'] = amuletGame.amuletScene.index;
  return json;
}

Json writeAmuletFiendToJson(AmuletFiend amuletFiend){
  final json = Json();
  json['x'] = amuletFiend.x.toInt();
  json['y'] = amuletFiend.y.toInt();
  json['z'] = amuletFiend.z.toInt();
  json['start_x'] = amuletFiend.startPositionX;
  json['start_y'] = amuletFiend.startPositionY;
  json['start_z'] = amuletFiend.startPositionZ;
  json['fiend_type'] = amuletFiend.fiendType.index;
  json['health'] = amuletFiend.health;
  json['character_state'] = amuletFiend.characterState;
  json['angle'] = amuletFiend.angle.toInt();
  return json;
}