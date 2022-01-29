
import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/modules/website/enums.dart';
import 'package:bleed_client/server/server.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/stripe.dart';
import 'package:bleed_client/ui/actions/signInWithFacebook.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:flutter/services.dart';
import 'package:lemon_dispatch/instance.dart';

import 'classes/Authentication.dart';
import 'common/GameType.dart';

final _Actions actions = _Actions();

class _Actions {


}