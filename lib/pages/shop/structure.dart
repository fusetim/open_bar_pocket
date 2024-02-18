import 'package:flutter/material.dart';
import 'package:open_bar_pocket/models/cart.dart';
import 'package:open_bar_pocket/pages/shop/cart.dart';
import 'package:open_bar_pocket/pages/shop/menu.dart';
import 'package:provider/provider.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ShoppingState();
  }
}

class _ShoppingState extends State<ShoppingPage> {
  int _open = 0;

  void onDestinationChange(int value) {
    setState(() {
      _open = value;
    });
  }

  Widget? childBuild() {
    switch (_open) {
      case 0:
        return Menu();
      case 1:
        return CartTab();
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Profil",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            OutlinedButton(
              onPressed: (){
                Navigator.pushNamed(context, '/auth');
              },
              child: Text("Login"),
            )
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CartModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('OpenBar'),
          elevation: 8,
        ),
        body: childBuild(),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
                icon: Icon(Icons.restaurant_menu), label: "Carte"),
            NavigationDestination(
                icon: Consumer<CartModel>(
                  builder:
                      (BuildContext context, CartModel cart, Widget? child) {
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
    );
  }
}
