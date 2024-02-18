import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(onPageStarted: (url) {
        log('Started loading $url');
        if (url.startsWith("https://bar.telecomnancy.net/admin")) {
          // extract cookie
          final authCookie = _controller.runJavaScriptReturningResult('document.cookie')
              .then((value) => value.toString().split(';').first);
          // snackbar
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Connexion réussie\nCookie: $authCookie'),
            duration: const Duration(seconds: 2),
          ));
        }
      }))
      ..loadRequest(Uri.parse('https://bar.telecomnancy.net/auth'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion...')),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
