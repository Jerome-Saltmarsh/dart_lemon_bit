
import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/common/src.dart';
import 'package:amulet_engine/isometric/classes/character.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';

import 'amulet_field.dart';

AmuletFiend mapFiendJsonToAmuletFiend(Json fiendJson) {
  final amuletFiend = AmuletFiend(
    x: fiendJson.getDouble('x'),
    y: fiendJson.getDouble('y'),
    z: fiendJson.getDouble('z'),
    level: fiendJson.getInt(AmuletField.Level),
    team: TeamType.Evil,
    fiendType: FiendType.values.tryGet(fiendJson.getInt('fiend_type')) ?? FiendType.Goblin,
    difficulty: Difficulty.values.tryGet(fiendJson.tryGetInt(AmuletField.Difficulty)) ?? Difficulty.Normal,
  )
    ..health = fiendJson.getDouble('health')
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
