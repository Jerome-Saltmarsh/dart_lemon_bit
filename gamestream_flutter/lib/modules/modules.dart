
import 'package:gamestream_flutter/modules/isometric/module.dart';

import 'core/module.dart';
import 'editor/module.dart';
import 'game/module.dart';
import 'website/module.dart';


final modules = Modules();

class Modules {
  final core = CoreModule();
  final website = WebsiteModule();
  final editor = EditorModule();
  final game = GameModule();
  final isometric = IsometricModule();
}

CoreModule get core => modules.core;
WebsiteModule get website => modules.website;
EditorModule get editor => modules.editor;
IsometricModule get isometric => modules.isometric;


