import 'package:bleed_client/classes/Lobby.dart';
import 'package:bleed_client/enums/GameType.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:flutter/material.dart';

Future showCreateGameDialog() async {
  TextEditingController nameController = TextEditingController();

  return showDialog<void>(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Create Game'),
        content: Column(
          children: [
            Text("Game Name"),
            TextField(controller: nameController),
          ],
        ),
        actions: <Widget>[
          TextButton(
              child: const Text('Create'),
              onPressed: () {
                pop(context);
                sendClientRequestLobbyCreate(
                    maxPlayers: 8,
                    type: GameType.DeathMatch,
                    name: "hello world");
              }),
        ],
      );
    },
  );
}

Future showDialogListGames() async {
  sendRequestLobbyList();
  await Future.delayed(Duration(seconds: 1));

  return showDialog<void>(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Games'),
        content:
        state.lobbies == null ? CircularProgressIndicator() :
        Column(children: state.lobbies.map(_lobbyListTile).toList()
        ),
        actions: <Widget>[
          TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                pop(context);
              }),
        ],
      );
    },
  );
}

Widget _lobbyListTile(Lobby lobby){
  return ListTile(
    leading: Text(lobby.name),
    trailing: Text("${lobby.playersJoined} / ${lobby.maxPlayers}")
  );
}

void pop(BuildContext context) {
  Navigator.of(context).pop();
}
