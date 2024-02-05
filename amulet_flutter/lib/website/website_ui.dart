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
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:typedef/json.dart';

import '../amulet/src.dart';
import 'functions/build_website_page_new_user.dart';
import 'widgets/dialog_create_character_computer.dart';

extension WebsiteUI on WebsiteGame {

  Widget buildPageWebsiteDesktop(BuildContext context) {
    return WatchBuilder(options.serverMode, (ServerMode serverMode) {

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
                            // buildTogglePlayMode(),
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
                  DialogCreateCharacterComputer(
                    createCharacter: server.activeServer.createNewCharacter,
                    onCreated: showPageSelectCharacter,
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: onPressed(
                      action: showPageSelectCharacter,
                      child: Container(
                          color: Colors.white12,
                          width: 100,
                          height: 30,
                          alignment: Alignment.center,
                          child: buildText('<- BACK')),
                    ),
                  )
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
  }

  Widget buildTogglePlayMode() {
    return WatchBuilder(options.serverMode, (activeServerMode) {
      return Container(
        width: 500,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [...ServerMode.values.map((serverMode) {
              return onPressed(
                action: () => options.serverMode.value = serverMode,
                child: Container(
                  alignment: Alignment.center,
                  width: 80,
                  height: 30,
                  color: activeServerMode == serverMode
                      ? Colors.green
                      : Colors.green.withOpacity(0.25),
                  child: buildText(getServerModeText(serverMode),
                      color: activeServerMode == serverMode
                          ? Colors.white
                          : Colors.white60),
                ),
              );
            }).toList(growable: false),
              if (activeServerMode == ServerMode.remote)
              const Expanded(child: const SizedBox()),
              if (activeServerMode == ServerMode.remote)
                buildOnlineRow(),

          ],
        ),
      );
    });
  }

  Widget buildOnlineRow(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GSButtonRegion(
          region: server.remote.region,
          action: website.showWebsitePageRegion,
        ),
        width4,
        Container(
          color: Colors.white12,
          child: buildControlUser(server.remote),
        ),
      ],
    );
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
      buildWatch(serverRemote.characters, (characters) =>
          buildTableCharacters(characters, (){})
      );

  Widget buildCharacters(List<CharacterJson> characters, Function rebuild) =>
      Container(
      height: 200,
      child: SingleChildScrollView(
        child: Column(
            children: characters
                .map((character) {

                  final weapon = AmuletItem.findByName(character.weapon);
                  final helm = AmuletItem.findByName(character.helm);
                  final armour = AmuletItem.findByName(character.armor);
                  final shoes = AmuletItem.findByName(character.shoes);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  onPressed(
                    action: () => server.playCharacter(character),
                    child: Container(
                        alignment: Alignment.center,
                        width: 360,
                        color: Colors.white12,
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildText(character['name'], size: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              buildContainerAmuletItem(amuletItem: weapon),
                              buildContainerAmuletItem(amuletItem: helm),
                              buildContainerAmuletItem(amuletItem: armour),
                              buildContainerAmuletItem(amuletItem: shoes),
                            ],
                            )
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

  Widget buildContainerAmuletItem({AmuletItem? amuletItem})=> Container(
      width: 36,
      height: 36,
      color: Colors.black26,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(right: 4),
      child: amuletItem != null ? AmuletItemImage(amuletItem: amuletItem, scale: 1.0) : null,
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

  Widget buildControlUser(ServerRemote serverRemote) => onPressed(
    action: serverRemote.logout,
    hint: 'LOGOUT',
    child: Container(
        height: 30,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: buildWatch(serverRemote.username, buildText)),

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

  void showPageSelectCharacter() => websitePage.value = WebsitePage.Select_Character;
}



