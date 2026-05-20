import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final String category;
  final int price;
  int quantity;

  CartItem({
    required this.name,
    required this.category,
    required this.price,
    this.quantity = 1,
  });

  int get totalPrice => price * quantity;
}

class CartService {
  CartService._internal();

  static final CartService instance = CartService._internal();

  final ValueNotifier<List<CartItem>> cartItems = ValueNotifier<List<CartItem>>(
    [],
  );

  void addItem({
    required String name,
    required String category,
    required int price,
  }) {
    final current = List<CartItem>.from(cartItems.value);

    final index = current.indexWhere((item) => item.name == name);

    if (index != -1) {
      current[index].quantity++;
    } else {
      current.add(
        CartItem(
          name: name,
          category: category,
          price: price,
          quantity: 1,
        ),
      );
    }

    cartItems.value = current;
  }

  void increaseQuantity(CartItem item) {
    final current = List<CartItem>.from(cartItems.value);
    final index = current.indexWhere((e) => e.name == item.name);

    if (index != -1) {
      current[index].quantity++;
      cartItems.value = current;
    }
  }

  void decreaseQuantity(CartItem item) {
    final current = List<CartItem>.from(cartItems.value);
    final index = current.indexWhere((e) => e.name == item.name);

    if (index != -1) {
      if (current[index].quantity > 1) {
        current[index].quantity--;
      } else {
        current.removeAt(index);
      }
      cartItems.value = current;
    }
  }

  void removeItem(CartItem item) {
    final current = List<CartItem>.from(cartItems.value);
    current.removeWhere((e) => e.name == item.name);
    cartItems.value = current;
  }

  int get totalPrice {
    return cartItems.value.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get totalQuantity {
    return cartItems.value.fold(0, (sum, item) => sum + item.quantity);
  }

  void clearCart() {
    cartItems.value = [];
  }
}
