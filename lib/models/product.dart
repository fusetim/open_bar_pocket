import 'dart:ffi';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:open_bar_pocket/models/price_role.dart';

class Product {
  final String id;
  final String name;
  final int? amountLeft;
  final int? buyLimit;
  final Uint8List? pictureData;
  final List<int> prices;

  const Product(
      {required this.id,
      required this.name,
      required this.prices,
      this.amountLeft,
      this.buyLimit,
      this.pictureData});

  String getName() {
    return name;
  }

  int getPrice(PriceRole role) {
    return prices[role.index];
  }

  String getFormattedPrice(PriceRole role, {int quantity = 1}) {
    int price = prices[role.index];
    var fnb = NumberFormat("##0.00€", 'fr_FR');
    return fnb.format(price.toDouble() / 100.0 * quantity);
  }

  bool hasPicture() {
    return pictureData != null;
  }

  @override
  bool operator ==(Object other) {
    return other is Product && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
