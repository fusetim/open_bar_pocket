import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:open_bar_pocket/models/cart.dart';
import 'package:open_bar_pocket/models/price_role.dart';
import 'package:provider/provider.dart';

class CartTab extends StatelessWidget {
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
                      return ListTile(
                        title: Text(value.items[index].$1.getName()),
                        subtitle: Text("Quantité: ${value.items[index].$2}"),
                        trailing: Text(
                            "${value.items[index].$1.getPrice(PriceRole.ceten)} €/u"),
                      );
                    }));
          },
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<CartModel>(
                  builder: (context, value, child) => Text(
                    "TOTAL: ${value.calculatePrice(PriceRole.ceten)} €",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => {},
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
          margin: EdgeInsets.all(16.0),
          color: Colors.deepPurple[100],
          elevation: 16,
        )
      ],
    );
  }
}
