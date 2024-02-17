import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_bar_pocket/models/price_role.dart';
import 'package:open_bar_pocket/models/product.dart';

class CartModel extends ChangeNotifier {
  final List<(Product, int)> _items = List.empty(growable: true);
  int _count = 0;

  UnmodifiableListView<(Product, int)> get items =>
      UnmodifiableListView(_items);

  void add(Product item) {
    log("Adding product ${item.getName()} to cart.");
    for (var (index, (it, qty)) in _items.indexed) {
      if (it == item) {
        _items[index] = (it, qty + 1);
        _count += 1;
        notifyListeners();
        return;
      }
    }
    _items.add((item, 1));
    _count += 1;
    notifyListeners();
  }

  bool remove(Product item) {
    for (var (index, (it, qty)) in _items.indexed) {
      if (it == item) {
        if (qty > 1) {
          _items[index] = (it, qty - 1);
        }
        _count -= 1;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void removeAll() {
    items.clear();
    _count = 0;
    notifyListeners();
  }

  int itemCount() {
    return _count;
  }

  double calculatePrice(PriceRole role) {
    double price = 0;
    for (var (it, qty) in _items) {
      price += it.getPrice(role) * qty;
    }
    return price;
  }
}
