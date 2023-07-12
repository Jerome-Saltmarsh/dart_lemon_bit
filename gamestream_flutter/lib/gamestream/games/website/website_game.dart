
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/games/website/website_ui.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'enums/website_dialog.dart';
import 'enums/website_page.dart';

class WebsiteGame extends Game {

  final gameTypes = [
    GameType.Fight2D,
    GameType.Capture_The_Flag,
    GameType.Moba,
    GameType.Mmo,
  ];

  final error = Watch<String?>(null);
  final websitePage = Watch(WebsitePage.Region);
  final signInSuggestionVisible = Watch(false);
  final dialog = Watch(WebsiteDialog.Games);
  final customConnectionStrongController = TextEditingController();
  final download = Watch(0.0);
  final debug = true;
  final isVisibleDialogCustomRegion = Watch(false);
  final colorRegion = Colors.orange;
  final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
  final errorMessageEnabled = Watch(true);

  late final visitCount = Watch(0, onChanged: onChangedVisitCount);
  
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
    gamestream.isometric.animation.updateAnimationFrame();
  }

  onChangedVisitCount(int value){
    print('visit-count: $value');
  }

  String formatDate(DateTime value){
    return dateFormat.format(value.toLocal());
  }

  void setError(String message){
    gamestream.games.website.error.value = message;
  }

  void renderCanvas(Canvas canvas, Size size) {

  }

  @override
  Widget buildUI(BuildContext context) => Stack(
      children: [
        buildWatch(gamestream.operationStatus, buildOperationStatus),
        buildWatchErrorMessage(),
      ]);


  void toggleWebsitePage() =>
      websitePage.value =
      websitePage.value == WebsitePage.Region
          ? WebsitePage.Games
          : WebsitePage.Region;

  void showWebsitePageRegion(){
     websitePage.value = WebsitePage.Region;
  }

  void showWebsitePageGames(){
    websitePage.value = WebsitePage.Games;
  }

  void openUrlYoutube() =>
      launchUrl(Uri.parse('https://www.youtube.com/@gamestream.online'));

  void openUrlDiscord() =>
      launchUrl(Uri.parse('https://discord.com/channels/888728235653885962/888728235653885965'));

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
    _log('showDialogCustomMaps');
    gamestream.games.website.dialog.value = WebsiteDialog.Custom_Maps;
  }

  void connectToCustomGame(String customGame){
    _log('connectToCustomGame');
  }

  void _log(String value){
    print('website.actions.$value()');
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

  void closeErrorMessage(){
    error.value = null;
  }

  void checkForLatestVersion() async {
    await saveVisitDateTime();
    gamestream.operationStatus.value = OperationStatus.Checking_For_Updates;
    engine.refreshPage();
  }

  Future saveVisitDateTime() async =>
      save('visit-datetime', DateTime.now().toIso8601String());

  Future saveVersion() async =>
      await save('version', version);

  Future save(String key, dynamic value) async =>
      (await SharedPreferences.getInstance()).putAny(key, value);

}