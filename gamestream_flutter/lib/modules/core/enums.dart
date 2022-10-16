import 'package:gamestream_flutter/enums/region.dart';
import 'package:lemon_engine/engine.dart';


const regions = Region.values;

final selectableRegions = regions.where((element){
  if (element == Region.LocalHost && !Engine.isLocalHost) return false;
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

