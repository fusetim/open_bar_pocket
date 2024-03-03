import 'package:flutter/material.dart';
import 'package:open_bar_pocket/api/controller.dart';
import 'package:open_bar_pocket/models/account_notifier.dart';
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

  int? _selectedCategory;

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
                child: _ProductList(_api,
                    catId: snapshot.data![_selectedCategory ?? 0].id,
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
            borderRadius: BorderRadius.circular(4.0),
            child: Container(
              margin: const EdgeInsets.all(4.0),
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
                  Hero(
                      tag: "catName",
                      child: Text(
                        categories[index].getName(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ))
                ],
              ),
            ),
          );
        });
  }
}

class _ProductList extends StatelessWidget {
  final ApiController _api;
  final String catId;
  final String catName;
  final void Function()? onBackPress;
  final Future<List<Product>> _products;

  _ProductList(this._api,
      {super.key, required this.catId, required this.catName, this.onBackPress})
      : _products = _api.getProducts(catId);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppBar(
          title: Hero(
              tag: "catName",
              child: Text(catName, style: TextStyle(fontSize: 18))),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackPress,
          ),
        ),
        FutureBuilder(
            future: _products,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150, childAspectRatio: 0.7),
                      itemBuilder: (context, index) {
                        if (index >= snapshot.data!.length) {
                          return null;
                        }
                        var image_stack = [
                          snapshot.data![index].hasPicture()
                              ? Image.memory(
                                  snapshot.data![index].pictureData!,
                                  fit: BoxFit.scaleDown,
                                )
                              : const Placeholder(),
                        ];
                        if ((snapshot.data![index].amountLeft ?? 0) <= 0) {
                          image_stack.add(Image.network(
                              "https://bar.telecomnancy.net/epuise.webp"));
                        }
                        ;

                        return InkWell(
                          onTap: () => {
                            Provider.of<CartModel>(context, listen: false)
                                .add(snapshot.data![index])
                          },
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
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1.0,
                                      child: Stack(
                                        alignment: AlignmentDirectional.center,
                                        children: image_stack,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          snapshot.data![index].getName(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        Consumer<AccountNotifier>(
                                            builder: (ctx, acc, _) {
                                          PriceRole accPriceRole =
                                              acc.account.price_role;
                                          return Text(
                                            snapshot.data![index]
                                                .getFormattedPrice(
                                                    PriceRole.coutant),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          );
                                        }),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                        );
                      }),
                );
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
            }),
      ],
    );
  }
}
