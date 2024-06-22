import 'package:flutter/material.dart';
import 'package:open_bar_pocket/api/controller.dart';
import 'package:open_bar_pocket/models/account.dart';
import 'package:open_bar_pocket/models/account_notifier.dart';
import 'package:open_bar_pocket/models/cart.dart';
import 'package:open_bar_pocket/models/orders_notifier.dart';
import 'package:open_bar_pocket/pages/shop/cart.dart';
import 'package:open_bar_pocket/pages/shop/menu.dart';
import 'package:open_bar_pocket/pages/shop/profile.dart';
import 'package:provider/provider.dart';

class ShoppingPage extends StatefulWidget {
  final ApiController _api;
  final Account account;

  const ShoppingPage(this._api, {super.key, required this.account});

  @override
  State<StatefulWidget> createState() {
    return _ShoppingState(_api, account: account);
  }
}

class _ShoppingState extends State<ShoppingPage> {
  final ApiController _api;
  final AccountNotifier _acc_notif;
  final OrdersNotifier _orders_notif = OrdersNotifier([]);

  int _open = 0;

  _ShoppingState(this._api, {required Account account})
      : _acc_notif = AccountNotifier(account);

  void onDestinationChange(int value) {
    setState(() {
      _open = value;
    });
  }

  void refreshContext() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Rafraichissement en cours..."),
    ));

    _api.getMyAccount().then((value) {
      _acc_notif.set(value);
      _api.getLastOrders().then((value) {
        _orders_notif.set(value.orders);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Rafraichissement terminé !"),
        ));
      });
    });
  }

  Widget? childBuild() {
    switch (_open) {
      case 0:
        return Menu(_api);
      case 1:
        return CartTab(_api);
      default:
        return ProfileTab(_api);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (ctx) => _acc_notif,
        child: ChangeNotifierProvider(
          create: (ctx) {
            _api.getLastOrders().then((value) {
              _orders_notif.set(value.orders);
            });
            return _orders_notif;
          },
          child: ChangeNotifierProvider(
            create: (ctx) => CartModel(),
            child: Scaffold(
              appBar: AppBar(
                title: Text('OpenBar'),
                elevation: 8,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<AccountNotifier>(
                    builder: (BuildContext context, AccountNotifier acc,
                        Widget? child) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(acc.account.google_picture),
                      );
                    },
                  )
                ),
                actions: ((){
                  if (_open == 2) {
                    return [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: refreshContext,
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ];
                  } else {
                    return [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ];
                  }
                })(),
              ),
              body: childBuild(),
              bottomNavigationBar: NavigationBar(
                destinations: [
                  NavigationDestination(
                      icon: Icon(Icons.restaurant_menu), label: "Carte"),
                  NavigationDestination(
                      icon: Consumer<CartModel>(
                        builder: (BuildContext context, CartModel cart,
                            Widget? child) {
                          return Badge.count(
                            count: cart.itemCount(),
                            child: const Icon(Icons.shopping_cart),
                          );
                        },
                      ),
                      label: "Panier"),
                  NavigationDestination(
                      icon: Icon(Icons.co_present_outlined), label: "Profil"),
                ],
                onDestinationSelected: onDestinationChange,
                selectedIndex: _open,
              ),
            ),
        )));
  }
}
