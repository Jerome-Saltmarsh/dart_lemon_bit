import 'package:bleed_client/classes/Lobby.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../state.dart';

Widget buildLobby() {
  return center(Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    text(
        "${state.lobby.name} Joined ${state.lobby.playersJoined} / ${state.lobby.maxPlayers}"),
    button("Leave", leaveLobby)
  ]));
}

void leaveLobby() {
  sendRequestLobbyExit();
  state.lobby = null;
  redrawUI();
}

Widget buildLobbyList() {
  return Refresh(
      builder: Builder(builder: (BuildContext context) {
        print("refreshing lobby list");
        return border(
          child: Container(
              width: 400,
              height: 400,
              child: ListView(
                  children: state.lobbies.map(_buildLobbyListTile).toList())),
        );
      }),
      duration: Duration(seconds: 1));
}

Widget _buildLobbyListTile(Lobby lobby) {
  return ListTile(
      leading: text(lobby.name),
      trailing: text("${lobby.playersJoined} / ${lobby.maxPlayers}"));
}
