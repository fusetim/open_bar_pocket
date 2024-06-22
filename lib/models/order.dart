import 'package:intl/intl.dart';

class Order {
  final String id;
  final String accountId;
  final String accountName;
  final int createdAt;
  final OrderState state;
  final int totalCost;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.createdAt,
    required this.state,
    required this.totalCost,
    required this.items,
  });

  @override
  bool operator ==(Object other) {
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory Order.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = json["items"];
    List<OrderItem> orderItems = List.empty(growable: true);
    for (Map<String, dynamic> item in items) {
      orderItems.add(OrderItem.fromJson(item));
    }
    return Order(
      id: json["id"],
      accountId: json["account_id"],
      accountName: json["account_name"],
      createdAt: json["created_at"],
      state: OrderState.fromText(json["state"]),
      totalCost: json["total_cost"],
      items: orderItems,
    );
  }

  int get totalItems => items.fold(0, (previousValue, element) => previousValue + element.itemAmount);

  int get totalItemsDone {
    if (isFinished) return totalItems;
    return items.fold(0, (previousValue, element) {
      if (element.state == OrderState.finished) {
        return previousValue + element.itemAmount;
      }
      return previousValue;
    });
  }

  int get totalItemsLeft => totalItems - totalItemsDone;

  bool get isFinished => state == OrderState.finished;

  bool get isCanceled => state == OrderState.canceled;

  String getFormattedTotalCost() {
    var fnb = NumberFormat("##0.00€", 'fr_FR');
    return fnb.format(totalCost.toDouble() / 100.0);
  }

  String getFormattedDate() {
    var date = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    var formatter = DateFormat("dd/MM/yyyy HH:mm");
    return formatter.format(date);
  }
}

class OrderItem {
  final String itemId;
  final String itemName;
  final int itemAmount;
  final int totalCost;
  final int unitCost;
  final bool isMenu;
  final int itemAlreadyDone;
  final String pictureUri;
  final OrderState state;

  const OrderItem({
    required this.itemId,
    required this.itemName,
    required this.itemAmount,
    required this.totalCost,
    required this.unitCost,
    required this.isMenu,
    required this.itemAlreadyDone,
    required this.pictureUri,
    required this.state,
  });

  @override
  bool operator ==(Object other) {
    return other is OrderItem && other.itemId == itemId;
  }

  @override
  int get hashCode => itemId.hashCode;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json["item_id"],
      itemName: json["item_name"],
      itemAmount: json["item_amount"],
      totalCost: json["total_cost"],
      unitCost: json["unit_cost"],
      isMenu: json["is_menu"],
      itemAlreadyDone: json["item_already_done"],
      pictureUri: json["picture_uri"],
      state: OrderState.fromText(json["state"]),
    );
  }
}

enum OrderState {
  started,
  takenCareOf,
  finished,
  canceled,
  unknown;

  static OrderState fromText(String text) {
    switch (text) {
      case "started":
        return OrderState.started;
      case "taken_care_of":
        return OrderState.takenCareOf;
      case "finished":
        return OrderState.finished;
      case "canceled":
        return OrderState.canceled;
      default:
        return OrderState.unknown;
    }
  }
}