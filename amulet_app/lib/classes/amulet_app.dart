import 'package:amulet_app/classes/connection_local.dart';
import 'package:amulet_app/enums/src.dart';
import 'package:amulet_flutter/amulet_client.dart';
import 'package:amulet_flutter/isometric/classes/connection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lemon_watch/src.dart';

import '../ui/enums/website_dialog.dart';
import '../ui/enums/website_page.dart';

class AmuletApp {
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
  final AmuletClient amuletClient;

  AmuletApp(this.amuletClient);


  void setConnectionSinglePlayer() {
    connection.value = ConnectionLocal(
        parser: amuletClient.components.responseReader,
        playerClient: amuletClient.components.player,
        sharedPreferences: amuletClient.components.engine.sharedPreferences,
    );
  }
}