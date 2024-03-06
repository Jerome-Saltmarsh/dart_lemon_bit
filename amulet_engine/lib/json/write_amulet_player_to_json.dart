
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/classes/amulet_game.dart';
import 'package:amulet_engine/io/scene_json_writer.dart';
import 'package:amulet_engine/json/map_amulet_item_object_to_json.dart';
import 'package:lemon_json/src.dart';

import 'amulet_field.dart';
import 'character_json.dart';
import '../classes/amulet_player.dart';
import '../utils/generate_uuid.dart';
import 'map_amulet_fiend_to_json.dart';

CharacterJson writeAmuletPlayerToJson(AmuletPlayer player) {
  final json = CharacterJson();

  if (player.uuid.isEmpty){
    player.uuid = generateUUID();
  }

  json.uuid = player.uuid;

  final equippedWeapon = player.equippedWeapon;
  final equippedHelm = player.equippedHelm;
  final equippedArmor = player.equippedArmor;
  final equippedShoes = player.equippedShoes;

  if (equippedWeapon != null){
    json[AmuletField.Equipped_Weapon] = mapAmuletItemObjectToJson(equippedWeapon);
  }
  if (equippedHelm != null){
    json[AmuletField.Equipped_Helm] = mapAmuletItemObjectToJson(equippedHelm);
  }
  if (equippedArmor != null){
    json[AmuletField.Equipped_Armor] = mapAmuletItemObjectToJson(equippedArmor);
  }
  if (equippedShoes != null){
    json[AmuletField.Equipped_Shoes] = mapAmuletItemObjectToJson(equippedShoes);
  }

  json[AmuletField.Difficulty] = player.difficulty.index;
  json.skillTypeLeft = player.skillTypeLeft;
  json.skillTypeRight = player.skillTypeRight;
  json[AmuletField.X] = player.x.toInt();
  json[AmuletField.Y] = player.y.toInt();
  json[AmuletField.Z] = player.z.toInt();
  json[AmuletField.Health] = player.health;
  json[AmuletField.Magic] = player.magic;
  json.setInt('quest_main', player.questMain.index);
  json['flags'] = player.flags;
  json['name'] = player.name;
  json['complexion'] = player.complexion;
  json['gender'] = player.gender;
  json['hairType'] = player.hairType;
  json['hairColor'] = player.hairColor;
  json['initialized'] = player.initialized;
  json['amulet_scene_name'] = player.amuletGame.amuletScene.name;
  json['skill_slots'] = player.skillSlots.map((e) => e.index).toList(growable: false);
  json['consumable_slots'] = player.consumableSlots.map((e) => e?.index ?? -1).toList(growable: false);
  json['amulet'] = writeAmuletToJson(player);
  return json;
}

Json writeAmuletToJson(final AmuletPlayer amuletPlayer) {
  final amulet = amuletPlayer.amulet;
  final json = Json();
  json['time'] = amulet.amuletTime.time;
  json['scenes'] = amulet.games
      .map((game) => writeAmuletGameToJson(game, amuletPlayer))
      .toList(growable: false);
  return json;
}

Json writeAmuletGameToJson(AmuletGame amuletGame, AmuletPlayer amuletPlayer) {
  final json = Json();
  final fiends = <Json>[];
  for (final character in amuletGame.characters) {
    if (character is! AmuletFiend) continue;
    fiends.add(mapAmuletFiendToJson(character));
  }
  json['gameobjects'] = writeGameObjectsToJson(amuletGame.gameObjects);
  json['fiends'] = fiends;
  json['scene_index'] = amuletGame.amuletScene.index;
  json['shrines_used'] = amuletPlayer.sceneShrinesUsed[amuletGame.amuletScene] ??  [];
  return json;
}
