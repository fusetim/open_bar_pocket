import 'package:open_bar_pocket/models/order.dart';

class LastOrdersResponse {
  int page;
  int limit;
  int maxPage;
  List<Order> orders;

  LastOrdersResponse({required this.page, required this.limit, required this.maxPage, required this.orders});

  factory LastOrdersResponse.fromJson(Map<String, dynamic> json) {
    List<Order> orders = List.empty(growable: true);
    for (var o in json["transactions"]) {
      orders.add(Order.fromJson(o));
    }
    return LastOrdersResponse(
      page: json["page"],
      limit: json["limit"],
      maxPage: json["max_page"],
      orders: orders,
    );
  }
}