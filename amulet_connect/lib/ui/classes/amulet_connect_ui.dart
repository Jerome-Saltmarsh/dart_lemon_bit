
import 'package:amulet/classes/amulet_connect.dart';
import 'package:amulet/enums/src.dart';
import 'package:amulet/ui/consts/font_families.dart';
import 'package:amulet/ui/widgets/dialog_create_character_computer.dart';
import 'package:amulet_client/classes/amulet_client.dart';
import 'package:amulet_client/ui/isometric_colors.dart';
import 'package:amulet_client/ui/widgets/loading_page.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_server/json/amulet_field.dart';
import 'package:amulet_server/json/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../classes/connection_websocket.dart';
import '../../functions/get_server_mode_text.dart';
import '../enums/website_dialog.dart';
import '../enums/website_page.dart';
import 'package:lemon_watch/src.dart';


class AmuletConnectUI extends LemonEngine {

  late final AmuletConnect amuletConnect;

  AmuletClient get amuletClient => amuletConnect.amuletClient;

  AmuletConnectUI() : super(
    backgroundColor: Palette.black,
      themeData: ThemeData(
        fontFamily: FontFamilies.VT323_Regular
      ),
  ) {
    amuletConnect = AmuletConnect(AmuletClient(this));
  }

  Widget buildWatchGameRunning(BuildContext context){
    final mainMenu = buildMainMenu(context);
    return buildWatch(
        amuletConnect.gameRunning,
            (gameRunning) => gameRunning ? amuletConnect.amuletClient.buildUI(context) : mainMenu
    );
  }

  @override
  Widget buildLoadingPage(BuildContext context) =>
      LoadingPage(images: amuletConnect.amuletClient.images);

  void setError(String message){
    amuletConnect.error.value = message;
  }

  void showWebsitePageRegion(){
    amuletConnect.websitePage.value = WebsitePage.Select_Region;
  }

  void showWebsitePageGames(){
    amuletConnect.websitePage.value = WebsitePage.Select_Character;
  }

  void connectToCustomGame(String customGame){
    _log('connectToCustomGame');
  }

  void _log(String value){
    print('website.actions.$value()');
  }

  void showDialogChangeRegion(){
    amuletConnect.dialog.value = WebsiteDialog.Change_Region;
  }

  void showDialogSubscription(){
    amuletConnect.dialog.value = WebsiteDialog.Account;
  }

  void showDialogLogin(){
    amuletConnect.dialog.value = WebsiteDialog.Login;
  }

  void showDialogGames(){
    amuletConnect.dialog.value = WebsiteDialog.Games;
  }

  void closeErrorMessage(){
    amuletConnect.error.value = null;
  }

  void checkForLatestVersion() async {
    amuletConnect.operationStatus.value = OperationStatus.Checking_For_Updates;
  }

  void showPageNewCharacter() => amuletConnect.websitePage.value = WebsitePage.New_Character;

  Widget buildMainMenu(BuildContext context) {
    return WatchBuilder(amuletConnect.serverMode, (ServerMode serverMode) {
    final page = WatchBuilder(
        amuletConnect.websitePage,
            (websitePage) => switch (websitePage) {
          WebsitePage.Select_Character =>
              buildPageSelectCharacter(serverMode),
          WebsitePage.New_Character => buildPageNewCharacter(context),
          WebsitePage.Select_Region => throw Exception(),
        });


    final body = maximize(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(child: page),
          Positioned(top: 0, left: 0, child: buildError(context))
        ],
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AMULET',
      home: Scaffold(
        backgroundColor: Palette.black,
        body: body,
      ),
    );
  });
  }

  Widget buildError(BuildContext context) => buildWatch(amuletConnect.error, (error) {
    if (error == null) return nothing;
    const width = 300.0;
    return maximize(
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
                  action: amuletConnect.clearError,
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

  Widget buildPageSelectCharacter(ServerMode serverMode) => maximize(
    child: Stack(
                alignment: Alignment.center,
                children: [
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
                          buildWatch(amuletConnect.connection, (connection) {

                            if (connection == null){
                              return buildPageSelectConnection();
                            }

                            return buildWatch(amuletConnect.characters, buildTableCharacters);
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
  );

  Stack buildPageNewCharacter(BuildContext context) {
    return Stack(
          alignment: Alignment.center,
          children: [
            DialogCreateCharacterComputer(
              app: this,
              onCreated: amuletConnect.onNewCharacterCreated,
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
    action: amuletConnect.exitApplication,
    child: buildText('EXIT'),
  );

  Widget buildPageSelectConnection() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
      children: [
        onPressed(
            action: amuletConnect.setConnectionSinglePlayer,
            child: buildText('Singleplayer')),
        width32,
        buildText('Multiplayer', color: Colors.white38),
      ],
    );

  Widget buildTogglePlayMode() => WatchBuilder(
      amuletConnect.serverMode,
      (activeServerMode) => Container(
            width: 500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...ServerMode.values.map((serverMode) {
                  return onPressed(
                    action: () => this.amuletConnect.serverMode.value = serverMode,
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

  Widget buildCharacters(List<CharacterJson> characters) =>
      Container(
        height: 200,
        child: SingleChildScrollView(
          child: Column(
              children: characters
                  .map((character) {

                final weapon = character.equippedWeapon;
                final helm = character.equippedHelm;
                final armour = character.equippedArmor;
                final shoes = character.equippedShoes;
                final difficulty = Difficulty.values.tryGet(character.tryGetInt(AmuletField.Difficulty)) ?? Difficulty.Normal;
                final uuid = character.getString('uuid');

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildBorder(
                        color: Colors.black26,
                        width: 4,
                        child: Container(
                          width: 400,
                          color: Colors.black12,
                          padding: paddingAll8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              onPressed(
                                action: () => amuletConnect.playCharacter(uuid),
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
                                    width32,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (weapon != null)
                                        amuletClient.amuletUI.buildCardSmallAmuletItemObject(weapon),
                                        if (helm != null)
                                        amuletClient.amuletUI.buildCardSmallAmuletItemObject(helm),
                                        if (armour != null)
                                        amuletClient.amuletUI.buildCardSmallAmuletItemObject(armour),
                                        if (shoes != null)
                                        amuletClient.amuletUI.buildCardSmallAmuletItemObject(shoes),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              if (characterIsLocked(character))
                                buildText('LOCKED', color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                      width16,
                      onPressed(
                        action: () => showDialogDeleteCharacter(character),
                        child: Container(
                            padding: paddingAll8,
                            color: Colors.white12,
                            child: buildText('delete')),
                      ),
                    ],
                  ),
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

  Widget buildTableCharacters(List<Json> characters) => Container(
    width: 500,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildButtonNewCharacter(),
        height8,
        buildCharacters(characters),
      ],
    ),
  );

  Widget buildButtonNewCharacter() => onPressed(
        action: showPageNewCharacter,
        child: buildBorder(
          color: Colors.black26,
          width: 3,
          child: Container(
              color: Colors.black12,
              alignment: Alignment.center,
              padding: paddingAll8,
              child: buildText('NEW CHARACTER', color: Colors.orange)),
        ),
      );

  Widget buildControlUser(ConnectionWebsocket serverRemote) => onPressed(
    action: serverRemote.logout,
    hint: 'LOGOUT',
    child: Container(
        height: 30,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: buildWatch(serverRemote.username, buildText)),

  );

  void showDialogDeleteCharacter(Json character, {Function? onDeleted}) {
    amuletClient.ui.showDialogGetBool(
        text: 'Are you sure you want to delete ${character['name']}?',
        textFalse: 'Cancel',
        textTrue: 'CONFIRM',
        onSelected: (bool value) async {
          if (value){
            await amuletConnect.deleteCharacter(character.uuid);
            onDeleted?.call();
          }
        });
  }

  void showPageSelectCharacter() => amuletConnect.websitePage.value = WebsitePage.Select_Character;

  @override
  Widget buildUI(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        buildWatchGameRunning(context),
        buildWatch(amuletClient.ui.dialog, (dialog) {
          if (dialog == null) return nothing;
          return maximize(
            color: Colors.black26,
          );
        }),
        buildWatch(amuletClient.ui.dialog, (dialog) {
          if (dialog == null) return nothing;
          return dialog;
        })
      ],
    );
  }

  @override
  void onDispose() {
    // return amuletClient.onDisp(canvas, size);
  }

  @override
  void onDrawCanvas(Canvas canvas, Size size) {
    if (!amuletConnect.gameRunning.value) return;
    return amuletClient.onDrawCanvas(canvas, size);
  }

  @override
  Future onInit(SharedPreferences sharedPreferences) {
    return amuletClient.onInit(sharedPreferences);
  }

  @override
  void onUpdate(double delta) {
    if (!gameRunning) return;
    amuletConnect.amuletClient.onUpdate(delta);
  }

  @override
  void onKeyPressed(PhysicalKeyboardKey keyCode) {
    if (!gameRunning) return;
    amuletClient.onKeyPressed(keyCode);
  }

  @override
  void onLeftClicked() {
    if (!gameRunning) return;
    amuletClient.onLeftClicked();
  }

  @override
  void onRightClicked() {
    if (!gameRunning) return;
    amuletClient.onRightClicked();
  }

  bool get gameRunning => amuletConnect.gameRunning.value;
}