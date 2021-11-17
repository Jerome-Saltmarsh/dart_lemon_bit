import 'package:bleed_client/audio.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/events/onAmbientLightChanged.dart';
import 'package:bleed_client/events/onCompiledGameChanged.dart';
import 'package:bleed_client/events/onGameJoined.dart';
import 'package:bleed_client/events/onPhaseChanged.dart';
import 'package:bleed_client/setters/setAmbientLightAccordingToPhase.dart';
import 'package:bleed_client/events/onShadeMaxChanged.dart';
import 'package:bleed_client/events/onTimeChanged.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/network/functions/send.dart';
import 'package:bleed_client/network/streams/eventStream.dart';
import 'package:bleed_client/network/streams/onConnect.dart';
import 'package:bleed_client/network/streams/onConnected.dart';
import 'package:bleed_client/network/streams/onDisconnected.dart';
import 'package:bleed_client/network/streams/onDone.dart';
import 'package:bleed_client/onMouseScroll.dart';
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

import '../state/settings.dart';
import '../ui/compose/dialogs.dart';

Future init() async {
  print("init()");
  print("loading images");
  await images.load();
  await loadSharedPreferences();
  print("loading images finished");
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

  player.state.onChanged((CharacterState state) {
     player.alive.value = state != CharacterState.Dead;
  });

  settings.audioMuted.onChanged((value) {
    if (sharedPreferences == null) return;
    sharedPreferences.setBool('audioMuted' , value);
  });

  for (int i = 0; i < settings.maxParticles; i++) {
    game.particles.add(Particle());
  }

  for (int i = 0; i < 1000; i++) {
    game.projectiles.add(Projectile(0, 0, ProjectileType.Bullet, Direction.DownLeft));
    game.items.add(Item());
  }

  for (int i = 0; i < 2000; i++) {
    game.crates.add(Vector2(0, 0));
  }

  for (int i = 0; i < settings.maxBulletHoles; i++) {
    game.bulletHoles.add(Vector2(0, 0));
  }

  game.zombies.clear();
  for (int i = 0; i < 5000; i++) {
    game.zombies.add(Zombie());
  }

  game.interactableNpcs.clear();
  for (int i = 0; i < 200; i++) {
    game.interactableNpcs.add(Character());
  }

  game.humans.clear();
  for (int i = 0; i < 1000; i++) {
    game.humans.add(Character());
  }

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

  initAudioPlayers();
  initUI();
  rebuildUI();


  onRightClickChanged.stream.listen((bool down) {
    inputRequest.sprint = down;
  });

  game.playerWeapon.onChanged(onPlayerWeaponChanged);
}

void onPlayerWeaponChanged(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      playAudioReload(screenCenterWorldX, screenCenterWorldY);
      break;
    case Weapon.Shotgun:
      playAudioCockShotgun(screenCenterWorldX, screenCenterWorldY);
      break;
    case Weapon.SniperRifle:
      playAudioSniperEquipped(screenCenterWorldX, screenCenterWorldY);
      break;
    case Weapon.AssaultRifle:
      playAudioReload(screenCenterWorldX, screenCenterWorldY);
      break;
  }
}


void _onEventReceivedFromServer(dynamic value) {
  lag = framesSinceEvent;
  framesSinceEvent = 0;
  compiledGame = value;
}

void _onConnected(_event) {
  print("on connected");
  rebuildUI();
  Future.delayed(Duration(seconds: 1), rebuildUI);
  sendRequestJoinGame();
}

void joinGameCasual() {
  // send(ClientRequest.Game_Join_Casual.index.toString());
}

void sendRequestJoinGame() {
  send(ClientRequest.Join.index.toString());
}

Future loadSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
  //@ on sharedPreferences loaded
  settings.audioMuted.value = sharedPreferences.containsKey('audioMuted') &&
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

