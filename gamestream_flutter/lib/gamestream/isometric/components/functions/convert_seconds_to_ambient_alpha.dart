
int convertSecondsToAmbientAlpha(int totalSeconds) {
  const Seconds_Per_Hours_12 = Duration.secondsPerHour * 12;
  return ((totalSeconds < Seconds_Per_Hours_12
      ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
      : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) *
      255)
      .round();

}
