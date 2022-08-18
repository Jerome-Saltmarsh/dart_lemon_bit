

class NodeOrientationGroup {
  static const Solid = 0;
  static const SlopeSymmetric = 1;
  static const SlopeInner = 1;
  static const SlopeOuter = 1;
  static const Corner = 1;
  static const Half = 1;
}

bool isNodeOrientationGroupSolid(int nodeType) {
  return false;
}

