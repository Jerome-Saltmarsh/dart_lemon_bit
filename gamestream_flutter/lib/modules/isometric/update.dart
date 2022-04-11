
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/modules/isometric/spawn.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

import 'module.dart';

final _particles = isometric.particles;
final _spawn = isometric.spawn;

class IsometricUpdate {

  final IsometricModule state;
  final IsometricSpawn spawn;

  IsometricUpdate(this.state, this.spawn);


}