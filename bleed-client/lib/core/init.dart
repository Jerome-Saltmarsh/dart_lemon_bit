import 'package:bleed_client/audio.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/events/onAmbientLightChanged.dart';
import 'package:bleed_client/events/onCompiledGameChanged.dart';
import 'package:bleed_client/events/onGameJoined.dart';
import 'package:bleed_client/events/onPhaseChanged.dart';
import 'package:bleed_client/events/onShadeMaxChanged.dart';
import 'package:bleed_client/events/onTimeChanged.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/network/functions/connect.dart';
import 'package:bleed_client/network/streams/eventStream.dart';
import 'package:bleed_client/network/streams/onConnect.dart';
import 'package:bleed_client/network/streams/onConnected.dart';
import 'package:bleed_client/network/streams/onDisconnected.dart';
import 'package:bleed_client/network/streams/onDone.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/watches/ambientLight.dart';
import 'package:bleed_client/watches/compiledGame.dart';
import 'package:bleed_client/watches/phase.dart';
import 'package:bleed_client/watches/time.dart';
import 'package:lemon_engine/functions/register_on_mouse_scroll.dart';
import 'package:lemon_engine/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/compose/dialogs.dart';

Future init() async {
  await images.load();
  await loadSharedPreferences();
  initializeGameInstances();
  initializeEventListeners();
  initAudioPlayers();
  initUI();
  rebuildUI();



  if (Uri.base.hasQuery && Uri.base.queryParameters.containsKey('host')) {
    Future.delayed(Duration(seconds: 1), () {
      String host = Uri.base.queryParameters['host'];
      String connectionString = parseHttpToWebSocket(host);
      connect(connectionString);
    });
  }
}

void initializeGameInstances() {
  for (int i = 0; i < 5000; i++) {
    game.projectiles
        .add(Projectile(0, 0, ProjectileType.Bullet, Direction.DownLeft));
    game.items.add(Item());
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

void initializeEventListeners(){

  registerPlayKeyboardHandler();
  registerOnMouseScroll(onMouseScroll);
  onConnectedController.stream.listen(_onConnected);
  eventStream.stream.listen(_onEventReceivedFromServer);
  observeCompiledGame(onCompiledGameChanged);
  on(onGameJoined);
  timeInSeconds.onChanged(onTimeChanged);
  phase.onChanged(onPhaseChanged);
  observeAmbientLight(onAmbientLightChanged);
  game.shadeMax.onChanged(onShadeMaxChanged);

  onLeftClicked.stream.listen((event) {
    print("left clicked");
    characterController.action = CharacterAction.Perform;
  });

  game.player.state.onChanged((CharacterState state) {
    game.player.alive.value = state != CharacterState.Dead;
  });

  game.settings.audioMuted.onChanged((value) {
    if (sharedPreferences == null) return;
    sharedPreferences.setBool('audioMuted', value);
  });

  game.player.weapon.onChanged(onPlayerWeaponChanged);

  onDisconnected.stream.listen((event) {
    print("disconnect");
    showDialogConnectFailed();
    clearState();
  });

  onConnectController.stream.listen((event) {
    print('on connect $event');
    clearState();
    sendRequestPing();
  });

  onDoneStream.stream.listen((event) {
    print("connection done");
    clearState();
    rebuildUI();
    redrawCanvas();
  });

  onRightClickChanged.stream.listen((bool down) {
    if (down){
      print("request deselect");
      sendRequestDeselectAbility();
    }
  });
}

void _onEventReceivedFromServer(dynamic value) {
  lag = framesSinceEvent;
  framesSinceEvent = 0;
  compiledGame = value;
}

void _onConnected(_event) {
  print("Connection to server established");
  sendRequestJoinGame();
}

Future loadSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
  game.settings.audioMuted.value = sharedPreferences.containsKey('audioMuted') &&
      sharedPreferences.getBool('audioMuted');

  // if (sharedPreferences.containsKey('server')) {
  //   Server server = servers[sharedPreferences.getInt('server')];
  //   connectServer(server);
  // }

  // if (sharedPreferences.containsKey('last-refresh')) {
  //   DateTime lastRefresh =
  //   DateTime.parse(sharedPreferences.getString('last-refresh'));
  //   DateTime now = DateTime.now();
  //   if (now
  //       .difference(lastRefresh)
  //       .inHours > 1) {
  //     sharedPreferences.setString(
  //         'last-refresh', DateTime.now().toIso8601String());
  //     refreshPage();
  //   }
  // } else {
  //   sharedPreferences.setString(
  //       'last-refresh', DateTime.now().toIso8601String());
  // }
  // );
}
