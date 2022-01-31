import 'package:bleed_client/modules/core/init.dart';

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
  Editor,
}

enum Region {
  Australia,
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