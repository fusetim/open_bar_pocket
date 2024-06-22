import 'dart:collection';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:open_bar_pocket/api/controller.dart';
import 'package:open_bar_pocket/models/account_notifier.dart';
import 'package:open_bar_pocket/models/cart.dart';
import 'package:open_bar_pocket/models/price_role.dart';
import 'package:open_bar_pocket/models/product.dart';
import 'package:open_bar_pocket/pages/pin.dart';
import 'package:provider/provider.dart';

class CartTab extends StatelessWidget {
  final ApiController _api;

  const CartTab(this._api, {super.key});

  void onNewTransaction(BuildContext context) async {
    UnmodifiableListView<(Product, int)> cart = context.read<CartModel>().items;

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Votre panier est vide !"),
      ));
      return;
    }

    String? pin = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinPage(),
      ),
    );

    if (!context.mounted) return;

    if (pin == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Transaction annulée !"),
      ));
      return;
    }

    try {
      await _api
        .newTransaction(cart, pin)
        .then((value) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Transaction réussie !"),
            ),
          );
          context.read<CartModel>().clear();
        });
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la transaction : ${e.toString()}"),
        ),
      );
    }    
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<CartModel>(
          builder: (ctx, value, _) {
            return Expanded(
                child: ListView.builder(
                    itemCount: value.items.length,
                    itemBuilder: (cctx, index) {
                      if (value.items.length <= index) {
                        return null;
                      }
                      return Consumer<AccountNotifier>(builder: (ctx, acc, _) {
                        PriceRole accPriceRole = acc.account.price_role;
                        return ListTile(
                          leading: InputQty(
                            initVal: value.items[index].$2,
                            minVal: 0,
                            maxVal: min(value.items[index].$1.buyLimit ?? 99,
                                value.items[index].$1.amountLeft ?? 99),
                            steps: 1,
                            decoration: const QtyDecorationProps(
                              qtyStyle: QtyStyle.btnOnLeft,
                              orientation: ButtonOrientation.vertical,
                              btnColor: Colors.deepPurple,
                            ),
                            //qtyFormProps: QtyFormProps(enableTyping: false),
                            onQtyChanged: (val) {
                              value.setQuantity(
                                  value.items[index].$1, val.toInt());
                            },
                          ),
                          title: Text(value.items[index].$1.getName()),
                          subtitle: Text(
                              "${value.items[index].$1.getFormattedPrice(accPriceRole)} l'unité"),
                          trailing: Text(
                            value.items[index].$1.getFormattedPrice(accPriceRole, quantity: value.items[index].$2),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      });
                    }));
          },
        ),
        Card(
          margin: const EdgeInsets.all(16.0),
          color: Colors.deepPurple[100],
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<AccountNotifier>(builder: (ctx, acc, _) {
                  PriceRole accPriceRole = acc.account.price_role;
                  return Consumer<CartModel>(
                    builder: (context, value, child) => Text(
                      "TOTAL: ${value.calculateFormattedPrice(accPriceRole)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  );
                }),
                TextButton(
                  onPressed: () => onNewTransaction(context),
                  child: Text(
                    "POURSUIVRE",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
