import 'package:bleed_client/classes/Lobby.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../state.dart';
import 'dialogs.dart';

Widget buildLobby() {
  return center(Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    text(
        "${state.lobby.name} Joined ${state.lobby.playersJoined} / ${state.lobby.maxPlayers}"),
    button("Leave", leaveLobby)
  ]));
}

// TODO Logic does not belong here
void leaveLobby() {
  sendRequestLobbyExit();
  state.lobby = null;
  redrawUI();
}

Widget buildLobbyList() {
  return Refresh(
      builder: Builder(builder: (BuildContext context) {

        if (state.lobby != null) return buildLobby();

        sendRequestLobbyList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            height(50),
            button("Create Game", showDialogCreateGame),
            border(
              child: Container(
                  width: 400,
                  height: 400,
                  child: ListView(
                      children: state.lobbies.map(_buildLobbyListTile).toList())),
            ),
          ],
        );
      }),
      duration: Duration(seconds: 3));
}

Widget _buildLobbyListTile(Lobby lobby) {
  return border(
    child: ListTile(
        leading: text(lobby.name),
        title: text("${lobby.playersJoined} / ${lobby.maxPlayers}"),
        trailing: text("JOIN", onPressed: () => { sendRequestJoinLobby(lobby.uuid) })),
  );
}
