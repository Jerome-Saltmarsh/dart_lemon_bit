import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:golden_ratio/constants.dart';
import 'package:intl/intl.dart';

class GameWebsite {
  static final operationStatus = Watch(OperationStatus.None);
  static final account = Watch<Account?>(null, onChanged: onChangedAccount);
  static final region = Watch(ConnectionRegion.LocalHost, onChanged: onChangedRegion);
  static final download = Watch(0.0);
  static final debug = true;
  static final isVisibleDialogCustomRegion = Watch(false);
  static final colorRegion = Colors.orange;
  static const Padding = 16.0;
  static final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
  static final visitCount = Watch(0, onChanged: onChangedVisitCount);
  static final errorMessageEnabled = Watch(true);

  static onChangedVisitCount(int value){
    print("visit-count: $value");
  }

  static String formatDate(DateTime value){
    return dateFormat.format(value.toLocal());
  }

  static final websitePage = Watch(WebsitePage.Games);

  static void setError(String message){
    WebsiteState.error.value = message;
  }

   static void renderCanvas(Canvas canvas, Size size){
      // final centerX = size.width * 0.5;
      // Engine.renderSprite(
      //   image: GameImages.atlas_nodes,
      //   srcX: 0,
      //   srcY: 0,
      //   srcWidth: 48,
      //   srcHeight: 72,
      //   dstX: centerX,
      //   dstY: 100 + GameAnimation.animationFrameWaterHeight.toDouble(),
      // );
      // Engine.renderSprite(
      //   image: GameImages.atlas_characters,
      //   srcX: 0,
      //   srcY: 0,
      //   srcWidth: 64,
      //   srcHeight: 64,
      //   dstX: centerX,
      //   dstY: 100 + GameAnimation.animationFrameWaterHeight.toDouble() - GameConstants.Node_Height,
      // );

      // Engine.renderSprite(
      //   image: GameImages.atlas_nodes,
      //   srcX: 2032,
      //   srcY: 2032,
      //   srcWidth: 16,
      //   srcHeight: 16,
      //   dstX: centerX,
      //   dstY: 100 + GameAnimation.animationFrameWaterHeight.toDouble(),
      // );
   }

   static void update(){
      GameAnimation.updateAnimationFrame();
   }

   static Widget buildLoadingPage() =>
      Container(
         color: GameColors.black,
         alignment: Alignment.center,
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             text("SQUIGITAL GAMES"),
             height8,
             Image.asset('images/squigital-logo.png'),
             // FutureBuilder<ui.Image>(
             //   future: Engine.loadImageAsset('images/loading-icon.png'),
             //   builder: (context, snapshot){
             //       if (snapshot.connectionState != ConnectionState.done){
             //         return const SizedBox(height: 45,);
             //       }
             //       final image = snapshot.data;
             //       if (image == null){
             //         return const SizedBox(height: 45,);
             //       }
             //       return Engine.buildAtlasImage(
             //           image: image,
             //           srcX: 0,
             //           srcY: 0,
             //           srcWidth: 22,
             //           srcHeight: 45
             //       );
             //
             //   }),
           ],
         ),
      );

   static Widget buildUI(BuildContext context) => buildFullScreen(
     child: Stack(
      children: [
        watch(GameWebsite.operationStatus, buildOperationStatus),
        WebsiteBuild.buildWatchErrorMessage(),
      ]),
   );

  static Widget buildOperationStatus(OperationStatus operationStatus) =>
      operationStatus != OperationStatus.None
          ? buildFullscreen(child: text(operationStatus.name.replaceAll("_", " ")))
          : buildFullscreen(child: watch(GameNetwork.connectionStatus, buildConnection));

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
       ? buildColumnSelectGameType()
       : buildWebsitePageRegions();

  static Widget buildColumnSelectGameType() =>
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildTextButton("COMBAT", action: GameNetwork.connectToGameCombat, colorRegular: GameColors.green.withOpacity(0.5), size: 50),
        height24,
        buildTextButton("CREATE", action: GameNetwork.connectToGameEditor, colorRegular: GameColors.green.withOpacity(0.5), size: 50),
      ],
    );

  static Widget buildWebsitePageRegions() =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ConnectionRegion.values.map((ConnectionRegion region) {
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
    Container(
      constraints: BoxConstraints(
        maxWidth: 300,
        // maxHeight: 300 * goldenRatio_0618,
      ),
      child: border(
        color: Colors.transparent,
        child: Stack(
          children: [

            // Positioned(
            //   top: Padding,
            //   right: Padding,
            //   child: buildTextVersion(),
            // ),
            // Positioned(
            //   top: Padding,
            //   left: 180,
            //   child: buildWatchBool(isVisibleDialogCustomRegion, buildInputCustomConnectionString),
            // ),
            if (deviceType == DeviceType.Computer)
              buildColumnRegions(),
            // Positioned(
            //   bottom: Padding,
            //   right: Padding,
            //   child: onPressed(
            //       action: () {
            //         launchUrl(
            //           Uri.parse('https://linktr.ee/gamestream.online'),
            //           mode: LaunchMode.externalApplication,
            //           webOnlyWindowName: '_blank',
            //         );
            //       },
            //       child: buildLogoSquigitalGames()
            //   ),
            // ),
            // Positioned(
            //   child: buildFullscreen(
            //     child: watch(websitePage, buildWebsitePage)
            //   ),
            // )
          ],
        ),
      ),
    );

  static Row buildLogoSquigitalGames() {
    return Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 64,
                        height: 64,
                        child: FittedBox(child: Image.asset('images/squigital-logo.png'))),
                    Container(
                        margin: const EdgeInsets.only(right: 4),
                        child: text("SQUIGITAL GAMES", color: GameColors.white60, size: 35)),
                  ],
                );
  }

  static void onChangedRegion(ConnectionRegion region) {
    storage.saveRegion(region);
    isVisibleDialogCustomRegion.value = region == ConnectionRegion.Custom;
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

  static const Live_Regions = [
    ConnectionRegion.Australia,
    ConnectionRegion.Singapore,
    ConnectionRegion.Brazil,
    ConnectionRegion.Germany,
    ConnectionRegion.South_Korea,
    ConnectionRegion.USA_East,
    ConnectionRegion.USA_West,
  ];


  static Widget buildColumnRegions() =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLogoSquigitalGames(),
          height6,
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: (Engine.isLocalHost ? ConnectionRegion.values : Live_Regions)
                  .map((ConnectionRegion region) =>
                  onPressed(
                    action: (){
                      actionSelectRegion(region);
                      GameNetwork.connectToGameCombat();
                    },
                    child: onMouseOver(builder: (bool mouseOver) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: mouseOver ? Colors.green : Colors.white10,
                        child: text(
                            '${Engine.enumString(region)}',
                            size: 24,
                            color: mouseOver ? Colors.white : Colors.white60
                        ),
                      );
                    }),
                  ))
                  .toList(),
            ),
          )
        ],
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

  static Widget buildButtonSelectRegion(ConnectionRegion region) =>
    Container(
        height: 50,
        child: text(region.name, onPressed: () => actionSelectRegion(region))
    );

  static Widget buildTextVersion() =>
    text('gamestream.online - v$version', color:  Colors.white60, size: FontSize.Regular);

  static void actionSelectRegion(ConnectionRegion value) =>
    GameWebsite.region.value = value;
}

enum WebsitePage {
   Games,
   Region,
}

typedef MouseOverBuilder = Widget Function(bool mouseOver);

Widget onMouseOver({
  required Widget Function(bool mouseOver) builder,
  Function? onEnter,
  Function? onExit
}) {
  return Builder(builder: (context) {
    bool mouseOver = false;
    return StatefulBuilder(builder: (BuildContext cont, StateSetter setState) {
      return MouseRegion(
          onEnter: (_) {
            if (onEnter != null) onEnter();
            setState(() {
              mouseOver = true;
            });
          },
          onExit: (_) {
            if (onExit != null) onExit();
            setState(() {
              mouseOver = false;
            });
          },
          child: builder(mouseOver));
    });
  });
}

typedef HoverBuilder = Widget Function(bool hovering);

Widget onHover(HoverBuilder builder, {
  Function? onEnter,
  Function? onExit
}) {
  return Builder(builder: (context) {
    bool mouseOver = false;
    return StatefulBuilder(builder: (BuildContext cont, StateSetter setState) {
      return MouseRegion(
          onEnter: (_) {
            if (onEnter != null) onEnter();
            setState(() {
              mouseOver = true;
            });
          },
          onExit: (_) {
            if (onExit != null) onExit();
            setState(() {
              mouseOver = false;
            });
          },
          child: builder(mouseOver));
    });
  });
}

