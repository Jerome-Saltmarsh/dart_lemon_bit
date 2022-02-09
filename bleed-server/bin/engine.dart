import 'dart:async';

import 'package:lemon_math/hypotenuse.dart';

import 'classes/Game.dart';
import 'classes/GameObject.dart';
import 'common/Settings.dart';
import 'games/world.dart';
import 'global.dart';
import 'language.dart';
import 'maths.dart';

const framesPerSecond = targetFPS;
const msPerFrame = Duration.millisecondsPerSecond ~/ framesPerSecond;
const msPerUpdateNpcTarget = 500;
const secondsPerRemoveDisconnectedPlayers = 4;
const secondsPerUpdateNpcObjective = 4;

final _Engine engine = _Engine();

class _Engine {

  int frame = 0;

  void init() {
    // @on init jobs
    Future.delayed(Duration(seconds: 3), () {
      periodic(fixedUpdate, ms: msPerFrame);
      periodic(updateNpcObjective, seconds: secondsPerUpdateNpcObjective);
      periodic(removeDisconnectedPlayers, seconds: secondsPerRemoveDisconnectedPlayers);
      periodic(updateNpcTargets, ms: msPerUpdateNpcTarget);
    });
  }

  void fixedUpdate(Timer timer) {
    frame++;
    updateOpenWorldTime();
    global.update();
  }

  void updateNpcTargets(Timer timer) {
    for (final game in global.games) {
      game.updateInteractableNpcTargets();
      game.updateZombieTargets();
    }
  }

  void updateOpenWorldTime() {
    worldTime = (worldTime + secondsPerFrame) % secondsPerDay;
  }

  void removeDisconnectedPlayers(Timer timer) {
    for (Game game in global.games) {
      game.removeDisconnectedPlayers();
    }
  }

  void updateNpcObjective(Timer timer) {
    for (final game in global.games) {
      for (final zombie in game.zombies) {
        if (zombie.inactive) continue;
        if (zombie.busy) continue;
        if (zombie.dead) continue;
        final ai = zombie.ai;
        if (ai == null) continue;
        if (ai.target != null) continue;
        if (ai.path.isNotEmpty) continue;
        game.updateNpcObjective(ai);
        if (ai.objectives.isEmpty) {
          game.npcSetRandomDestination(ai);
        } else {
          final objective = ai.objectives.last;
          game.npcSetPathTo(ai, objective.x, objective.y);
        }
      }
    }
  }
}


