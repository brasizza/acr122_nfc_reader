enum CardState {
  unknown(0),
  absent(1),
  present(2),
  swallowed(3),
  powered(4),
  negotiable(5),
  specific(6);

  final int value;
  const CardState(this.value);
}
