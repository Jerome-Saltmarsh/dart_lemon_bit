
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
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../title.dart';
import '../webSocket.dart';
import '../styles.dart';

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
final _Style _style = _Style();

class _Style {
   final double viewPadding = 8;
}

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

final Map<Connection, String> connectionMessage = {
    Connection.Done: "Connection to the server was lost",
    Connection.Error: "An error occurred with the connection to the server",
    Connection.Connected: "Connected to server",
    Connection.Connecting: "Connecting to server",
    Connection.Failed_To_Connect: "Failed to establish a connection with the server",
    Connection.None: "There is no connection to the server",
};

class _BuildView {
  Widget connection(){
    return WatchBuilder(webSocket.connection, (Connection value){
      return center(Column(
        mainAxisAlignment: axis.main.center,
        children: [
          text(connectionMessage[value], fontSize: 25),
          height16,
          button("Cancel", logic.exit, width: 100)
        ],
      ));
    });
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
            return _buildView.awaitingPlayers();
          case GameStatus.In_Progress:
            switch (game.type.value) {
              case GameType.MMO:
                return hud.buildView.standardMagic();
              case GameType.Moba:
                return hud.buildView.standardMagic();
              case GameType.BATTLE_ROYAL:
                return hud.buildView.standardMagic();
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
    return layout(
        padding: 8,
        topLeft: widgets.title,
        children: [
      center(
        SingleChildScrollView(
          child: Column(crossAxisAlignment: axis.cross.center, children: [
            height16,
            Container(child: text("REGION", fontSize: 50, fontWeight: bold)),
            height16,
            ...selectableServerTypes.map(_buildSelectRegionButton)
          ]),
        ),
      )
    ]);
  }

  Widget gameFinished() {
    return dialog(child: text("Game Finished"));
  }

  final Widget _waiting = text("Waiting", color: Colors.white54);

  Widget awaitingPlayers() {
    return layout(
      padding: 8,
      topLeft: button(text("Back", fontSize: 20), logic.leaveLobby, borderWidth: 3, fillColor: colours.orange, fillColorMouseOver: colours.redDark),
      topRight: text("GAMESTREAM", fontSize: 25),
      children: [dialog(
        padding: 16,
          color: colours.black05,
          borderWidth: 6,
          child: Column(
            crossAxisAlignment: axis.cross.stretch,
            children: [
              Row(
                mainAxisAlignment: axis.main.apart,
                children: [
                  text(enumString(game.type.value), fontSize: 35, fontWeight: FontWeight.bold),
                  // button(text("Cancel", fontSize: 20), logic.leaveLobby, borderWidth: 3, fillColor: colours.orange, fillColorMouseOver: colours.redDark),
                ],
              ),
              height16,
              text("Welcome, the game will automatically start once all players have joined."),
              height16,
              WatchBuilder(game.lobby.playerCount, (int value) {

                int totalPlayersRequired = game.numberOfTeams.value * game.teamSize.value;

                if (game.teamSize.value == 1) {
                  List<Widget> playerNames = [];

                  for(int i = 0; i < game.lobby.players.length; i++){
                    playerNames.add(text(game.lobby.players[i].name, fontSize: 20));
                  }
                  for(int i = 0; i < game.numberOfTeams.value - game.lobby.players.length; i++){
                    playerNames.add(_waiting);
                  }
                  return Column(
                    crossAxisAlignment: axis.cross.start,
                    children: [
                      text("Players ${game.lobby.players.length} / $totalPlayersRequired", decoration: underline, fontSize: 22),
                      height8,
                      ...playerNames
                    ],
                  );
                }

                int count1 =
                    5 - game.lobby.players.where((player) => player.team == 0).length;
                int count2 =
                    5 - game.lobby.players.where((player) => player.team == 1).length;


                List<Widget> a = [];
                List<Widget> b = [];

                for (int i = 0; i < count1; i++) {
                  a.add(_waiting);
                }
                for (int i = 0; i < count2; i++) {
                  b.add(_waiting);
                }

                return Column(
                  crossAxisAlignment: axis.cross.start,
                  children: [
                    text("Team 1", decoration: underline),
                    height8,
                    ...game.lobby
                        .getPlayersOnTeam(0)
                        .map((player) => text(player.name)),
                    ...a,
                    height16,
                    text("Team 2", decoration: underline),
                    height8,
                    ...game.lobby
                        .getPlayersOnTeam(1)
                        .map((player) => text(player.name)),
                    ...b,
                  ],
                );
              }),
            ],
          )),
    ]);
  }

  Widget selectGame() {
    return layout(
        padding: _style.viewPadding,
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




