import 'package:bleed_client/constants/servers.dart';

String getServerName(ServerType server) {
  return _serverTypeNames[server]!;
}

final Map<ServerType, String> _serverTypeNames = {
  ServerType.Australia: "Australia",
  ServerType.Brazil: "Brazil",
  ServerType.Germany: "Germany",
  ServerType.South_Korea: "South Korea",
  ServerType.USA_East: "USA East",
  ServerType.USA_West: "USA West",
  ServerType.LocalHost: "Localhost",
  ServerType.None: "None",
};

