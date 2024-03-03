import 'package:flutter/material.dart';
import 'package:open_bar_pocket/api/controller.dart';
import 'package:open_bar_pocket/models/account_notifier.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  final ApiController _api;

  const ProfileTab(this._api, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<AccountNotifier>(builder: (ctx, _acc, _) {
                return Column(
                  children: [
                    Text(
                        "${_acc.account.first_name} ${_acc.account.last_name}"),
                    Text("Statut: ${_acc.account.price_role.toString()}"),
                    Text(
                        "Balance: ${_acc.account.getFormattedBalance()} + ${_acc.account.getFormattedPoints()}"),
                  ],
                );
              })),
          ),
          Text("TODO: Historique des transactions."),
        ],
      ),
    );
  }
}
