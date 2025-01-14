enum InviteType {
  server(0),
  groupDm(1),
  friend(2);

  final int value;
  const InviteType(this.value);
}