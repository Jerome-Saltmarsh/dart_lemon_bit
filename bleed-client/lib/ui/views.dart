import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/send.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../state.dart';
import '../ui.dart';

Widget buildLobby() {
  return center(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      text("${state.lobby.name} Joined ${state.lobby.playersJoined} / ${state.lobby.maxPlayers}"),
      button("Leave", leaveLobby)
    ]));
}

void leaveLobby(){
  sendRequestLobbyExit();
  state.lobby = null;
  redrawUI();
}
