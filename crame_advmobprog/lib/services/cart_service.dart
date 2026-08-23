import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/cart.dart';

class CartService {
  Future<List<Cart>> getAllCarts() async {
    final response = await http.get(Uri.parse('$host/carts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];
      return cartsJson.map((json) => Cart.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load carts');
    }
  }

  // ENHANCEMENT 3: Get cart by user ID
  Future<Cart> getCartByUserId(int userId) async {
    try {
      final response = await http.get(Uri.parse('$host/carts/user/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List cartsJson = data['carts'] ?? [];
        if (cartsJson.isNotEmpty) {
          return Cart.fromJson(cartsJson.first);
        } else {
          throw Exception('No carts found for user');
        }
      } else {
        throw Exception('Failed to load cart for user $userId');
      }
    } catch (e) {
      if (host.contains('10.0.2.2') || host.contains('localhost')) {
        try {
          final fallbackUrl = Uri.parse('https://dummyjson.com/carts/user/$userId');
          final response = await http.get(fallbackUrl);
          if (response.statusCode == 200) {
            final Map<String, dynamic> data = jsonDecode(response.body);
            final List cartsJson = data['carts'] ?? [];
            if (cartsJson.isNotEmpty) {
              return Cart.fromJson(cartsJson.first);
            } else {
              throw Exception('No carts found for user');
            }
          }
        } catch (_) {}
      }
      rethrow;
    }
  }

  // ENHANCEMENT 3: Add to cart
  Future<Cart> addToCart(int userId, List<Map<String, dynamic>> products) async {
    try {
      final response = await http.post(
        Uri.parse('$host/carts/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'products': products,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Cart.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } catch (e) {
      if (host.contains('10.0.2.2') || host.contains('localhost')) {
        try {
          final fallbackUrl = Uri.parse('https://dummyjson.com/carts/add');
          final response = await http.post(
            fallbackUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'products': products,
            }),
          );
          if (response.statusCode == 201 || response.statusCode == 200) {
            return Cart.fromJson(jsonDecode(response.body));
          }
        } catch (_) {}
      }
      rethrow;
    }
  }
}

