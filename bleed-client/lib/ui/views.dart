import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/functions/refreshPage.dart';
import 'package:bleed_client/logic.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../title.dart';
import '../webSocket.dart';
import 'state/flutter_constants.dart';

Widget buildView(BuildContext context){

  return WatchBuilder(game.mode, (Mode mode) {

    if (mode == Mode.Edit){
      return _views.editor;
    }

    return WatchBuilder(game.region, (Region serverType){
      if (serverType == Region.None){
        return _views.selectRegion;
      }
      return WatchBuilder(game.type, (GameType gameType) {
        if (gameType == GameType.None) {
          return _views.selectGame;
        }
        return WatchBuilder(webSocket.connection, (Connection connection){
          switch(connection) {
            case Connection.Connecting:
              return _views.connecting;
            case Connection.Connected:
              return _views.connected;
            default:
              return _views.connection;
          }
        });
      });
    });
  });
}

final _Views _views = _Views();
final _BuildView _buildView = _BuildView();

class _Views {
  final Widget selectRegion = _buildView.selectRegion();
  final Widget selectGame = _buildView.selectGame();
  final Widget connecting = _buildView.connecting();
  final Widget connected = _buildView.connected();
  final Widget connection = _buildView.connection();
  final Widget editor = buildEditorUI();
  final Widget gameFinished = _buildView.gameFinished();
  final Widget awaitingPlayers = _buildView.awaitingPlayers();
}

class _BuildView {

  Widget connection(){
    return center(Column(
      mainAxisAlignment: axis.main.center,
      children: [
        text(enumString(webSocket.connection.value)),
        height8,
        button("Cancel", logic.exit, width: 100)
      ],
    ));
  }

  Widget connected() {
    print("buildView.connected()");

    return WatchBuilder(game.player.uuid, (String uuid) {
      if (uuid.isEmpty) {
        return center(text("game.player.uuid is empty"));
      }

      return WatchBuilder(game.status, (GameStatus gameStatus) {
        switch (gameStatus) {
          case GameStatus.Awaiting_Players:
            return _views.awaitingPlayers;
          case GameStatus.In_Progress:
            switch (game.type.value) {
              case GameType.MMO:
                return buildUIStandardRolePlaying();
              case GameType.Moba:
                return buildUIStandardRolePlaying();
              case GameType.BATTLE_ROYAL:
                return buildUIBattleRoyal();
              case GameType.CUBE3D:
                return buildUI3DCube();
              default:
                return text(game.type.value);
            }
          case GameStatus.Finished:
            return _views.gameFinished;
          default:
            return text(enumString(gameStatus));
        }
      });
    });
  }

  Widget selectRegion() {
    return center(
      SingleChildScrollView(
        child: Column(crossAxisAlignment: axis.cross.center, children: [
          text(title, fontSize: 45),
          height16,
          Container(
              child: text("Welcome! Please select a region")),
          height32,
          ...selectableServerTypes.map(_buildSelectRegionButton)
        ]),
      ),
    );
  }

  Widget gameFinished() {
    return dialog(child: text("Game Finished"));
  }

  Widget awaitingPlayers() {
    return dialog(
        child: Column(
          crossAxisAlignment: axis.cross.stretch,
          children: [
            Row(
              mainAxisAlignment: axis.main.apart,
              children: [
                text(enumString(game.type.value)),
                button("Cancel", logic.leaveLobby),
              ],
            ),
            height16,
            WatchBuilder(game.lobby.playerCount, (int value) {

              if (game.teamSize.value == 1) {
                List<Widget> playerNames = [];

                for(int i = 0; i < game.lobby.players.length; i++){
                  playerNames.add(text(game.lobby.players[i].name));
                }
                for(int i = 0; i < game.numberOfTeams.value - game.lobby.players.length; i++){
                  playerNames.add(text("Waiting"));
                }
                return Column(
                  children: playerNames,
                );
              }

              int count1 =
                  5 - game.lobby.players.where((player) => player.team == 0).length;
              int count2 =
                  5 - game.lobby.players.where((player) => player.team == 1).length;


              List<Widget> a = [];
              List<Widget> b = [];

              for (int i = 0; i < count1; i++) {
                a.add(text("Waiting"));
              }
              for (int i = 0; i < count2; i++) {
                b.add(text("Waiting"));
              }

              return Column(
                children: [
                  text("Team 1"),
                  ...game.lobby
                      .getPlayersOnTeam(0)
                      .map((player) => text(player.name)),
                  ...a,
                  height16,
                  text("Team 2"),
                  ...game.lobby
                      .getPlayersOnTeam(1)
                      .map((player) => text(player.name)),
                  ...b,
                ],
              );
            }),
          ],
        ));
  }

  Widget selectGame() {
    return layout(
        topLeft: buttons.region,
        topRight: buttons.editor,
        children: [
          Column(
            children: [
              widgets.title,
              height8,
              widgets.gamesList,
          ],)
        ]
    );
  }

  Widget connecting() {
    return center(
        Column(
          mainAxisAlignment: axis.main.center,
          children: [
            Container(
              height: 80,
              child: AnimatedTextKit(repeatForever: true, animatedTexts: [
                RotateAnimatedText("Connecting to server: ${game.region.value}",
                    textStyle: TextStyle(color: Colors.white, fontSize: 30)),
              ]),
            ),
            height32,
            onPressed(child: text("Cancel"), callback: (){
              sharedPreferences.remove('server');
              refreshPage();
            }),
          ],
        )
    );
  }
}


Widget _buildSelectRegionButton(Region region) {
  return button(
    text(
        enumString(region),
        fontSize: 25,
        // fontWeight: FontWeight.bold
    ), (){
          game.region.value = region;
        },
    margin: EdgeInsets.only(bottom: 8),
    width: 180,
    borderWidth: 3,
    fillColor: colours.black05,
  );
}
