import 'package:gamestream_flutter/modules/core/init.dart';

enum OperationStatus {
  None,
  Authenticating,
  Creating_Account,
  Logging_Out,
  Opening_Secure_Payment_Session,
  Cancelling_Subscription,
  Updating_Account,
  Changing_Public_Name,
  Loading_Map,
  Saving_Map,
}

enum Mode {
  Website,
  Player,
}

enum Region {
  Australia,
  Singapore,
  Brazil,
  Germany,
  South_Korea,
  USA_East,
  USA_West,
  LocalHost
}

final List<Region> regions = Region.values;

final selectableRegions = regions.where((element){
  if (element == Region.LocalHost && !isLocalHost) return false;
  return true;
}).toList();

String getRegionName(Region server) {
  return _regionNames[server]!;
}

final Map<Region, String> _regionNames = {
  Region.Australia: "Australia",
  Region.Brazil: "Brazil",
  Region.Germany: "Germany",
  Region.South_Korea: "South Korea",
  Region.USA_East: "USA East",
  Region.USA_West: "USA West",
  Region.LocalHost: "Localhost",
};

