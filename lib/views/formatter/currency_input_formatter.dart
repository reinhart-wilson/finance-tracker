import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only digits
    String numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericString.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final formatted = _formatter.format(int.parse(numericString));

    // Maintain cursor position
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
