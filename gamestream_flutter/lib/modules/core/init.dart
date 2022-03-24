import 'dart:async';

import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/classes/Character.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/Projectile.dart';
import 'package:bleed_common/CharacterType.dart';
import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/WeaponType.dart';
import 'package:bleed_common/enums/ProjectileType.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/sharedPreferences.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:shared_preferences/shared_preferences.dart';


final isLocalHost = Uri.base.host == 'localhost';

Future init() async {
  await loadSharedPreferences();
  isometric.state.image = await loadImage('images/atlas.png');
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
    game.projectiles.add(Projectile(0, 0, ProjectileType.Bullet, 0));
    isometric.state.items.add(Item(type: ItemType.Handgun, x: 0, y: 0));
  }

  for (var i = 0; i < 1000; i++) {
    game.crates.add(Vector2(0, 0));
  }

  for (var i = 0; i < game.settings.maxBulletHoles; i++) {
    game.bulletHoles.add(Vector2(0, 0));
  }

  final zombies = game.zombies;
  zombies.clear();
  for (var i = 0; i < 5000; i++) {
    zombies.add(Character(type: CharacterType.Zombie));
  }

  game.interactableNpcs.clear();
  for (int i = 0; i < 300; i++) {
    game.interactableNpcs.add(Character(type: CharacterType.Human));
  }

  game.players.clear();
  for (int i = 0; i < 500; i++) {
    game.players.add(Character(type: CharacterType.Human));
  }
}

void onPlayerWeaponChanged(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.HandGun:
      audio.reload(screenCenterWorldX, screenCenterWorldY);
      break;
    case WeaponType.Shotgun:
      audio.cockShotgun(screenCenterWorldX, screenCenterWorldY);
      break;
    case WeaponType.SniperRifle:
      audio.sniperEquipped(screenCenterWorldX, screenCenterWorldY);
      break;
    case WeaponType.AssaultRifle:
      audio.reload(screenCenterWorldX, screenCenterWorldY);
      break;
    default:
      break;
  }
}

void initializeEventListeners() {
  engine.callbacks.onMouseScroll = engine.events.onMouseScroll;
  modules.game.state.soldier.weaponType.onChanged(onPlayerWeaponChanged);
}

Future loadSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
  _loadStateFromSharedPreferences();
}

void _loadStateFromSharedPreferences(){
  print("_loadStateFromSharedPreferences()");

  if (storage.serverSaved) {
    core.state.region.value = storage.serverType;
  }

  if (storage.authorizationRemembered) {
    core.actions.login(storage.recallAuthorization());
  }

  // userService.getVersion().then((version) {
  //     print("server-version: $version");
  // });
}
