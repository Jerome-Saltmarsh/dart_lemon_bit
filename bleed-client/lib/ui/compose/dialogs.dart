import 'dart:async';

import 'package:bleed_client/bleed.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/connection.dart';
import 'package:bleed_client/engine/engine_state.dart';
import 'package:bleed_client/engine/state/buildContext.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/material.dart';

import '../../state.dart';

BuildContext contextMainMenuDialog;

bool get dialogOpen => contextMainMenuDialog != null;

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

Future showDialogClientUpdateAvailable() async {
  double height = 300;

  return showDialog<void>(
    context: globalContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Update Available ${state.serverVersion}"),
        actions: [
          // onPressed(
          //     callback: refreshPage,
          //     child: text("Update", color: Colors.black)),
          onPressed(
              callback: () {
                disconnect();
                pop(context);
              },
              child: text("Cancel", color: Colors.black)),
          onPressed(
              callback: () {
                pop(context);
                // joinCasualGame();
                joinGameOpenWorld();
              },
              child: text("Ignore", color: Colors.black)),
        ],
        content: Container(
          height: height,
          width: height * goldenRatioInverse,
          child: Row(
            mainAxisAlignment: main.center,
            children: [
              mouseOver(builder: (BuildContext context, bool mouseOver){
                Widget update = text("Update", color: Colors.black, fontSize: 40);
                if (!mouseOver) return update;
                return border(child: update, color: Colors.black, padding: padding8, radius: borderRadius4);
              }),
            ],
          ),
        ),
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
                pop(context);
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

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  Timer lobbyUpdateJob;

  @override
  void initState() {
    super.initState();
    mainMenuTabController = new TabController(vsync: this, length: 3);
    lobbyUpdateJob = periodic(sendRequestLobbyList, seconds: 1);
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
      width: 600,
      child: Scaffold(
        backgroundColor: Colors.black54,
        appBar: TabBar(
          controller: mainMenuTabController,
          tabs: [
            Tab(
              child: text('Deathmatch'),
            ),
            Tab(
              child: text('Join'),
            ),
            // Tab(
            //   child: text('Lobby'),
            // ),
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
                    button('Alone', () {
                      sendRequestJoinLobbyDeathMatch(squadSize: 1);
                    }),
                    height(50),
                    button('Coop', () {
                      sendRequestJoinLobbyDeathMatch(squadSize: 2);
                    }),
                    height(50),
                    button('Trio', () {
                      sendRequestJoinLobbyDeathMatch(squadSize: 3);
                    }),
                    height(50),
                  ]),
            ),
            Container(
              height: 100,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    height(50),
                    button('Death Match', sendRequestJoinLobbyDeathMatch),
                    height(50),
                    button('Fortress', sendRequestJoinGameFortress),
                    height(50),
                    button('Casual', requestJoinRandomGame),
                  ]),
            ),
            // buildLobbyList(),
            center(text("Settings")),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: !dialogOpen
            ? null
            : Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: button("Close", () => pop(context)),
                  ),
                ],
              ),
      ),
    );
  }
}

Future showDialogMainMenu() async {
  if (contextMainMenuDialog != null) return;

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
        title: const Text('Connection Lost'),
        actions: <Widget>[_buildCancelButton(context)],
      );
    },
  );
}

Future showDialogChangeServer() async {
  return showDialog(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Change Server'),
        content: Column(
          children: [
            text("Germany"),
            text("USA East"),
            text("USA West"),
          ],
        ),
        backgroundColor: Colors.black54,
        actions: <Widget>[_buildCancelButton(context)],
      );
    },
  );
}

// private functions

void pop(BuildContext context) {
  Navigator.of(context).pop();
}

Widget _buildCancelButton(BuildContext context) {
  return TextButton(
      child: text('close', color: Colors.black),
      onPressed: () => pop(context));
}


