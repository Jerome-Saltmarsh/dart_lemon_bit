import 'package:amulet_engine/json/character_json.dart';
import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/gamestream/isometric/components/functions/get_server_mode_text.dart';
import 'package:amulet_flutter/gamestream/operation_status.dart';
import 'package:amulet_flutter/gamestream/ui/src.dart';
import 'package:amulet_flutter/packages/lemon_websocket_client.dart';
import 'package:amulet_flutter/server/src.dart';
import 'package:amulet_flutter/types/server_mode.dart';
import 'package:amulet_flutter/website/enums/website_page.dart';
import 'package:amulet_flutter/website/functions/build_website_page_select_region.dart';
import 'package:amulet_flutter/website/website_game.dart';
import 'package:amulet_flutter/website/widgets/gs_button_region.dart';
import 'package:amulet_flutter/website/widgets/src.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:typedef/json.dart';

import 'functions/build_website_page_new_user.dart';
import 'widgets/dialog_create_character_computer.dart';

extension WebsiteUI on WebsiteGame {

  Widget buildPageWebsiteDesktop(BuildContext context) =>
      WatchBuilder(options.serverMode, (ServerMode serverMode) {

        final page = WatchBuilder(websitePage, (websitePage) =>
            switch (websitePage) {
              WebsitePage.Select_Character =>
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 8,
                        right: 8,
                        child: onPressed(
                          action: engine.window.close,
                          child: buildText('EXIT'),
                        ),
                      ),
                      Positioned(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buildText('AMULET', size: 120),
                            height32,
                            buildTogglePlayMode(),
                            if (serverMode == ServerMode.local)
                              buildState(builder: (context, rebuild) =>
                                  buildTableCharacters(
                                    server.local.getCharacters(),
                                    rebuild,
                                  )
                              ),
                            if (serverMode == ServerMode.remote)
                              buildWatch(server.remote.userId, (userId) {
                                final authenticated = userId.isNotEmpty;
                                if (authenticated) {
                                  return buildContainerAuthenticated(server.remote);
                                }
                                return buildContainerAuthenticate(this, server.remote);
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
              WebsitePage.New_Character => Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: onPressed (
                      action: showPageSelectCharacter,
                      child: buildText('<- BACK'),
                    ),
                  ),
                  DialogCreateCharacterComputer(
                    createCharacter: server.activeServer.createNewCharacter,
                    onCreated: showPageSelectCharacter,
                  ),
                ],
              ),
              WebsitePage.Select_Region => buildWebsitePageSelectRegion(
                options: options,
                website: website,
                engine: engine,
              ),
            });

        if (serverMode == ServerMode.remote){
          return buildWatch(server.remote.operationStatus, (operationStatus){
            return operationStatus != OperationStatus.None
              ? buildFullScreen(child: buildText(operationStatus.name.replaceAll('_', ' ')))
              : buildWatch(server.remote.websocket.connectionStatus, (connectionStatus){
                return switch (connectionStatus) {
                  ConnectionStatus.Connected =>
                      buildPageConnectionStatus(connectionStatus.name),
                  ConnectionStatus.Connecting =>
                      buildPageConnectionStatus(connectionStatus.name),
                  _ => page
                };
            });
          });
        }

        return page;
      });



  Widget buildPageSelectServerMode() => Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: ServerMode.values.map((serverMode) {
         const width = 130.0;
         return onPressed(
             action: () => options.serverMode.value = serverMode,
             child: Container(
               margin: const EdgeInsets.symmetric(horizontal: 8),
               color: Colors.white30,
               width: width,
               height: width * goldenRatio_0618,
               alignment: Alignment.center,
               child: buildText(getServerModeText(serverMode))));
       }).toList(growable: false),
     );

  Widget buildTogglePlayMode() {
    return WatchBuilder(options.serverMode, (activePlayMode) {
      return Container(
        width: 500,
        color: Colors.black26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ServerMode.values.map((serverMode) {
            return onPressed(
              action: () => options.serverMode.value = serverMode,
              child: Container(
                alignment: Alignment.center,
                width: 80,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: activePlayMode == serverMode ? Colors.green : Colors.green.withOpacity(0.25),
                child: buildText(
                    getServerModeText(serverMode),
                    color: activePlayMode == serverMode ? Colors.white : Colors.white60
                  ),
              ),
            );
          }).toList(growable: false),
        ),
      );
    });
  }

  Widget buildPageConnectionStatus(String message) =>
      buildFullScreen(
        child: buildText(message, color: colors.white80, align: TextAlign.center),
      );

  Widget buildGameTypeImage(GameType gameType) => Image.asset((const {
      GameType.Capture_The_Flag: 'images/website/game-isometric.png',
      GameType.Moba: 'images/website/game-isometric.png',
      GameType.Amulet: 'images/website/game-isometric.png',
    }[gameType] ?? ''), fit: BoxFit.fitWidth,);

  Widget buildContainerAuthenticated(ServerRemote serverRemote) =>
      Column(
        children: [
          buildWatch(serverRemote.characters, (characters) =>
              buildTableCharacters(characters, (){})
          ),
          height12,
          GSContainer(
            width: 500,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GSButtonRegion(),
                Container(
                  padding: style.containerPadding,
                    color: Colors.white12,
                    child: buildControlUser(serverRemote),
                ),
              ],
            ),
          ),
        ],
      );

  Widget buildCharacters(List<Json> characters, Function rebuild) =>
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
                    action: () => server.playCharacter(character),
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
                      action: () => showDialogDeleteCharacter(character, onDeleted: rebuild),
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

  Widget buildTableCharacters(List<Json> characters, Function rebuild) => GSContainer(
    color: Colors.black12,
    width: 500,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // buildText('CHARACTERS', size: 22, color: Colors.white70),
              // width16,
              onPressed(
                action: showPageNewCharacter,
                child: Container(
                    color: Colors.white12,
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(4),
                    child: buildText('NEW CHARACTER', color: Colors.orange)),
              ),
            ],
          ),
          buildCharacters(characters, rebuild),
        ],
      ),
  );

  Widget buildControlUser(ServerRemote serverRemote) => Row(
    children: [
      buildWatch(serverRemote.username, buildText),
      width8,
      buildBorder(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(4),
          child: onPressed(
            action: serverRemote.logout,
            child: buildText('Logout'),
          ),
        ),
      ),
    ],
  );

  void showDialogDeleteCharacter(Json character, {Function? onDeleted}) {
    ui.showDialogGetBool(
        text: 'Are you sure you want to delete ${character['name']}?',
        textFalse: 'Cancel',
        textTrue: 'CONFIRM',
        onSelected: (bool value) async {
          if (value){
            await server.deleteCharacter(character.uuid);
            onDeleted?.call();
          }
        });
  }

  void showPageSelectCharacter()=> websitePage.value = WebsitePage.Select_Character;
}



