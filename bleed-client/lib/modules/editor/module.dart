
import 'package:bleed_client/modules/editor/render.dart';

import 'actions.dart';
import 'build.dart';
import 'config.dart';
import 'events.dart';
import 'state.dart';
import 'update.dart';

class EditorModule {
  final state = EditorState();
  final actions = EditorActions();
  final build = EditorBuild();
  final events = EditorEvents();
  final config = EditorConfig();
  final update = updateEditor;
  final render = renderEditor;
}
