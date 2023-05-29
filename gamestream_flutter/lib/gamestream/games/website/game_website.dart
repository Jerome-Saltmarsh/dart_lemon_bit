

import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/enums/operation_status.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/website/widgets/game_type_column.dart';
import 'package:gamestream_flutter/website/widgets/region_column.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class GameWebsite extends Game {
  final signInSuggestionVisible = Watch(false);
  final dialog = Watch(WebsiteDialog.Games);
  final customConnectionStrongController = TextEditingController();
  static const Icon_Size = 25.0;
  final operationStatus = Watch(OperationStatus.None);
  late final account = Watch<Account?>(null, onChanged: onChangedAccount);
  late final region = Watch(ConnectionRegion.Asia_South, onChanged: onChangedRegion);
  late final visitCount = Watch(0, onChanged: onChangedVisitCount);
  final download = Watch(0.0);
  final debug = true;
  final isVisibleDialogCustomRegion = Watch(false);
  final colorRegion = Colors.orange;
  static const Padding = 16.0;
  final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
  final errorMessageEnabled = Watch(true);
  
  @override
  void drawCanvas(Canvas canvas, Size size) {
    // TODO: implement drawCanvas
  }

  @override
  void onActivated() {
    gamestream.audio.musicStop();
    engine.fullScreenExit();
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    // TODO: implement renderForeground
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

  final websitePage = Watch(WebsitePage.Games);

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
        watch(operationStatus, buildOperationStatus),
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

  Widget buildPageWebsiteDesktop() =>
      Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildLogoGameStream(),
              height16,
              SelectRegionColumn(),
              GameTypeColumn(),
            ],
          ),
        ),
      );

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
    return text("GAMESTREAM ONLINE", size: 40);
  }

  Widget buildLogoSquigitalGames() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            width: 64,
            height: 64,
            child: FittedBox(child: Image.asset('images/squigital-logo.png'))),
        Container(
            margin: const EdgeInsets.only(right: 4),
            child: Row(
              children: [
                text("SQUIGITAL GAMES", color: GameIsometricColors.white, size: 35),
                // width4,
                // text("GAMES", color: GameIsometricColors.white85, size: 35),
              ],
            )),
      ],
    );
  }

  void onChangedRegion(ConnectionRegion region) {
    storage.saveRegion(region);
    isVisibleDialogCustomRegion.value = region == ConnectionRegion.Custom;
  }

  void onChangedAccount(Account? account) {
    if (account == null) return;
    final flag = 'subscription_status_${account.userId}';
    if (storage.contains(flag)){
      final storedSubscriptionStatusString = storage.get<String>(flag);
      final storedSubscriptionStatus = parseSubscriptionStatus(storedSubscriptionStatusString);
      if (storedSubscriptionStatus != account.subscriptionStatus){
        // WebsiteActions.showDialogSubscriptionStatusChanged();
      }
    }
    // website.actions.showDialogGames();
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

  Widget buildColumnRegions() =>
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: (engine.isLocalHost ? ConnectionRegion.values : SelectRegionColumn.Live_Regions)
              .map((ConnectionRegion region) =>
              onPressed(
                action: () {
                  actionSelectRegion(region);
                  if (engine.deviceIsPhone) {
                    gamestream.network.connectToGameAeon();
                  } else {
                    gamestream.network.connectToGameCombat();
                  }
                },
                child: onMouseOver(builder: (bool mouseOver) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: mouseOver ? Colors.green : Colors.white10,
                    child: text(
                        '${engine.enumString(region)}',
                        size: 24,
                        color: mouseOver ? Colors.white : Colors.white60
                    ),
                  );
                }),
              ))
              .toList(),
        ),
      );


  Widget buildInputCustomConnectionString() =>
      Container(
        width: 280,
        margin: const EdgeInsets.only(left: 12),
        child: TextField(
          autofocus: true,
          controller: gamestream.games.gameWebsite.customConnectionStrongController,
          decoration: InputDecoration(
              labelText: 'ws connection string'
          ),
        ),
      );

  Widget buildButtonSelectRegion(ConnectionRegion region) =>
      Container(
          height: 50,
          child: text(region.name, onPressed: () => actionSelectRegion(region))
      );

  Widget buildTextVersion() =>
      text('gamestream.online - v$version', color:  Colors.white60, size: FontSize.Regular);

  void actionSelectRegion(ConnectionRegion value) => region.value = value;

  void showDialogChangePublicName(){
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Change_Public_Name;
  }

  void showDialogConfirmCancelSubscription() {
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Confirm_Cancel_Subscription;
  }

  void showDialogAccount(){
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Account;
  }

  void showDialogWelcome(){
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Account_Created;
  }

  void showDialogWelcome2(){
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Welcome_2;
  }

  void showDialogSubscriptionSuccessful(){
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Subscription_Successful;
  }

  void showDialogSubscriptionStatusChanged(){
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Subscription_Status_Changed;
  }

  void showDialogSubscriptionRequired(){
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Subscription_Required;
  }

  void showDialogCustomMaps(){
    _log("showDialogCustomMaps");
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Custom_Maps;
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
}