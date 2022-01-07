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

final selectableRegions = regions.where((element) => element != Region.None).toList();