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
import 'package:bleed_client/events/onAmbientLightChanged.dart';
import 'package:bleed_client/events/onCompiledGameChanged.dart';
import 'package:bleed_client/events/onPhaseChanged.dart';
import 'package:bleed_client/events/onShadeMaxChanged.dart';
import 'package:bleed_client/events/onTimeChanged.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:bleed_client/watches/ambientLight.dart';
import 'package:bleed_client/watches/compiledGame.dart';
import 'package:bleed_client/watches/phase.dart';
import 'package:bleed_client/watches/time.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:lemon_engine/functions/register_on_mouse_scroll.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/cursor.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../actions.dart';

final isLocalHost = Uri.base.host == 'localhost';

// int start = 0;
// final streamText = "|~ |||  | ~|| | ||| | ||~ |  ||  | ||||~ | |  |";
// final streamLength = 20;
//
// int index = 0;

Future init() async {
  Events();
  await images.load();
  await loadSharedPreferences();
  initializeGameInstances();
  initializeEventListeners();
  initAudioPlayers();
  initCube();
  if (isLocalHost){
    print("Environment: Localhost");
  }else{
    print("Environment: Production");
  }

  // repeat update title for loading

  // Timer.periodic(Duration(milliseconds: 100), (timer) {
  //   index = (index + 1) % 4;
  //   setFavicon('archer${index + 1}.png');
  // });

  // Timer.periodic(Duration(milliseconds: 100), (timer) {
  //     final buffer = StringBuffer('GAMESTREAM');
  //     // start = (start + 1) % streamText.length;
  //     start--;
  //     if (start < 0){
  //       start = streamText.length - 1;
  //     }
  //     if (start + streamLength < streamText.length){
  //       for(int i = 0; i < streamLength; i++){
  //         buffer.write(streamText[start + i]);
  //       }
  //     }else{
  //       int diff = streamText.length - start;
  //       for(int i = 0; i < diff; i++){
  //         buffer.write(streamText[start + i]);
  //       }
  //       for(int i = 0; i < streamLength - diff; i++){
  //         buffer.write(streamText[i]);
  //       }
  //     }
  //     setDocumentTitle(buffer.toString());
  // });

  cursorType.value = CursorType.Basic;

  // if (Uri.base.hasQuery && Uri.base.queryParameters.containsKey('host')) {
  //   // Future.delayed(Duration(seconds: 1), () {
  //   //   String host = Uri.base.queryParameters['host'];
  //   //   String connectionString = parseHttpToWebSocket(host);
  //   //   connectWebSocket(connectionString);
  //   // });
  //   print(Uri.base.path);
  // }
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
  }
}

void initializeEventListeners() {
  // registerPlayKeyboardHandler();
  registerOnMouseScroll(onMouseScroll);
  webSocket.eventStream.stream.listen(_onEventReceivedFromServer);
  observeCompiledGame(onCompiledGameChanged);
  timeInSeconds.onChanged(onTimeChanged);
  phase.onChanged(onPhaseChanged);
  observeAmbientLight(onAmbientLightChanged);
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
    game.region.value = storage.serverType;
  }

  if (storage.authorizationRemembered) {
    actions.login(storage.recallAuthorization());
  }

  userService.getVersion().then((version) {
      print("server-version: $version");
  });
}
