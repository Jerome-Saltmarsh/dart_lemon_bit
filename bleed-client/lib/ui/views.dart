import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/core/init.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/functions/refreshPage.dart';
import 'package:bleed_client/logic.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/ui.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_math/golden_ratio.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../assets.dart';
import '../styles.dart';
import '../webSocket.dart';
import 'build.dart';

final nameController = TextEditingController();

Widget buildLoginDialog() {
  return dialog(
      padding: 16,
      color: colours.white05,
      borderColor: colours.none,
      height: 400,
      borderWidth: 3,
      child: layout(
          bottomLeft: button("Sign up", (){}),
          bottomRight: button("No Thanks", () {
            game.dialog.value = Dialogs.Games;
          }, fillColor: colours.none,
            borderColor: colours.none,
          ),

          child: Column(
            crossAxisAlignment: axis.cross.start,
            children: [
              text("Sign in", fontWeight: bold, fontSize: 25),
              height32,
              buttons.signInWithGoogleB,
              height16,
              buttons.signInWithFacebookButton,
              height32,
            ],
          )));
}

Widget buildView(BuildContext context) {

  return WatchBuilder(game.mode, (Mode mode) {
    if (mode == Mode.Edit) {
      return _views.editor;
    }

    return NullableWatchBuilder<Authentication?>(authentication, (Authentication? auth){
      final bool authenticated = auth != null;

      return WatchBuilder(game.signingIn, (bool signingIn){

        if (signingIn){
          return layout(
            // topLeft: widgets.title,
            child: fullScreen(
              child: Row(
                mainAxisAlignment: axis.main.center,
                children: [
                  AnimatedTextKit(repeatForever: true, animatedTexts: [
                    RotateAnimatedText("Signing in to gamestream",
                        textStyle: TextStyle(color: Colors.white, fontSize: 45,
                          fontFamily: assets.fonts.libreBarcode39Text
                        )),
                  ])
                ],
              ),
            )
          );
        }

        return NullableWatchBuilder<Account?>(game.account, (Account? account){
          final now = DateTime.now().toUtc();
          final bool subscribed = account != null && account.subscriptionExpirationDate != null;
          final subscriptionExpired = account != null
              && account.subscriptionExpirationDate != null
              && now.isAfter(account.subscriptionExpirationDate!);
          final bool subscriptionActive = account != null && !subscriptionExpired;

          return WatchBuilder(webSocket.connection, (Connection connection) {
            switch (connection) {
              case Connection.Connecting:
                return _views.connecting;
              case Connection.Connected:
                return _views.connected;
              case Connection.None:
                return layout(
                    padding: 16,
                    expand: true,
                    topLeft: widgets.title,
                    top: !authenticated || subscriptionActive ? null : () {

                      return Container(
                        width: screen.width,
                        margin: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: axis.main.center,
                          children: [
                            if (!subscribed)
                            button(text("Subscribe for \$4.99 per month"), logic.openStripeCheckout,
                              height: style.buttonHeight * goldenRatioInverse,
                            ),
                            if (account != null && subscriptionExpired)
                              Row(
                                children: [
                                  onPressed(
                                    callback: logic.showDialogSubscription,
                                    child: border(
                                        color: colours.red,
                                        child: text("Your subscription expired on ${dateFormat.format(account.subscriptionExpirationDate!)}", color: colours.red)),
                                  ),
                                  width8,
                                  button(text("Renew"), logic.showDialogSubscription, borderColor: colours.none),                                ],
                              ),
                          ],
                        ),
                      );
                    }(),
                    topRight: Row(
                      crossAxisAlignment: axis.cross.start,
                      mainAxisAlignment: axis.main.end,
                      children: [
                        // buttons.region,
                        // width16,
                        if (!authenticated) buttons.login,
                        if (authenticated)  mouseOver(builder: (BuildContext context, bool mouseOver) {
                          return mouseOver ? Column(
                            children: [
                              buttons.account,
                              if (subscribed)
                                buttons.subscription,
                              if (!subscribed)
                                button("Subscribe", logic.openStripeCheckout,
                                  width: style.buttonWidth,
                                  height: style.buttonHeight,
                                  fillColorMouseOver: colours.white05,
                                ),
                              buttons.logout,
                            ],
                          ) : buttons.account;
                        }),
                      ],
                    ),
                    bottomRight: buttons.region,
                    bottomLeft: dev(onHover((bool hovering){

                      return Container(
                        width: style.buttonWidth,
                        child: Column(
                          crossAxisAlignment: axis.cross.start,
                          children: [
                              if (hovering) ...[
                                widgets.theme,
                                buttons.showDialogSubscribed,
                                buttons.loginTestUser01,
                                buttons.loginTestUser02,
                                buttons.loginTestUser03,
                                buttons.spawnRandomUser,
                                // button("Logging In", (){
                                //   game.signingIn.value = true;
                                // }),
                                buttons.editor,
                              ],
                              border(child: "Debug")
                          ],
                        ),
                      );
                    }
                    )),
                    child: WatchBuilder(game.region, (Region serverType) {
                      if (serverType == Region.None) {
                        return _views.selectRegion;
                      }
                      return WatchBuilder(game.dialog, (Dialogs dialogs) {
                        switch (dialogs) {
                          case Dialogs.Subscription_Successful:
                            final name = auth != null ? auth.displayName : "";

                            return dialog(
                                padding: 16,
                                height: 180,
                                width: 180 * goldenRatio,
                                child: layout(child: Column(
                                  crossAxisAlignment: axis.cross.start,
                                  children: [
                                    text("Welcome $name", fontSize: 20, fontWeight: bold),
                                    height16,
                                    text("Thank you very much for subscribing to gamestream"),
                                  ],
                                ),
                                  bottomRight: button("Great", (){
                                    game.dialog.value = Dialogs.Games;
                                  }, fillColor: colours.green),
                                )
                            );

                          case Dialogs.Change_Display_Name:

                            if (account != null && account.displayName != null){
                              nameController.text = account.displayName!;
                            }else{
                              nameController.text = "";
                            }

                            return dialog(
                              child: layout(
                                child: TextField(
                                  controller: nameController,
                                ),
                                bottomLeft: button("Save", (){}),
                                bottomRight: text("Cancel"),
                              ),
                            );

                          case Dialogs.Subscription:
                          // @build subscription dialog
                            if (!authenticated) {
                              return layout(
                                bottomLeft: buttons.login,
                                bottomRight: button("Close", logic.showDialogGames),
                                child: dialog(
                                    child: Column(
                                      crossAxisAlignment: axis.cross.start,
                                      children: [
                                        border(child: text("ACCOUNT")),
                                        height16,
                                        text("Authentication Required"),
                                      ],
                                    )
                                ),
                              );
                            }

                            if (!subscribed){
                              return dialog(
                                  child: text("Not subscribed")
                              );
                            }

                            final formattedSubscription = dateFormat.format(account.subscriptionExpirationDate!);

                            return dialog(
                              color: colours.white05,
                              borderColor: colours.none,
                              padding: 16,
                              child: layout(
                                bottomLeft: (subscriptionExpired)
                                    ? null
                                    : button("Cancel Subscription", () {},
                                    hint: "If you decide to cancel your subscription you will continue to be able to play premium games until $formattedSubscription",
                                    borderColor: colours.none,
                                fillColor: colours.red),
                                  bottomRight: button(text('close', fontWeight: bold), () {
                                    game.dialog.value = Dialogs.Games;
                                  }, fillColor: colours.none,

                                  ),
                                  child: Column(
                                    crossAxisAlignment: axis.cross.start,
                                    children: [
                                      text("ACCOUNT",
                                          fontSize: 30,
                                          fontWeight: bold),
                                      height32,
                                      Tooltip(
                                          message: "The name other players see in game",
                                          child: text("Display Name")),
                                      StatefulBuilder(
                                          builder: (context, setState) {
                                        return onHover((hovering) {

                                          if (_editingName){
                                            if (account.displayName != null) {
                                              _nameController.text =
                                                  account.displayName!;
                                            } else {
                                              _nameController.text = "";
                                            }

                                            return Row(
                                              children: [
                                                Container(
                                                    width: 200,
                                                    child: TextField(controller: _nameController,)),
                                                button("Save", (){
                                                  print("Saving display name");
                                                }),
                                                button("cancel", (){
                                                  print("Saving display name");
                                                })
                                              ],
                                            );
                                          }

                                          return Row(
                                            children: [
                                              text(account.displayName),
                                              if (hovering) ...[
                                                width8,
                                                onPressed(
                                                    child: buildIconEdit(),
                                                    callback: () {
                                                      setState((){
                                                        _editingName = true;
                                                      });
                                                    })
                                              ]
                                            ],
                                          );
                                        });
                                      }),
                                      height16,
                                      text("Name"),
                                      text(auth.displayName),
                                      height16,
                                      text("Email"),
                                      text(auth.email),
                                      height16,
                                      if (!subscriptionExpired) text("Automatically Renews"),
                                      if (subscriptionExpired)
                                        Row(
                                          children: [
                                            text("Expired", color: colours.red),
                                            width8,
                                            button("Renew", () {},
                                                fillColor: colours.green)
                                          ],
                                        ),
                                      text(formattedSubscription),
                                    ],
                                  )),

                            );
                          case Dialogs.Login:
                            return buildLoginDialog();
                          case Dialogs.Invalid_Arguments:
                            return dialog(child: text("Invalid Arguments"));
                          case Dialogs.Subscription_Required:
                            return dialog(child: text("Subscription Required"));
                          case Dialogs.Games:
                            return WatchBuilder(game.type, (GameType gameType) {
                              if (gameType == GameType.None) {
                                return build.gamesList(subscriptionActive);
                              }

                              bool isFreeToPlay = freeToPlay.contains(gameType);

                              final playButton = button(text("Play", fontSize: 25, fontWeight: bold),
                                  logic.connectToSelectedGame,
                                  fillColor: colours.green,
                                  borderWidth: 2
                              );

                              final loginButton = button(text("Play", fontSize: 25, fontWeight: bold),
                                  logic.showDialogLogin,
                                  fillColor: colours.green,
                                  borderWidth: 2
                              );

                              final subscribeButton = button(text("Subscribe", fontSize: 25, fontWeight: bold),
                                  logic.connectToSelectedGame,
                                  fillColor: colours.green,
                                  borderWidth: 2
                              );

                              return dialog(
                                  color: colours.white05,
                                  borderColor: colours.none,
                                  padding: 16,
                                  height: 300,
                                  width: 300 * goldenRatio,
                                  child: layout(
                                  bottomLeft: isFreeToPlay
                                      ? playButton
                                      : !authenticated
                                        ? loginButton
                                        : !subscriptionActive
                                          ? subscribeButton
                                          : playButton,
                                  bottomRight: button("No Thanks", logic.deselectGameType,
                                      fillColor: colours.none,
                                      borderColor: colours.none,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: axis.cross.start,
                                    children: [
                                      text(gameTypeNames[gameType], fontSize: 25),
                                      height32,
                                      if (!isFreeToPlay && !authenticated)
                                        border(child: text(
                                            "* This is a premium game which requires an active subscription to play",
                                            color: colours.white60
                                          ),
                                        color: colours.white80
                                        )
                                    ],
                                  )
                              ));
                            });
                          case Dialogs.Account:
                            return _views.account;
                          case Dialogs.Confirm_Logout:
                            return dialog(child: text("Confirm Logout"));
                        }
                      });
                    }));

              default:
                return _views.connection;
            }
          });
        });
      });
    });
  });
}

final _Views _views = _Views();
final _BuildView _buildView = _BuildView();

class _Views {
  final Widget account = _buildView.account();
  final Widget selectRegion = _buildView.selectRegion();
  // final Widget selectGame = widgets.gamesList;
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
  Connection.Failed_To_Connect:
      "Failed to establish a connection with the server",
  Connection.None: "There is no connection to the server",
};

class _BuildView {
  Widget connection() {
    return WatchBuilder(webSocket.connection, (Connection value) {
      return center(Column(
        mainAxisAlignment: axis.main.center,
        children: [
          text(connectionMessage[value], fontSize: 25),
          height16,
          button("Cancel", () {
            logic.exit();
            webSocket.disconnect();
          }, width: 100)
        ],
      ));
    });
  }

  Widget connected() {
    print("buildView.connected()");

    return WatchBuilder(game.player.uuid, (String uuid) {

      if (uuid.isEmpty) {
        return buildLayoutLoadingGame();
      }

      return WatchBuilder(game.status, (GameStatus gameStatus) {
        switch (gameStatus) {
          case GameStatus.Awaiting_Players:
            return _buildView.awaitingPlayers();
          case GameStatus.In_Progress:
            switch (game.type.value) {
              case GameType.MMO:
                return buildHud.playerCharacterType();
              case GameType.Moba:
                return buildHud.playerCharacterType();
              case GameType.BATTLE_ROYAL:
                return buildHud.playerCharacterType();
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

  Widget account() {
    return NullableWatchBuilder<Authentication?>(authentication,
        (Authentication? authorization) {
      if (authorization == null) {
        return dialog(child: text("No one logged in"));
      }

      return dialog(
          child: Column(
        crossAxisAlignment: axis.cross.start,
        children: [
          text('${authorization.displayName}`s Account', fontSize: 25),
          text("Card Number"),
          Container(width: 250, child: TextField()),
          button('Subscribe', () {}),
        ],
      ));
    });
  }

  Widget selectRegion() {
    return Row(
      mainAxisAlignment: axis.main.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 140),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: axis.main.center,
                crossAxisAlignment: axis.cross.center,
                children: [
                  Container(
                      child: text("SELECT REGION",
                          fontSize: 50, fontWeight: bold)),
                  height16,
                  ...selectableServerTypes.map(_buildSelectRegionButton)
                ]),
          ),
        ),
      ],
    );
  }

  Widget gameFinished() {
    return dialog(
        child: layout(
      topLeft: text("Game Finished"),
      topRight: text("Exit"),
    ));
  }

  final Widget _waiting = text("Waiting", color: Colors.white54);

  Widget awaitingPlayers() {
    return layout(
        padding: 8,
        topLeft: widgets.title,
        child: dialog(
            padding: 16,
            color: colours.white05,
            borderColor: colours.none,
            // borderWidth: 6,
            child: layout(
              bottomRight: button("Cancel", logic.leaveLobby, borderColor: colours.none, fontSize: 25),
              child: Column(
                crossAxisAlignment: axis.cross.stretch,
                children: [
                  Row(
                    mainAxisAlignment: axis.main.apart,
                    children: [
                      text(enumString(game.type.value),
                          fontSize: 35, fontWeight: FontWeight.bold),
                      // button(text("Cancel", fontSize: 20), logic.leaveLobby, borderWidth: 3, fillColor: colours.orange, fillColorMouseOver: colours.redDark),
                    ],
                  ),
                  height16,
                  border(
                      color: colours.white60,
                      child: text("The game will start automatically once all players have joined", color: colours.white60)),
                  height16,
                  WatchBuilder(game.lobby.playerCount, (int value) {
                    int totalPlayersRequired =
                        game.numberOfTeams.value * game.teamSize.value;

                    if (game.teamSize.value == 1) {
                      List<Widget> playerNames = [];

                      for (int i = 0; i < game.lobby.players.length; i++) {
                        playerNames
                            .add(text(game.lobby.players[i].name, fontSize: 20));
                      }
                      for (int i = 0;
                          i <
                              game.numberOfTeams.value -
                                  game.lobby.players.length;
                          i++) {
                        playerNames.add(_waiting);
                      }
                      return Column(
                        crossAxisAlignment: axis.cross.start,
                        children: [
                          text(
                              "Players ${game.lobby.players.length} / $totalPlayersRequired",
                              decoration: underline,
                              fontSize: 22),
                          height8,
                          ...playerNames
                        ],
                      );
                    }

                    int count1 = 5 -
                        game.lobby.players
                            .where((player) => player.team == 0)
                            .length;
                    int count2 = 5 -
                        game.lobby.players
                            .where((player) => player.team == 1)
                            .length;

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
              ),
            )));
  }

  Widget connecting() {
    return WatchBuilder(game.region, (Region region) {
      return center(Column(
        mainAxisAlignment: axis.main.center,
        children: [
          Container(
            height: 80,
            child: AnimatedTextKit(repeatForever: true, animatedTexts: [
              RotateAnimatedText("Connecting to ${enumString(game.type.value)} (${enumString(region)})",
                  textStyle: TextStyle(color: Colors.white, fontSize: 30)),
            ]),
          ),
          height32,
          onPressed(
              child: text("Cancel"),
              callback: () {
                sharedPreferences.remove('server');
                refreshPage();
              }),
        ],
      ));
    });
  }
}

Widget _buildSelectRegionButton(Region region) {
  return button(
    text(
      enumString(region),
      fontSize: 25,
      // fontWeight: FontWeight.bold
    ),
    () {
      game.region.value = region;
    },
    margin: EdgeInsets.only(bottom: 8),
    width: 200,
    borderWidth: 3,
    // fillColor: colours.black15,
    fillColorMouseOver: colours.black15,
  );
}


final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);

final empty = SizedBox();

Widget? dev(Widget child){
  return isLocalHost ? child : null;
}

Widget buildLayoutLoadingGame(){
  return layout(
      topLeft: widgets.title,
      child: fullScreen(
        child: Row(
          mainAxisAlignment: axis.main.center,
          children: [
            text("JOINING GAME.."),
          ],
        ),
      )
  );
}

bool _editingName = false;
final _nameController = TextEditingController();

