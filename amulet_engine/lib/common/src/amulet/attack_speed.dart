enum AttackSpeed {
  Very_Slow(duration: 48),
  Slow(duration: 40),
  Fast(duration: 32),
  Very_Fast(duration: 24);

  final int duration;

  const AttackSpeed({required this.duration});

  static AttackSpeed fromDuration(int duration) {
    for (final value in values) {
      if (duration >= value.duration) {
        return value;
      }
    }
    return AttackSpeed.values.last;
  }
}
