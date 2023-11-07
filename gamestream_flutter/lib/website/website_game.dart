
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_src_icon_type.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/website/widgets/gs_fullscreen.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/website/website_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'enums/website_dialog.dart';
import 'enums/website_page.dart';

class WebsiteGame extends Game {

  final gameTypes = [
    GameType.Amulet,
  ];

  var imagesCached = false;
  final websitePage = Watch(WebsitePage.User);
  final signInSuggestionVisible = Watch(false);
  final dialog = Watch(WebsiteDialog.Games);
  final customConnectionStrongController = TextEditingController();
  final isVisibleDialogCustomRegion = Watch(false);
  final colorRegion = Colors.orange;
  final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
  final errorMessageEnabled = Watch(true);

  late final visitCount = Watch(0, onChanged: onChangedVisitCount);

  @override
  void onComponentReady() {
    print('isometric.website.onComponentsInitialized()');
    validateAtlases();
  }

  void validateAtlases(){

    for (final iconType in IconType.values){
       if (!atlasSrcIconType.containsKey(iconType)){
         print('validation: "atlasSrcIconType does not contain $iconType"');
       }
    }

    for (final entry in ItemType.collections.entries){
      final type = entry.key;
      final values = entry.value;
      final atlas = Atlas.SrcCollection[type];
      if (atlas == null) {
        print('validation: "missing atlas ${ItemType.getName(type)}"');
        continue;
      }
      for (final value in values){
        if (!atlas.containsKey(value)){
          print('validation: "missing atlas src for ${ItemType.getName(type)} ${ItemType.getNameSubType(type, value)}"');
        }
      }
    }
  }


  @override
  void onActivated() {
    // getComponent<GameAudio>().musicStop();
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
          ? WebsitePage.User
          : WebsitePage.Select_Region;

  void showWebsitePageRegion(){
     websitePage.value = WebsitePage.Select_Region;
  }

  void showWebsitePageGames(){
    websitePage.value = WebsitePage.User;
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