import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/classes/DynamicObject.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/Explosion.dart';
import 'package:gamestream_flutter/classes/NpcDebug.dart';
import 'package:gamestream_flutter/classes/Projectile.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

import 'modules/isometric/classes.dart';


final game = _Game();

class _Game {
  final lobby = _Lobby();
  final royal = _Royal();
  final type = Watch(GameType.None);
  final countDownFramesRemaining = Watch(0);
  final numberOfPlayersNeeded = Watch(0);
  final teamLivesWest = Watch(-1);
  final teamLivesEast = Watch(-1);
  final teamSize = Watch(0);
  final numberOfTeams = Watch(0);
  final totalZombies = Watch(0);
  final totalPlayers = Watch(0);
  final totalDynamicObjects = Watch(0);
  final players = <Character>[];
  final zombies = <Character>[];
  final collectables = <Collectable>[];
  final interactableNpcs = <Character>[];
  final dynamicObjects = <DynamicObject>[];
  final effects = <Effect>[];
  final torches = <EnvironmentObject>[];
  final projectiles = <Projectile>[];
  final crates = <Vector2>[];
  final bulletHoles = <Vector2>[];
  final npcDebug = <NpcDebug>[];
  final scoreBuilder = StringBuffer();
  final scoreText = Watch("");
  var customGameName = "";
  var cratesTotal = 0;
  var totalNpcs = 0;
  var totalCubes = 0;
  var totalCollectables = 0;
  var bulletHoleIndex = 0;
  var id = -1;
  var totalProjectiles = 0;
  var itemsTotal = 0;

  _Game() {
    for (var i = 0; i < 2000; i++) {
      dynamicObjects.add(DynamicObject());
    }
    for (var i = 0; i < 150; i++) {
      players.add(Character());
    }
    for (var i = 0; i < 50; i++) {
      interactableNpcs.add(Character());
    }
    for (var i = 0; i < 1500; i++) {
      zombies.add(Character());
    }
    for (var i = 0; i < 50; i++) {
      bulletHoles.add(Vector2(0, 0));
    }
    for (var i = 0; i < 200; i++) {
      projectiles.add(Projectile());
    }
    for (var i = 0; i < 500; i++) {
      collectables.add(Collectable());
    }
  }

  Character getNextHighestScore(){
     Character? highestPlayer;
     final numberOfPlayers = totalPlayers.value;
     for(var i = 0; i < numberOfPlayers; i++){
        final player = players[i];
        if (player.scoreMeasured) continue;
        if (highestPlayer == null){
          highestPlayer = player;
          continue;
        }
        if (player.score < highestPlayer.score) continue;
        highestPlayer = player;
     }
     if (highestPlayer == null){
       throw Exception("Could not find highest player");
     }
     highestPlayer.scoreMeasured = true;
     return highestPlayer;
  }

  void updateScoreText(){
    scoreBuilder.clear();
    final totalNumberOfPlayers = totalPlayers.value;
    if (totalNumberOfPlayers <= 0) return;
    scoreBuilder.write("SCORE\n");

    for (var i = 0; i < totalNumberOfPlayers; i++) {
      final player = players[i];
      player.scoreMeasured = false;
    }

    for (var i = 0; i < totalNumberOfPlayers; i++) {
      final player = getNextHighestScore();
      scoreBuilder.write('${i + 1}. ${player.name} ${player.score}\n');
    }
    scoreText.value = scoreBuilder.toString();
  }
}

class _Royal {
  var radius = 0.0;
  var mapCenter = Vector2(0, 0);
}

class _Lobby {
  final playerCount = Watch(0);
  final players = <_LobbyPlayer>[];

  void add({
    required int team,
    required String name
  }) {
    if (team == 0) {
      players.insert(0, _LobbyPlayer(name, team));
    } else {
      players.add(_LobbyPlayer(name, team));
    }
  }

  List<_LobbyPlayer> getPlayersOnTeam(int team) {
    return players.where((element) => element.team == team).toList();
  }
}

class _LobbyPlayer {
  String name;
  int team;
  bool notSet = true;

  _LobbyPlayer(this.name, this.team);
}


