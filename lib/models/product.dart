import 'package:open_bar_pocket/models/price_role.dart';

class Product {
  final String? ident;
  final String name;
  final String? description;
  final List<double> prices;

  const Product(this.name,
      {this.description, this.ident, required this.prices});

  Product.uniquePrice(this.name, double price)
      : ident = null,
        description = null,
        prices = List.filled(PriceRole.length, price, growable: false);

  String getName() {
    return name;
  }

  double getPrice(PriceRole role) {
    return prices[role.index];
  }

  String getFormattedPrice(PriceRole role) {
    double price = prices[role.index];
    return "$price EUR";
  }

  @override
  bool operator ==(Object other) {
    return other is Product &&
        other.ident == ident &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(ident, name);
}
