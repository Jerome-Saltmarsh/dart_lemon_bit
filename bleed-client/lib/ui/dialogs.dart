import 'dart:async';

import 'package:bleed_client/enums/GameType.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:neuro/instance.dart';

BuildContext contextMainMenuDialog;

Future showErrorDialogPlayerNotFound() async {
  return showDialog<void>(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error: Player Not Found'),
      );
    },
  );
}

Future showErrorDialog(String message) async {
  return showDialog<void>(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
      );
    },
  );
}



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
                    name: nameController.text,
                    private: false);

                mainMenuTabController.index = 2;
              }),
        ],
      );
    },
  );
}

TabController mainMenuTabController;

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {

  Timer lobbyUpdateJob;

  @override
  void initState() {
    super.initState();
    mainMenuTabController = new TabController(vsync: this, length: 3);

    lobbyUpdateJob = periodic(sendRequestLobbyList, seconds: 1);

    // respondTo((LobbyJoined lobbyJoined) async {
    //   mainMenuTabController.index = 1;
    // });
  }


  @override
  void dispose() {
    super.dispose();
    contextMainMenuDialog = null;
    lobbyUpdateJob.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      child: Scaffold(
        backgroundColor: Colors.black54,
        appBar: TabBar(
          controller: mainMenuTabController,
          tabs: [
            Tab(
              child: text('Join'),
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
          controller: mainMenuTabController,
          children: [
            Container(
              height: 100,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    height(50),
                    button('Death Match', sendRequestGameJoinDeathMatch),
                    height(50),
                    button('Fortress', sendRequestJoinGameFortress),
                    height(50),
                    button('Casual', requestJoinRandomGame),
                  ]),
            ),
            buildLobbyList(),
            text("Settings"),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: button("Close", () => _pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}

Future showDialogMainMenu() async {
  return showDialog(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      contextMainMenuDialog = dialogContext;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(60),
        child: MainMenu(),
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
