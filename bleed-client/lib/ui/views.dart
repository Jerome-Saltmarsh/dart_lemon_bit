import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/classes/Lobby.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/instances/settings.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bleed.dart';
import '../connection.dart';
import '../state.dart';
import '../ui.dart';
import 'flutter_constants.dart';

GameType _gameType = GameType.DeathMatch;
int _maxPlayers = 8;
bool _private = false;

Widget buildViewJoinedLobby() {
  if (state.lobby.maxPlayers == 0) {
    return text("Joining", fontSize: 30);
  }

  if (state.lobby.playersJoined == state.lobby.maxPlayers) {
    return buildViewLoading();
  }

  return Container(
    padding: EdgeInsets.all(20),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          height50,
          text(
              "Players ${state.lobby.playersJoined} / ${state.lobby.maxPlayers}"),
          height8,
          text("The game will automatically start once the room is full"),
          height32,
          Tooltip(
            child: button("Copy Join-ID", () {
              FlutterClipboard.copy(state.lobby.uuid);
            }),
            message:
                "Send this id to friends. Once copied, they can click the 'Paste Join-ID' button in the lobby to join",
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
  if (state.lobby != null) return buildViewJoinedLobby();

  return text("no implemented");

  // double lobbyListViewHeight = 200;
  //
  // return Refresh(
  //   duration: Duration(milliseconds: 300),
  //   builder: (BuildContext context) {
  //
  //
  //     return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
  //
  //       Widget gameTypeButton = StatefulBuilder(
  //           builder: ((BuildContext builderContext, StateSetter setState) {
  //             return button("${_gameType.toString().replaceAll("GameType.", "")}",
  //                     () {
  //                   setState(() {
  //                     _gameType =
  //                     GameType.values[(_gameType.index + 1) % GameType.values.length];
  //                   });
  //                 });
  //           }));
  //
  //       Widget playersButton = StatefulBuilder(
  //           builder: ((BuildContext builderContext, StateSetter setState) {
  //             return button("Players: $_maxPlayers", () {
  //               setState(() {
  //                 if (_maxPlayers >= 64) {
  //                   _maxPlayers = 2;
  //                 } else {
  //                   _maxPlayers += _maxPlayers;
  //                 }
  //               });
  //             });
  //           }));
  //
  //       Widget privateButton = StatefulBuilder(
  //           builder: ((BuildContext builderContext, StateSetter setState) {
  //             return button(_private ? "Private" : "Public", () {
  //               setState(() => _private = !_private);
  //             });
  //           }));
  //
  //       Widget startButton = button("START", () {
  //         sendClientRequestLobbyCreate(
  //             maxPlayers: _maxPlayers,
  //             type: _gameType,
  //             name: "Silly",
  //             private: _private);
  //       });
  //
  //       sendRequestLobbyList();
  //       return Container(
  //         padding: EdgeInsets.symmetric(horizontal: 8),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               // padding: EdgeInsets.symmetric(horizontal: 20),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   height(16),
  //                   text("Create"),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       gameTypeButton,
  //                       playersButton,
  //                     ],
  //                   ),
  //                   height(4),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       privateButton,
  //                       startButton,
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             height(16),
  //             text("Public Games"),
  //             height(4),
  //             border(
  //               child: Container(
  //                   height: lobbyListViewHeight,
  //                   child: ListView(
  //                       children:
  //                       state.lobbies.map(_buildLobbyListTile).toList())),
  //             ),
  //             height(16),
  //             Tooltip(
  //                 child: button("Paste Join-ID", () async {
  //                   String copied = await FlutterClipboard.paste();
  //                   sendRequestJoinLobby(copied);
  //                 }),
  //                 message:
  //                 "First copy (ctrl + c) the game id then click this button"),
  //           ],
  //         ),
  //       );
  //       }
  //     );
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

Widget buildViewLoading() {
  return Refresh(
    duration: Duration(seconds: 6),
    builder: (BuildContext context) {
      return center(TextLiquidFill(
        text: 'BLEED',
        boxWidth: screenWidth,
        boxHeight: screenHeight,
        waveColor: Colors.red,
        textStyle: const TextStyle(
            fontFamily: 'PermanentMarker',
            fontSize: 140.0,
            fontWeight: FontWeight.bold,
            color: Colors.white),
        waveDuration: Duration(seconds: 2),
        loadDuration: Duration(seconds: 5),
        boxBackgroundColor: Colors.black,
      ));
    },
  );
}

Widget buildViewConnect() {
  return center(
    Column(crossAxisAlignment: cross.center, children: [
      height(50 * goldenRatioInverse),
      text("BLEED", fontSize: 120),
        height(50 * goldenRatioInverse),
      text("Select a server to play on"),
      height(50 * goldenRatioInverseB),
      ...Server.values.map((server) {
        return Container(
          width: 50 * (goldenRatio * 2),
          child: button(getServerName(server), () {
            connectServer(server);
          }, alignment: Alignment.center),
          margin: EdgeInsets.only(bottom: 50 * goldenRatioInverseB),
        );
      })
      // row([
      //   button('LOCALHOST', connectLocalHost, fontSize: 21),
      //   Container(
      //     width: 10,
      //   ),
      //   button('ONLINE', connectToGCP, fontSize: 21),
      // ]),
    ]),
  );
}
