import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  final Uri _auth_url = Uri.parse("https://bar.telecomnancy.net/api/auth/google?r=openbarpocket://bar.telecomnancy.net/shop");

  void redirectConn() async {
    if (!await launchUrl(_auth_url)) {
      throw Exception('Could not launch $_auth_url');
    }
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Vous devez vous connecter pour continuer."),
                          Text(
                              "Vous allez être redirigé sur une page d'authentification Google."),
                        ]))),
            
            const SizedBox(height: 64),
            
            OutlinedButton(
              onPressed: redirectConn,
              child: const Text("SE CONNECTER"),
            )
          ],
        ));
  }
}
