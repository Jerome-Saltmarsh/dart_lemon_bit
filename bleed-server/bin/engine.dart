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


void updateCollisionBetween(List<GameObject> gameObjects) {
  for (int i = 0; i < gameObjects.length - 1; i++) {
    if (!gameObjects[i].collidable) continue;
    for (int j = i + 1; j < gameObjects.length; j++) {
      if (!gameObjects[j].collidable) continue;
      if (gameObjects[j].top > gameObjects[i].bottom) break;
      if (gameObjects[j].left > gameObjects[i].right) continue;
      if (gameObjects[j].bottom < gameObjects[i].top) continue;
      resolveCollisionA(gameObjects[i], gameObjects[j]);
    }
  }
}

typedef void CollisionResolver(GameObject a, GameObject b);

void resolveCollisionA(GameObject a, GameObject b) {
  double overlap = collisionOverlap(a, b);
  if (overlap < 0) return;
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;

  if (xDiff == 0 && yDiff == 0) {
    a.x -= 5;
    b.y += 5;
    xDiff = 10;
  }

  double halfOverlap = overlap * 0.5;
  double mag = hypotenuse(xDiff, yDiff);
  double ratio = 1.0 / mag;
  double xDiffNormalized = xDiff * ratio;
  double yDiffNormalized = yDiff * ratio;
  double targetX = xDiffNormalized * halfOverlap;
  double targetY = yDiffNormalized * halfOverlap;
  a.x += targetX;
  a.y += targetY;
  b.x -= targetX;
  b.y -= targetY;
}

void resolveCollisionB(GameObject a, GameObject b) {
  double overlap = collisionOverlap(a, b);
  if (overlap < 0) return;
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;
  double mag = hypotenuse(xDiff, yDiff);
  double ratio = 1.0 / mag;
  double xDiffNormalized = xDiff * ratio;
  double yDiffNormalized = yDiff * ratio;
  double targetX = xDiffNormalized * overlap;
  double targetY = yDiffNormalized * overlap;
  a.x += targetX;
  a.y += targetY;
}

double collisionOverlap(GameObject a, GameObject b) {
  return a.radius + b.radius - distanceV2(a, b);
}

void resolveCollisionBetween(List<GameObject> gameObjectsA,
    List<GameObject> gameObjectsB, CollisionResolver resolve) {
  int minJ = 0;
  for (int i = 0; i < gameObjectsA.length; i++) {
    final a = gameObjectsA[i];
    if (!a.collidable) continue;
    for (int j = minJ; j < gameObjectsB.length; j++) {
      final b = gameObjectsB[j];
      if (!b.collidable) continue;
      if (a.bottom < b.top) {
        minJ++;
        break;
      }
      if (a.top > b.bottom) continue;
      if (a.right < b.left) continue;
      if (a.left > b.right) continue;
      resolve(a, b);
    }
  }
}
