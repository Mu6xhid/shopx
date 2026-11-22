
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {
  static const String baseUrl = 'https://fakestoreapi.com';

  Future<List<ProductModel>> getProducts() async {
    final url = Uri.parse('$baseUrl/products');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) {
        return ProductModel.fromJson(json);
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }


Future<List<String>> getCategories() async {
  final response = await http.get(
    Uri.parse('$baseUrl/products/categories'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    return data.map((category) => category.toString()).toList();
  } else {
    throw Exception('Failed to load categories');
  }
}

}

