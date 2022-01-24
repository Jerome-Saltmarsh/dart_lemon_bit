

import 'config.dart';
import 'editor.dart';
import 'events.dart';
import 'state.dart';

abstract class EditorScope {
  EditorState get state => editor.state;
  EditorEvents get events => editor.events;
  EditorConfig get config => editor.config;
}