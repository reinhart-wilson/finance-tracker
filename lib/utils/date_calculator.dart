DateTime getFirstDateOfMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
}

DateTime getLastDateOfMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
}
