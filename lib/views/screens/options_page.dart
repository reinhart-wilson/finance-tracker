import 'package:file_picker/file_picker.dart';
import 'package:finance_tracker/configs/dependencies.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/viewmodels/options/options_viewmodel.dart';
import 'package:finance_tracker/views/screens/transaction_category_management.dart';
import 'package:finance_tracker/views/widgets/restart_prompt_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<OptionsViewmodel>();
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
            },
          ),
          const SizedBox(
            height: AppSizes.paddingSmall,
          ),
          _OptionItem(
            iconData: Icons.upload,
            label: "Export data",
            onTap: () async {
              await _handleExportData(context);
            },
          ),
          _OptionItem(
            iconData: Icons.download,
            label: "Import data",
            onTap: () async {
              await _handleImportData(context);
            },
          ),
        ],
      ),
    );
  }

  static void _goToManageCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionCategoryManagement(),
      ),
    );
  }

  static Future<void> _handleExportData(BuildContext context) async {
    final rootContext = context;
    final vm = rootContext.read<OptionsViewmodel>();

    showDialog(
      // Shows loading dialog
      context: rootContext,
      barrierDismissible: false,
      builder: (context) => const _LoadingDialog(),
    );

    var msg =
        'Backup exported to downloads folder as ${OptionsViewmodel.fileName}';

    try {
      await vm.exportDb();
    } catch (e) {
      msg = 'Failed to export (${e.toString()})';
    } finally {
      if (rootContext.mounted) {
        ScaffoldMessenger.of(rootContext).showSnackBar(
          SnackBar(content: Text(msg)),
        ); // dismiss the dialog
        Navigator.of(rootContext, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _handleImportData(BuildContext context) async {
    final rootContext = context;
    final vm = context.read<OptionsViewmodel>();

    // Show loading dialog
    showDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (context) => const _LoadingDialog(),
    );

    try {
      final filePath = await _pickJsonFile();

      if (filePath == null) {
        throw Exception('File selection cancelled.');
      }

      await vm.importDb(filePath); // Make sure this is awaited!

      if (rootContext.mounted) {
        Navigator.of(rootContext, rootNavigator: true).pop(); // Dismiss loading

        // Show restart prompt
        showDialog(
          context: rootContext,
          barrierDismissible: false,
          builder: (context) => const RestartPromptDialog(),
        );
      }
    } catch (e) {
      if (rootContext.mounted) {
        Navigator.of(rootContext, rootNavigator: true).pop(); // Dismiss loading
        ScaffoldMessenger.of(rootContext).showSnackBar(
          SnackBar(content: Text("Import failed: ${e.toString()}")),
        );
      }
    }
  }

  Future<String?> _pickJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      return filePath;
    } else {
      // User canceled the picker
      return null;
    }
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

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Exporting..."),
          ],
        ),
      ),
    );
  }
}
