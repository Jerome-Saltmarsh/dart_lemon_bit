
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';

import '../classes/amulet.dart';
import '../classes/amulet_player.dart';
import '../packages/src.dart';
import 'character_json.dart';

void writeJsonToAmuletPlayer(
    CharacterJson json,
    AmuletPlayer player,
){
  player.equippedWeapon = AmuletItem.findByName(json.weapon);
  player.equippedHelm = AmuletItem.findByName(json.helm);
  player.equippedArmor = AmuletItem.findByName(json.armor);
  player.equippedShoes = AmuletItem.findByName(json.shoes);

  player.uuid = json['uuid'] ?? (throw Exception('json[uuid] is null'));
  player.complexion = json['complexion'] ?? 0;
  player.name = json['name'];
  player.gender = json['gender'] ?? 0;
  player.hairType = json['hairType'] ?? 0;
  player.flags = json['flags'] ?? [];
  player.hairColor = json['hairColor'] ?? 0;
  player.initialized = json['initialized'] ?? false;
  player.active = true;
  player.x = json.getDouble('x');
  player.y = json.getDouble('y');
  player.z = json.getDouble('z');
  player.setQuestMain(QuestMain.values[json.tryGetInt('quest_main') ?? 0]);
  player.writePlayerHealth(); // TODO remove game logic
  player.notifyEquipmentDirty(); // TODO remove game logic

  final jsonAmulet = json.tryGetChild('amulet');
  if (jsonAmulet != null) {
    writeJsonAmuletToMemory(jsonAmulet, player.amulet);
  }
}

void writeJsonAmuletToMemory(Json jsonAmulet, Amulet amulet) {
   amulet.amuletTime.time = jsonAmulet.getInt('time');
   final scenes = jsonAmulet.getObjects('scenes');
   for (final game in amulet.games) {
      for (final scene in scenes) {
         final sceneIndex = scene.getInt('scene_index');
         if (game.amuletScene.index != sceneIndex) continue;
         final characters = game.characters;
         characters.removeWhere((character) => character is AmuletFiend);
         characters.addAll(
             scene
                 .getObjects('fiends')
                 .map(mapFiendJsonToAmuletFiend)
         );
         break;
      }
   }
}

AmuletFiend mapFiendJsonToAmuletFiend(Json fiendJson) =>
    AmuletFiend(
       x: fiendJson.getDouble('x'),
       y: fiendJson.getDouble('y'),
       z: fiendJson.getDouble('z'),
       team: TeamType.Evil,
       fiendType: FiendType.values[fiendJson.getInt('fiend_type')],
   )
     ..health = fiendJson.getInt('health')
     ..characterState = fiendJson.getInt('character_state')
     ..angle = fiendJson.getDouble('angle')
     ..startPositionX = fiendJson.getDouble('start_x')
     ..startPositionY = fiendJson.getDouble('start_y')
     ..startPositionZ = fiendJson.getDouble('start_z');
