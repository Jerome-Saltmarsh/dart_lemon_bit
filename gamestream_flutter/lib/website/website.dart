
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/actions.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/events.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/website/build/build_column_games.dart';
import 'package:gamestream_flutter/website/build_layout_website.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

class Website {
  static final operationStatus = Watch(OperationStatus.None);
  static final error = Watch<String?>(null);
  static final account = Watch<Account?>(null);
  static final region = Watch(Region.LocalHost, onChanged: onChangedRegion);
  static final download = Watch(0.0);
  static final debug = true;

  static void setError(String message){
    error.value = message;
  }

   static void renderCanvas(Canvas canvas, Size size){
      Engine.renderSprite(
          image: Images.characters,
          srcX: 0,
          srcY: 0,
          srcWidth: 64,
          srcHeight: 64,
          dstX: 100,
          dstY: 100,
      );
      Engine.renderSprite(
        image: Images.blocks,
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
          ? _layoutOperationStatus(operationStatus)
          : watchAccount(buildAccount);

  static Widget _layoutOperationStatus(OperationStatus operationStatus) =>
      fullScreen(
        child: text(operationStatus.name),
      );

  static Widget buildLoadingScreen(BuildContext context) {
    final double _width = 300;
    final double _height = 50;
    return fullScreen(
      color: colours.black,
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
          buildTextButton("PLAY DARK-AGE", action: connectToGameDarkAge),
          height24,
          buildTextButton("PLAY FIRE-STORM", action: connectToGameSkirmish),
          height24,
          buildTextButton("PLAY SAND-BOX", action: connectToGameEditor),
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
            child: text("Created by Jerome Saltmarsh", color: colours.white618,
                size: FontSize.Small),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: Engine.screen.width,
              height: Engine.screen.height,
              alignment: Alignment.center,
              child: Website.buildColumnGames(),
            ),
          )
        ],
      );

}