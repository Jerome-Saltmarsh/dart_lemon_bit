

import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:bleed_common/enums/ObjectType.dart';
import 'package:bleed_common/enums/Shade.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';


final _translations = _Translations();
final _torchHeight = environmentObjectHeight[ObjectType.Torch]!;

const environmentObjectWidth = <ObjectType, double> {
  ObjectType.Palisade: 48,
  ObjectType.Palisade_H: 48,
  ObjectType.Palisade_V: 48,
  ObjectType.Rock_Wall: 48,
  ObjectType.Block_Grass: 48,
  ObjectType.Rock: 48,
  ObjectType.Grave: 48,
  ObjectType.Tree_Stump: 48,
  ObjectType.Rock_Small: 48,
  ObjectType.LongGrass: 48,
  ObjectType.Torch: 25,
  ObjectType.Tree01: 96,
  ObjectType.House01: 150,
  ObjectType.House02: 150,
  ObjectType.MystEmitter: 48,
  ObjectType.Flag: 48,
};

const environmentObjectHeight = <ObjectType, double> {
  ObjectType.Palisade: 100,
  ObjectType.Palisade_H: 100,
  ObjectType.Palisade_V: 100,
  ObjectType.Rock_Wall: 100,
  ObjectType.Rock: 48,
  ObjectType.Grave: 48,
  ObjectType.Tree_Stump: 48,
  ObjectType.Rock_Small: 48,
  ObjectType.LongGrass: 48,
  ObjectType.Torch: 70,
  ObjectType.Tree01: 96,
  ObjectType.House01: 150,
  ObjectType.House02: 150,
  ObjectType.MystEmitter: 48,
  ObjectType.Flag: 48,
  ObjectType.Block_Grass: 100,
};

const environmentObjectIndex = <ObjectType, int> {
  ObjectType.Rock: 0,
  ObjectType.Grave: 1,
  ObjectType.Tree_Stump: 2,
  ObjectType.Rock_Small: 3,
  ObjectType.LongGrass: 4,
  ObjectType.Torch: 0,
  ObjectType.Tree01: 0,
  ObjectType.House01: 0,
  ObjectType.House02: 1,
  ObjectType.Palisade: 0,
  ObjectType.Palisade_H: 1,
  ObjectType.Palisade_V: 2,
  ObjectType.MystEmitter: 0,
  ObjectType.Rock_Wall: 0,
  ObjectType.Flag: 6,
};

class _Translations {
  final objects48 = Vector2(5592, 1);
  final trees  = Vector2(2049, 1);
  final objects150  = Vector2(1748, 1);
  final palisades  = Vector2(1314, 1);
  final torches = Vector2(2146, 1 );
}

final objectTypeSrcPosition = <ObjectType, Vector2> {
  ObjectType.Rock: _translations.objects48,
  ObjectType.Grave: _translations.objects48,
  ObjectType.Tree_Stump: _translations.objects48,
  ObjectType.Rock_Small: _translations.objects48,
  ObjectType.LongGrass: _translations.objects48,
  ObjectType.Flag: _translations.objects48,
  ObjectType.Torch: _translations.torches,
  ObjectType.Tree01: _translations.trees,
  ObjectType.House01: _translations.objects150,
  ObjectType.House02: _translations.objects150,
  ObjectType.Palisade: _translations.palisades,
  ObjectType.Palisade_V: _translations.palisades,
  ObjectType.Palisade_H: _translations.palisades,
  ObjectType.MystEmitter: atlas.circle,
  ObjectType.Rock_Wall: atlas.rockWall,
  ObjectType.Block_Grass: atlas.blockGrass,
};

final _ambient = modules.isometric.state.ambient;
final _isoState = isometric.state;
final _torchesY = _translations.torches.y;

void mapEnvironmentObjectToSrc(EnvironmentObject env){
  const frames = 5;

  // TODO Optimize
  var shade = _isoState.getShade(env.row, env.column);
  if (env.isHouse){
    shade = _ambient.value == Shade.Bright ? 0 : 1;
  }
  var top = shade * env.height;
  if (env.isTorch && _ambient.value > Shade.Bright){
    top = _torchesY + (((engine.animationFrame + env.frameRandom) % frames) * _torchHeight) + _torchHeight;
  }
  engine.mapSrc(x: env.srcX, y: top, width: env.width, height: env.height);
}
