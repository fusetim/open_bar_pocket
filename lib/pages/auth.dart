import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  final Dio _dioClient = Dio()..httpClientAdapter = NativeAdapter();

  final Uri _auth_url = Uri.parse("https://bar.telecomnancy.net/api/auth/card");
  static const String _local_token = "ceciestuneborne";

  Future<Response<dynamic>>? _authRequest = null;

  late TextEditingController _cardNumberController;
  late TextEditingController _pinController;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _cardNumberController.dispose();
    _pinController.dispose();
  }

  void connect() {
    if (_authRequest != null) {
      return;
    }
    if (_cardNumberController.text.isEmpty || _pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Veuillez entrer un numéro de carte et un code PIN."),
        action: SnackBarAction(
          label: "Réessayer",
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));
      return;
    }
    if (_cardNumberController.text.length != 14) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Le numéro de carte doit contenir exactemement 14 caractères."),
        action: SnackBarAction(
          label: "Réessayer",
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));
      return;
    }
    // if (RegExp(r'([0-9a-fA-F]+)').hasMatch(_cardNumberController.text)) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(
    //         "Le numéro de carte doit contenir uniquement les caractères 0-9 et a-f."),
    //     action: SnackBarAction(
    //       label: "Réessayer",
    //       onPressed: () {
    //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //       },
    //     ),
    //   ));
    //   return;
    // }
    setState(() {
      _authRequest = _dioClient.postUri(_auth_url,
          data: jsonEncode({
            "card_id": _cardNumberController.text.toLowerCase(),
            "card_pin": _pinController.text
          }),
          options: Options(headers: {
            "X-Local-Token": _local_token,
          }));
    });
    _authRequest!.then((response) {
      log("Auth response: ${response.data}");
      if (response.statusCode == 200) {
        log("Auth success: ${response.data}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Connecté en tant que ${response.data["account"]["first_name"]} ${response.data["account"]["last_name"]}."),
          action: SnackBarAction(
            label: "Continuer",
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ));
        Navigator.pushNamed(context, '/shop');
      } else {
        log("Auth failed: ${response.data}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Authentification échouée."),
          action: SnackBarAction(
            label: "Réessayer",
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ));
      }
    }).catchError((error) {
      log("Auth error: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur lors de l'authentification."),
        action: SnackBarAction(
          label: "Réessayer",
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));
    }).whenComplete(() {
      setState(() {
        _authRequest = null;
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
                        labelText: "Numéro de carte",
                        hintText: "Entrez votre numéro de carte",
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un numéro de carte valide.";
                        }
                        if (value.length < 14 || value.length > 14) {
                          return "Le numéro de carte doit contenir exactemement 14 caractères.";
                        }
                        if (RegExp(r'([0-9a-fA-F]+)').hasMatch(value)) {
                          return "Le numéro de carte doit contenir uniquement les caractères 0-9 et a-f.";
                        }
                        return null;
                      },
                      controller: _cardNumberController,
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
