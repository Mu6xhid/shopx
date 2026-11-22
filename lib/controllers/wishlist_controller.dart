
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WishlistController extends ChangeNotifier {
  WishlistController._();

  static final WishlistController instance = WishlistController._();

  final List<ProductModel> _items = [];

  List<ProductModel> get items => List.unmodifiable(_items);

  bool isWishlisted(int productId) {
    return _items.any((product) => product.id == productId);
  }

  void toggleWishlist(ProductModel product) {
    if (isWishlisted(product.id)) {
      _items.removeWhere((item) => item.id == product.id);
    } else {
      _items.add(product);
    }

    notifyListeners();
  }

  void removeFromWishlist(int productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }
}
