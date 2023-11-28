
import 'package:flutter/material.dart';
import 'package:amulet_flutter/functions/validate_atlases.dart';
import 'package:amulet_flutter/gamestream/game.dart';
import 'package:amulet_flutter/gamestream/operation_status.dart';
import 'package:amulet_flutter/gamestream/ui/src.dart';
import 'package:amulet_flutter/website/website_ui.dart';
import 'package:amulet_flutter/website/widgets/gs_fullscreen.dart';
import 'package:intl/intl.dart';
import 'package:lemon_watch/src.dart';
import 'package:url_launcher/url_launcher.dart';

import 'enums/website_dialog.dart';
import 'enums/website_page.dart';

class WebsiteGame extends Game {

  var imagesCached = false;
  final websitePage = Watch(WebsitePage.Select_Character);
  final signInSuggestionVisible = Watch(false);
  final dialog = Watch(WebsiteDialog.Games);
  final customConnectionStrongController = TextEditingController();
  final isVisibleDialogCustomRegion = Watch(false);
  final colorRegion = Colors.orange;
  final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
  final errorMessageEnabled = Watch(true);

  late final visitCount = Watch(0, onChanged: onChangedVisitCount);

  @override
  void onComponentReady() => validateAtlases();

  @override
  void onActivated() {
    engine.fullScreenExit();
  }

  @override
  void renderForeground(Canvas canvas, Size size) {

  }

  onChangedVisitCount(int value){
    print('visit-count: $value');
  }

  String formatDate(DateTime value){
    return dateFormat.format(value.toLocal());
  }

  void setError(String message){
    ui.error.value = message;
  }

  @override
  Widget buildUI(BuildContext context) => GSFullscreen(
        child: buildWatch(options.operationStatus, buildOperationStatus),
      );

  void toggleWebsitePage() =>
      websitePage.value =
      websitePage.value == WebsitePage.Select_Region
          ? WebsitePage.Select_Character
          : WebsitePage.Select_Region;

  void showWebsitePageRegion(){
     websitePage.value = WebsitePage.Select_Region;
  }

  void showWebsitePageGames(){
    websitePage.value = WebsitePage.Select_Character;
  }

  void openUrlYoutube() =>
      launchUrl(Uri.parse('https://www.youtube.com/@gamestream.online'));

  void openUrlDiscord() =>
      launchUrl(Uri.parse('https://discord.com/channels/888728235653885962/888728235653885965'));

  void showDialogChangePublicName(){
    website.dialog.value = WebsiteDialog.Change_Public_Name;
  }

  void showDialogConfirmCancelSubscription() {
    website.dialog.value = WebsiteDialog.Confirm_Cancel_Subscription;
  }

  void showDialogAccount(){
    website.dialog.value = WebsiteDialog.Account;
  }

  void showDialogWelcome(){
    website.dialog.value = WebsiteDialog.Account_Created;
  }

  void showDialogWelcome2(){
    website.dialog.value = WebsiteDialog.Welcome_2;
  }

  void showDialogSubscriptionSuccessful(){
    website.dialog.value = WebsiteDialog.Subscription_Successful;
  }

  void showDialogSubscriptionStatusChanged(){
    website.dialog.value = WebsiteDialog.Subscription_Status_Changed;
  }

  void showDialogSubscriptionRequired(){
    website.dialog.value = WebsiteDialog.Subscription_Required;
  }

  void showDialogCustomMaps(){
    _log('showDialogCustomMaps');
    website.dialog.value = WebsiteDialog.Custom_Maps;
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
    ui.error.value = null;
  }

  void checkForLatestVersion() async {
    // await saveVisitDateTime();
    options.operationStatus.value = OperationStatus.Checking_For_Updates;
    engine.refreshPage();
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    // TODO: implement drawCanvas
  }

  @override
  void update() {
    // TODO: implement update
  }

  void showPageNewCharacter() => websitePage.value = WebsitePage.New_Character;
}