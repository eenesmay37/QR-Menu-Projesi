import 'package:firebase_database/firebase_database.dart';

import '../core/table_session.dart';
import '../features/cart/cart_service.dart';
import '../features/payment/payment_page.dart';

class OrderService {
  OrderService._();

  static final DatabaseReference _ordersRef =
      FirebaseDatabase.instance.ref("orders");

  static Future<void> createOrder({
    required List<CartItem> items,
    required int totalPrice,
    required PaymentMethodType paymentMethod,
  }) async {
    final newOrderRef = _ordersRef.push();

    final tableNumber = TableSession.instance.tableNumber ?? '';

    final Map<String, dynamic> orderData = {
      "orderId": newOrderRef.key,
      "createdAt": ServerValue.timestamp,
      "status": "pending",
      "paymentStatus":
          paymentMethod == PaymentMethodType.card ? "paid" : "pending",
      "paymentMethod": _paymentMethodToString(paymentMethod),
      "tableNumber": tableNumber,
      "totalPrice": totalPrice,
      "totalQuantity": items.fold(0, (sum, item) => sum + item.quantity),
      "items": items
          .map(
            (item) => {
              "name": item.name,
              "category": item.category,
              "price": item.price,
              "quantity": item.quantity,
              "totalPrice": item.totalPrice,
            },
          )
          .toList(),
    };

    await newOrderRef.set(orderData);
  }

  static String _paymentMethodToString(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.card:
        return "card";
      case PaymentMethodType.cash:
        return "cash";
      case PaymentMethodType.payAtTable:
        return "pay_at_table";
    }
  }
}
