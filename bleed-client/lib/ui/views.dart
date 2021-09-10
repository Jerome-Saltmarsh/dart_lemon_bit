import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/classes/Lobby.dart';
import 'package:bleed_client/enums/GameType.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bleed.dart';
import '../connection.dart';
import '../state.dart';
import '../ui.dart';


GameType _gameType = GameType.DeathMatch;
int _maxPlayers = 8;
bool _private = false;

Widget buildJoinedLobby() {
  return Container(
    padding: EdgeInsets.all(20),
    child: Column(mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          height50,
          text("Players ${state.lobby.playersJoined} / ${state.lobby.maxPlayers}"),
          height8,
          text("The game will automatically start once the room is full"),
          height32,
          Tooltip(
            child: button("Copy Join-ID", () {
              FlutterClipboard.copy(state.lobby.uuid);
            }),
            message: "Send this id to friends. Once copied, they can click the 'Paste Join-ID' button in the lobby to join",
          ),
          height8,
          button("Leave", leaveLobby)
        ]),
  );
}

// TODO Logic does not belong here
void leaveLobby() {
  sendRequestLobbyExit();
  state.lobby = null;
  redrawUI();
}


Widget buildLobbyList() {
  double lobbyListViewHeight = 200;

  return Refresh(
      duration: Duration(milliseconds: 300),
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
              maxPlayers: _maxPlayers, type: _gameType, name: "Silly", private: _private);
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
      );
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

Widget buildViewLoading(){
  return center(TextLiquidFill(
    text: 'BLEED',
    waveColor: Colors.red,
    textStyle: const TextStyle(
        fontSize: 48.0, fontWeight: FontWeight.bold, color: Colors.white),
    waveDuration: Duration(seconds: 4),
    loadDuration: Duration(seconds: 12),
    boxBackgroundColor: Colors.black,
    // speed: const Duration(milliseconds: 2000),
  ));
}

Widget buildViewConnect() {
  return center(
    column([
      row([
        text("BLEED", fontSize: 120),
      ]),
      height50,
      row([
        button('Localhost', connectLocalHost, fontSize: 21),
        Container(
          width: 10,
        ),
        button('GCP', connectToGCP, fontSize: 21),
      ]),
    ]),
  );
}
