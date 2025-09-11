import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) =>
    DateFormat('dd-MM-yyyy').format(dateTime);

String formatCurrency(
  double balance, {
  bool includeCurrency = true,
  bool shorten = false,
}) {
  String formatted;

  if (shorten) {
    final absValue = balance.abs();

    if (absValue >= 1000000000) {
      formatted = (absValue / 1000000000).toStringAsFixed(3) + 'b';
    } else if (absValue >= 1000000) {
      formatted = (absValue / 1000000).toStringAsFixed(2) + 'm';
    } else if (absValue >= 1000) {
      formatted = (absValue / 1000).toStringAsFixed(1) + 'k';
    } else {
      formatted = absValue.toStringAsFixed(0);
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
