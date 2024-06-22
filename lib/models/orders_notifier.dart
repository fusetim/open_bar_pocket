import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:open_bar_pocket/models/account.dart';
import 'package:open_bar_pocket/models/order.dart';

class OrdersNotifier extends ChangeNotifier {
  List<Order> _orders;

  OrdersNotifier(this._orders);

  UnmodifiableListView<Order> get orders => UnmodifiableListView(_orders);

  void set(List<Order> orders) {
    _orders = orders;
    notifyListeners();
  }
}
