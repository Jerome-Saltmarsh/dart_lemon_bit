// import 'dart:ui';
import 'dart:ui';
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/website/widgets/game_type_column.dart';
import 'package:gamestream_flutter/website/widgets/region_column.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class GameWebsite {
  static final operationStatus = Watch(OperationStatus.None);
  static final account = Watch<Account?>(null, onChanged: onChangedAccount);
  static final region = Watch(ConnectionRegion.Asia_South, onChanged: onChangedRegion);
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

   static void renderCanvas(Canvas canvas, Size size) {

    final positions = Float32List(16);
    final size = 50.0;

    positions[0] = 0;
    positions[1] = 0;

    positions[2] = 0;
    positions[3] = size;

    positions[4] = size;
    positions[5] = size;

    positions[6] = size;
    positions[7] = 0;

    final indices = Uint16List(8);
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 3;
    indices[4] = 4;
    indices[5] = 5;
    indices[6] = 6;
    indices[7] = 7;

    final colors = Int32List(8);
    colors[0] = Colors.red.value;
    colors[1] = Colors.yellow.value;
    colors[2] = Colors.blue.value;
    colors[3] = Colors.green.value;
    colors[4] = Colors.green.value;
    colors[5] = Colors.green.value;
    colors[6] = Colors.green.value;
    colors[7] = Colors.green.value;

     // Create the vertices object using Vertices.raw
     final vertexObject = Vertices.raw(
       VertexMode.triangles,
       positions,
       colors: colors,
       indices: indices,
     );

     // Create the paint object
     final paint = Paint()
       ..color = Colors.blue
       ..style = PaintingStyle.stroke
       ..strokeWidth = 2.0;

     // Draw the cube on the canvas using drawVertices
     canvas.drawVertices(vertexObject, BlendMode.src, paint);

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
         child: text("LOADING GAMESTREAM"),
      );

   static Widget buildUI(BuildContext context) => Stack(
       children: [
         watch(GameWebsite.operationStatus, buildOperationStatus),
         WebsiteBuild.buildWatchErrorMessage(),
       ]);

  static Widget buildOperationStatus(OperationStatus operationStatus) =>
      operationStatus != OperationStatus.None
          ? buildFullscreen(child: text(operationStatus.name.replaceAll("_", " ")))
          : watch(GameNetwork.connectionStatus, buildConnectionStatus);

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

  static Widget buildNotConnected()  => watch(Engine.deviceType, buildPageWebsite);

  static void toggleWebsitePage() =>
     websitePage.value =
        websitePage.value == WebsitePage.Region
         ? WebsitePage.Games
         : WebsitePage.Region;

  static Widget buildPageWebsite(int deviceType) =>
      deviceType == DeviceType.Computer
          ? buildPageWebsiteDesktop()
          // : buildPageWebsiteDesktop();
          : buildPageWebsiteMobile();

  static const Icon_Size = 25.0;

  static Widget buildPageWebsiteDesktop() =>
      Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildLogoGameStream(),
              height16,
              // buildColumnRegions(),
              SelectRegionColumn(),
              GameTypeColumn(),
            ],
          ),
        ),
      );

  static void openUrlYoutube() =>
      launchUrl(Uri.parse('https://www.youtube.com/@gamestream.online'));

  static void openUrlDiscord() =>
      launchUrl(Uri.parse('https://discord.com/channels/888728235653885962/888728235653885965'));

  static Widget buildRowSocialLinks() => Row(
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

  static Widget buildPageWebsiteMobile() =>
      Container(
        // width: 300,
        width: Engine.screen.width,
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

  static Widget buildButtonJoinGameType({required int gameType, required String gameName}){
    return onPressed(
        action: () => GameNetwork.connectToGame(gameType),
        child: text(gameName, size: 26, color: Colors.white70),
    );
  }


  static Widget buildLogoGameStream(){
    return text("GAMESTREAM ONLINE", size: 40);
  }

  static Widget buildLogoSquigitalGames() {
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
                            text("SQUIGITAL GAMES", color: GameColors.white, size: 35),
                            // width4,
                            // text("GAMES", color: GameColors.white85, size: 35),
                          ],
                        )),
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
    ConnectionRegion.America_North,
    ConnectionRegion.America_South,
    ConnectionRegion.Europe,
    ConnectionRegion.Asia_North,
    ConnectionRegion.Asia_South,
    ConnectionRegion.Oceania,
  ];

  static Widget buildColumnRegions() =>
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: (Engine.isLocalHost ? ConnectionRegion.values : Live_Regions)
              .map((ConnectionRegion region) =>
              onPressed(
                action: () {
                  actionSelectRegion(region);
                  if (Engine.deviceIsPhone) {
                    GameNetwork.connectToGameAeon();
                  } else {
                    GameNetwork.connectToGameCombat();
                  }
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

