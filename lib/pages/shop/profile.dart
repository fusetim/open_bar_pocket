import 'package:flutter/material.dart';
import 'package:open_bar_pocket/api/controller.dart';
import 'package:open_bar_pocket/models/account_notifier.dart';
import 'package:open_bar_pocket/models/order.dart';
import 'package:open_bar_pocket/models/orders_notifier.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  final ApiController _api;

  static const profileLabelTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const profileValueTextStyle = TextStyle(
    fontSize: 16,
  );

  const ProfileTab(this._api, {super.key});

  Future<void> refreshAccountInfo(BuildContext context) async {
    try {
      await _api.getMyAccount().then((value) {
        if (!context.mounted) return;
        Provider.of<AccountNotifier>(context, listen: false).set(value);
      });
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Erreur lors de la récupération des informations de votre compte : ${e.toString()}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 8.0,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<AccountNotifier>(builder: (ctx, _acc, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Profil",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Nom :", style: profileLabelTextStyle),
                          Text(_acc.account.getFullName(),
                              style: profileValueTextStyle),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Rôle :", style: profileLabelTextStyle),
                          Text(_acc.account.price_role.toString(),
                              style: profileValueTextStyle),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Solde :", style: profileLabelTextStyle),
                          Text(
                              "${_acc.account.getFormattedBalance()} + ${_acc.account.getFormattedPoints()}",
                              style: profileValueTextStyle),
                        ],
                      )
                    ],
                  );
                })),
          ),
          Card(
            borderOnForeground: true,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<AccountNotifier>(builder: (ctx, _acc, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Commandes passées",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Consumer<OrdersNotifier>(builder: (ctx, _orders, _) {
                        if (_orders.orders.isEmpty) {
                          return const Text("Aucune commande passée");
                        }
                        return SizedBox(
                          height: 400,
                          child: ListView.builder(
                              itemBuilder: (ctx, index) {
                                if (index == _orders.orders.length) {
                                  return null;
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    tileColor: _orders.orders[index].state ==
                                            OrderState.finished
                                        ? Colors.greenAccent[100]
                                        : _orders.orders[index].state ==
                                                OrderState.canceled
                                            ? Colors.redAccent[100]
                                            : Colors.white,
                                    title: Text(
                                        "Commande du ${_orders.orders[index].getFormattedDate()}"),
                                    trailing: Text(_orders.orders[index]
                                        .getFormattedTotalCost()),
                                    subtitle: Text(
                                        "Articles délivrés : ${_orders.orders[index].totalItemsDone}/${_orders.orders[index].totalItems}"),
                                  ),
                                );
                              },
                              itemCount: _orders.orders.length + 1),
                        );
                      }),
                    ],
                  );
                })),
          ),
        ],
      ),
    );
    ;
  }
}
