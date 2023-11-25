import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/common/src/duration_auto_save.dart';
import 'package:gamestream_flutter/packages/common/src/game_type.dart';
import 'package:gamestream_flutter/packages/lemon_websocket_client.dart';
import 'package:gamestream_flutter/types/server_mode.dart';
import 'package:gamestream_flutter/website/enums/website_page.dart';
import 'package:gamestream_flutter/website/functions/build_website_page_select_region.dart';
import 'package:gamestream_flutter/website/website_game.dart';
import 'package:gamestream_flutter/website/widgets/gs_button_region.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:typedef/json.dart';

import 'functions/build_website_page_new_user.dart';
import 'widgets/dialog_create_character_computer.dart';

extension WebsiteUI on WebsiteGame {

  Widget buildPageWebsiteDesktop() =>
      buildWatchPlayMode();

  Widget buildWatchPlayMode() =>
      WatchBuilder(
      options.serverMode,
      (ServerMode playMode) => playMode == ServerMode.local
          ? buildGameModeSinglePlayer()
          : buildGameModeMultiPlayer());

  Widget buildGameModeSinglePlayer(){
    return Column(
      children: [
        buildTogglePlayMode(),
        onPressed(
          action: options.localServer.playerJoin,
          child: buildText('NEW CHARACTER'),
        ),
      ],
    );
  }

  Widget buildTogglePlayMode() {
    return WatchBuilder(options.serverMode, (activePlayMode) {
      return Row(
        children: ServerMode.values.map((playMode) {
          return onPressed(
            action: () => options.serverMode.value = playMode,
            child: Container(
              alignment: Alignment.center,
              width: 80,
              height: 50,
              color: activePlayMode == playMode ? Colors.green : Colors.green.withOpacity(0.5),
              child: buildText(
                  playMode.name,
              ),
            ),
          );
        }).toList(growable: false),
      );
    });
  }

  Widget buildGameModeMultiPlayer(){
    return WatchBuilder(websitePage, (websitePage) =>
    switch (websitePage) {
      WebsitePage.User => buildWebsitePageUser(),
      WebsitePage.New_Character => DialogCreateCharacterComputer(),
      WebsitePage.Select_Region =>
          buildWebsitePageSelectRegion(
            options: options,
            website: website,
            engine: engine,
          ),
    });
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

  Widget buildOperationStatus(OperationStatus operationStatus) =>
      operationStatus != OperationStatus.None
          ? buildFullScreen(child: buildText(operationStatus.name.replaceAll('_', ' ')))
          : buildWatch(options.websocket.connectionStatus, buildConnectionStatus);

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

  Widget buildWebsitePageUser() {
    return WatchBuilder(options.region, (ConnectionRegion? region) {

      if (region == null) {
        this.websitePage.value = WebsitePage.Select_Region;
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildTogglePlayMode(),
          buildText('AMULET', size: 80, family: 'REBUFFED'),
          height32,
          buildContainerAuthentication(),
        ],
      );
    }
    );
  }

  Widget buildContainerAuthentication(){
    return buildWatch(user.userId, (userId) {
        final authenticated = userId.isNotEmpty;
        if (authenticated) {
          return buildContainerAuthenticated();
        }
        return buildContainerAuthenticate(user);
    });
  }

  Widget buildContainerAuthenticated() =>
      GSContainer(
        width: 400,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GSButtonRegion(),
                Container(
                  padding: style.containerPadding,
                    color: Colors.white12,
                    child: buildControlUser(),
                ),
              ],
            ),
            height12,
            buildContainerCharacters(),
          ],
        ),
      );

  Widget buildCharacters(List<Json> characters) =>
      Container(
      height: 200,
      child: SingleChildScrollView(
        child: Column(
            children: characters
                .map((character) {

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  onPressed(
                    action: () =>
                        user.playCharacter(character['uuid']),
                    child: Container(
                        alignment: Alignment.center,
                        width: 200,
                        color: Colors.white12,
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildText(character['name'], size: 22),
                            buildText('lvl ${character['level']}', size: 22, color: Colors.white70),
                          ],
                        )),
                  ),
                  if (characterIsLocked(character))
                    buildText('LOCKED', color: Colors.red),
                  onPressed(
                      action: () => showDialogDeleteCharacter(character),
                      child: buildText('delete'),
                  ),
                ],
              );
            })
                .toList(growable: false)),
      ),
    );

  bool characterIsLocked(Json character){
     final lockDateString = character.tryGetString('lock_date');
     if (lockDateString == null){
       return false;
     }
     final lockDate = DateTime.parse(lockDateString);
     final lockDuration = DateTime.now().toUtc().difference(lockDate);
     return lockDuration.inSeconds <= durationAutoSave.inSeconds;
  }

  Widget buildContainerCharacters() => GSContainer(
    color: Colors.transparent,
    child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildText('CHARACTERS', size: 22, color: Colors.white70),
              // width8,
              // Tooltip(
              //   message: 'Refresh',
              //   child: onPressed(
              //     action: user.refreshUser,
              //     child: IsometricIcon(iconType: IconType.Turn_Right, scale: 0.15,),
              //   ),
              // ),
              width16,
              buildBorder(
                color: Colors.orange,
                child: onPressed(
                  action: user.website.showPageNewCharacter,
                  child: Container(
                      padding: const EdgeInsets.all(4),
                      child: buildText('CREATE NEW', color: Colors.orange)),
                ),
              ),
            ],
          ),
          height12,
          buildWatch(
              user.characters,
              buildCharacters
          ),
        ],
      ),
  );

  Widget buildControlUser() => Row(
    children: [
      buildWatch(user.username, buildText),
      width8,
      buildBorder(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(4),
          child: onPressed(
            action: user.logout,
            child: buildText('Logout'),
          ),
        ),
      ),
    ],
  );

  void showDialogDeleteCharacter(Json character) {
    ui.showDialogGetBool(
        text: 'Are you sure you want to delete ${character['name']}?',
        textFalse: 'Cancel',
        textTrue: 'CONFIRM',
        onSelected: (bool value) async {
          if (value){
            user.deleteCharacter(character['uuid']);
          }
        });
  }

}



