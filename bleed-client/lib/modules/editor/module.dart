import 'package:bleed_client/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/zoom.dart';

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
