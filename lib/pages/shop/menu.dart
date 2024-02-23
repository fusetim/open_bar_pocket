import 'package:flutter/material.dart';
import 'package:open_bar_pocket/api/controller.dart';
import 'package:open_bar_pocket/models/cart.dart';
import 'package:open_bar_pocket/models/price_role.dart';
import 'package:open_bar_pocket/models/product.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';

class Menu extends StatefulWidget {
  final ApiController _api;

  const Menu(this._api, {super.key});

  @override
  State<StatefulWidget> createState() {
    return MenuState(_api);
  }
}

class MenuState extends State<Menu> {
  final ApiController _api;

  late Future<List<Category>> _categories;

  MenuState(this._api);

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
  void initState() {
    super.initState();
    _categories = _api.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_selectedCategory == null) {
              return _CategorySelector(
                  categories: snapshot.data!, onSelection: onCategorySelection);
            } else {
              return PopScope(
                canPop: false,
                onPopInvoked: (_) => returnToCategories(),
                child: _ProductList(
                    products: _products,
                    catName: snapshot.data![_selectedCategory ?? 0].getName(),
                    onBackPress: returnToCategories),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Oops, an error has occured: ${snapshot.error}"),
            );
          } else {
            return const Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
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
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.purple[200]!,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: categories[index].hasPicture()
                          ? Image.memory(categories[index].picture_data!)
                          : const Placeholder(),
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

  const _ProductList(
      {super.key,
      required this.catName,
      required this.products,
      this.onBackPress});

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
                    Provider.of<CartModel>(context, listen: false)
                        .add(products[index])
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
                          products[index].getFormattedPrice(PriceRole.coutant),
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
