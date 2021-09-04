import 'package:bleed_client/classes/Lobby.dart';
import 'package:bleed_client/enums/GameType.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../state.dart';

Widget buildJoinedLobby() {
  return center(Column(mainAxisAlignment: MainAxisAlignment.start, children: [
    text(
        "${state.lobby.name} Joined ${state.lobby.playersJoined} / ${state.lobby.maxPlayers}"),
    Tooltip(
      child: button("Copy Join-ID", () {
        FlutterClipboard.copy(state.lobby.uuid);
      }),
      message: "Send this id to friends. Once copied, they can click the 'Paste Join-ID' button in the lobby to join",
    ),
    button("Leave", leaveLobby)
  ]));
}

// TODO Logic does not belong here
void leaveLobby() {
  sendRequestLobbyExit();
  state.lobby = null;
  redrawUI();
}

GameType _gameType = GameType.DeathMatch;
int _maxPlayers = 8;
bool _private = false;

Widget buildLobbyList() {
  double lobbyListViewHeight = 200;

  return Refresh(
      builder: Builder(builder: (BuildContext context) {
        if (state.lobby != null) return buildJoinedLobby();

        Widget gameTypeButton = StatefulBuilder(
            builder: ((BuildContext builderContext, StateSetter setState) {
          return button("${_gameType.toString().replaceAll("GameType.", "")}",
              () {
            setState(() {
              _gameType = GameType
                  .values[(_gameType.index + 1) % GameType.values.length];
            });
          });
        }));

        Widget playersButton = StatefulBuilder(
            builder: ((BuildContext builderContext, StateSetter setState) {
          return button("Players: $_maxPlayers", () {
            setState(() {
              if (_maxPlayers >= 64) {
                _maxPlayers = 2;
              } else {
                _maxPlayers += _maxPlayers;
              }
            });
          });
        }));

        Widget privateButton = StatefulBuilder(
            builder: ((BuildContext builderContext, StateSetter setState) {
          return button(_private ? "Private" : "Public", () {
            setState(() => _private = !_private);
          });
        }));

        Widget startButton = button("START", () {
          sendClientRequestLobbyCreate(
              maxPlayers: _maxPlayers, type: _gameType, name: "Silly");
        });

        sendRequestLobbyList();
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    height(16),
                    text("Create"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        gameTypeButton,
                        playersButton,
                      ],
                    ),
                    height(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        privateButton,
                        startButton,
                      ],
                    ),
                  ],
                ),
              ),
              height(16),
              text("Public Games"),
              height(4),
              border(
                child: Container(
                    height: lobbyListViewHeight,
                    child: ListView(
                        children:
                            state.lobbies.map(_buildLobbyListTile).toList())),
              ),
              height(16),
              Tooltip(
                  child: button("Paste Join-ID", () async {
                    String copied = await FlutterClipboard.paste();
                    sendRequestJoinLobby(copied);
                  }),
                  message:
                      "First copy (ctrl + c) the game id then click this button"),
            ],
          ),
        );
      }),
      duration: Duration(seconds: 3));
}

Widget _buildLobbyListTile(Lobby lobby) {
  return border(
    child: ListTile(
        leading: text(lobby.name),
        title: text("${lobby.playersJoined} / ${lobby.maxPlayers}"),
        trailing:
            text("JOIN", onPressed: () => {sendRequestJoinLobby(lobby.uuid)})),
  );
}
