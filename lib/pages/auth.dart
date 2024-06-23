import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_bar_pocket/api/controller.dart';
import 'package:open_bar_pocket/models/account.dart';
import 'package:open_bar_pocket/pages/nfc_card.dart';
import 'package:open_bar_pocket/pages/shop/structure.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  final ApiController _apiController;

  const AuthPage(this._apiController, {super.key});

  @override
  State<StatefulWidget> createState() {
    return AuthPageState(_apiController);
  }
}

class AuthPageState extends State<AuthPage> {
  Future<Account>? _authRequest = null;

  late TextEditingController _serverController;
  late TextEditingController _cardNumberController;
  late TextEditingController _pinController;
  final ApiController _apiController;

  AuthPageState(this._apiController);

  @override
  void initState() {
    super.initState();
    _serverController = TextEditingController()
      ..text = "https://bar.telecomnancy.net";
    _cardNumberController = TextEditingController();
    _pinController = TextEditingController();

    _loadCredentials();
  }

  void _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.containsKey("server")) {
        _serverController.text = prefs.getString("server")!;
      }
      if (prefs.containsKey("cardNumber")) {
        _cardNumberController.text = prefs.getString("cardNumber")!;
      }
      if (prefs.containsKey("pin") &&
          prefs.containsKey("cardNumber") &&
          prefs.containsKey("server")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Connexion automatique en cours..."),
        ));
        _connect(prefs.getString("server")!, prefs.getString("cardNumber")!,
            prefs.getString("pin")!);
        _authRequest!.then((account) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Connecté en tant que ${account.getFullName()}."),
          ));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShoppingPage(_apiController, account: account),
            ),
          );
        }).catchError((error) {
          log("Auth error: $error");
          prefs.remove("pin");
        }).whenComplete(() {
          setState(() {
            _authRequest = null;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _serverController.dispose();
    _cardNumberController.dispose();
    _pinController.dispose();
  }

  void _connect(String serverUri, String cardNumber, String pin) {
    _apiController.setBaseUri(serverUri);
    _authRequest = _apiController.updateApiConfig().then((_) {
      return _apiController.connectByCard(cardNumber.toLowerCase(), pin);
    });
  }

  void connect() {
    if (_authRequest != null) {
      return;
    }
    if (_serverController.text.isEmpty ||
        _cardNumberController.text.isEmpty ||
        _pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Veuillez entrer les informations requises."),
      ));
      return;
    }
    if (_cardNumberController.text.length != 14) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Le numéro de carte doit contenir exactemement 14 caractères."),
      ));
      return;
    }
    // TODO: Check that the card number is hexadecimal.
    setState(() {
      _connect(_serverController.text, _cardNumberController.text,
          _pinController.text);
    });
    _authRequest!.then((account) {
      final prefs = SharedPreferences.getInstance();
      final server = _serverController.text;
      final cardNumber = _cardNumberController.text.toLowerCase();
      final pin = _pinController.text;
      prefs.then((prefs) {
        prefs.setString("server", server);
        prefs.setString("cardNumber", cardNumber);
        prefs.setString("pin", pin);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Connecté en tant que ${account.getFullName()}."),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShoppingPage(_apiController, account: account),
        ),
      );
    }).catchError((error) {
      log("Auth error: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur lors de l'authentification."),
      ));
    }).whenComplete(() {
      setState(() {
        _authRequest = null;
        _pinController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Authentification')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Card(
                margin: EdgeInsets.all(16.0),
                elevation: 8,
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Vous devez vous connecter pour continuer."),
                        ]))),
            const SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Serveur OpenBar",
                        hintText: "Entrez l'URL du serveur OpenBar",
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      controller: _serverController,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Numéro de carte",
                            hintText: "Entrez votre numéro de carte",
                            prefixIcon: Icon(Icons.credit_card),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          controller: _cardNumberController,
                        )),
                        const SizedBox(width: 8),
                        IconButton.outlined(
                          iconSize: 38.0,
                          padding: EdgeInsets.all(12.0),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0))),
                          ),
                          onPressed: () {
                            startSession(context: context).then((cardNumber) {
                              if (cardNumber != null) {
                                _cardNumberController.text = cardNumber;
                              }
                            });
                          },
                          icon: const Icon(Icons.nfc),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Code PIN",
                        hintText: "Entrez votre code PIN",
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      controller: _pinController,
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _authRequest != null ? null : connect,
                        child: Text("CONNEXION"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
