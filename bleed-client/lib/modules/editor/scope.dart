

import 'package:bleed_client/modules/modules.dart';

import 'config.dart';
import 'events.dart';
import 'state.dart';

abstract class EditorScope {
  EditorState get state => editor.state;
  EditorEvents get events => editor.events;
  EditorConfig get config => editor.config;
}