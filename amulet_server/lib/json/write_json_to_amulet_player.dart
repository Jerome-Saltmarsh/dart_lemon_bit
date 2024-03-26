
import 'package:amulet_common/src.dart';
import 'package:amulet_server/classes/amulet_fiend.dart';
import 'package:amulet_server/io/scene_json_reader.dart';
import 'package:amulet_server/src.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';

import 'amulet_field.dart';

void writeJsonToAmuletPlayer(
    CharacterJson json,
    AmuletPlayer player,
){
  final amulet = player.amulet;
  amulet.resetGames();

  final jsonAmulet = json.getChild('amulet');
  final amuletSceneName = json['amulet_scene_name'];
  final amuletScene = AmuletScene.findByName(amuletSceneName) ?? AmuletScene.Village;

  player.stash.clear();
  final jsonStash = json.tryGetObjects(AmuletField.Stash);

  if (jsonStash != null) {
    for (final child in jsonStash){
      player.stash.tryAdd(mapJsonToAmuletItemObject(child));
    }
  }


  player.amuletGame = amulet.findGame(amuletScene);
  player.equippedWeapon = mapJsonToAmuletItemObject(json[AmuletField.Equipped_Weapon]);
  player.equippedHelm = mapJsonToAmuletItemObject(json[AmuletField.Equipped_Helm]);
  player.equippedArmor = mapJsonToAmuletItemObject(json[AmuletField.Equipped_Armor]);
  player.equippedShoes = mapJsonToAmuletItemObject(json[AmuletField.Equipped_Shoes]);
  player.equipmentDirty = true;
  player.uuid = json.getString(AmuletField.UUID);
  player.complexion = json.getInt(AmuletField.Complexion);
  player.name = json.getString(AmuletField.Name);
  player.gender = json.getInt(AmuletField.Gender);
  player.hairType = json.getInt(AmuletField.Hair_Type);
  player.flags = json['flags'] ?? [];
  player.hairColor = json.getInt(AmuletField.Hair_Color);
  player.initialized = json.getBool(AmuletField.Initialized);
  player.x = json.getDouble(AmuletField.X);
  player.y = json.getDouble(AmuletField.Y);
  player.z = json.getDouble(AmuletField.Z);
  player.setQuestMain(QuestMain.values[json.tryGetInt('quest_main') ?? 0]);
  writeJsonAmuletToMemory(jsonAmulet, player);
  player.writePlayerHealth();
  player.joinGame(player.amuletGame);
}


void writeJsonAmuletToMemory(Json jsonAmulet, AmuletPlayer player) {
   final amulet = player.amulet;
   amulet.amuletTime.time = jsonAmulet.getInt('time');
   final scenes = jsonAmulet.getObjects('scenes');

   for (final game in amulet.games) {
      for (final sceneJson in scenes) {
         final sceneIndex = sceneJson.getInt('scene_index');
         if (game.amuletScene.index != sceneIndex) continue;
         final characters = game.characters;
         characters.removeWhere((character) => character is AmuletFiend);

         final fiendJsons = sceneJson.getObjects('fiends');

         for (final fiendJson in fiendJsons) {
           final amuletFiend = mapJsonToAmuletFiend(fiendJson);
           if (amuletFiend == null) continue;
           characters.add(amuletFiend);
         }
         final nodeTypes = game.scene.nodeTypes;
         final nodeTypesLength = nodeTypes.length;
         final variations = game.scene.variations;
         final shrinesUsed = sceneJson.getListInt('shrines_used');
         player.sceneShrinesUsed[game.amuletScene] = shrinesUsed;
         game.setGameObjects(readGameObjectsFromJson(sceneJson));

         for (var index = 0; index < nodeTypesLength; index++) {
            final nodeType = nodeTypes[index];
            if (nodeType != NodeType.Shrine) continue;
            final shrineUsed = shrinesUsed.contains(index);
            variations[index] = shrineUsed
                ? NodeType.Variation_Shrine_Inactive
                : NodeType.Variation_Shrine_Active;
         }
         break;
      }
   }
}
