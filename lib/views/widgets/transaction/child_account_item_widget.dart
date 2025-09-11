import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/utils/formatter.dart';

ListView buildChildAccountItem(
  BuildContext context,
  List<Account> children,
  Map<int, double> unsettledAmountsById, {
  bool disableScrollPhysics = false,
}) {
  return ListView.builder(
    shrinkWrap: true,
    physics: disableScrollPhysics ? const NeverScrollableScrollPhysics() : null,
    padding: const EdgeInsets.all(AppSizes.paddingSmall),
    itemCount: children.length,
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, index) {
      final account = children[index];
      final projected =
          account.balance + (unsettledAmountsById[account.id!] ?? 0);
      final theme = Theme.of(context);

      return Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 3.0), // jarak antar item
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // sudut melingkar
          child: Container(
            width: 120, // lebar tiap box, biar konsisten
            color: index % 2 == 0
                ? theme.colorScheme.surface
                : Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  account.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 1),
                Text(
                  formatCurrency(account.balance, shorten: true),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 1),
                RichText(
                    text: TextSpan(text: "P: ", style: theme.textTheme.labelSmall, children: [
                  TextSpan(
                      text: formatCurrency(projected, shorten: true),
                      style: TextStyle(
                        color: projected >= 0 ? Colors.green : Colors.red,
                      ))
                ])),
              ],
            ),
          ),
        ),
      );
    },
  );
}
