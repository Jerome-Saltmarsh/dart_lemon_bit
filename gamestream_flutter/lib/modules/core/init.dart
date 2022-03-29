import 'dart:async';

import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/classes/Character.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/Projectile.dart';
import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/enums/ProjectileType.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/sharedPreferences.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:shared_preferences/shared_preferences.dart';


final isLocalHost = Uri.base.host == 'localhost'; // TODO move to lemon-engine

Future init() async {
  await loadSharedPreferences();
  isometric.state.image = await loadImage('images/atlas.png'); // TODO move to lemon-engine
  engine.image = isometric.state.image;
  initializeGameInstances();
  initializeEventListeners();
  audio.init();
  if (isLocalHost) {
    print("Environment: Localhost");
  } else {
    print("Environment: Production");
  }
  engine.cursorType.value = CursorType.Basic;
}

void initializeGameInstances() {
  for (var i = 0; i < 1000; i++) {
    isometric.state.items.add(Item(type: ItemType.Handgun, x: 0, y: 0));
  }


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

  if (storage.authorizationRemembered) {
    core.actions.login(storage.recallAuthorization());
  }
}
