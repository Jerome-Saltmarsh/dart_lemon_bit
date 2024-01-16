
import '../classes/amulet_player.dart';
import '../packages/src.dart';
import 'character_json.dart';

void writeJsonToAmuletPlayer(
    CharacterJson json,
    AmuletPlayer player,
){
  player.equipWeapon(AmuletItem.findByName(json.weapon), force: true);
  player.equipHelm(AmuletItem.findByName(json.helm), force: true);
  player.equipBody(AmuletItem.findByName(json.body), force: true);
  player.equipShoes(AmuletItem.findByName(json.shoes), force: true);

  // player.equipHandLeft(null, force: true);
  // player.equipHandRight(null, force: true);

  final itemNames = json.tryGetList<String>('items');
  if (itemNames != null){
    for (var i = 0; i < itemNames.length; i++){
      final itemName =  itemNames[i];
      if (itemName != '-'){
        player.items[i].amuletItem = AmuletItem.findByName(itemName);
      } else {
        player.items[i].amuletItem = null;
      }
    }
  }

  player.elementPoints = json.elementPoints;
  player.elementAir = json.elementElectricity;
  player.elementFire = json.elementFire;
  player.elementWater = json.elementWater;
  player.data = json['data'] ?? Json();
  player.uuid = json['uuid'] ?? (throw Exception('json[uuid] is null'));
  player.complexion = json['complexion'] ?? 0;
  player.name = json['name'];
  player.gender = json['gender'] ?? 0;
  player.hairType = json['hairType'] ?? 0;
  player.hairColor = json['hairColor'] ?? 0;
  player.experience = json['experience'] ?? 0;
  player.level = json['level'] ?? 1;
  player.initialized = json['initialized'] ?? false;
  player.active = true;
  player.writePlayerHealth(); // TODO remove game logic
  player.notifyEquipmentDirty(); // TODO remove game logic
}
