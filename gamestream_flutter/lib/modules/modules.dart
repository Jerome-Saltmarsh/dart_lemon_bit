
import 'package:gamestream_flutter/modules/isometric/module.dart';

import 'core/module.dart';
import 'editor/module.dart';
import 'game/module.dart';
import 'website/module.dart';

final modules = Modules();
final core = modules.core;
final isometric = modules.isometric;
final website = modules.website;
final editor = modules.editor;

class Modules {
  final core = CoreModule();
  final website = WebsiteModule();
  final editor = EditorModule();
  final game = GameModule();
  final isometric = IsometricModule();
}



