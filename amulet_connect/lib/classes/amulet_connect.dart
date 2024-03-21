
import 'package:amulet/classes/connection_embedded.dart';
import 'package:amulet/enums/src.dart';
import 'package:amulet/ui/classes/character_profile.dart';
import 'package:amulet_client/classes/amulet_client.dart';
import 'package:amulet_client/interfaces/src.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lemon_json/src.dart';
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
  final characters = Watch<List<Json>>([]);
  final AmuletClient amuletClient;

  AmuletConnect(this.amuletClient) {
    connection.onChanged(onChangedConnection);
  }

  void onChangedConnection(Connection? connection){
    refreshCharacters();
  }

  void onConnectionLost() {
    gameRunning.value = false;
    refreshCharacters();
  }

  Future refreshCharacters() async {
     final connection = this.connection.value;
     if (connection == null){
       characters.value = [];
       return;
     }
     characters.value = await connection.getCharacters();
  }

  void setConnectionSinglePlayer() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      connection.value = ConnectionEmbedded(
        onDisconnect: onConnectionLost,
        parser: amuletClient.responseReader,
        clientPlayer: amuletClient.player,
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

  void onNewCharacterCreated(CharacterProfile characterProfile){
    websitePage.value = WebsitePage.Select_Character;
    final connection = this.connection.value;
    if (connection == null){
      handleError('connection required');
      return;
    }
    connection
       .createNewCharacter(
         name: characterProfile.name,
         complexion: characterProfile.complexion,
         hairColor: characterProfile.hairColor,
         hairType: characterProfile.hairType,
         gender: characterProfile.gender,
         difficulty: characterProfile.difficulty,
         headType: characterProfile.headType,
       )
      .then(playCharacter)
      .catchError(handleError);

    refreshCharacters();
  }

  void handleError(dynamic value) => error.value = value;

  Future deleteCharacter(String uuid) async {
    final connection = this.connection.value;
    if (connection == null){
      handleError('connection required');
      return;
    }
    await connection.deleteCharacter(uuid);
    await refreshCharacters();
  }
}