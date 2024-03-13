
import 'package:amulet_common/src.dart';
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/isometric/classes/character.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';

import 'amulet_field.dart';

AmuletFiend? mapJsonToAmuletFiend(Json json) {

  final x = json.tryGetDouble(AmuletField.X);
  final y = json.tryGetDouble(AmuletField.Y);
  final z = json.tryGetDouble(AmuletField.Z);
  final level = json.tryGetInt(AmuletField.Level);
  final fiendType = FiendType.values.tryGet(json.tryGetInt(AmuletField.Fiend_Type));
  final difficulty = Difficulty.values.tryGet(json.tryGetInt(AmuletField.Difficulty));
  final health = json.tryGetDouble(AmuletField.Health);
  final characterState = json.tryGetInt(AmuletField.Character_State);
  final angle = json.tryGetDouble(AmuletField.Angle);
  final startX = json.tryGetDouble(AmuletField.Start_X);
  final startY = json.tryGetDouble(AmuletField.Start_Y);
  final startZ = json.tryGetDouble(AmuletField.Start_Z);

  if (
    x == null ||
    y == null ||
    z == null ||
    fiendType == null ||
    difficulty == null ||
    health == null ||
    characterState == null ||
    angle == null ||
    startX == null ||
    startY == null ||
    startZ == null ||
    level == null
  ) return null;

  final amuletFiend = AmuletFiend(
    x: x,
    y: y,
    z: z,
    level: level,
    team: TeamType.Evil,
    fiendType: fiendType,
    difficulty: difficulty,
  )
    ..health = health
    ..characterState = characterState
    ..angle = angle
    ..startPositionX = startX
    ..startPositionY = startY
    ..startPositionZ = startZ;

  if (amuletFiend.dead) {
    amuletFiend.frame = Character.maxAnimationDeathFrames.toDouble();
  }

  return amuletFiend;
}
