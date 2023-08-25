
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/packages/lemon_websocket_client.dart';
import 'package:gamestream_flutter/website/enums/website_page.dart';
import 'package:gamestream_flutter/website/website_game.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:golden_ratio/constants.dart';

extension WebsiteUI on WebsiteGame {

  Widget buildRowSelectGame() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: gameTypes.map((gameType) => onPressed(
        action: () => action.startGameType(gameType),
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
          .toList());

  Widget buildPageWebsiteDesktop() => Center(
      child: WatchBuilder(websitePage, (websitePage){
        if (websitePage == WebsitePage.Region){
          return buildSelectRegionColumn();
        }
        return WatchBuilder(options.region, (ConnectionRegion? region) {
          if (region == null) return buildSelectRegionColumn();

          final regionButton = onPressed(
            action: showWebsitePageRegion,
            child: Container(
              color: Colors.white12,
              alignment: Alignment.center,
              padding: style.containerPadding,
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
              buildRowSelectGame(),
              buttonDownloadImageTest(),
            ],
          );
        }
        );
      }),
    );

  Widget buttonDownloadImageTest() => onPressed(
    action: downloadImageTest,
    child: buildText('DOWNLOAD IMAGE'),
  );

  void downloadImageTest(){
    final width = 100;
    final height = 150;
    final colors = Uint32List(width * height);

    for (var i = 0; i < colors.length; i++){
       // colors[i] = aRGBToColor(255, 255, 0, 0);
       colors[i] = rgba(r: 255, a: 255);
    }

    final png = writeToPng(
      width: width,
      height: height,
      colors: colors,
    );
    downloadBytes(bytes: png, name: 'test.png');
  }

  Widget buildWatchErrorMessage() =>
      WatchBuilder(website.error, (String? message) {
        if (message == null) return nothing;
        return buildErrorDialog(message);
      });

  Widget buildOperationStatus(OperationStatus operationStatus) =>
      operationStatus != OperationStatus.None
          ? buildFullScreen(child: buildText(operationStatus.name.replaceAll('_', ' ')))
          : buildWatch(network.websocket.connectionStatus, buildConnectionStatus);

  Widget buildConnectionStatus(ConnectionStatus connectionStatus) =>
      switch (connectionStatus) {
        ConnectionStatus.Connected =>
            buildPageConnectionStatus(connectionStatus.name),
        ConnectionStatus.Connecting =>
            buildPageConnectionStatus(connectionStatus.name),
        _ => buildNotConnected()
      };

  Widget buildNotConnected()  => buildWatch(engine.deviceType, buildPageWebsite);

  Widget buildPageWebsite(int deviceType) =>
      deviceType == DeviceType.Computer
          ? buildPageWebsiteDesktop()
          : buildPageWebsiteMobile();

  Widget buildPageWebsiteMobile() =>
      Container(
        width: engine.screen.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildLogoGameStream(),
            height16,
            buildButtonJoinGameType(
              gameType: GameType.Mobile_Aeon,
              gameName: 'AEON',
            ),
          ],
        ),
      );

  Widget buildButtonJoinGameType({required GameType gameType, required String gameName}) => onPressed(
      action: () => network.connectToGame(gameType),
      child: buildText(gameName, size: 26, color: Colors.white70),
    );

  Widget buildLogoGameStream() => buildText('GAMESTREAM.ONLINE', size: FontSize.largeX);

  Widget buildPageConnectionStatus(String message) =>
      buildFullScreen(
        child: buildText(message, color: colors.white80, align: TextAlign.center),
      );

  Widget buildGameTypeImage(GameType gameType) => Image.asset((const {
      GameType.Capture_The_Flag: 'images/website/game-isometric.png',
      GameType.Moba: 'images/website/game-isometric.png',
      GameType.Amulet: 'images/website/game-isometric.png',
    }[gameType] ?? ''), fit: BoxFit.fitWidth,);

  Widget buildSelectRegionColumn() => SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildText('Select Your Region', size: FontSize.large),
          height16,
          WatchBuilder(options.region, (activeRegion) {
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
                        options.region.value = region;
                        website.websitePage.value = WebsitePage.Games;
                      },
                      child: MouseOver(builder: (bool mouseOver) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: activeRegion == region ? Colors.greenAccent : mouseOver ? Colors.green : Colors.white10,
                          child: buildText(
                              '${region.name}',
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

  Widget buildErrorDialog(String message, {Widget? bottomRight}) => buildDialog(
        width: 200,
        height: 200 * goldenRatio_0618,
        color: colors.brownDark,
        borderColor: Colors.transparent,
        child: buildLayout(
            child: Center(
              child: buildText(message, color: colors.white),
            ),
            bottomRight: onPressed(
                action: () => website.error.value = null,
                child: bottomRight ?? buildText('okay'))
        )
    );
}