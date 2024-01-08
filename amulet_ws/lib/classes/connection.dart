import 'dart:async';


import 'root.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../packages/src.dart';

class Connection extends ByteReader {

  final Root root;
  final errorWriter = ByteWriter();
  final started = DateTime.now();

  late WebSocketChannel webSocket;
  late WebSocketSink sink;
  late StreamSubscription subscription;

  late final AmuletController controller;
  Function? onDone;

  Connection({
    required this.webSocket,
    required this.root,
  }){
    sink = webSocket.sink;
    controller = AmuletController(
      player: AmuletPlayer(
        amuletGame: root.amulet.amuletGameLoading,
        itemLength: 6,
        x: 0,
        y: 0,
        z: 0,
      ),
      isAdmin: false,
      sink: sink,
      handleClientRequestJoin: handleClientRequestJoin,
    );

    sink.done.then(onDisconnect);
    subscription = webSocket.stream.listen(controller.onData, onError: onStreamError);
  }

  void onDisconnect(dynamic value) {
    onDone?.call();
    subscription.cancel();
  }

  void onStreamError(Object error, StackTrace stackTrace){
    print("onStreamError()");
    print(error);
    print(stackTrace);
  }

  void sendGameError(GameError error) {
    errorWriter.writeByte(NetworkResponse.Game_Error);
    errorWriter.writeByte(error.index);
    sink.add(errorWriter.compile());
  }

  Future sendServerError(dynamic error) async {
    errorWriter.writeByte(NetworkResponse.Server_Error);
    errorWriter.writeString(error.toString());
    sink.add(errorWriter.compile());
  }

  void handleClientRequestJoin(List<String> arguments) {

    if (arguments.length < 2) {
      errorInvalidClientRequest();
      return;
    }

    final player = controller.player;

    final gameTypeIndex =  arguments.tryGetArgInt('--gameType');
    if (gameTypeIndex == null || !isValidIndex(gameTypeIndex, GameType.values)){
      errorInvalidClientRequest();
      return;
    }

    if (arguments.length > 2) {
      final userId = arguments.tryGetArgString('--userId');

      if (userId == null){
          controller.playerJoinGameTutorial();
          player.name = arguments.tryGetArgString('--name') ?? 'anon${randomInt(9999, 99999)}';
          player.complexion = arguments.tryGetArgInt('--complexion') ?? 0;
          player.hairType = arguments.tryGetArgInt('--hairType') ?? 0;
          player.hairColor = arguments.tryGetArgInt('--hairColor') ?? 0;
          player.gender = arguments.tryGetArgInt('--gender') ?? 0;
          player.headType = arguments.tryGetArgInt('--headType') ?? 0;
          player.active = true;
          onPlayerLoaded(player);
          return;
      }

      final characterId = arguments.tryGetArgString('--characterId');

      if (characterId == null){
        throw Exception('characterId == null');
      }

      root.userService.getUser(userId).then((user) {

        final characters = user.getList<Json>('characters');
        for (final character in characters) {
          final uuid = character.getString('uuid');
          if (uuid == characterId) {
            final nowUtc = DateTime.now().toUtc();
            final lockDateIso8601String = character.tryGetString('auto_save');
            if (lockDateIso8601String != null && !root.admin){
              final lockDate = DateTime.parse(lockDateIso8601String);
              final lockDuration = nowUtc.difference(lockDate);
              if (lockDuration.inSeconds < durationAutoSave.inSeconds){
                sendServerError('Character is already active in another session');
                disconnect(
                    closeCode: CloseCode.Character_Locked,
                    reason: 'reason: CloseCode.Character_Locked',
                );
                return;
              }
            }
            if (character.containsKey('tutorial_completed')){
              controller.playerJoinAmuletTown();
            } else {
              controller.playerJoinGameTutorial();
            }

            player.userId = userId;
            // player.active = false;

            character['auto_save'] = nowUtc.toIso8601String();
            root.userService.saveUserCharacter(
                userId: userId,
                character: character,
            );
            writeJsonToAmuletPlayer(character, player);
            onPlayerLoaded(player);
            return;
          }
        }
        throw Exception('could not find character $characterId');
      }).catchError((error) {
        sendServerError(error);
        disconnect(
          closeCode: CloseCode.Character_Not_Found,
          reason: 'reason: CloseCode.Character_Not_Found',
        );
      });
    } else {
      controller.playerJoinAmuletTown();
    }
  }

  void cancelSubscription() {
    subscription.cancel();
  }

  int getArg(List<String> arguments, int index){
    if (index < 0 || index >= arguments.length){
      throw Exception('invalid index');
    }
    return int.parse(arguments[index]);

  }

  int? parseArg(List<String> arguments, int index, {bool error = true}){

     if (index >= arguments.length) {
       if (error){
         errorInvalidClientRequest();
       }
       return null;
     }
     final value = int.tryParse(arguments[index]);
     if (value == null) {
       if (error){
         errorInvalidClientRequest();
       }
     }
     return value;
  }

  int? parse(String source) {
    final value = int.tryParse(source);
    if (value == null) {
        errorInvalidClientRequest();
       return null;
    }
    return value;
  }

  void errorInvalidClientRequest() {
    sendGameError(GameError.Invalid_Client_Request);
  }

  void disconnect({required int closeCode, String? reason}) {
    sink.close(closeCode, reason);
  }

  void onPlayerLoaded(AmuletPlayer player) {
    // if (!player.data.containsKey('tutorial_completed')){
    //   nerve.amulet.playerStartTutorial(player);
    // }
    player.refillItemSlotsWeapons();
  }

  bool playerNeedsToBeInitialized(AmuletPlayer player) => !player.initialized;
}


