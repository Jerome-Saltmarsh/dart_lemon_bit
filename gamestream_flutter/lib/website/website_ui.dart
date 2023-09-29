import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/common/src/game_type.dart';
import 'package:gamestream_flutter/packages/lemon_websocket_client.dart';
import 'package:gamestream_flutter/packages/utils.dart';
import 'package:gamestream_flutter/website/enums/website_page.dart';
import 'package:gamestream_flutter/website/functions/build_website_page_select_region.dart';
import 'package:gamestream_flutter/website/website_game.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'widgets/dialog_create_character_computer.dart';

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
      child: WatchBuilder(websitePage, (websitePage) =>
        switch (websitePage) {
          WebsitePage.Select_Character => buildWebsitePageSelectCharacter(),
          WebsitePage.New_Character => DialogCreateCharacterComputer(
            onStart: createNewCharacter,
          ),
          WebsitePage.Select_Region => buildWebsitePageSelectRegion(
              options: options,
              website: website,
              engine: engine,
            )
        }),
    );

  void createNewCharacter({required int complex}){

  }

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


  Widget buildWebsitePageSelectCharacter() {
    return WatchBuilder(options.region, (ConnectionRegion? region) {

      if (region == null) {
        this.websitePage.value = WebsitePage.Select_Region;
      }

      final regionButton = onPressed(
        action: showWebsitePageRegion,
        child: Container(
          color: Colors.white12,
          alignment: Alignment.center,
          padding: style.containerPadding,
          child: buildText(formatEnumName(region?.name ?? 'region')),
        ),
      );

      return GSContainer(
        width: 400,
        height: 400 * goldenRatio_1381,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            regionButton,
            height32,
            buildWebsitePageSelectCharacter2(),
          ],
        ),
      );
    }
    );
  }

  Widget buildWebsitePageSelectCharacter2() =>
      GSContainer(
        child: Column(
          children: [
            onPressed(
              action: user.refreshCharacterNames,
              child: buildText('CHARACTERS'),
            ),
            onPressed(
              action: user.website.showPageNewCharacter,
              child: buildText('NEW CHARACTER', color: Colors.orange),
            ),
            height12,
            buildWatch(
                user.characters,
                    (characters) => Column(
                    children: characters
                        .map((character) => onPressed(
                      action: () =>
                          user.playCharacter(character['uuid']),
                      child: buildText(character['name']),
                    ))
                        .toList(growable: false))),
          ],
        ),
      );

}

