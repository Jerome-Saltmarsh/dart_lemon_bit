import 'package:lemon_math/Vector2.dart';

import '../common/CharacterType.dart';
import '../common/WeaponType.dart';
import '../enums/npc_mode.dart';
import '../maths.dart';
import '../settings.dart';
import 'Character.dart';
import 'TileNode.dart';
import 'Weapon.dart';

final Character _nonTarget =
  Character(
      type: CharacterType.Human,
      x: -100000,
      y: -1000000,
      weapons: [Weapon(type: WeaponType.Unarmed, damage: 0, capacity: 0)],
      health: 0,
      speed: 0
  );

class Npc extends Character {
  Character target = _nonTarget;
  List<Vector2> path = [];
  List<TileNodeVisit> visits = [];
  List<Vector2> objectives = [];
  NpcMode mode = NpcMode.Aggressive;
  bool followingPath = false;
  int experience;

  static const _maxVisits = 10;

  Npc({
    required CharacterType type,
    required double x,
    required double y,
    required int health,
    Weapon? weapon,
    this.experience = 0,
  })
      : super(
      type: type,
      x: x,
      y: y,
      weapons: weapon != null ? [weapon] : [],
      health: health,
      speed: settings.zombieSpeed,
  ){
    for(int i = 0; i < _maxVisits; i++){
      visits.add(TileNodeVisit(null, -1, emptyTileNode));
    }
  }

  bool get targetSet => target != _nonTarget;
  bool get pathSet => path.isNotEmpty;
  bool get objectiveSet => objectives.isNotEmpty;
  Vector2 get objective => objectives.last;

  void clearTarget() {
    target = _nonTarget;
    if (path.isNotEmpty){
      path = [];
    }
  }

  void findPathNodes(TileNode startNode, TileNode endNode) {
    followingPath = true;
    if (!startNode.open) followingPath = false;
    if (!endNode.open) followingPath = false;

    _search++;
    visits.forEach((visit) {
      visit.available = true;
    });
    startNode.search = _search;

    while (visits.isNotEmpty) {
      TileNodeVisit closest = visits[0];
      int index = 0;

      for(int i = 1; i < visits.length; i++){
        if (closest.isCloserThan(visits[i])) continue;
        closest = visits[i];
        index = i;
      }

      if (closest.tileNode == endNode) {
        List<Vector2> nodes =
        List.filled(closest.travelled, _vector2Zero, growable: true);
        int index = closest.travelled - 1;
        while (closest.previous != null) {
          nodes[index] = closest.tileNode.position;
          index--;
          closest = closest.previous!;
        }
        visits.clear();
        return;
      }

      visits.removeAt(index);

      if (closest.tileNode.up.open) {
        visit(closest.tileNode.up, closest, visits, endNode);
        if (closest.tileNode.right.open) {
          visit(closest.tileNode.upRight, closest, visits, endNode);
        }
        if (closest.tileNode.left.open) {
          visit(closest.tileNode.upRight, closest, visits, endNode);
        }
      }
      if (closest.tileNode.down.open) {
        visit(closest.tileNode.down, closest, visits, endNode);
        if (closest.tileNode.right.open) {
          visit(closest.tileNode.rightDown, closest, visits, endNode);
        }
        if (closest.tileNode.left.open) {
          visit(closest.tileNode.downLeft, closest, visits, endNode);
        }
      }
      visit(closest.tileNode.right, closest, visits, endNode);
      visit(closest.tileNode.left, closest, visits, endNode);
    }
  }

  void visit(TileNode tileNode, TileNodeVisit previous,
      List<TileNodeVisit> visits, TileNode endNode) {
    if (!tileNode.open) return;
    if (tileNode.search == _search) return;

    int remaining =
        diffInt(tileNode.x, endNode.x) + diffInt(tileNode.y, endNode.y);
    TileNodeVisit tileNodeVisit = TileNodeVisit(previous, remaining, tileNode);
    visits.add(tileNodeVisit);
    tileNode.search = _search;
  }

  int _search = 0;
}

final Vector2 _vector2Zero = Vector2(0, 0);
final TileNode emptyTileNode = TileNode(false);

