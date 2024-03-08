
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/common/src.dart';
import 'package:amulet_engine/isometric/classes/character.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';

import 'amulet_field.dart';

AmuletFiend mapFiendJsonToAmuletFiend(Json fiendJson) {
  final amuletFiend = AmuletFiend(
    x: fiendJson.getDouble(AmuletField.X),
    y: fiendJson.getDouble(AmuletField.Y),
    z: fiendJson.getDouble(AmuletField.Z),
    level: fiendJson.getInt(AmuletField.Level),
    team: TeamType.Evil,
    fiendType: FiendType.values.tryGet(fiendJson.getInt(AmuletField.Fiend_Type)) ?? FiendType.Goblin,
    difficulty: Difficulty.values.tryGet(fiendJson.tryGetInt(AmuletField.Difficulty)) ?? Difficulty.Normal,
  )
    ..health = fiendJson.getDouble(AmuletField.Health)
    ..characterState = fiendJson.getInt(AmuletField.Character_State)
    ..angle = fiendJson.getDouble(AmuletField.Angle)
    ..startPositionX = fiendJson.getDouble(AmuletField.Start_X)
    ..startPositionY = fiendJson.getDouble(AmuletField.Start_Y)
    ..startPositionZ = fiendJson.getDouble(AmuletField.Start_Z);

  if (amuletFiend.dead) {
    amuletFiend.frame = Character.maxAnimationDeathFrames.toDouble();
  }

  return amuletFiend;
}
