
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/games/website/enums/website_page.dart';
import 'package:gamestream_flutter/gamestream/games/website/website_game.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_status.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:gamestream_flutter/language_utils.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/style.dart';

extension WebsiteUI on WebsiteGame {

  Widget buildColumnSelectGameType(){
    return WatchBuilder(
        gamestream.gameType,
            (activeGameType) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              GameType.Combat,
              GameType.Fight2D,
              GameType.Capture_The_Flag,
            ]
                .map((gameType) => onPressed(
              action: () => gamestream.startGameType(gameType),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    SizedBox(
                        width: 256,
                        child: buildGameTypeImage(gameType)),
                    buildText(gameType.name, size: 25),
                  ],
                ),
              ),
            ))
                .toList()));

  }

  Widget buildPageWebsiteDesktop() {
    return Center(
      child: WatchBuilder(websitePage, (websitePage){
        if (websitePage == WebsitePage.Region){
          return buildSelectRegionColumn();
        }
        return WatchBuilder(gamestream.network.region, (ConnectionRegion? region) {
          if (region == null) return buildSelectRegionColumn();

          final regionButton = onPressed(
            action: showWebsitePageRegion,
            child: Container(
              color: Colors.white12,
              alignment: Alignment.center,
              padding: GameStyle.Container_Padding,
              child: Row(
                children: [
                  buildText(formatEnumName(region.name)),
                ],
              ),
            ),
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildLogoGameStream(),
                    // width32,
                    regionButton,
                  ],
                ),
              ),
              height32,
              buildColumnSelectGameType(),
            ],
          );
        }
        );
      }),
    );

  }

  Widget buildWatchErrorMessage() =>
      WatchBuilder(gamestream.games.website.error, (String? message) {
        if (message == null) return GameStyle.Null;
        return buildErrorDialog(message);
      });

  Widget buildOperationStatus(OperationStatus operationStatus) =>
      operationStatus != OperationStatus.None
          ? buildFullscreen(child: buildText(operationStatus.name.replaceAll("_", " ")))
          : watch(gamestream.network.connectionStatus, buildConnectionStatus);

  Widget buildConnectionStatus(ConnectionStatus connectionStatus) =>
      switch (connectionStatus) {
        ConnectionStatus.Connected =>
            buildPageConnectionStatus(connectionStatus.name),
        ConnectionStatus.Connecting =>
            buildPageConnectionStatus(connectionStatus.name),
        _ => buildNotConnected()
      };

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
                buildText("GAMESTREAM ${(value * 100).toInt()}%", color: Colors.white),
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

  Widget buildPageWebsite(int deviceType) =>
      deviceType == DeviceType.Computer
          ? buildPageWebsiteDesktop()
          : buildPageWebsiteMobile();

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
      child: buildText(gameName, size: 26, color: Colors.white70),
    );
  }

  Widget buildLogoGameStream(){
    return buildText("GAMESTREAM.ONLINE", size: FontSize.VeryLarge);
  }

  Widget buildPageConnectionStatus(String message) =>
      buildFullScreen(
        child: buildText(message, color: GameIsometricColors.white80, align: TextAlign.center),
      );

  Widget buildLoadingPage() =>
      Container(
        color: GameIsometricColors.black,
        alignment: Alignment.center,
        child: buildText("LOADING GAMESTREAM"),
      );

  Widget buildGameTypeImage(GameType gameType) => Image.asset((const {
      GameType.Fight2D: 'images/website/game-fight2d.png',
      GameType.Combat: 'images/website/game-isometric.png',
      GameType.Capture_The_Flag: 'images/website/game-isometric.png',
    }[gameType] ?? ''), fit: BoxFit.fitWidth,);

  @override
  Widget buildSelectRegionColumn() {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildText("Select Your Region", size: FontSize.Large),
          height16,
          WatchBuilder(gamestream.network.region, (activeRegion) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: (engine.isLocalHost ? ConnectionRegion.values : const [
                  ConnectionRegion.America_North,
                  ConnectionRegion.America_South,
                  ConnectionRegion.Asia_North,
                  ConnectionRegion.Asia_South,
                  ConnectionRegion.Europe,
                  ConnectionRegion.Oceania,
                ])
                    .map((ConnectionRegion region) =>
                    onPressed(
                      action: () {
                        gamestream.network.region.value = region;
                        gamestream.games.website.websitePage.value = WebsitePage.Games;
                      },
                      child: MouseOver(builder: (bool mouseOver) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: activeRegion == region ? Colors.greenAccent : mouseOver ? Colors.green : Colors.white10,
                          child: buildText(
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
          }),
        ],
      ),
    );
  }

  Widget buildErrorDialog(String message, {Widget? bottomRight}) => dialog(
        width: style.dialogWidthMedium,
        height: style.dialogHeightVerySmall,
        color: GameIsometricColors.brownDark,
        borderColor: GameIsometricColors.none,
        child: buildLayout(
            child: Center(
              child: buildText(message, color: GameIsometricColors.white),
            ),
            bottomRight: bottomRight ?? buildText("okay", onPressed: () => gamestream.games.website.error.value = null)
        )
    );
}