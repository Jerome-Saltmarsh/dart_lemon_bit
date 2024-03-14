
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/classes/amulet_game.dart';
import 'package:amulet_engine/io/scene_json_writer.dart';
import 'package:amulet_engine/json/map_amulet_item_object_to_json.dart';
import 'package:lemon_json/src.dart';

import 'amulet_field.dart';
import 'character_json.dart';
import '../classes/amulet_player.dart';
import 'map_amulet_fiend_to_json.dart';

CharacterJson writeAmuletPlayerToJson(AmuletPlayer player) {
  final json = CharacterJson();

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

  json[AmuletField.UUID] = player.uuid;
  json[AmuletField.Difficulty] = player.difficulty.index;
  json[AmuletField.X] = player.x.toInt();
  json[AmuletField.Y] = player.y.toInt();
  json[AmuletField.Z] = player.z.toInt();
  json[AmuletField.Health] = player.health;
  json[AmuletField.Magic] = player.magic;
  json[AmuletField.Quest_Main] = player.questMain.index;
  json[AmuletField.Flags] = player.flags;
  json[AmuletField.Name] = player.name;
  json[AmuletField.Complexion] = player.complexion;
  json[AmuletField.Gender] = player.gender;
  json[AmuletField.Hair_Type] = player.hairType;
  json[AmuletField.Hair_Color] = player.hairColor;
  json[AmuletField.Initialized] = player.initialized;
  json[AmuletField.Amulet_Scene_Name] = player.amuletGame.amuletScene.name;
  json[AmuletField.Amulet] = writeAmuletToJson(player);

  json.skillTypeLeft = player.skillTypeLeft;
  json.skillTypeRight = player.skillTypeRight;

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
