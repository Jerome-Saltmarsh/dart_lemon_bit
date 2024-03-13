
import 'package:amulet_common/src.dart';

import '../../src.dart';

class WitchesLair1 extends AmuletGame {

  WitchesLair1({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
  }) : super (
    name: 'Witches Lair Lvl 1',
    amuletScene: AmuletScene.Witches_Lair_1,
    fiendLevelMin: 3,
    fiendLevelMax: 5,
  );
}


