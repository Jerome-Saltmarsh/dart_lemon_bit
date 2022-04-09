import 'package:gamestream_flutter/modules/core/enums.dart';

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

