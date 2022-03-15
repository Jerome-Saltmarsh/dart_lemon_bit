
import 'actions.dart';
import 'build.dart';
import 'compile.dart';
import 'config.dart';
import 'events.dart';
import 'render.dart';
import 'state.dart';
import 'update.dart';

class EditorModule {
  final state = EditorState();
  final build = EditorBuild();
  final config = EditorConfig();
  final render = EditorRender();
  final update = updateEditor;
  late final EditorActions actions;
  late final EditorEvents events;
  late final EditorCompile compile;

  EditorModule() {
    compile = EditorCompile(state);
    actions = EditorActions(compile);
    events = EditorEvents(actions);
  }
}
