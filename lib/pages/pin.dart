import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_bar_pocket/api/controller.dart';
import 'package:open_bar_pocket/models/account.dart';
import 'package:open_bar_pocket/pages/shop/structure.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return PinPageState();
  }
}

class PinPageState extends State<PinPage> {
  late TextEditingController _pinController;

  @override
  void initState() {
    super.initState();
    ;
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _pinController.dispose();
  }

  void onNext() {
    if (_pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Veuillez entrer votre code PIN pour continuer !"),
      ));
      return;
    }
    Navigator.pop(context, _pinController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Comfirmation')),
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
                          Text(
                              "Vous devez entrer votre code PIN pour continuer."),
                        ]))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: onNext,
                        child: const Text("POURSUIVRE"),
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
