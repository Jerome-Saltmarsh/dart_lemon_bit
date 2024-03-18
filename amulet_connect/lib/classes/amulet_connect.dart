
import 'package:amulet/classes/connection_embedded.dart';
import 'package:amulet/enums/src.dart';
import 'package:amulet_client/classes/amulet_client.dart';
import 'package:amulet_client/isometric/classes/connection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lemon_watch/src.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

import '../ui/enums/website_dialog.dart';
import '../ui/enums/website_page.dart';

class AmuletConnect {
  final websitePage = Watch(WebsitePage.Select_Character);
  final signInSuggestionVisible = Watch(false);
  final dialog = Watch(WebsiteDialog.Games);
  final customConnectionStrongController = TextEditingController();
  final isVisibleDialogCustomRegion = Watch(false);
  final colorRegion = Colors.orange;
  final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
  final errorMessageEnabled = Watch(true);
  final serverMode = Watch(ServerMode.local);
  final operationStatus = Watch(OperationStatus.None);
  final connectionRegion = Watch<ConnectionRegion?>(null);
  final connection = Watch<Connection?>(null);
  final error = Watch<dynamic>(null);
  final gameRunning = WatchBool(false);
  final AmuletClient amuletClient;

  AmuletConnect(this.amuletClient);


  void onConnectionLost() {
    gameRunning.value = false;
  }

  void setConnectionSinglePlayer() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      connection.value = ConnectionEmbedded(
        onDisconnect: onConnectionLost,
        parser: amuletClient.components.responseReader,
        clientPlayer: amuletClient.components.player,
        sharedPreferences: sharedPreferences,
        clientAmulet: amuletClient,
      );
    });
  }

  void playCharacter(String uuid){
    final connection = this.connection.value;
    if (connection == null) {
      showError('connection required');
      return;
    }
    try {
      connection.playCharacter(uuid);
      gameRunning.value = true;
    } catch(error) {
      showError(error.toString());
      gameRunning.value = false;
    }
  }

  void showError(String message) => error.value = message;

  void clearError() => error.value = null;

  Future initialize() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await amuletClient.onInit(sharedPreferences);
  }

  void exitApplication() => exit(0);
}