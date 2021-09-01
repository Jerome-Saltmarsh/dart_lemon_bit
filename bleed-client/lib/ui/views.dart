import 'package:flutter/material.dart';

import '../state.dart';
import '../ui.dart';

Widget buildLobby() {
  return Column(children: [
      text("Players ${state.lobby.playersJoined} / ${state.lobby.maxPlayers}"),
      // if(state.lobby.)
    ]);
}
