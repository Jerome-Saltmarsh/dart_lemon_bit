
import 'package:gamestream_server/amulet.dart';
import 'package:gamestream_server/packages/common.dart';
import 'package:typedef/json.dart';

void writeJsonToAmuletPlayer(Json json, AmuletPlayer player){
  player.uuid = json['uuid'];
  player.name = json['name'];

  final bodyType = json['equipped_body'] ?? 0;
  if (bodyType != BodyType.None){
    player.equipBody(AmuletItem.findBody(bodyType), force: true);
  } else {
    player.equipBody(null, force: true);
  }

  player.healthBase = 100;
  player.experience = 20;
  player.characterCreated = true;
  player.active = true;
  player.writePlayerHealth();
  player.notifyEquipmentDirty();
}