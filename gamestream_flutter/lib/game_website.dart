
import 'package:bleed_common/version.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/enums/region.dart';
import 'package:gamestream_flutter/game_colors.dart';
import 'package:gamestream_flutter/game_images.dart';
import 'package:gamestream_flutter/game_network.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/storage_service.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/website/build/build_column_games.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'enums/operation_status.dart';
import 'to_string.dart';

class GameWebsite {
  static final operationStatus = Watch(OperationStatus.None);
  static final error = Watch<String?>(null);
  static final account = Watch<Account?>(null, onChanged: onChangedAccount);
  static final region = Watch(Region.LocalHost, onChanged: onChangedRegion);
  static final download = Watch(0.0);
  static final debug = true;
  static final isVisibleDialogCustomRegion = Watch(false);
  static final colorRegion = Colors.orange;
  static const Padding = 12.0;

  static final websitePage = Watch(WebsitePage.Games);

  static void setError(String message){
    error.value = message;
  }

   static void renderCanvas(Canvas canvas, Size size){
      Engine.renderSprite(
          image: GameImages.characters,
          srcX: 0,
          srcY: 0,
          srcWidth: 64,
          srcHeight: 64,
          dstX: 100,
          dstY: 100,
      );
      Engine.renderSprite(
        image: GameImages.blocks,
        srcX: 0,
        srcY: 0,
        srcWidth: 48,
        srcHeight: 72,
        dstX: 200,
        dstY: 100,
      );
   }

   static void update(){

   }

   static Widget buildUI(BuildContext context) => Stack(
    children: [
      watch(GameWebsite.operationStatus, buildOperationStatus),
      buildWatchErrorMessage(),
    ]);

  static Widget buildOperationStatus(OperationStatus operationStatus) =>
      operationStatus != OperationStatus.None
          ? buildFullscreen(child: text(operationStatus.name))
          : watch(GameNetwork.connectionStatus, buildConnection);

  static Widget buildPageLoading(BuildContext context) {
    final _width = 300.0;
    final _height = 50.0;
    return buildFullscreen(
      color: GameColors.black,
      child: watch(GameWebsite.download, (double value) {
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

  static Widget buildWebsitePage(WebsitePage page) =>
      page == WebsitePage.Games
       ? buildWebsitePageGames()
       : buildWebsitePageRegions();

  static Widget buildWebsitePageGames() =>
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextButton("DARK-AGE", action: GameNetwork.connectToGameDarkAge),
        height24,
        buildTextButton("FIRE-STORM", action: GameNetwork.connectToGameSkirmish),
        height24,
        buildTextButton("GAME-MAKER", action: GameNetwork.connectToGameEditor),
      ],
    );

  static Widget buildWebsitePageRegions() =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: Region.values.map((Region region) {
          return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: text(region.name.replaceAll("_", " "), onPressed: (){
                GameWebsite.region.value = region;
                GameWebsite.websitePage.value = WebsitePage.Games;
              }, size: 20),
          );
        }).toList(),
      );

  static Widget buildNotConnected()  => watch(Engine.deviceType, buildDevice);

  static void toggleWebsitePage() =>
     websitePage.value =
        websitePage.value == WebsitePage.Region
         ? WebsitePage.Games
         : WebsitePage.Region;

  static Widget buildDevice(int deviceType) =>
    Stack(
      children: [
        Positioned(
          top: Padding,
          right: Padding,
          child: buildTextVersion(),
        ),
        // Positioned(
        //   bottom: Padding,
        //   left: Padding,
        //   child: text(deviceType == DeviceType.Computer ? 'Computer: ${Engine.screenArea}' : 'Mobile: ${Engine.screenArea}'),
        // ),
        Positioned(
          top: Padding,
          left: 180,
          child: buildWatchBool(isVisibleDialogCustomRegion, buildInputCustomConnectionString),
        ),
        if (deviceType == DeviceType.Computer)
          Positioned(
            left: 32,
            child: buildFullscreen(
              child: watch(GameWebsite.region, buildColumnRegions),
              alignment: Alignment.centerLeft
            ),
          ),
        if (deviceType == DeviceType.Phone)
          Positioned(
              top: Padding,
              left: Padding,
              child: watch(region, (Region region) => text(region.name, color: colorRegion, onPressed: () => websitePage.value = WebsitePage.Region))
          ),
        Positioned(
          bottom: Padding,
          right: Padding,
          child: text(
              "Created by Jerome Saltmarsh",
              color: GameColors.white382,
              size: FontSize.Small
          ),
        ),
        Positioned(
          child: buildFullscreen(
            child: watch(websitePage, buildWebsitePage)
          ),
        )
      ],
    );

  static void onChangedRegion(Region region) {
    storage.saveRegion(region);
    isVisibleDialogCustomRegion.value = region == Region.Custom;
  }

  static void onChangedAccount(Account? account) {
    if (account == null) return;
    final flag = 'subscription_status_${account.userId}';
    if (storage.contains(flag)){
      final storedSubscriptionStatusString = storage.get<String>(flag);
      final storedSubscriptionStatus = parseSubscriptionStatus(storedSubscriptionStatusString);
      if (storedSubscriptionStatus != account.subscriptionStatus){
        website.actions.showDialogSubscriptionStatusChanged();
      }
    }
    website.actions.showDialogGames();
  }

  static Widget buildPageConnectionStatus(String message) =>
      buildFullScreen(
        child: text(message, color: GameColors.white80, align: TextAlign.center),
      );

  static Widget buildFullScreen({required Widget child, Alignment alignment = Alignment.center}) =>
      Container(
        width: Engine.screen.width,
        height: Engine.screen.height,
        alignment: alignment,
        child: child,
      );

  static Widget buildColumnRegions(Region selectedRegion) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: Region.values
            .map((Region region) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: buildTextButton(
                    'Region ${enumString(region)}',
                    action: selectedRegion == region
                        ? null
                        : () => actionSelectRegion(region),
                    size: 18,
                    colorRegular: selectedRegion == region
                        ? colorRegion.withOpacity(0.54)
                        : colorRegion.withOpacity(0.24),
                    colorMouseOver: selectedRegion == region
                        ? colorRegion.withOpacity(0.54)
                        : colorRegion.withOpacity(0.39),
                  ),
                ))
            .toList(),
      );

  static Widget buildInputCustomConnectionString() =>
      Container(
        width: 280,
        margin: const EdgeInsets.only(left: 12),
        child: TextField(
          autofocus: true,
          controller: website.state.customConnectionStrongController,
          decoration: InputDecoration(
              labelText: 'ws connection string'
          ),
        ),
      );

  static Widget buildButtonSelectRegion(Region region) =>
    Container(
        height: 50,
        child: text(region.name, onPressed: () => actionSelectRegion(region))
    );

  static Widget buildTextVersion() =>
    text(version, color: GameColors.white382, size: FontSize.Small);

  static void actionSelectRegion(Region value) =>
    GameWebsite.region.value = value;
}


enum WebsitePage {
   Games,
   Region,
}