import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  void setQuantity(Product item, int quantity) {
    for (var (index, (it, qty)) in _items.indexed) {
      if (it == item) {
        if (quantity == 0) {
          _items.removeAt(index);
          _count -= qty;
          notifyListeners();
          return;
        }
        _items[index] = (it, quantity);
        _count += quantity - qty;
        notifyListeners();
        return;
      }
    }
    _items.add((item, quantity));
    _count += quantity;
    notifyListeners();
  }

  bool remove(Product item) {
    for (var (index, (it, qty)) in _items.indexed) {
      if (it == item) {
        if (qty > 1) {
          _items[index] = (it, qty - 1);
        } else {
          _items.removeAt(index);
        }
        _count -= 1;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void removeAll() {
    _items.clear();
    _count = 0;
    notifyListeners();
  }

  void clear() {
    return removeAll();
  }

  int itemCount() {
    return _count;
  }

  int calculatePrice(PriceRole role) {
    int price = 0;
    for (var (it, qty) in _items) {
      price += it.getPrice(role) * qty;
    }
    return price;
  }

  String calculateFormattedPrice(PriceRole role) {
    var fnb = NumberFormat("##0.00€", "fr_FR");
    return fnb.format((calculatePrice(role).toDouble()) / 100);
  }
}
