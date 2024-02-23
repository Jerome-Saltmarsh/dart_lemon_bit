
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/io/scene_json_reader.dart';
import 'package:amulet_engine/isometric/classes/character.dart';
import 'package:amulet_engine/src.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';

void writeJsonToAmuletPlayer(
    CharacterJson json,
    AmuletPlayer player,
){
  final amulet = player.amulet;
  amulet.resetGames();

  final jsonAmulet = json.getChild('amulet');
  final amuletSceneName = json['amulet_scene_name'];
  final amuletScene = AmuletScene.findByName(amuletSceneName);
  final skillSlotInts = json.getListInt('skill_slots');
  final consumableSlots = json.getListInt('consumable_slots');

  player.amuletGame = amulet.findGame(amuletScene);
  player.equippedWeapon = AmuletItem.findByName(json.weapon);
  player.equippedHelm = AmuletItem.findByName(json.helm);
  player.equippedArmor = AmuletItem.findByName(json.armor);
  player.equippedShoes = AmuletItem.findByName(json.shoes);
  player.equipmentDirty = true;
  player.uuid = json['uuid'] ?? (throw Exception('json[uuid] is null'));
  player.complexion = json['complexion'] ?? 0;
  player.name = json['name'];
  player.gender = json['gender'] ?? 0;
  player.hairType = json['hairType'] ?? 0;
  player.flags = json['flags'] ?? [];
  player.hairColor = json['hairColor'] ?? 0;
  player.initialized = json['initialized'] ?? false;
  player.x = json.getDouble('x');
  player.y = json.getDouble('y');
  player.z = json.getDouble('z');
  player.skillTypeLeft = json.skillTypeLeft;
  player.skillTypeRight = json.skillTypeRight;
  player.consumableSlots.fill(null);
  player.consumableSlotsDirty = true;
  player.skillSlots.fill(SkillType.None);

  if (consumableSlots.length == player.consumableSlots.length){
    for (var i = 0; i < consumableSlots.length; i++){
       player.consumableSlots[i] = AmuletItem.values.tryGet(consumableSlots[i]);
    }
  }

  if (skillSlotInts.length == player.skillSlots.length){
    for (var i = 0; i < skillSlotInts.length; i++){
       final skillSlotIndex = skillSlotInts[i];
       if (SkillType.values.isValidIndex(skillSlotIndex)){
          player.skillSlots[i] = SkillType.values[skillSlotIndex];
       }
    }
  }

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
         characters.addAll(
             sceneJson
                 .getObjects('fiends')
                 .map(mapFiendJsonToAmuletFiend)
         );
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

AmuletFiend mapFiendJsonToAmuletFiend(Json fiendJson) {
  final amuletFiend = AmuletFiend(
       x: fiendJson.getDouble('x'),
       y: fiendJson.getDouble('y'),
       z: fiendJson.getDouble('z'),
       team: TeamType.Evil,
       fiendType: FiendType.values.tryGet(fiendJson.getInt('fiend_type')) ?? FiendType.Goblin,
   )
     ..health = fiendJson.getInt('health')
     ..characterState = fiendJson.getInt('character_state')
     ..angle = fiendJson.getDouble('angle')
     ..startPositionX = fiendJson.getDouble('start_x')
     ..startPositionY = fiendJson.getDouble('start_y')
     ..startPositionZ = fiendJson.getDouble('start_z');

  if (amuletFiend.dead) {
    amuletFiend.frame = Character.maxAnimationDeathFrames.toDouble();
  }

  return amuletFiend;
}
