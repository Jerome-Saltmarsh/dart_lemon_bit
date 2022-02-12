import 'dart:async';

import 'package:bleed_client/audio.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/sharedPreferences.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:shared_preferences/shared_preferences.dart';


final isLocalHost = Uri.base.host == 'localhost';

Future init() async {
  await loadSharedPreferences();
  isometric.state.image = await loadImage('images/atlas.png');
  engine.state.image = isometric.state.image;
  initializeGameInstances();
  initializeEventListeners();
  initAudioPlayers();
  if (isLocalHost) {
    print("Environment: Localhost");
  } else {
    print("Environment: Production");
  }

  engine.state.cursorType.value = CursorType.Basic;
}

void initializeGameInstances() {
  for (int i = 0; i < 5000; i++) {
    game.projectiles
        .add(Projectile(0, 0, ProjectileType.Bullet, 0));
    isometric.state.items.add(Item(type: ItemType.None, x: 0, y: 0));
  }

  for (int i = 0; i < 1000; i++) {
    game.crates.add(Vector2(0, 0));
  }

  for (int i = 0; i < game.settings.maxBulletHoles; i++) {
    game.bulletHoles.add(Vector2(0, 0));
  }

  game.zombies.clear();
  for (int i = 0; i < 2500; i++) {
    game.zombies.add(Character(type: CharacterType.Zombie));
  }

  game.interactableNpcs.clear();
  for (int i = 0; i < 200; i++) {
    game.interactableNpcs.add(Character(type: CharacterType.Soldier));
  }

  game.humans.clear();
  for (int i = 0; i < 500; i++) {
    game.humans.add(Character(type: CharacterType.Template));
  }
}

void onPlayerWeaponChanged(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.HandGun:
      audio.reload(screenCenterWorldX, screenCenterWorldY);
      break;
    case WeaponType.Shotgun:
      playAudioCockShotgun(screenCenterWorldX, screenCenterWorldY);
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

  modules.game.state.textFieldMessage.addListener(() {
    if (hud.textBoxFocused){
        modules.game.state.textMode.value = true;
    }else{
      modules.game.state.textMode.value = false;
    }
  });

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
