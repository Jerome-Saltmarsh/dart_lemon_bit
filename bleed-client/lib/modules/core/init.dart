import 'dart:async';

import 'package:bleed_client/audio.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/cube/init_cube.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/events/onCompiledGameChanged.dart';
import 'package:bleed_client/events/onShadeMaxChanged.dart';
import 'package:bleed_client/events/onTimeChanged.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/watches/compiledGame.dart';
import 'package:bleed_client/watches/phase.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../actions.dart';

final isLocalHost = Uri.base.host == 'localhost';

Future init() async {
  Events();
  await images.load();
  await loadSharedPreferences();
  initializeGameInstances();
  initializeEventListeners();
  initAudioPlayers();
  initCube();
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
        .add(Projectile(0, 0, ProjectileType.Bullet, Direction.DownLeft));
    game.items.add(Item(type: ItemType.None, x: 0, y: 0));
  }

  for (int i = 0; i < 1000; i++) {
    game.crates.add(Vector2(0, 0));
  }

  for (int i = 0; i < game.settings.maxBulletHoles; i++) {
    game.bulletHoles.add(Vector2(0, 0));
  }

  game.zombies.clear();
  for (int i = 0; i < 2500; i++) {
    game.zombies.add(Zombie());
  }

  game.interactableNpcs.clear();
  for (int i = 0; i < 200; i++) {
    game.interactableNpcs.add(Character(type: CharacterType.Human));
  }

  game.humans.clear();
  for (int i = 0; i < 500; i++) {
    game.humans.add(Character(type: CharacterType.Human));
  }
}

void onPlayerWeaponChanged(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.HandGun:
      playAudioReload(screenCenterWorldX, screenCenterWorldY);
      break;
    case WeaponType.Shotgun:
      playAudioCockShotgun(screenCenterWorldX, screenCenterWorldY);
      break;
    case WeaponType.SniperRifle:
      playAudioSniperEquipped(screenCenterWorldX, screenCenterWorldY);
      break;
    case WeaponType.AssaultRifle:
      playAudioReload(screenCenterWorldX, screenCenterWorldY);
      break;
    default:
      break;
  }
}

void initializeEventListeners() {
  engine.callbacks.onMouseScroll = onMouseScroll;
  webSocket.eventStream.stream.listen(_onEventReceivedFromServer);
  observeCompiledGame(onCompiledGameChanged);
  modules.isometric.state.time.onChanged(onTimeChanged);
  phase.onChanged(modules.isometric.actions.setAmbientLightAccordingToPhase);
  game.shadeMax.onChanged(onShadeMaxChanged);



  // registerKeyboardHandler((RawKeyEvent event) {
  //   if (!hud.state.textBoxVisible.value) return;
  //   if (event is RawKeyDownEvent) {
  //     if (event.logicalKey == LogicalKeyboardKey.enter) {
  //       sendAndCloseTextBox();
  //     } else if (event.logicalKey == LogicalKeyboardKey.escape) {
  //       hideTextBox();
  //     }
  //   }
  // });

  hud.focusNodes.textFieldMessage.addListener(() {
    if (hud.textBoxFocused){
      deregisterPlayKeyboardHandler();
      registerTextBoxKeyboardHandler();
    }else{
      registerPlayKeyboardHandler();
      deregisterTextBoxKeyboardHandler();
    }
  });


  game.player.state.onChanged((CharacterState state) {
    game.player.alive.value = state != CharacterState.Dead;
  });

  game.settings.audioMuted.onChanged((value) {
    if (sharedPreferences == null) return;
    sharedPreferences.setBool('audioMuted', value);
  });

  game.player.weaponType.onChanged(onPlayerWeaponChanged);

  onRightClickChanged.stream.listen((bool down) {
    if (down) {
      print("request deselect");
      sendRequestDeselectAbility();
    }
  });
}

void _onEventReceivedFromServer(dynamic value) {
  game.lag = game.framesSinceEvent;
  game.framesSinceEvent = 0;
  compiledGame = value;
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
    actions.login(storage.recallAuthorization());
  }

  // userService.getVersion().then((version) {
  //     print("server-version: $version");
  // });
}
