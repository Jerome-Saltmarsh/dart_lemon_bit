

import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/enums/operation_status.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_status.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:gamestream_flutter/language_utils.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/ui/widgets.dart';
import 'package:gamestream_flutter/website/widgets/game_type_column.dart';
import 'package:gamestream_flutter/website/widgets/region_column.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'enums/website_dialog.dart';
import 'enums/website_page.dart';

class GameWebsite extends Game {
  static const Icon_Size = 25.0;
  static const Padding = 16.0;

  final websitePage = Watch(WebsitePage.Region);
  final signInSuggestionVisible = Watch(false);
  final dialog = Watch(WebsiteDialog.Games);
  final customConnectionStrongController = TextEditingController();
  late final visitCount = Watch(0, onChanged: onChangedVisitCount);
  final download = Watch(0.0);
  final debug = true;
  final isVisibleDialogCustomRegion = Watch(false);
  final colorRegion = Colors.orange;
  final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
  final errorMessageEnabled = Watch(true);
  
  @override
  void drawCanvas(Canvas canvas, Size size) {

  }

  @override
  void onActivated() {
    gamestream.audio.musicStop();
    engine.fullScreenExit();
  }

  @override
  void renderForeground(Canvas canvas, Size size) {

  }

  @override
  void update() {
    gamestream.animation.updateAnimationFrame();
  }

  onChangedVisitCount(int value){
    print("visit-count: $value");
  }

  String formatDate(DateTime value){
    return dateFormat.format(value.toLocal());
  }

  void setError(String message){
    WebsiteState.error.value = message;
  }

  void renderCanvas(Canvas canvas, Size size) {

  }

  Widget buildLoadingPage() =>
      Container(
        color: GameIsometricColors.black,
        alignment: Alignment.center,
        child: text("LOADING GAMESTREAM"),
      );

  @override
  Widget buildUI(BuildContext context) => Stack(
      children: [
        watch(gamestream.operationStatus, buildOperationStatus),
        buildWatchErrorMessage(),
      ]);

  Widget buildWatchErrorMessage(){
    return WatchBuilder(WebsiteState.error, (String? message){
      if (message == null) return GameStyle.Null;
      return buildErrorDialog(message);
    });
  }

  Widget buildOperationStatus(OperationStatus operationStatus) =>
      operationStatus != OperationStatus.None
          ? buildFullscreen(child: text(operationStatus.name.replaceAll("_", " ")))
          : watch(gamestream.network.connectionStatus, buildConnectionStatus);

  Widget buildConnectionStatus(ConnectionStatus connectionStatus) {
    switch (connectionStatus) {
      case ConnectionStatus.Connected:
        return buildPageConnectionStatus(connectionStatus.name);
      case ConnectionStatus.Connecting:
        return buildPageConnectionStatus(connectionStatus.name);
      default:
        return buildNotConnected();
    }
  }

  Widget buildPageLoading(BuildContext context) {
    final _width = 300.0;
    final _height = 50.0;
    return buildFullscreen(
      color: GameIsometricColors.black,
      child: watch(download, (double value) {
        value = 0.6182;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text("GAMESTREAM ${(value * 100).toInt()}%", color: Colors.white),
                height8,
                Container(
                  width: _width,
                  height: _height,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: Colors.white,
                    width: _width * value,
                    height: _height,
                  ),
                )
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget buildNotConnected()  => watch(engine.deviceType, buildPageWebsite);

  void toggleWebsitePage() =>
      websitePage.value =
      websitePage.value == WebsitePage.Region
          ? WebsitePage.Games
          : WebsitePage.Region;

  Widget buildPageWebsite(int deviceType) =>
      deviceType == DeviceType.Computer
          ? buildPageWebsiteDesktop()
          : buildPageWebsiteMobile();

  void showWebsitePageRegion(){
     websitePage.value = WebsitePage.Region;
  }

  void showWebsitePageGames(){
    websitePage.value = WebsitePage.Games;
  }

  Widget buildPageWebsiteDesktop() {
    return Center(
      child: WatchBuilder(websitePage, (websitePage){
        if (websitePage == WebsitePage.Region){
          return SelectRegionColumn();
        }
        return WatchBuilder(gamestream.network.region, (ConnectionRegion? region) {
          if (region == null) return SelectRegionColumn();

          final regionButton = onPressed(
            action: showWebsitePageRegion,
            child: Container(
              color: Colors.white12,
              alignment: Alignment.center,
              padding: GameStyle.Container_Padding,
              child: Row(
                children: [
                  text(formatEnumName(region.name)),
                ],
              ),
            ),
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildLogoGameStream(),
                  width32,
                  regionButton,
                ],
              ),
              height32,
              SelectGameTypeColumn(),
            ],
          );
        }
        );
      }),
    );

  }

  void openUrlYoutube() =>
      launchUrl(Uri.parse('https://www.youtube.com/@gamestream.online'));

  void openUrlDiscord() =>
      launchUrl(Uri.parse('https://discord.com/channels/888728235653885962/888728235653885965'));

  Widget buildRowSocialLinks() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      onPressed(
          action: openUrlYoutube,
          child: text("youtube", color: Colors.white70, underline: true)),
      width16,
      onPressed(
          action: openUrlDiscord,
          child: text("discord", color: Colors.white70, underline: true)),
    ],
  );

  Widget buildPageWebsiteMobile() =>
      Container(
        // width: 300,
        width: engine.screen.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildLogoGameStream(),
            height16,
            buildButtonJoinGameType(
              gameType: GameType.Mobile_Aeon,
              gameName: "AEON",
            ),
            height16,
            buildButtonJoinGameType(
              gameType: GameType.Rock_Paper_Scissors,
              gameName: "CHASE",
            ),
            height16,
          ],
        ),
      );

  Widget buildButtonJoinGameType({required GameType gameType, required String gameName}){
    return onPressed(
      action: () => gamestream.network.connectToGame(gameType),
      child: text(gameName, size: 26, color: Colors.white70),
    );
  }

  Widget buildLogoGameStream(){
    return text("GAMESTREAM.ONLINE", size: FontSize.VeryLarge);
  }

  Widget buildPageConnectionStatus(String message) =>
      buildFullScreen(
        child: text(message, color: GameIsometricColors.white80, align: TextAlign.center),
      );

  Widget buildFullScreen({required Widget child, Alignment alignment = Alignment.center}) =>
      Container(
        width: engine.screen.width,
        height: engine.screen.height,
        alignment: alignment,
        child: child,
      );

  Widget buildInputCustomConnectionString() =>
      Container(
        width: 280,
        margin: const EdgeInsets.only(left: 12),
        child: TextField(
          autofocus: true,
          controller: gamestream.games.website.customConnectionStrongController,
          decoration: InputDecoration(
              labelText: 'ws connection string'
          ),
        ),
      );

  Widget buildTextVersion() =>
      text('gamestream.online - v$version', color:  Colors.white60, size: FontSize.Regular);

  void showDialogChangePublicName(){
    gamestream.games.website.dialog.value = WebsiteDialog.Change_Public_Name;
  }

  void showDialogConfirmCancelSubscription() {
    gamestream.games.website.dialog.value = WebsiteDialog.Confirm_Cancel_Subscription;
  }

  void showDialogAccount(){
    gamestream.games.website.dialog.value = WebsiteDialog.Account;
  }

  void showDialogWelcome(){
    gamestream.games.website.dialog.value = WebsiteDialog.Account_Created;
  }

  void showDialogWelcome2(){
    gamestream.games.website.dialog.value = WebsiteDialog.Welcome_2;
  }

  void showDialogSubscriptionSuccessful(){
    gamestream.games.website.dialog.value = WebsiteDialog.Subscription_Successful;
  }

  void showDialogSubscriptionStatusChanged(){
    gamestream.games.website.dialog.value = WebsiteDialog.Subscription_Status_Changed;
  }

  void showDialogSubscriptionRequired(){
    gamestream.games.website.dialog.value = WebsiteDialog.Subscription_Required;
  }

  void showDialogCustomMaps(){
    _log("showDialogCustomMaps");
    gamestream.games.website.dialog.value = WebsiteDialog.Custom_Maps;
  }

  void connectToCustomGame(String customGame){
    _log("connectToCustomGame");
    // game.type.value = GameType.Custom;
    // game.customGameName = customGame;
    // connectToWebSocketServer(core.state.region.value, GameType.Custom);
  }

  void _log(String value){
    print("website.actions.$value()");
  }

  void showDialogChangeRegion(){
    dialog.value = WebsiteDialog.Change_Region;
  }

  void showDialogSubscription(){
    dialog.value = WebsiteDialog.Account;
  }

  void showDialogLogin(){
    dialog.value = WebsiteDialog.Login;
  }

  void showDialogGames(){
    dialog.value = WebsiteDialog.Games;
  }

  Widget buttonRegion(){
    return Tooltip(
      message: "Change Region",
      child: button(
        text(engine.enumString(gamestream.network.region.value),
            color: GameIsometricColors.white80),
        gamestream.games.website.showDialogChangeRegion,
        borderColor: GameIsometricColors.none,
        fillColor: GameIsometricColors.black20,
      ),
    );
  }

  Widget buttonCustomMap(){
    return buildMenuButton("Custom", gamestream.games.website.showDialogCustomMaps);
  }

  Widget dialogCustomMaps() {
    print("website.builders.dialogCustomMaps()");

    return FutureBuilder(future: firestoreService.getMapNames(), builder: (context, snapshot){

      if (snapshot.hasError){
        buildErrorDialog(snapshot.error.toString());
      }

      if (snapshot.connectionState == ConnectionState.waiting){
        return buildDialogMessage("Loading Games");
      }

      final games = snapshot.data;

      if (games == null){
        return buildDialogMessage("No games found");
      }

      return buildDialog(
          width: style.dialogWidthMedium,
          height: style.dialogHeightLarge,
          bottomRight: closeDialogButton,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buttonRegion(),
                height16,
                Column(
                  children: games.map((mapName) => margin(
                    bottom: 16,
                    child: button(text(mapName, color: GameIsometricColors.white618), (){
                      // connect to custom game
                      gamestream.games.website.connectToCustomGame(mapName);
                    },
                        alignment: Alignment.centerLeft,
                        fillColor: GameIsometricColors.white05, fillColorMouseOver: GameIsometricColors.white10, borderColor: GameIsometricColors.none, borderColorMouseOver: GameIsometricColors.none),
                  )).toList(),
                ),
              ],
            ),
          )
      );
    },);
  }

}