import 'package:bleed_client/classes/Lobby.dart';
import 'package:bleed_client/enums/GameType.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:flutter/material.dart';

Future showDialogCreateGame() async {
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
                _pop(context);
                sendClientRequestLobbyCreate(
                    maxPlayers: 8,
                    type: GameType.DeathMatch,
                    name: nameController.text);
              }),
        ],
      );
    },
  );
}

// Future showDialogListGames() async {
//   sendRequestLobbyList();
//   await Future.delayed(Duration(seconds: 1));
//
//   return showDialog<void>(
//     context: globalContext,
//     barrierDismissible: true,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Games'),
//         content: state.lobbies == null
//             ? CircularProgressIndicator()
//             : Column(children: state.lobbies.map(_buildLobbyListTile).toList()),
//         actions: <Widget>[
//           _buildCancelButton(context),
//         ],
//       );
//     },
//   );
// }

Future showDialogMainMenu() async {
  return showDialog(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(60),
        child: DefaultTabController(
            length: 4,
            child: Scaffold(
              backgroundColor: Colors.black54,
              appBar: TabBar(
                tabs: [
                  Tab(
                    child: text('Play'),
                  ),
                  Tab(
                    child: text('Create'),
                  ),
                  Tab(
                    child: text('Lobby'),
                  ),
                  Tab(
                    child: text('Options'),
                  ),
                ],
              ),
              body: TabBarView(
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        button('Death Match', requestJoinRandomGame),
                        button('Fortress', sendRequestJoinGameFortress),
                        button('Casual', requestJoinRandomGame),
                      ]),
                  button("Create Game", showDialogCreateGame),
                  buildLobbyList(),
                  text("Settings"),
                ],
              ),
              floatingActionButton: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      heroTag: null,
                      child: text("X"),
                      onPressed: () => _pop(dialogContext),
                    ),
                  ),
                ],
              ),
            )),
      );
    },
  );
}

Future showDialogConnectFailed() async {
  return showDialog(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Connection Failed'),
        actions: <Widget>[_buildCancelButton(context)],
      );
    },
  );
}

// private functions

void _pop(BuildContext context) {
  Navigator.of(context).pop();
}

Widget _buildCancelButton(BuildContext context) {
  return TextButton(
      child: const Text(
        'close',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      onPressed: () => _pop(context));
}
