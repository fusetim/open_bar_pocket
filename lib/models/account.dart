import 'package:intl/intl.dart';
import 'package:open_bar_pocket/models/price_role.dart';

class Account {
  final String id;
  final String first_name;
  final String last_name;
  final String google_picture;
  final String email_address;

  /// Balance is in cents.
  final int balance;

  /// Points are expressed in "cents".
  final int points;
  final String card_id;
  final PriceRole price_role;
  final String state;

  const Account(
      this.id,
      this.first_name,
      this.last_name,
      this.google_picture,
      this.email_address,
      this.balance,
      this.points,
      this.card_id,
      this.price_role,
      this.state);

  factory Account.fromJson(Map<String, dynamic> data) {
    return Account(
        data["id"]! as String,
        data["first_name"]! as String,
        data["last_name"]! as String,
        data["google_picture"]! as String,
        data["email_address"]! as String,
        data["balance"]! as int,
        data["points"]! as int,
        data["card_id"]! as String,
        PriceRole.fromText(data["price_role"]! as String),
        data["state"]! as String);
  }

  String getFullName() {
    return "$first_name ${last_name.toUpperCase()}";
  }

  String getFormattedBalance() {
    var fnb = NumberFormat("##0.00€", 'fr_FR');
    return fnb.format(balance.toDouble() / 100.0);
  }

  String getFormattedPoints() {
    var fnb = NumberFormat("##0.00€pts", 'fr_FR');
    return fnb.format(points.toDouble() / 100.0);
  }

}
