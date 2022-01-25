
import 'actions.dart';
import 'builder.dart';
import 'config.dart';
import 'events.dart';
import 'state.dart';
import 'update.dart';

class EditorModule {
  final state = EditorState();
  final actions = EditorActions();
  final build = EditorBuilder();
  final events = EditorEvents();
  final config = EditorConfig();
  final update = updateEditor;
}
