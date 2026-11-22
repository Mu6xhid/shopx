
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController {
  final ProductService _productService = ProductService();

  Future<List<ProductModel>> fetchProducts() async {
    return await _productService.getProducts();
  }

Future<List<String>> fetchCategories() async {
  return await _productService.getCategories();
}

}
