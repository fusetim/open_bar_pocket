import 'package:flutter/material.dart';
import 'package:open_bar_pocket/models/account.dart';

class AccountNotifier extends ChangeNotifier {
  Account _account;

  AccountNotifier(this._account);

  Account get account => _account;

  void set(Account acc) {
    _account = acc;
    notifyListeners();
  }
}
