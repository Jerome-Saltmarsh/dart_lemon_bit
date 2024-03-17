
import 'package:amulet_app/classes/amulet_app.dart';
import 'package:amulet_app/enums/src.dart';
import 'package:amulet_app/ui/widgets/dialog_create_character_computer.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_engine/json/amulet_field.dart';
import 'package:amulet_engine/json/src.dart';
import 'package:amulet_flutter/isometric/src.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../../classes/connection_remote.dart';
import '../../functions/get_server_mode_text.dart';
import '../enums/website_dialog.dart';
import '../enums/website_page.dart';
import 'package:lemon_watch/src.dart';


class AmuletAppBuilder extends StatelessWidget {

  final AmuletApp amuletApp;

  AmuletAppBuilder({super.key, required this.amuletApp});

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AMULET',
        home: Scaffold(
          body: buildScaffoldBody(context),
        ),
    );
  }

  void onChangedVisitCount(int value){
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
    amuletApp.operationStatus.value = OperationStatus.Checking_For_Updates;
  }

  void showPageNewCharacter() => amuletApp.websitePage.value = WebsitePage.New_Character;

  Widget buildScaffoldBody(BuildContext context) {
    final mainMenu = buildMainMenu(context);
    return buildWatch(amuletApp.gameRunning, (gameRunning) =>
      gameRunning ? amuletApp.amuletClient : mainMenu);
  }

  WatchBuilder<ServerMode> buildMainMenu(BuildContext context) {
    return WatchBuilder(amuletApp.serverMode, (ServerMode serverMode) {
    final page = WatchBuilder(
        amuletApp.websitePage,
            (websitePage) => switch (websitePage) {
          WebsitePage.Select_Character =>
              buildPageSelectCharacter(serverMode),
          WebsitePage.New_Character => buildPageNewCharacter(context),
          WebsitePage.Select_Region => throw Exception(),
        });

    return Stack(
      children: [
        Positioned(child: page),
        Positioned(top: 0, left: 0, child: buildError(context))
      ],
    );
  });
  }

  Widget buildError(BuildContext context) => buildWatch(amuletApp.error, (error) {
    if (error == null) return nothing;
    const width = 300.0;
    return maximize(
      context: context,
      alignment: Alignment.center,
      color: Colors.black26,
      child: Container(
        width: width,
        height: width * goldenRatio_0618,
        color: Palette.brown_4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(child: buildText(error)),
            Positioned(
                bottom: 8,
                right: 8,
                child: onPressed(
                  action: amuletApp.clearError,
                  child: Container(
                    color: Colors.white12,
                      padding: const EdgeInsets.all(8),
                      child: buildText('Okay')),
                )),
          ],
        ),
      ),
    );

  });

  Stack buildPageSelectCharacter(ServerMode serverMode) {
    return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(child: amuletApp.amuletClient),
                Positioned(
                  top: 8,
                  right: 8,
                  child: buildButtonExit(),
                ),
                Positioned(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildImageMainHeader(),
                      height32,
                      if (serverMode == ServerMode.local)
                        buildWatch(amuletApp.connection, (connection) {

                          if (connection == null){
                            return buildPageSelectConnection();
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
            );
  }

  Stack buildPageNewCharacter(BuildContext context) {
    return Stack(
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
            ),
          ],
        );
  }

  Image buildImageMainHeader() => Image.asset('assets/images/main_header.png');

  Widget buildButtonExit() => onPressed(
        child: buildText('EXIT'),
      );

  Widget buildPageSelectConnection() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
      children: [
        onPressed(
            action: amuletApp.setConnectionSinglePlayer,
            child: buildText('Singleplayer')),
        width32,
        buildText('Multiplayer', color: Colors.white38),
      ],
    );

  Widget buildTogglePlayMode() => WatchBuilder(
      amuletApp.serverMode,
      (activeServerMode) => Container(
            width: 500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...ServerMode.values.map((serverMode) {
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
                if (activeServerMode == ServerMode.remote) buildOnlineRow(),
              ],
            ),
          ));

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
                      action: () => amuletApp.playCharacter(uuid),
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