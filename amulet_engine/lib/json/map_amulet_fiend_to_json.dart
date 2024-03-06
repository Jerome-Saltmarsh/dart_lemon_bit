
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/json/amulet_field.dart';
import 'package:lemon_json/src.dart';

Json mapAmuletFiendToJson(AmuletFiend amuletFiend){
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
  json[AmuletField.Difficulty] = amuletFiend.difficulty.index;
  return json;
}