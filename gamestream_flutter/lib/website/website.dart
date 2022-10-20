
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
import 'package:gamestream_flutter/website/build_layout_website.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import '../enums/operation_status.dart';

class Website {
  static final operationStatus = Watch(OperationStatus.None);
  static final error = Watch<String?>(null);
  static final account = Watch<Account?>(null, onChanged: onChangedAccount);
  static final region = Watch(Region.LocalHost, onChanged: onChangedRegion);
  static final download = Watch(0.0);
  static final debug = true;
  static final isVisibleDialogCustomRegion = Watch(false);

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
      watch(Website.operationStatus, buildOperationStatus),
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
      child: watch(Website.download, (double value) {
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

  static Widget buildColumnGames() =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextButton("PLAY DARK-AGE", action: GameNetwork.connectToGameDarkAge),
          height24,
          buildTextButton("PLAY FIRE-STORM", action: GameNetwork.connectToGameSkirmish),
          height24,
          buildTextButton("PLAY SAND-BOX", action: GameNetwork.connectToGameEditor),
        ],
      );

  static Widget build({double padding = 6})  =>
      Stack(
        children: [
          Positioned(
            top: padding,
            right: padding,
            child: buildTextVersion(),
          ),
          Positioned(
            top: 0,
            left: 180,
            child: buildWatchBool(isVisibleDialogCustomRegion, buildInputCustomConnectionString),
          ),
          Positioned(
            // top: padding,
            left: 32,
            child: watch(Website.region, buildStateRegion),
          ),
          Positioned(
            bottom: padding,
            right: padding,
            child: text("Created by Jerome Saltmarsh", color: GameColors.white618,
                size: FontSize.Small),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: buildFullscreen(
              child: buildColumnGames(),
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
    // AccountService.store(flag, enumString(account.subscriptionStatus));
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
}
