import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/views/screens/transaction_category_management.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Options",
        style: GoogleFonts.manrope(
            textStyle: theme.textTheme.titleLarge, fontWeight: FontWeight.w600),
      )),
      body: ListView(
        children: [
          _OptionItem(
            iconData: Icons.label,
            label: "Manage Transaction Categories",
            onTap: () {
              _goToManageCategories(context);
            }, // static method or wrap in () {}
          ),
          SizedBox(
            height: AppSizes.paddingSmall,
          ),
          // _OptionItem(
          //   iconData: Icons.settings,
          //   label: "Settings",
          //   onTap: _goToSettings,
          // ),
          // _OptionItem(
          //   iconData: Icons.logout,
          //   label: "Logout",
          //   onTap: _handleLogout,
          // ),
        ],
      ),
    );
  }

  static void _goToManageCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionCategoryManagement(),
      ),
    );
  }

  static void _goToSettings() {
    // navigate or handle
  }

  static void _handleLogout() {
    // handle logout
  }
}

class _OptionItem extends StatelessWidget {
  final IconData iconData;
  final String label;
  final void Function()? onTap;

  const _OptionItem({required this.iconData, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: colorScheme.onPrimary,
      leading: Icon(iconData),
      trailing: const Icon(Icons.arrow_right),
      title: Text(label),
      onTap: onTap,
    );
  }
}
