import 'package:flutter/material.dart';
import 'package:open_bar_pocket/models/cart.dart';
import 'package:open_bar_pocket/models/price_role.dart';
import 'package:open_bar_pocket/models/product.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';

class Menu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MenuState();
  }
}

class MenuState extends State<Menu> {
  static const _categories = [
    const Category(name: "Pizza"),
    const Category(name: "Plat du bar"),
    const Category(name: "Plats préparés"),
    const Category(name: "Boissons"),
    const Category(name: "Friandises"),
  ];

  static final _products = [
    Product.uniquePrice("Vosgien", 2.95),
    Product.uniquePrice("Lance-roquette", 2.75),
    Product.uniquePrice("Athénien", 2.25),
  ];

  int? _selectedCategory = null;

  void onCategorySelection(int index) {
    setState(() {
      _selectedCategory = index;
    });
  }

  void returnToCategories() {
    setState(() {
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) {
      return _CategorySelector(
          categories: _categories, onSelection: onCategorySelection);
    } else {
      return PopScope(
        canPop: false,
        onPopInvoked: (_) => returnToCategories(),
        child:
            _ProductList(products: _products, catName: _categories[_selectedCategory ?? 0].getName(), onBackPress: returnToCategories),
      );
    }
  }
}

class _CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final void Function(int) onSelection;

  const _CategorySelector(
      {super.key, required this.categories, required this.onSelection});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150, childAspectRatio: 0.8),
        itemBuilder: (context, index) {
          if (index >= categories.length) {
            return null;
          }
          return InkWell(
            onTap: () => onSelection(index),
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Placeholder(
                      fallbackWidth: 50,
                      fallbackHeight: 100,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categories[index].getName(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              ),
            ),
          );
        });
  }
}

class _ProductList extends StatelessWidget {
  final String catName;
  final List<Product> products;
  final void Function()? onBackPress;

  const _ProductList({super.key, required this.catName, required this.products, this.onBackPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppBar(
          title: Text(catName, style: TextStyle(fontSize: 18)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPress,
          ),
        ),
        Expanded(
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150, childAspectRatio: 0.6),
              itemBuilder: (context, index) {
                if (index >= products.length) {
                  return null;
                }
                return InkWell(
                  onTap: () => {
                    Provider.of<CartModel>(context, listen: false).add(products[index])
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: Placeholder(
                            fallbackWidth: 50,
                            fallbackHeight: 100,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          products[index].getName(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          products[index].getFormattedPrice(PriceRole.vip),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
