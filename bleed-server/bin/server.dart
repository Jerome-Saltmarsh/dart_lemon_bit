import 'dart:math';

import 'package:bleed_server/CubeGame.dart';
import 'package:lemon_math/diff.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'classes/Ability.dart';
import 'classes/Character.dart';
import 'classes/Game.dart';
import 'classes/Player.dart';
import 'classes/Weapon.dart';
import 'common/AbilityMode.dart';
import 'common/CharacterAction.dart';
import 'common/CharacterState.dart';
import 'common/CharacterType.dart';
import 'common/ClientRequest.dart';
import 'common/GameError.dart';
import 'common/GameStatus.dart';
import 'common/GameType.dart';
import 'common/PlayerEvent.dart';
import 'common/ServerResponse.dart';
import 'common/WeaponType.dart';
import 'common/enums/Direction.dart';
import 'common/version.dart';
import 'compile.dart';
import 'functions/loadScenes.dart';
import 'functions/withinRadius.dart';
import 'games/Hunter.dart';
import 'games/moba.dart';
import 'games/world.dart';
import 'global.dart';
import 'settings.dart';
import 'update.dart';
import 'utils.dart';
import 'values/world.dart';

const String _space = " ";
final int errorIndex = ServerResponse.Error.index;
final StringBuffer _buffer = StringBuffer();

const List<ClientRequest> clientRequests = ClientRequest.values;
final int clientRequestsLength = clientRequests.length;

void write(dynamic value) {
  _buffer.write(value);
  _buffer.write(_space);
}

Player? findPlayerByUuid(String uuid) {
  return playerMap[uuid];
}

void main() {
  print('Bleed Game Server Starting');
  initUpdateLoop();
  loadScenes();

  int totalConnections = 0;

  var handler = webSocketHandler((WebSocketChannel webSocket) {
    totalConnections++;
    print("New connection established. Total Connections $totalConnections");

    void sendToClient(String response) {
      webSocket.sink.add(response);
    }

    void clearBuffer() {
      _buffer.clear();
    }

    void sendAndClearBuffer() {
      sendToClient(_buffer.toString());
      clearBuffer();
    }

    void sendCompiledPlayerState(Game game, Player player) {
      clearBuffer();
      write(game.compiled);
      compilePlayer(_buffer, player);
      if (player.message.isNotEmpty) {
        compilePlayerMessage(_buffer, player.message);
        player.message = "";
      }

      if (game is Moba) {
        if (game.awaitingPlayers) {
          compilePlayersRemaining(
              _buffer, game.totalPlayersRequired - game.players.length);
          sendAndClearBuffer();
          return;
        } else {
          compilePlayersRemaining(_buffer, 0);
        }

        if (game.inProgress) {
          compileTeamLivesRemaining(_buffer, game);
        }
      }

      sendAndClearBuffer();
    }

    void joinGameMoba() {
      final Moba moba = global.findPendingMobaGame();
      final Player player = playerJoinMoba(moba);
      compileWholeGame(moba);
      compilePlayerJoined(_buffer, player);
      sendAndClearBuffer();
    }

    void joinBattleRoyal(){
      final Hunter hunter = global.findPendingHunterGame();
      final Player player = Player(x: 0, y: 600, game: hunter, team: -1);
      player.type = CharacterType.Human;
      registerPlayer(player);
      hunter.players.add(player);
      compileWholeGame(hunter);
      compilePlayerJoined(_buffer, player);
      compileGameStatus(_buffer, hunter.status);
      sendAndClearBuffer();
    }

    void joinCube3D(){
      final CubePlayer cubePlayer = CubePlayer(position: Vector3(), rotation: Vector3());
      cubeGame.cubes.add(cubePlayer);
      sendToClient('${ServerResponse.Cube_Joined.index} ${cubePlayer.uuid}');
    }

    void joinGameOpenWorld() {
      clearBuffer();
      Player player = spawnPlayerInTown();
      compilePlayer(_buffer, player);
      write(
          '${ServerResponse.Game_Joined.index} ${player.id} ${player.uuid} ${player.x.toInt()} ${player.y.toInt()} ${player.game.id} ${player.team}');
      write(player.game.compiledTiles);
      write(player.game.compiledEnvironmentObjects);
      write(player.game.compiled);
      compilePlayersRemaining(_buffer, 0);
      sendAndClearBuffer();
    }

    void error(GameError error, {String message = ""}) {
      sendToClient('$errorIndex ${error.index} $message');
    }

    void errorInvalidArg(String message) {
      sendToClient('$errorIndex ${GameError.InvalidArguments.index} $message');
    }

    void errorArgsExpected(int expected, List arguments) {
      errorInvalidArg(
          'Invalid number of arguments received. Expected $expected but got ${arguments.length}');
    }

    void errorIntegerExpected(int index, got) {
      errorInvalidArg(
          'Invalid type at index $index, expected integer but got $got');
    }

    void errorPlayerNotFound() {
      error(GameError.PlayerNotFound);
    }

    void errorPlayerDead() {
      error(GameError.PlayerDead);
    }

    void errorInsufficientSkillPoints() {
      error(GameError.InsufficientSkillPoints);
    }

    void onEvent(requestD) {
      final String requestString = requestD;
      final List<String> arguments = requestString.split(_space);

      if (arguments.isEmpty) {
        error(GameError.ClientRequestArgumentsEmpty);
        return;
      }

      int? clientRequestInt = int.tryParse(arguments[0]);
      if (clientRequestInt == null) {
        error(GameError.ClientRequestRequired);
        return;
      }

      if (clientRequestInt >= clientRequestsLength) {
        error(GameError.UnrecognizedClientRequest);
        return;
      }

      final ClientRequest request = clientRequests[clientRequestInt];

      switch (request) {
        case ClientRequest.Update_Cube3D:
          final String playerUUid = arguments[1];
          CubePlayer? player = findCubePlayer(playerUUid);

          if (player == null) {
            return;
          }

          player.position.x = double.parse(arguments[2]);
          player.position.y = double.parse(arguments[3]);
          player.position.z = double.parse(arguments[4]);
          player.rotation.x = double.parse(arguments[5]);
          player.rotation.y = double.parse(arguments[6]);
          player.rotation.z = double.parse(arguments[7]);

          StringBuffer buffer = StringBuffer();
          compileCubePlayers(buffer, cubeGame.cubes);
          compileGameStatus(buffer, GameStatus.In_Progress);
          sendToClient(buffer.toString());
          break;

        case ClientRequest.Update:
          final Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.lastUpdateFrame = 0;
          final Game game = player.game;

          if (game is Moba) {
            if (game.awaitingPlayers) {
              compileLobby(_buffer, game);
              compileGameStatus(_buffer, game.status);
              compilePlayersRemaining(
                  _buffer, game.totalPlayersRequired - game.players.length);
              sendAndClearBuffer();
              return;
            } else if (game.finished) {
              compileTeamLivesRemaining(_buffer, game);
              compileGameStatus(_buffer, game.status);
            }
          }

          if (player.sceneChanged) {
            player.sceneChanged = false;
            _buffer.clear();
            _buffer.write(
                '${ServerResponse.Scene_Changed.index} ${player.x.toInt()} ${player.y.toInt()} ');
            _buffer.write(game.compiledTiles);
            _buffer.write(game.compiledEnvironmentObjects);
            _buffer.write(game.compiled);
            sendToClient(_buffer.toString());
            return;
          }

          if (!player.busy && !player.dead) {
            int actionIndex = int.parse(arguments[2]);
            CharacterAction action = characterActions[actionIndex];
            double mouseX = double.parse(arguments[4]);
            double mouseY = double.parse(arguments[5]);

            Character? closestEnemy = game.getClosestEnemy(mouseX, mouseY, player.team);
            player.aimTarget = null;
            if (closestEnemy != null){
              if (withinDistance(closestEnemy, mouseX, mouseY, settings.radius.cursor)) {
                if (withinDistance(closestEnemy, player.x, player.y, player.attackRange)) {
                  player.aimTarget = closestEnemy;
                }
              }
            }

            switch (action) {
              case CharacterAction.Idle:
                game.setCharacterState(player, CharacterState.Idle);
                break;
              case CharacterAction.Perform:
                Ability? ability = player.ability;
                player.attackTarget = player.aimTarget;

                if (ability == null) {
                  if (player.type == CharacterType.Swordsman ||
                      player.attackTarget != null) {
                    characterAimAt(player, mouseX, mouseY);
                    game.setCharacterState(player, CharacterState.Striking);
                  }
                  break;
                }

                if (player.magic < ability.magicCost) {
                  error(GameError.InsufficientMana);
                  break;
                }

                if (ability.cooldownRemaining > 0) {
                  error(GameError.Cooldown_Remaining);
                  break;
                }

                switch (ability.mode) {
                  case AbilityMode.None:
                    return;
                  case AbilityMode.Targeted:
                    if (player.attackTarget == null) {
                      return;
                    }
                    break;
                  case AbilityMode.Activated:
                    // TODO: Handle this case.
                    break;
                  case AbilityMode.Area:
                    // TODO: Handle this case.
                    break;
                  case AbilityMode.Directed:
                    // TODO: Handle this case.
                    break;
                }

                // @on player perform ability
                player.magic -= ability.magicCost;
                player.performing = ability;
                ability.cooldownRemaining = ability.cooldown;
                player.abilitiesDirty = true;
                player.ability = null;

                characterAimAt(player, mouseX, mouseY);
                game.setCharacterState(player, CharacterState.Performing);
                break;
              case CharacterAction.Run:
                Direction direction = directions[int.parse(arguments[3])];
                setDirection(player, direction);
                game.setCharacterState(player, CharacterState.Running);
                break;
            }
          }
          sendCompiledPlayerState(game, player);
          return;

        case ClientRequest.Join:
          if (arguments.length != 2) {
            errorArgsExpected(2, arguments);
            return;
          }
          final int? gameTypeIndex = int.tryParse(arguments[1]);

          if (gameTypeIndex == null) {
            errorInvalidArg('expected integer at args[1]');
            return;
          }
          if (gameTypeIndex >= gameTypes.length) {
            errorInvalidArg(
                'game type index cannot exceed ${gameTypes.length - 1}');
            return;
          }
          if (gameTypeIndex < 0) {
            errorInvalidArg('game type must be greater than 0');
            return;
          }

          final GameType gameType = gameTypes[gameTypeIndex];
          switch (gameType) {
            case GameType.None:
              break;
            case GameType.MMO:
              joinGameOpenWorld();
              break;
            case GameType.Moba:
              joinGameMoba();
              break;
            case GameType.CUBE3D:
              joinCube3D();
              break;
            case GameType.BATTLE_ROYAL:
              joinBattleRoyal();
              break;
          }
          break;

        case ClientRequest.Ping:
          sendToClient('${ServerResponse.Pong.index} ;');
          break;

        case ClientRequest.Revive:
          Player? player = findPlayerByUuid(arguments[1]);

          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.alive) {
            error(GameError.PlayerStillAlive);
            return;
          }
          player.game.revive(player);
          return;

        case ClientRequest.CasteFireball:
          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.dead) {
            errorPlayerDead();
            return;
          }
          if (player.busy) {
            return;
          }
          player.aimAngle = double.parse(arguments[2]);
          player.game.spawnFireball(player);
          return;

        case ClientRequest.SelectCharacterType:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.type != CharacterType.None) {
            error(GameError.CharacterTypeAlreadySelected);
            break;
          }

          int? characterTypeIndex = int.tryParse(arguments[2]);
          if (characterTypeIndex == null) {
            errorIntegerExpected(1, arguments[2]);
            return;
          }

          selectCharacterType(player, characterTypes[characterTypeIndex]);
          break;

        case ClientRequest.Leave_Lobby:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          player.game.players
              .removeWhere((element) => element.uuid == player.uuid);
          break;

        case ClientRequest.Reset_Character_Type:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.type = CharacterType.None;
          player.x = player.game.playerSpawnPoints[0].x;
          player.y = player.game.playerSpawnPoints[0].y;
          break;

        case ClientRequest.Upgrade_Ability:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          if (player.abilityPoints < 1) {
            error(GameError.SkillPointsRequired);
            return;
          }

          int? upgradeIndex = int.tryParse(arguments[2]);
          if (upgradeIndex == null) {
            errorInvalidArg('arg[2] expected int but got $upgradeIndex');
            return;
          }
          if (upgradeIndex < 0) {
            errorInvalidArg('arg[2] $upgradeIndex must be greater than 0');
            return;
          }
          if (upgradeIndex > 4) {
            errorInvalidArg('arg[2] $upgradeIndex must be less than 5');
            return;
          }

          Ability ability = player.getAbilityByIndex(upgradeIndex);
          ability.level++;
          player.abilityPoints--;
          print("player.abilitiesDirty = true;");
          player.abilitiesDirty = true;
          player.dispatch(PlayerEvent.Skill_Upgraded);
          break;

        case ClientRequest.DeselectAbility:
          if (arguments.length != 2) {
            errorArgsExpected(2, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          player.ability = null;
          break;

        case ClientRequest.SelectAbility:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          if (player.busy) return;
          if (player.dead) return;

          int? abilityIndex = int.tryParse(arguments[2]);
          if (abilityIndex == null) {
            errorInvalidArg('arg[2] expected int but got $abilityIndex');
            return;
          }
          if (abilityIndex < 0) {
            errorInvalidArg('arg[2] $abilityIndex must be greater than 0');
            return;
          }
          if (abilityIndex > 4) {
            errorInvalidArg('arg[2] $abilityIndex must be less than 5');
            return;
          }

          Ability ability = player.getAbilityByIndex(abilityIndex);

          if (ability.level < 1) {
            player.ability = null;
            error(GameError.SkillLocked);
            return;
          }

          Ability? playerAbility = player.ability;

          if (playerAbility != null && playerAbility.type == ability.type) {
            player.ability = null;
            return;
          }

          if (ability.magicCost > player.magic) {
            error(GameError.InsufficientMana);
            return;
          }

          if (ability.cooldownRemaining > 0) {
            error(GameError.Cooldown_Remaining);
            return;
          }

          if (ability is Dash) {
            ability.cooldownRemaining = ability.cooldown;
            ability.durationRemaining = ability.duration;
            player.speedModifier += dashSpeed;
            player.dispatch(PlayerEvent.Dash_Activated);
            break;
          }

          if (ability is IronShield) {
            ability.cooldownRemaining = ability.cooldown;
            ability.durationRemaining = ability.duration;
            player.invincible = true;
            break;
          }

          player.ability = ability;
          break;

        case ClientRequest.AcquireAbility:
          if (arguments.length != 3) {
            errorArgsExpected(3, arguments);
            return;
          }
          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.dead) {
            errorPlayerDead();
            return;
          }
          if (player.busy) {
            return;
          }
          if (player.abilityPoints <= 0) {
            errorInsufficientSkillPoints();
            return;
          }

          int? weaponTypeIndex = int.tryParse(arguments[2]);
          if (weaponTypeIndex == null) {
            errorIntegerExpected(2, arguments[2]);
            return;
          }

          if (weaponTypeIndex >= weaponTypes.length) {
            errorInvalidArg(
                "WeaponType $weaponTypeIndex cannot be greater than ${weaponTypes.length}");
            return;
          }

          if (weaponTypeIndex < 0) {
            errorInvalidArg("WeaponType $weaponTypeIndex cannot be negative");
            return;
          }

          WeaponType type = weaponTypes[int.parse(arguments[2])];

          switch (type) {
            case WeaponType.Shotgun:
              player.weapons.add(
                  Weapon(type: WeaponType.Shotgun, damage: 1, capacity: 5));
              player.weaponsDirty = true;
              player.abilityPoints--;
              break;

            case WeaponType.HandGun:
              player.weapons.add(
                  Weapon(type: WeaponType.HandGun, damage: 1, capacity: 5));
              player.weaponsDirty = true;
              player.abilityPoints--;
              break;

            case WeaponType.Firebolt:
              player.weapons.add(
                  Weapon(type: WeaponType.Firebolt, damage: 1, capacity: 5));
              player.weaponsDirty = true;
              player.abilityPoints--;
              break;
          }
          break;

        case ClientRequest.Teleport:
          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          double x = double.parse(arguments[2]);
          double y = double.parse(arguments[3]);
          player.x = x;
          player.y = y;
          break;

        case ClientRequest.Equip:
          if (arguments.length < 3) {
            error(GameError.InvalidArguments,
                message:
                    "ClientRequest.Equip Error: Expected 2 args but got ${arguments.length}");
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          int? weaponIndex = int.tryParse(arguments[2]);
          if (weaponIndex == null) {
            error(GameError.InvalidArguments,
                message: "arg4, weapon-index: $weaponIndex integer expected");
            return;
          }
          if (weaponIndex < 0) {
            error(GameError.InvalidArguments,
                message:
                    "arg4, weapon-index: $weaponIndex must be greater than 0, got ");
          }
          if (weaponIndex >= player.weapons.length) {
            error(GameError.InvalidArguments,
                message:
                    "arg4, weapon-index: $weaponIndex cannot be greater than player.weapons.length: ${player.weapons.length}");
          }

          changeWeapon(player, weaponIndex);
          return;

        case ClientRequest.Purchase:
          return;

        case ClientRequest.SetCompilePaths:
          if (arguments.length != 2) {
            errorArgsExpected(2, arguments);
            return;
          }

          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          // type gameId playerId playerUuid value
          int value = int.parse(arguments[4]);
          player.game.compilePaths = value == 1;
          print("game.compilePaths = ${player.game.compilePaths}");
          break;

        case ClientRequest.Version:
          sendToClient('${ServerResponse.Version.index} $version');
          break;

        case ClientRequest.SkipHour:
          time = (time + secondsPerHour) % secondsPerDay;
          break;

        case ClientRequest.ReverseHour:
          time = (time - secondsPerHour) % secondsPerDay;
          break;

        case ClientRequest.Speak:
          Player? player = findPlayerByUuid(arguments[1]);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }

          player.text = arguments
              .sublist(2, arguments.length)
              .fold("", (previousValue, element) => '$previousValue $element');
          player.textDuration = 150;
          break;

        case ClientRequest.Interact:
          Player? player = findPlayerByUuid(arguments[1]);

          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (player.dead) {
            errorPlayerDead();
            return;
          }

          playerInteract(player);
      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, settings.host, settings.port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}

Player spawnPlayerInTown() {
  Player player = Player(game: world.town, x: 0, y: 1750, team: 1);
  player.team = teams.west;
  player.abilityPoints = 0;
  player.type = CharacterType.None;
  world.town.players.add(player);
  playerMap[player.uuid] = player;
  return player;
}

void compileWholeGame(Game game) {
  compileGame(game);
  write(game.compiledTiles);
  write(game.compiledEnvironmentObjects);
  write(game.compiled);
}
