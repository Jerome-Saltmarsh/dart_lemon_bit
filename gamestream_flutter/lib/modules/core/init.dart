import 'dart:async';

import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/event_handlers.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/shared_preferences.dart';
import 'package:gamestream_flutter/website/website.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_engine/load_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future init(SharedPreferences sharedPreferences) async {
  await loadStateFromSharedPreferences();
  Images.characters = await loadImage('images/atlas-characters.png');
  Images.zombie = await loadImage('images/atlas-zombie.png');
  Images.mapAtlas = await loadImage('images/atlas-map.png');
  Images.blocks = await loadImage('images/atlas-blocks.png');
  engine.cursorType.value = CursorType.Basic;
  print("environment: ${engine.isLocalHost ? 'localhost' : 'production'}");

  engine.register(
     onTapDown: EventHandler.onTapDown,
     onDrawCanvas: Website.renderCanvas,
  );
}


Future loadStateFromSharedPreferences() async {
  if (storage.serverSaved) {
    core.state.region.value = storage.serverType;
  }
  // if (storage.authorizationRemembered) {
  //   core.actions.login(storage.recallAuthorization());
  // }
}

