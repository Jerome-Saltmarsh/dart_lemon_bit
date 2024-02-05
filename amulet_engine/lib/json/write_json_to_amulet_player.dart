
import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';

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
  player.setQuestMain(QuestMain.values[json.tryGetInt('quest_main') ?? 0]);
  player.writePlayerHealth(); // TODO remove game logic
  player.notifyEquipmentDirty(); // TODO remove game logic
}
