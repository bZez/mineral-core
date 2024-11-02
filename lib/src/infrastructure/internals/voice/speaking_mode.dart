enum SpeakingMode {
  microphone(1 << 0),
  soundshare(1 << 1),
  priority(1 << 2);

  final int value;
  const SpeakingMode(this.value);
}