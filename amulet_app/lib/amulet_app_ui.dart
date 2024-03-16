
import 'package:amulet_app/amulet_app.dart';
import 'package:amulet_app/enums/src.dart';
import 'package:amulet_app/ui/widgets/dialog_create_character_computer.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_engine/json/amulet_field.dart';
import 'package:amulet_engine/json/src.dart';
import 'package:amulet_flutter/isometric/src.dart';
import 'package:flutter/material.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'classes/connection_remote.dart';
import 'functions/get_server_mode_text.dart';
import 'ui/enums/website_dialog.dart';
import 'ui/enums/website_page.dart';
import 'package:lemon_watch/src.dart';

class AmuletAppUI extends StatelessWidget {

  final AmuletApp amuletApp;

  const AmuletAppUI({super.key, required this.amuletApp});

  @override
  Widget build(BuildContext context) =>
      MaterialApp(
        title: 'AMULET',
        home: Scaffold(
          body: buildPageWebsiteDesktop(context),
        ),
    );


  onChangedVisitCount(int value){
    print('visit-count: $value');
  }

  String formatDate(DateTime value){
    return amuletApp.dateFormat.format(value.toLocal());
  }

  void setError(String message){
    amuletApp.error.value = message;
  }

  void showWebsitePageRegion(){
    amuletApp.websitePage.value = WebsitePage.Select_Region;
  }

  void showWebsitePageGames(){
    amuletApp.websitePage.value = WebsitePage.Select_Character;
  }
  //
  // void openUrlYoutube() =>
  //     launchUrl(Uri.parse('https://www.youtube.com/@gamestream.online'));
  //
  // void openUrlDiscord() =>
  //     launchUrl(Uri.parse('https://discord.com/channels/888728235653885962/888728235653885965'));


  void connectToCustomGame(String customGame){
    _log('connectToCustomGame');
  }

  void _log(String value){
    print('website.actions.$value()');
  }

  void showDialogChangeRegion(){
    amuletApp.dialog.value = WebsiteDialog.Change_Region;
  }

  void showDialogSubscription(){
    amuletApp.dialog.value = WebsiteDialog.Account;
  }

  void showDialogLogin(){
    amuletApp.dialog.value = WebsiteDialog.Login;
  }

  void showDialogGames(){
    amuletApp.dialog.value = WebsiteDialog.Games;
  }

  void closeErrorMessage(){
    amuletApp.error.value = null;
  }

  void checkForLatestVersion() async {
    // await saveVisitDateTime();
    amuletApp.operationStatus.value = OperationStatus.Checking_For_Updates;
    // engine.refreshPage();
  }

  void showPageNewCharacter() => amuletApp.websitePage.value = WebsitePage.New_Character;

  Widget buildPageWebsiteDesktop(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/library_hero.png'), // Replace with your image path
          fit: BoxFit.cover, // Adjust the fit as per your requirement
        ),
      ),
      child: WatchBuilder(amuletApp.serverMode, (ServerMode serverMode) {

        final page = WatchBuilder(amuletApp.websitePage, (websitePage) =>
        switch (websitePage) {
          WebsitePage.Select_Character =>
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: onPressed(
                      // action: engine.window.close,
                      child: buildText('EXIT'),
                    ),
                  ),
                  Positioned(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // buildText('AMULET', size: 120),
                        Image.asset('assets/images/main_header.png'),
                        height32,
                        // if (options.developMode)
                        //   buildTogglePlayMode(),
                        if (serverMode == ServerMode.local)
                          buildWatch(amuletApp.connection, (connection) {

                            if (connection == null){
                              return buildText('connection required');
                            }

                            return FutureBuilder(
                              future: connection.getCharacters(),
                              builder: (context, snapshot) {
                                final data = snapshot.data;
                                if (data == null) {
                                  return buildText('loading');
                                }

                                return buildTableCharacters(
                                  data,
                                      (){}, // TODO
                                );
                              },
                            );
                          }),

                        // if (serverMode == ServerMode.remote)
                        // buildWatch(server.remote.userId, (userId) {
                        //   final authenticated = userId.isNotEmpty;
                        //   if (authenticated) {
                        //     return buildContainerAuthenticated(server.remote);
                        //   }
                        //   return buildContainerAuthenticate(this, server.remote);
                        // }),
                      ],
                    ),
                  ),
                ],
              ),
          WebsitePage.New_Character => Stack(
            alignment: Alignment.center,
            children: [
              DialogCreateCharacterComputer(
                app: this,
                createCharacter: amuletApp.connection.value?.createNewCharacter ?? (throw Exception()),
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
          WebsitePage.Select_Region => throw Exception(),
        });

        // if (serverMode == ServerMode.remote){
        //   return buildWatch(operationStatus, (operationStatus){
        //     return operationStatus != OperationStatus.None
        //       ? buildFullScreen(child: buildText(operationStatus.name.replaceAll('_', ' ')))
        //       : buildWatch(server.remote.websocket.connectionStatus, (connectionStatus){
        //         return switch (connectionStatus) {
        //           ConnectionStatus.Connected =>
        //               buildPageConnectionStatus(connectionStatus.name),
        //           ConnectionStatus.Connecting =>
        //               buildPageConnectionStatus(connectionStatus.name),
        //           _ => page
        //         };
        //     });
        //   });
        // }

        return page;
      }),
    );
  }

  Widget buildTogglePlayMode() {
    return WatchBuilder(amuletApp.serverMode, (activeServerMode) {
      return Container(
        width: 500,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [...ServerMode.values.map((serverMode) {
            return onPressed(
              action: () => this.amuletApp.serverMode.value = serverMode,
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
        // GSButtonRegion(
        //   region: server.remote.region,
        //   action: website.showWebsitePageRegion,
        // ),
        // width4,
        // Container(
        //   color: Colors.white12,
        //   child: buildControlUser(server.remote),
        // ),
      ],
    );
  }

  Widget buildPageConnectionStatus(String message) =>
      Container(
        child: buildText(message, color: Colors.white70, align: TextAlign.center),
      );

  // Widget buildGameTypeImage(GameType gameType) => Image.asset((const {
  //   GameType.Capture_The_Flag: 'images/website/game-isometric.png',
  //   GameType.Moba: 'images/website/game-isometric.png',
  //   GameType.Amulet: 'images/website/game-isometric.png',
  // }[gameType] ?? ''), fit: BoxFit.fitWidth,);

  // Widget buildContainerAuthenticated(ServerRemote serverRemote) =>
  //     buildWatch(serverRemote.characters, (characters) =>
  //         buildTableCharacters(characters, (){})
  //     );

  Widget buildCharacters(List<CharacterJson> characters, Function rebuild) =>
      Container(
        height: 200,
        child: SingleChildScrollView(
          child: Column(
              children: characters
                  .map((character) {

                final weapon = character.equippedWeapon?.amuletItem;
                final helm = character.equippedHelm?.amuletItem;
                final armour = character.equippedArmor?.amuletItem;
                final shoes = character.equippedShoes?.amuletItem;
                final difficulty = Difficulty.values.tryGet(character.tryGetInt(AmuletField.Difficulty)) ?? Difficulty.Normal;
                final uuid = character.getString('uuid');

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    onPressed(
                      action: () => amuletApp.connection.value?.playCharacter(uuid),
                      child: Container(
                          alignment: Alignment.center,
                          width: 360,
                          color: Colors.white12,
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildText(character['name'], size: 22),
                                  buildText(difficulty.name),
                                ],
                              ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     buildContainerAmuletItem(amuletItem: weapon),
                              //     buildContainerAmuletItem(amuletItem: helm),
                              //     buildContainerAmuletItem(amuletItem: armour),
                              //     buildContainerAmuletItem(amuletItem: shoes),
                              //   ],
                              // )
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

  // Widget buildContainerAmuletItem({AmuletItem? amuletItem})=> Container(
  //   width: 36,
  //   height: 36,
  //   color: Colors.black26,
  //   alignment: Alignment.center,
  //   margin: const EdgeInsets.only(right: 4),
  //   child: amuletItem != null ? AmuletItemImage(amuletItem: amuletItem, scale: 1.0) : null,
  // );

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

  Widget buildControlUser(ConnectionRemote serverRemote) => onPressed(
    action: serverRemote.logout,
    hint: 'LOGOUT',
    child: Container(
        height: 30,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: buildWatch(serverRemote.username, buildText)),

  );

  void showDialogDeleteCharacter(Json character, {Function? onDeleted}) {
    // ui.showDialogGetBool(
    //     text: 'Are you sure you want to delete ${character['name']}?',
    //     textFalse: 'Cancel',
    //     textTrue: 'CONFIRM',
    //     onSelected: (bool value) async {
    //       if (value){
    //         await server.deleteCharacter(character.uuid);
    //         onDeleted?.call();
    //       }
    //     });
  }

  void showPageSelectCharacter() => amuletApp.websitePage.value = WebsitePage.Select_Character;
}