import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'classes/Game.dart';
import 'classes/Lobby.dart';
import 'classes/Player.dart';
import 'common/PlayerEvents.dart';
import 'common/version.dart';
import 'common/constants.dart';
import 'compile.dart';
import 'common/ClientRequest.dart';
import 'common/GameError.dart';
import 'common/GameEventType.dart';
import 'common/GameType.dart';
import 'common/ServerResponse.dart';
import 'common/PurchaseType.dart';
import 'common/Weapons.dart';
import 'enums.dart';
import 'functions/loadScenes.dart';
import 'instances/gameManager.dart';
import 'settings.dart';
import 'update.dart';
import 'utils.dart';

const String _space = " ";
final int errorIndex = ServerResponse.Error.index;
final StringBuffer _buffer = StringBuffer();

const List<ClientRequest> clientRequests = ClientRequest.values;
const List<PurchaseType> purchaseTypes = PurchaseType.values;
final int clientRequestsLength = clientRequests.length;

void main() {
  print('Bleed Game Server Starting');
  initUpdateLoop();
  loadScenes();

  var handler = webSocketHandler((WebSocketChannel webSocket) {
    void sendToClient(String response) {
      webSocket.sink.add(response);
    }

    void sendCompiledPlayerState(Game game, Player player) {
      _buffer.clear();
      _buffer.write(game.compiled);
      compilePlayer(_buffer, player);
      sendToClient(_buffer.toString());
    }

    void joinGame(Game game) {
      _buffer.clear();
      Player player = game.spawnPlayer();
      compilePlayer(_buffer, player);
      _buffer.write(
          '${ServerResponse.Game_Joined.index} ${player.id} ${player.uuid} ${player.x.toInt()} ${player.y.toInt()} ${game.id} ${game.type.index} ${player.squad} ');
      _buffer.write(game.compiledTiles);
      _buffer.write(game.compiled);
      sendToClient(_buffer.toString());
    }

    void error(GameError error, {String message = ""}) {
      sendToClient('$errorIndex ${error.index} $message');
    }

    void errorArgsExpected(int expected, List arguments) {
      sendToClient(
          '$errorIndex ${GameError.InvalidArguments.index} expected $expected but got ${arguments.length}');
    }

    void errorGameNotFound() {
      error(GameError.GameNotFound);
    }

    void errorCannotSpawnNpc() {
      error(GameError.CannotSpawnNpc);
    }

    void errorGameFull() {
      error(GameError.GameFull);
    }

    void errorInvalidArguments() {
      error(GameError.InvalidArguments);
    }

    void errorLobbyNotFound() {
      error(GameError.LobbyNotFound);
    }

    void errorLobbyUserNotFound() {
      error(GameError.LobbyUserNotFound);
    }

    void errorPlayerNotFound() {
      error(GameError.PlayerNotFound);
    }

    void errorCannotRevive() {
      error(GameError.CannotRevive);
    }

    void errorInvalidPlayerUUID() {
      error(GameError.InvalidPlayerUUID);
    }

    void errorWeaponNotAcquired() {
      error(GameError.WeaponNotAcquired);
    }

    void errorWeaponAlreadyAcquired() {
      error(GameError.WeaponAlreadyAcquired);
    }

    void onEvent(requestD) {
      String requestString = requestD;
      List<String> arguments = requestString.split(_space);

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

      ClientRequest request = clientRequests[clientRequestInt];

      switch (request) {
        case ClientRequest.Lobby_Join_Fortress:
          LobbyUser user = LobbyUser();
          Lobby lobby = gameManager.findAvailableLobbyFortress();
          lobby.players.add(user);
          sendToClient(
              '${ServerResponse.Lobby_Joined.index} ${lobby.uuid} ${user.uuid}');
          break;

        case ClientRequest.Game_Update:
          Game? game = findGameById(arguments[1]);
          if (game == null) {
            errorGameNotFound();
            return;
          }
          Player? player = game.findPlayerById(int.parse(arguments[2]));
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          if (arguments[3] != player.uuid) {
            errorInvalidPlayerUUID();
            return;
          }

          if (player.events.isNotEmpty) {
            // TODO compile player events
          }

          player.lastUpdateFrame = 0;
          CharacterState requestedState =
              CharacterState.values[int.parse(arguments[4])];
          Direction requestedDirection =
              Direction.values[int.parse(arguments[5])];
          double aim = double.parse(arguments[6]);
          player.aimAngle = aim;
          setDirection(player, requestedDirection);
          game.setCharacterState(player, requestedState);
          sendCompiledPlayerState(game, player);
          return;

        case ClientRequest.Player_Use_MedKit:
          return;
          // return;
          // Game? game = findGameById(arguments[1]);
          // if (game == null) {
          //   errorGameNotFound();
          //   return;
          // }
          // Player? player = game.findPlayerById(int.parse(arguments[2]));
          // if (player == null) {
          //   errorPlayerNotFound();
          //   return;
          // }
          // if (arguments[3] != player.uuid) {
          //   errorInvalidPlayerUUID();
          //   return;
          // }
          // if (player.health == player.maxHealth) return;
          // if (player.dead) return;
          // if (player.meds <= 0) return;
          // player.meds--;
          // player.health = player.maxHealth;
          // game.dispatch(GameEventType.Use_MedKit, player.x, player.y, 0, 0);
          // break;

        case ClientRequest.Lobby_Create:
          if (arguments.length < 4) {
            errorInvalidArguments();
            return;
          }

          int maxPlayers = int.parse(arguments[1]);
          // TODO read from the arguments
          int squadSize = 4;
          GameType gameType = GameType.values[int.parse(arguments[2])];
          String name = arguments[3];
          bool private = arguments[4] == "1";
          Lobby lobby = gameManager.createLobby(
              maxPlayers: maxPlayers,
              squadSize: squadSize,
              gameType: gameType,
              name: name,
              private: private);
          LobbyUser user = LobbyUser();
          lobby.players.add(user);
          sendToClient(
              '${ServerResponse.Lobby_Joined.index} ${lobby.uuid} ${user.uuid}');
          return;

        case ClientRequest.Game_Join_Casual:
          joinGame(gameManager.getAvailableCasualGame());
          break;

        case ClientRequest.Ping:
          sendToClient('${ServerResponse.Pong.index} ;');
          break;

        case ClientRequest.Lobby_Join:
          if (arguments.length <= 1) {
            errorInvalidArguments();
            return;
          }

          String lobbyUuid = arguments[1];
          Lobby? lobby = findLobbyByUuid(lobbyUuid);
          if (lobby == null) {
            errorLobbyNotFound();
            return;
          }
          LobbyUser user = LobbyUser();
          lobby.players.add(user);
          sendToClient(
              '${ServerResponse.Lobby_Joined.index} ${lobby.uuid} ${user.uuid}');
          break;

        case ClientRequest.Lobby_Join_DeathMatch:
          LobbyUser user = LobbyUser();
          if (arguments.length <= 1) {
            errorInvalidArguments();
            return;
          }

          int squadSize = int.parse(arguments[1]);
          int maxPlayers = squadSize * 2;

          Lobby lobby = gameManager.findAvailableDeathMatchLobby(
              squadSize: squadSize, maxPlayers: maxPlayers);
          lobby.players.add(user);

          sendToClient(
              '${ServerResponse.Lobby_Joined.index} ${lobby.uuid} ${user.uuid}');
          break;

        case ClientRequest.Game_Join:
          print("ClientRequest.Game_Join");

          if (arguments.length < 2) {
            errorInvalidArguments();
            return;
          }
          String gameUuid = arguments[1];

          for (Game game in gameManager.games) {
            if (game.uuid != gameUuid) continue;
            if (game.players.length == game.maxPlayers) {
              errorGameFull();
              return;
            }
            joinGame(game);
            return;
          }

          errorGameNotFound();
          break;

        case ClientRequest.Lobby_Update:
          if (arguments.length < 3) {
            errorInvalidArguments();
            return;
          }
          String lobbyUuid = arguments[1];
          Lobby? lobby = findLobbyByUuid(lobbyUuid);
          if (lobby == null) {
            errorLobbyNotFound();
            return;
          }
          String playerUuid = arguments[2];
          LobbyUser? user = findLobbyUser(lobby, playerUuid);
          if (user == null) {
            errorLobbyUserNotFound();
            return;
          }
          user.framesSinceUpdate = 0;
          StringBuffer buffer =
              StringBuffer("${ServerResponse.Lobby_Update.index} ");
          compileLobby(buffer, lobby);
          sendToClient(buffer.toString());
          break;

        case ClientRequest.Lobby_List:
          sendToClient(compileLobbies());
          return;

        case ClientRequest.Player_Revive:
          String gameId = arguments[1];
          Game? game = findGameById(gameId);
          if (game == null) {
            errorGameNotFound();
            return;
          }

          if (game.type != GameType.Casual) {
            errorCannotRevive();
            return;
          }

          int id = int.parse(arguments[2]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          String uuid = arguments[3];
          if (uuid != player.uuid) {
            errorInvalidPlayerUUID();
            return;
          }
          if (player.alive) {
            error(GameError.PlayerStillAlive);
            return;
          }
          game.revive(player);
          return;

        case ClientRequest.Spawn_Npc:
          String gameId = arguments[1];
          Game? game = findGameById(gameId);
          if (game == null) {
            errorGameNotFound();
            return;
          }

          if (game.type != GameType.Casual) {
            errorCannotSpawnNpc();
            return;
          }

          game.spawnRandomNpc();
          return;

        case ClientRequest.Player_Equip:
          String gameId = arguments[1];
          Game? game = findGameById(gameId);
          if (game == null) {
            errorGameNotFound();
            return;
          }
          int id = int.parse(arguments[2]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            errorPlayerNotFound();
            return;
          }
          String uuid = arguments[3];
          if (uuid != player.uuid) {
            errorInvalidPlayerUUID();
            return;
          }
          Weapon weapon = Weapon.values[int.parse(arguments[4])];
          if (player.stateDuration > 0) return;
          if (player.weapon == weapon) return;

          switch (weapon) {
            case Weapon.HandGun:
              if (!player.acquiredHandgun) {
                errorWeaponNotAcquired();
                return;
              }
              break;
            case Weapon.Shotgun:
              if (!player.acquiredShotgun) {
                errorWeaponNotAcquired();
                return;
              }
              break;
            case Weapon.SniperRifle:
              if (!player.acquiredSniperRifle) {
                errorWeaponNotAcquired();
                return;
              }
              break;
            case Weapon.AssaultRifle:
              if (!player.acquiredAssaultRifle) {
                errorWeaponNotAcquired();
                return;
              }
              break;
          }

          player.weapon = weapon;
          game.setCharacterState(player, CharacterState.ChangingWeapon);
          return;

        case ClientRequest.Lobby_Exit:
          if (arguments.length < 3) {
            errorInvalidArguments();
            return;
          }
          String lobbyUuid = arguments[1];
          Lobby? lobby = findLobbyByUuid(lobbyUuid);
          if (lobby == null) {
            errorLobbyNotFound();
            return;
          }
          String playerUuid = arguments[2];
          removePlayerFromLobby(lobby, playerUuid);
          break;

        case ClientRequest.Player_Throw_Grenade:
          String gameId = arguments[1];
          Game? game = findGameById(gameId);
          if (game == null) {
            error(GameError.GameNotFound);
            return;
          }

          int id = int.parse(arguments[2]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            error(GameError.PlayerNotFound);
            return;
          }

          String uuid = arguments[3];
          if (uuid != player.uuid) {
            error(GameError.InvalidPlayerUUID);
            return;
          }

          if (player.grenades <= 0) return;

          double strength = double.parse(arguments[4]);
          double aim = double.parse(arguments[5]);
          game.throwGrenade(player, aim, strength);
          game.dispatch(GameEventType.Throw_Grenade, player.x, player.y, 0, 0);
          player.grenades--;
          return;

        case ClientRequest.Purchase:
          if (arguments.length != 5) {
            errorArgsExpected(5, arguments);
            return;
          }

          String gameId = arguments[1];
          Game? game = findGameById(gameId);
          if (game == null) {
            error(GameError.GameNotFound);
            return;
          }

          int id = int.parse(arguments[2]);
          Player? player = game.findPlayerById(id);
          if (player == null) {
            error(GameError.PlayerNotFound);
            return;
          }

          String uuid = arguments[3];
          if (uuid != player.uuid) {
            error(GameError.InvalidPlayerUUID);
            return;
          }

          int? purchaseTypeIndex = int.tryParse(arguments[4]);

          if (purchaseTypeIndex == null) {
            sendToClient(
                '$errorIndex ${GameError.IntegerExpected} arguments[4] but got ${arguments[4]}');
            return;
          }

          if (purchaseTypeIndex >= purchaseTypes.length) {
            sendToClient(
                '$errorIndex ${GameError.InvalidArguments} $purchaseTypeIndex is not a valid PurchaseType index');
            return;
          }

          PurchaseType purchaseType = purchaseTypes[purchaseTypeIndex];
          int cost = getPurchaseTypeCost(purchaseType);
          if (player.points < cost) {
            error(GameError.InsufficientFunds);
            return;
          }

          switch (purchaseType) {
            case PurchaseType.Weapon_Handgun:
              if (player.acquiredHandgun) {
                errorWeaponAlreadyAcquired();
                return;
              }
              player.removeCredits(prices.weapon.handgun);
              player.clips.handgun = 1;
              player.rounds.handgun = settings.maxRounds.handgun;
              player.acquiredHandgun = true;
              player.addEvent(PlayerEventType.Acquired_Handgun, 1);
              player.weapon = Weapon.HandGun;
              game.setCharacterState(player, CharacterState.ChangingWeapon);
              return;

            case PurchaseType.Weapon_Shotgun:
              if (player.acquiredShotgun) {
                errorWeaponAlreadyAcquired();
                return;
              }
              player.removeCredits(prices.weapon.shotgun);
              player.clips.shotgun = 1;
              player.rounds.shotgun = settings.maxRounds.shotgun;
              player.acquiredShotgun = true;
              player.addEvent(PlayerEventType.Acquired_Shotgun, 1);
              player.weapon = Weapon.Shotgun;
              game.setCharacterState(player, CharacterState.ChangingWeapon);
              return;

            case PurchaseType.Weapon_SniperRifle:
              if (player.acquiredSniperRifle) {
                errorWeaponAlreadyAcquired();
                return;
              }
              player.removeCredits(prices.weapon.sniperRifle);
              player.clips.sniperRifle = 1;
              player.rounds.sniperRifle = settings.maxRounds.sniperRifle;
              player.acquiredSniperRifle = true;
              player.addEvent(PlayerEventType.Acquired_SniperRifle, 1);
              player.weapon = Weapon.SniperRifle;
              game.setCharacterState(player, CharacterState.ChangingWeapon);
              return;

            case PurchaseType.Weapon_AssaultRifle:
              if (player.acquiredAssaultRifle) {
                errorWeaponAlreadyAcquired();
                return;
              }
              player.removeCredits(prices.weapon.assaultRifle);
              player.clips.assaultRifle = 1;
              player.rounds.assaultRifle = settings.maxRounds.assaultRifle;
              player.acquiredAssaultRifle = true;
              player.addEvent(PlayerEventType.Acquired_AssaultRifle, 1);
              player.weapon = Weapon.AssaultRifle;
              game.setCharacterState(player, CharacterState.ChangingWeapon);
              return;
          }
          return;

        case ClientRequest.Score:
          String gameId = arguments[1];
          Game? game = findGameById(gameId);
          if (game == null) {
            error(GameError.GameNotFound);
            return;
          }

          StringBuffer buffer = StringBuffer();
          compileScore(buffer, game.players);
          sendToClient(buffer.toString());
          break;

        case ClientRequest.SetCompilePaths:
          if (arguments.length != 5) {
            errorArgsExpected(5, arguments);
            return;
          }

          String gameId = arguments[1];
          Game? game = findGameById(gameId);
          if (game == null) {
            error(GameError.GameNotFound);
            return;
          }
          // type gameId playerId playerUuid value
          int value = int.parse(arguments[4]);
          game.compilePaths = value == 1;
          print("game.compilePaths = ${game.compilePaths}");
          break;

          case ClientRequest.Version:
            sendToClient('${ServerResponse.Version.index} $version');
            break;

      }
    }

    webSocket.stream.listen(onEvent);
  });

  shelf_io.serve(handler, settings.host, settings.port).then((server) {
    print('Serving at wss://${server.address.host}:${server.port}');
  });
}
