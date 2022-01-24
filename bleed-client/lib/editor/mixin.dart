
import 'package:bleed_client/editor/config.dart';
import 'package:bleed_client/editor/events.dart';
import 'package:bleed_client/editor/state.dart';

import 'editor.dart';

abstract class EditorScope {
  EditorState get state => editor.state;
  EditorEvents get events => editor.events;
  EditorConfig get config => editor.config;
}