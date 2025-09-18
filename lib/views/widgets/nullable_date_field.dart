import 'package:finance_tracker/utils/formatter.dart';
import 'package:flutter/material.dart';

class TransactionFilterDateField extends StatefulWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool isNullable;
  final bool isLimitDate;

  const TransactionFilterDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isNullable = false,
    this.isLimitDate = false
  });

  @override
  State<TransactionFilterDateField> createState() => _TransactionFilterDateFieldState();
}

class _TransactionFilterDateFieldState extends State<TransactionFilterDateField> {
  DateTime? _selectedDate;


  @override
  void initState() {
    super.initState();
    _selectedDate = widget.value;
  }

  @override
  void didUpdateWidget(covariant TransactionFilterDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _selectedDate = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: _selectedDate != null && widget.isNullable
              ? IconButton(
                  iconSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                  icon: const Icon(
                    Icons.clear,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                    });
                    widget.onChanged(null);
                  },
                )
              : null,
        ),
        child: InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? now,
              firstDate: DateTime(2000),
              lastDate: widget.isLimitDate ? now : DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
              widget.onChanged(picked);
            }
          },
          child: Text(
            _selectedDate != null ? formatDate(_selectedDate!) : "Date not selected",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _selectedDate != null ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
