
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/actions.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/core/init.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/enums/OperationStatus.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/functions/refreshPage.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/editor/module.dart';
import 'package:bleed_client/modules/website/enums.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/constants.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../assets.dart';
import '../getters.dart';
import '../styles.dart';
import '../webSocket.dart';
import 'build.dart';

final nameController = TextEditingController();

// const dialogHeight = 400.0;
// const dialogWidth = dialogHeight * goldenRatio_1381;

Widget buildDialogLogin() {
  return dialog(
      padding: 16,
      color: colours.white05,
      borderColor: colours.none,
      height: 400,
      borderWidth: 3,
      child: layout(
          bottomLeft: button("Sign up", (){}),
          bottomRight: button("Back", () {
            website.state.dialog.value = WebsiteDialog.Games;
          }, fillColor: colours.none,
            borderColor: colours.none,
          ),
          child: Column(
            crossAxisAlignment: axis.cross.start,
            children: [
              // text("Sign in", weight: bold, size: 25),
              height32,
              buttons.signInWithGoogleButton,
              height16,
              buttons.signInWithFacebookButton,
              height32,
            ],
          )));
}

Widget buildView(BuildContext context) {
  return Stack(
    children: [
        buildWatchGameMode(),
        buildWatchErrorMessage(),
    ],
  );
}

Widget buildWatchErrorMessage(){
  return NullableWatchBuilder<String?>(core.state.errorMessage, (String? message){
    if (message == null) return empty;
    return buildErrorDialog(message);
  });
}

Widget buildErrorDialog(String message, {Widget? bottomRight}){
  return dialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightVerySmall,
      color: colours.orange,
      borderColor: colours.none,
      child: layout(
          child: Center(
            child: Container(
                decoration: BoxDecoration(
                  color: colours.black10,
                  borderRadius: borderRadius4,
                ),
                padding: padding16,
                child: text(message, color: colours.white),),
          ),
          bottomRight: bottomRight ?? text("okay", onPressed: actions.closeErrorMessage)
      )
  );
}

Widget buildWatchGameMode(){
  return WatchBuilder(core.state.mode, (Mode mode) {
    if (mode == Mode.Edit) {
      return editor.build.buildLayoutEditor();
    }
    return buildWatchOperationStatus();
  });
}


Widget buildWatchOperationStatus(){
  return WatchBuilder(core.state.operationStatus, (OperationStatus operationStatus){
    if (operationStatus != OperationStatus.None){
      return buildViewOperationStatus(operationStatus);
    }
    return watchAccount(buildAccount);
  });
}

Widget buildAccount(Account? account) {
  return buildWatchConnection(account);
}

WatchBuilder<Connection> buildWatchConnection(Account? account) {
  return WatchBuilder(webSocket.connection, (Connection connection) {
    switch (connection) {
      case Connection.Connecting:
        return _views.connecting;
      case Connection.Connected:
        return buildViewConnected();
      case Connection.None:
        return buildViewConnectionNone();
      default:
        return _views.connection;
    }
  });
}

Widget buildViewConnectionNone() {
  return layout(
      padding: 16,
      expand: true,
      topLeft: widgets.title,
      top:  Container(
          width: screen.width,
          margin: EdgeInsets.only(top: 20),
          child: Row(
              mainAxisAlignment: axis.main.center,
              children: [
                buildTopMessage()
              ])
      ),
      topRight: website.build.mainMenu(),
      bottomLeft: buildMenuDebug(),
      child: buildWatchBuilderDialog(),
  );
}

Positioned buildLoginSuggestionBox() {
  return Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: padding16,
            decoration: BoxDecoration(
              color: colours.white,
              borderRadius: borderRadius4,
            ),
            width: 230.0 * goldenRatio_1618,
            height: 230,
            child: Column(
              crossAxisAlignment: axis.cross.center,
              children: [
                height16,
                buttons.signInWithGoogleButton,
                height16,
                buttons.signInWithFacebookButton,
                height32,
                text("Close", color: colours.black618, underline: true),
              ],
            ))
    );
}

WatchBuilder<WebsiteDialog> buildWatchBuilderDialog() {
  return WatchBuilder(website.state.dialog, (WebsiteDialog dialogs) {
      switch (dialogs) {
        case WebsiteDialog.Custom_Maps:
          return website.build.dialogCustomMaps();

        case WebsiteDialog.Subscription_Status_Changed:
          return buildDialogSubscriptionStatus();

        case WebsiteDialog.Subscription_Cancelled:
          return buildDialogSubscriptionCancelled();

        case WebsiteDialog.Subscription_Successful:
          return buildDialogSubscriptionSuccessful();

        case WebsiteDialog.Account_Created:
          return buildDialogAccountCreated();

        case WebsiteDialog.Welcome_2:
          return buildDialogWelcome2();

        case WebsiteDialog.Change_Region:
          return buildDialogChangeRegion();

        case WebsiteDialog.Login_Error:
          return dialog(
              child: layout(
                  child: text("Login Error"), bottomRight: backButton));

        case WebsiteDialog.Change_Public_Name:
          return buildDialogChangePublicName();

        case WebsiteDialog.Account:
          return buildDialogAccount();

        case WebsiteDialog.Login:
          return buildDialogLogin();

        case WebsiteDialog.Invalid_Arguments:
          return dialog(child: text("Invalid Arguments"));

        case WebsiteDialog.Subscription_Required:
          return dialog(child: text("Subscription Required"));

        case WebsiteDialog.Games:
          return buildDialogGames();

        case WebsiteDialog.Confirm_Logout:
          return dialog(child: text("Confirm Logout"));

        case WebsiteDialog.Confirm_Cancel_Subscription:
          return buildDialogConfirmCancelSubscription();
      }
    });
}

Widget buildDialogGames() {
  return WatchBuilder(game.type, (GameType gameType) {
    if (gameType == GameType.None) {
      return build.gamesList();
    }
    return buildDialogGameTypeSelected(gameType);
  });
}

Widget buildDialogGameTypeSelected(GameType gameType) {
  return watchAccount((Account? account){
    final isFreeToPlay = freeToPlay.contains(gameType);
    final canPlay = isFreeToPlay || getters.premiumAccountAuthenticated;
    if (!canPlay){
      return buildDialogPremiumAccountRequired();
    }

    return dialog(
        color: colours.white05,
        borderColor: colours.none,
        padding: 16,
        height: style.dialogHeightMedium,
        width: style.dialogWidthMedium,
        child: layout(
            topRight: website.build.buttonRegion(),
            bottomLeft: buildButtonPrimary("PLAY", actions.connectToSelectedGame),
            bottomRight:
            buildButton("back", actions.deselectGameType),
            child: Column(
              crossAxisAlignment: axis.cross.start,
              children: [
                text(gameTypeNames[gameType],
                    size: 25, color: colours.white80),
                height32,
              ],
            )));
  });
}

Widget buildDialogChangeRegion() {
  return dialog(
      height: 500,
      padding: 16,
      borderColor: colours.none,
      color: colours.white05,
      child: layout(
          bottomRight: widgets.buttonClose,
          child: Column(
            crossAxisAlignment: axis.cross.start,
            children: [
              border(
                  color: colours.white618,
                  child: text(
                    "Distance impacts performance",
                    color: colours.white60,
                    italic: true,
                    size: 15,
                  )),
              height32,
              ...selectableRegions.map((region) {
                return button(enumString(region), () {
                  core.state.region.value = region;
                  setDialogGames();
                },
                    fillColor: region == core.state.region.value
                        ? colours.black20
                        : colours.white05,
                    borderColor: colours.none,
                    fillColorMouseOver: colours.green,
                    margin: const EdgeInsets.only(bottom: 8));
              }).toList()
            ],
          )));
}

Widget? buildMenuDebug() {
  return dev(onHover((bool hovering){
      return Container(
        width: style.buttonWidth,
        child: Column(
          crossAxisAlignment: axis.cross.start,
          children: [
            if (hovering) ...[
              widgets.theme,
              button("Font Jetbrains", (){
                ui.themeData.value = themes.jetbrains;
              }, width: 200, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
              buttons.showDialogSubscribed,
              buttons.loginTestUser01,
              buttons.loginTestUser02,
              buttons.loginTestUser03,
              buttons.spawnRandomUser,
              buttons.editor,
              button("Show Dialog - Welcome", actions.showDialogWelcome),
            ],
            border(child: "Debug")
          ],
        ),
      );
    }
    ));
}

Widget buildViewOperationStatus(OperationStatus operationStatus) {
  return layout(
      child: fullScreen(
        child: Row(
          mainAxisAlignment: axis.main.center,
          children: [
            AnimatedTextKit(repeatForever: true, animatedTexts: [
              RotateAnimatedText(enumString(operationStatus),
                  textStyle: TextStyle(color: Colors.white, fontSize: 45,
                      fontFamily: assets.fonts.libreBarcode39Text
                  )),
            ])
          ],
        ),
      )
  );
}

final _Views _views = _Views();
final _BuildView _buildView = _BuildView();

class _Views {
  final Widget selectRegion = _buildView.selectRegion();
  final Widget connecting = _buildView.connecting();
  final Widget connection = _buildView.connection();
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
          text(connectionMessage[value], size: 25),
          height16,
          button("Cancel", () {
            actions.exitGame();
            webSocket.disconnect();
          }, width: 100)
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
                          size: 50, weight: bold)),
                  height16,
                  ...selectableServerTypes.map(_buildSelectRegionButton)
                ]),
          ),
        ),
      ],
    );
  }


  Widget connecting() {
    return WatchBuilder(core.state.region, (Region region) {
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
      size: 25,
      // fontWeight: FontWeight.bold
    ),
    () {
      core.state.region.value = region;
    },
    margin: EdgeInsets.only(bottom: 8),
    width: 200,
    borderWidth: 3,
    // fillColor: colours.black15,
    fillColorMouseOver: colours.black15,
  );
}

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


Widget margin({
  required Widget child,
  double left = 0,
  double top = 0,
  double right = 0,
  double bottom = 0
}){
  return Container(
    child: child,
    margin: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom
    )
  );
}


Widget watchAccount(Widget builder(Account? value)) {
  return NullableWatchBuilder<Account?>(core.state.account, (Account? account) {
    return builder(account);
  });
}

Widget watchGameType(Widget builder(GameType value)) {
  return WatchBuilder<GameType>(game.type, (type) {
    return builder(type);
  });
}

Widget buildTopMessage(){
  print("buildTopMessage()");
  return watchAccount((account) {
    return WatchBuilder(website.state.dialog, (dialog){

      if (dialog != WebsiteDialog.Games) return empty;

      if (account == null){
        return onHover((hovering){
          return margin(
            top: 10,
            child: Row(
              children: [
                text("Sign in and subscribe", color: colours.green, underline: hovering, onPressed: actions.showDialogLogin),
                text(" to unlock all games", color: colours.white618, onPressed: actions.showDialogLogin, underline: hovering),
              ],
            ),
          );
        });
      }

      if (account.subscriptionActive) {
        return margin(
          top: 10,
          child: text("Premium Subscription Active",
              color: colours.green,
              size: 18,
              onPressed: actions.showDialogAccount),
        );
      }

      if (account.subscriptionNone) {
        return button(
            Row(
              children: [
                text("Subscribe", color: colours.green, bold: true, size: 20),
                onPressed(
                    child: text(" for \$9.99 per month to unlock all games",
                        color: colours.white80, size: 20),
                    callback: actions.openStripeCheckout),
              ],
            ),
            actions.openStripeCheckout,
            fillColorMouseOver: none,
            borderColor: none,
            borderColorMouseOver: colours.white80);
      }

      if (account.subscriptionEnded) {
        return Row(
          children: [
            onPressed(
              callback: actions.openStripeCheckout,
              child: text(
                  "Your subscription expired on ${formatDate(account.subscriptionEndDate!)}",
                  color: colours.red),
            ),
            width16,
            button(text("Renew", color: green), actions.openStripeCheckout,
                borderColor: colours.green),
          ],
        );
      }

      if (account.subscriptionStatus == SubscriptionStatus.Canceled){
        final subscriptionEndDate = account.subscriptionEndDate;
        if (subscriptionEndDate != null){
          return margin(
            top: 10,
              child:                   text("Premium subscription cancelled : ends ${formatDate(subscriptionEndDate)}", color: colours.white618,
                  onPressed: actions.showDialogAccount
              ));
        }
      }

      return empty;
    });
  });
}

Widget buildViewConnected() {
  return WatchBuilder(game.player.uuid, (String uuid) {
    if (uuid.isEmpty) {
      return buildLayoutLoadingGame();
    }
    return WatchBuilder(game.status, (GameStatus gameStatus) {
      switch (gameStatus) {
        case GameStatus.Counting_Down:
          return buildDialog(
            width: style.dialogWidthMedium,
            height: style.dialogHeightMedium,
            child: WatchBuilder(game.countDownFramesRemaining, (int frames){
              final seconds =  frames ~/ 30.0;
              return Center(child: text("Starting in $seconds seconds"));
            }));
        case GameStatus.Awaiting_Players:
          return buildLayoutLobby() ;
        case GameStatus.In_Progress:
          switch (game.type.value) {
            case GameType.MMO:
              return buildHud.playerCharacterType();
            case GameType.Custom:
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
          return buildDialogGameFinished();
        default:
          return text(enumString(gameStatus));
      }
    });
  });
}

final Widget _textWaiting = text("- waiting", color: colours.white382);

Widget buildLayoutLobby() {
  return buildDialog(
    width: style.dialogWidthMedium,
    height: style.dialogHeightLarge,
    bottomRight: buildButton('Cancel', actions.leaveLobby),
    child: Column(
      crossAxisAlignment: axis.cross.stretch,
      children: [
        Row(
          mainAxisAlignment: axis.main.apart,
          children: [
            text(enumString(game.type.value),
                size: 35, weight: FontWeight.bold, color: colours.white85),
          ],
        ),
        height16,
        border(
            fillColor: colours.white05,
            color: none,
            child: text(
                "waiting for more players to join",
                color: colours.white618)),
        height32,
        WatchBuilder(game.lobby.playerCount, (int value) {
          int totalPlayersRequired =
              game.numberOfTeams.value * game.teamSize.value;

          if (game.teamSize.value == 1) {
            List<Widget> playerNames = [];

            for (int i = 0; i < game.lobby.players.length; i++) {
              final isMe = isAccountName(game.lobby.players[i].name);
              playerNames.add(text(game.lobby.players[i].name,
                  size: 20, color: isMe ? colours.green : colours.white90));
            }
            for (int i = 0;
                i < game.numberOfTeams.value - game.lobby.players.length;
                i++) {
              playerNames.add(_textWaiting);
            }
            return Column(
              crossAxisAlignment: axis.cross.start,
              children: [
                text(
                    "Players ${game.lobby.players.length} / $totalPlayersRequired",
                    decoration: underline,
                    size: 22, color: colours.white80),
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
            a.add(_textWaiting);
          }
          for (int i = 0; i < count2; i++) {
            b.add(_textWaiting);
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
  );
}

Widget buildDialogGameFinished(){
  return buildDialogMedium(child: Center(child: text("Game Finished")), bottomRight: buildButton("Exit", actions.exitGame));
}

bool isAccountName(String publicName){
  final account = core.state.account.value;
  if (account == null) return false;
  return account.publicName == publicName;
}

Widget statefulBuilder(Widget Function(Function rebuild) build) {
  return StatefulBuilder(builder: (context, setState){
    Function rebuild = (){
      setState((){});
    };
    return build(rebuild);
  });
}
