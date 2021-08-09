import 'classes/Game.dart';
import 'classes.dart';
import 'instances/game.dart';
import 'jobs.dart';
import 'language.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';

void initUpdateLoop() {
  periodic(fixedUpdate, ms: 1000 ~/ 30);
  periodic(jobNpcWander, seconds: 3);
  periodic(jobRemoveDisconnectedPlayers, seconds: 5);
  periodic(updateNpcTargets, ms: 500);
}

void fixedUpdate() {
  frame++;
  DateTime now = DateTime.now();
  frameDuration = now.difference(frameTime);
  if (frameDuration.inMilliseconds > 0) {
    fps = 1000 ~/ frameDuration.inMilliseconds;
  }
  frameTime = now;
  game.updateAndCompile();
}

void updateNpcTargets() {
  int minP = 0;
  Npc npc;

  for (int i = 0; i < game.npcs.length; i++) {
    if (game.npcs[i].targetSet) continue;
    npc = game.npcs[i];
    for (int p = minP; p < game.players.length; p++) {
      if (game.players[p].x < npc.x - zombieViewRange) {
        minP++;
        break;
      }
      if (game.players[p].x > npc.x + zombieViewRange) {
        break;
      }
      if (abs(game.players[p].y - npc.y) > zombieViewRange) {
        continue;
      }

      npc.target = game.players[p];
    }
  }
}


int compareGameObjects(GameObject a, GameObject b) {
  if (a.x < b.x) {
    return -1;
  }
  return 1;
}

void updateCollisionBetween(List<GameObject> gameObjects) {
  for (int i = 0; i < gameObjects.length - 1; i++) {
    if (!gameObjects[i].collidable) continue;
    for (int j = i + 1; j < gameObjects.length; j++) {
      if (!gameObjects[j].collidable) continue;
      if (gameObjects[j].left > gameObjects[i].right) break;
      if (gameObjects[j].top > gameObjects[i].bottom) continue;
      if (gameObjects[j].bottom < gameObjects[i].top) continue;
      resolveCollision(gameObjects[i], gameObjects[j]);
    }
  }
}

double collisionOverlap(GameObject a, GameObject b) {
  return a.radius + b.radius - distanceBetween(a, b);
}

void resolveCollision(GameObject a, GameObject b) {
  double overlap = collisionOverlap(a, b);
  if (overlap < 0) return;
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;
  double halfOverlap = overlap * 0.5;
  double mag = magnitude(xDiff, yDiff);
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


void resolveCollisionBetween(
    List<GameObject> gameObjectsA, List<GameObject> gameObjectsB) {
  int minJ = 0;
  for (int i = 0; i < gameObjectsA.length; i++) {
    if (!gameObjectsA[i].collidable) continue;
    for (int j = minJ; j < gameObjectsB.length; j++) {
      if (!gameObjectsB[minJ].collidable) {
        minJ++;
        break;
      }
      if (gameObjectsB[j].left > gameObjectsA[i].right) break;
      if (gameObjectsB[j].right < gameObjectsA[i].left) {
        minJ++;
        continue;
      }
      if (gameObjectsA[i].top > gameObjectsB[j].bottom) continue;
      if (gameObjectsA[i].bottom < gameObjectsB[j].top) continue;
      resolveCollision(gameObjectsA[i], gameObjectsB[j]);
    }
  }
}
