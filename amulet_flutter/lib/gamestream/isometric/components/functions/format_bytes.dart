String formatBytes(int bytes) {
  final kb = bytes ~/ 1000;
  final mb = kb ~/ 1000;
  return 'mb: $mb, kb: ${kb % 1000}, b:${bytes % 1000}';
}
