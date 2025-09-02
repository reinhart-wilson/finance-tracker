import 'package:finance_tracker/models/account.dart';
import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:finance_tracker/viewmodels/account_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/views/account_form_view.dart';

class AccountListView extends StatelessWidget {
  const AccountListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Consumer<AccountListViewmodel>(builder: (context, viewModel, child) {
        viewModel.filter = null;

        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final accounts = viewModel.accountList;
        final treeRoot = TreeNode.root();
        _buildTree(treeRoot, accounts);

        return TreeView.simple(
          tree: treeRoot,
          showRootNode: false,
          expansionIndicatorBuilder: (context, node) =>
              ChevronIndicator.rightDown(
            tree: node,
            color: Colors.blue[700],
            padding: const EdgeInsets.all(8),
          ),
          indentation: const Indentation(style: IndentStyle.roundJoint),
          onTreeReady: (controller) {
            controller.expandAllChildren(treeRoot);
          },
          builder: (context, node) => Card(
            child: ListTile(
              title: Text(node.data == null ? 'Accounts' : node.data.name),
              subtitle: node.data == null
                  ? null
                  : Text('Balance: ${node.data.balance}'),
              trailing: IconButton(
                  onPressed: !viewModel.isLoading
                      ? () => viewModel.deleteAccount(node.data.id)
                      : null,
                  icon: const Icon(Icons.delete, color: Colors.red)),
            ),
          ),
        );
      }),
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
