import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) =>
    DateFormat('dd-MM-yyyy').format(dateTime);

String formatPercentage(double percentage) {
  final percentFormatter = NumberFormat.percentPattern()
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = 2;
  String formatted = percentFormatter.format(percentage);
  return (formatted);
}

String formatCurrency(
  double balance, {
  bool includeCurrency = true,
  bool shorten = false,
}) {
  String formatted;

  if (shorten) {
    final absValue = balance.abs();

    if (absValue >= 1000000000) {
      double truncated = (absValue / 1000000000);
      truncated = (truncated * 1000).floor() / 1000; // truncate to 3 decimals
      formatted = '${truncated.toStringAsFixed(3)}b';
    } else if (absValue >= 1000000) {
      double truncated = (absValue / 1000000);
      truncated = (truncated * 1000).floor() / 1000;
      formatted = '${truncated.toStringAsFixed(3)}m';
    } else if (absValue >= 1000) {
      double truncated = (absValue / 1000);
      truncated = (truncated * 10).floor() / 10; // truncate to 1 decimal
      formatted = '${truncated.toStringAsFixed(1)}k';
    } else {
      formatted = absValue.floor().toString();
    }
  } else {
    final formatter = NumberFormat("#,###", "id_ID");
    formatted = formatter.format(balance.abs());
  }

  if (includeCurrency) {
    formatted = 'Rp. $formatted';
  }

  if (balance < 0) {
    formatted = '- $formatted';
  }

  return formatted;
}
