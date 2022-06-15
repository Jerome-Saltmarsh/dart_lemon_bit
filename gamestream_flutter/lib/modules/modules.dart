
import 'package:gamestream_flutter/modules/isometric/module.dart';

import 'core/module.dart';
import 'game/module.dart';
import 'website/module.dart';

final modules = Modules();
final core = modules.core;
final isometric = modules.isometric;
final website = modules.website;

class Modules {
  final core = CoreModule();
  final website = WebsiteModule();
  final game = GameModule();
  final isometric = IsometricModule();
}



