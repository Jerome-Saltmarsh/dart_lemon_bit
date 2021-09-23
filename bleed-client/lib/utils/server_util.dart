import 'package:bleed_client/constants/servers.dart';

import '../connection.dart';

void connectServerGermany() {
  connect(servers.germany);
}

String getCurrentServer() {
  if (isUriConnected(servers.germany)) {
    return "Germany";
  }
  if (isUriConnected(servers.usaWest)) {
    return "USA West";
  }
  if (isUriConnected(servers.usaEast)) {
    return "USA East";
  }
  return "Localhost";
}
