import 'dart:async';

import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/shared_preferences.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_engine/load_image.dart';
import 'package:lemon_engine/state/atlas.dart';
import 'package:shared_preferences/shared_preferences.dart';

final isLocalHost = Uri.base.host == 'localhost'; // TODO move to lemon-engine

Future init() async {
  await loadSharedPreferences();
  initializeEventListeners();
  Images.mapAtlas = await loadImage('images/atlas-map.png');
  Images.blocks = await loadImage('images/atlas-blocks.png');
  Images.characters = await loadImage('images/atlas-characters.png');
  atlas = Images.characters;
  engine.cursorType.value = CursorType.Basic;
  print("environment: ${isLocalHost ? 'localhost' : 'production'}");
}

void initializeEventListeners() {
  engine.callbacks.onMouseScroll = engine.events.onMouseScroll;
}

Future loadSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
  _loadStateFromSharedPreferences();
}

void _loadStateFromSharedPreferences(){
  if (storage.serverSaved) {
    core.state.region.value = storage.serverType;
  }
  // if (storage.authorizationRemembered) {
  //   core.actions.login(storage.recallAuthorization());
  // }
}

