
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/common/src.dart';
import 'package:amulet_engine/isometric/classes/character.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';

import 'amulet_field.dart';

AmuletFiend? mapJsonToAmuletFiend(Json json) {

  final x = json.tryGetDouble(AmuletField.X);
  final y = json.tryGetDouble(AmuletField.Y);
  final z = json.tryGetDouble(AmuletField.Z);
  final level = json.tryGetInt(AmuletField.Level);

  if (
    x == null ||
    y == null ||
    z == null ||
    level == null
  ) return null;

  final amuletFiend = AmuletFiend(
    x: x,
    y: y,
    z: z,
    level: level,
    team: TeamType.Evil,
    fiendType: FiendType.values.tryGet(json.getInt(AmuletField.Fiend_Type)) ?? FiendType.Goblin,
    difficulty: Difficulty.values.tryGet(json.tryGetInt(AmuletField.Difficulty)) ?? Difficulty.Normal,
  )
    ..health = json.getDouble(AmuletField.Health)
    ..characterState = json.getInt(AmuletField.Character_State)
    ..angle = json.getDouble(AmuletField.Angle)
    ..startPositionX = json.getDouble(AmuletField.Start_X)
    ..startPositionY = json.getDouble(AmuletField.Start_Y)
    ..startPositionZ = json.getDouble(AmuletField.Start_Z);

  if (amuletFiend.dead) {
    amuletFiend.frame = Character.maxAnimationDeathFrames.toDouble();
  }

  return amuletFiend;
}
