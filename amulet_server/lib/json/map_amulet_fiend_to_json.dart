
import 'package:amulet_server/classes/amulet_fiend.dart';
import 'package:amulet_server/json/amulet_field.dart';
import 'package:lemon_json/src.dart';

Json mapAmuletFiendToJson(AmuletFiend amuletFiend) => Json()
  ..[AmuletField.X] = amuletFiend.x.toInt()
  ..[AmuletField.Y] = amuletFiend.y.toInt()
  ..[AmuletField.Z] = amuletFiend.z.toInt()
  ..[AmuletField.Start_X] = amuletFiend.startPositionX
  ..[AmuletField.Start_Y] = amuletFiend.startPositionY
  ..[AmuletField.Start_Z] = amuletFiend.startPositionZ
  ..[AmuletField.Fiend_Type] = amuletFiend.fiendType.index
  ..[AmuletField.Health] = amuletFiend.health
  ..[AmuletField.Character_State] = amuletFiend.characterState
  ..[AmuletField.Angle] = amuletFiend.angle.toInt()
  ..[AmuletField.Level] = amuletFiend.level
  ..[AmuletField.Difficulty] = amuletFiend.difficulty.index
;