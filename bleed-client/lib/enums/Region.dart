import 'package:bleed_client/core/init.dart';

enum Region {
  None,
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
  if (element == Region.None) return false;
  if (element == Region.LocalHost && !isLocalHost) return false;
  return true;
}).toList();