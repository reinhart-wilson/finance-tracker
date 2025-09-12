import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/views/account_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:finance_tracker/viewmodels/account/account_list_viewmodel.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/views/widgets/account_form_widget.dart';

class AccountListView extends StatelessWidget {
  const AccountListView({super.key});

  String formatBalance(double balance) {
    final formatter = NumberFormat("#,###", "id_ID");
    return "Rp. ${formatter.format(balance)}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    context.read<AccountListViewmodel>().filter = null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
            title: Text(
          "Your Accounts",
          style: GoogleFonts.manrope(textStyle: theme.textTheme.titleLarge, fontWeight: FontWeight.w600),
        )),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<AccountListViewmodel>(
                builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final accounts = viewModel.accountList;
              final treeRoot = TreeNode.root();
              _buildTree(treeRoot, accounts);

              return Expanded(
                child: TreeView.simple(
                  tree: treeRoot,
                  showRootNode: false,
                  expansionIndicatorBuilder: (context, node) =>
                      ChevronIndicator.rightDown(
                    tree: node,
                    color: theme.colorScheme.primary,
                    padding: const EdgeInsets.all(8),
                  ),
                  indentation:
                      const Indentation(style: IndentStyle.scopingLine),
                  onTreeReady: (controller) {
                    controller.expandAllChildren(treeRoot);
                  },
                  builder: (context, node) => ListTile(
                    onTap: () {
                      Navigator.of(context, rootNavigator: false).push(
                        MaterialPageRoute(
                          builder: (_) => const AccountDetailView(),
                          settings: RouteSettings(arguments: node.data),
                        ),
                      );
                    },
                    title:
                        Text(node.data == null ? 'Accounts' : node.data.name),
                    subtitle: node.data == null
                        ? null
                        : Text('Balance: ${formatBalance(node.data.balance)}'),
                    // onLongPress: ,
                    // trailing: IconButton(
                    //     onPressed: !viewModel.isLoading
                    //         ? () async {
                    //             try {
                    //               await viewModel.deleteAccount(node.data.id);
                    //             } catch (e) {
                    //               if (!context.mounted) return;
                    //               ScaffoldMessenger.of(context).showSnackBar(
                    //                 SnackBar(content: Text('Deletion failed: $e')),
                    //               );
                    //             }
                    //           }
                    //         : null,
                    //     icon: const Icon(Icons.delete, color: Colors.red)),
                  ),
                ),
              );
            }),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16))),
                  builder: (context) {
                    return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 16,
                          right: 16,
                          top: 24,
                        ),
                        child: const AccountFormView());
                  });
            },
            child: const Icon(Icons.add)),
      ),
    );
  }
}

void _buildTree(TreeNode treeRoot, List<Account> accounts) {
  treeRoot.clear();

  for (var parent in accounts.where((a) => a.parentId == null)) {
    final parentNode = TreeNode<Account>(
      data: parent,
      key: parent.id.toString(),
    );

    debugPrint("Adding node");

    final children = accounts
        .where((account) => account.parentId == parent.id)
        .map((child) => TreeNode<Account>(
              data: child,
              key: child.id.toString(),
            ))
        .toList();

    parentNode.addAll(children);
    treeRoot.add(parentNode);
  }
}
