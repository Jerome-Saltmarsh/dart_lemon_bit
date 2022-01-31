
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
  final config = EditorConfig();
  final render = EditorRender();
  final update = updateEditor;
  late final EditorEvents events;

  EditorModule(){
     events = EditorEvents(actions);
  }
}
