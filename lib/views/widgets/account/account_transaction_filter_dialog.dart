import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/views/widgets/nullable_date_field.dart';
import 'package:flutter/material.dart';

class AccountTransactionFilterDialog extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final VoidCallback onApply;
  final String title;
  final String? note;

  final bool isLimitDate;

  final bool isNullable;

  const AccountTransactionFilterDialog({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onApply,
    this.note,
    this.isLimitDate = false,
    this.isNullable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TransactionFilterDateField(
                  isNullable: isNullable,
                  isLimitDate: isLimitDate,
                  label: "Start date",
                  value: startDate,
                  onChanged: onStartDateChanged,
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                child: Text('_'),
              ),
              Expanded(
                child: TransactionFilterDateField(
                  isLimitDate: isLimitDate,
                  isNullable: isNullable,
                  label: "End date",
                  value: endDate,
                  onChanged: (date) {
                    if (date != null) {
                      onEndDateChanged(DateTime(
                          date.year, date.month, date.day, 23, 59, 59, 999));
                    } else {
                      onEndDateChanged(date);
                    }
                  },
                ),
              ),
            ],
          ),
          if (note != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
              child: Text(
                note!,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ElevatedButton(
            onPressed: () {
              onApply(); // Apply filter logic
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
