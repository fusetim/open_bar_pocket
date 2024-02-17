import 'package:flutter/material.dart';

class PinPage extends StatefulWidget {
  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmation d'identité"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // An information card, that explains the user what to do.
          // It includes the current account email we are trying to confirm.
          const Card(
            margin: EdgeInsets.all(16.0),
            elevation: 8,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Vous souhaitez vous connecter avec votre compte: email@domain.tld."),
                  Text("Veuillez confirmer votre identité en saisissant votre code PIN."),
                ]
              )
            )
          ),
          Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Code PIN",
                    hintText: "Entrez votre code PIN",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => {},
                    child: Text("CONFIRMER"),
                  ),
                )
              ]
            )
          )
        ]
      )
    );
  }
}