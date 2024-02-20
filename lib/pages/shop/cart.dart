import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:open_bar_pocket/api/controller.dart';
import 'package:open_bar_pocket/models/cart.dart';
import 'package:open_bar_pocket/models/price_role.dart';
import 'package:open_bar_pocket/pages/pin.dart';
import 'package:provider/provider.dart';

class CartTab extends StatelessWidget {
  final ApiController _api;

  const CartTab(this._api, {super.key});

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
                        leading: InputQty(
                          initVal: value.items[index].$2,
                          minVal: 0,
                          maxVal: 99,
                          steps: 1,
                          decoration: QtyDecorationProps(
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
                        title: Text("${value.items[index].$1.getName()}"),
                        subtitle: Text(
                            "${value.items[index].$1.getPrice(PriceRole.ceten)} € l'unité"),
                        trailing: Text(
                          "${value.items[index].$1.getPrice(PriceRole.ceten) * value.items[index].$2} €",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PinPage()),
                    )
                  },
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
