

import 'package:bleed_client/state/game.dart';

import 'enums.dart';

class WebsiteActions {

  void showDialogCustomMaps(){
    game.dialog.value = WebsiteDialog.Custom_Maps;
  }
}