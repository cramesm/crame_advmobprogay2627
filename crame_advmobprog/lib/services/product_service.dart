import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/product.dart';

/// Service responsible for fetching product data from remote API endpoint.
class ProductService {
  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches all products from the remote server.
  Future<List<Product>> getAllProducts() async {
    final url = Uri.parse('$host/products');

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        return _parseProducts(response.body);
      } else {
        throw HttpException(
          'Failed to load products. Server responded with status code ${response.statusCode}',
          uri: url,
        );
      }
    } catch (e) {
      // If local server is not running (Connection Refused), fallback to public dummyjson API
      if (host.contains('10.0.2.2') || host.contains('localhost')) {
        try {
          final fallbackUrl = Uri.parse('https://dummyjson.com/products');
          final response = await _client.get(fallbackUrl);
          if (response.statusCode == 200) {
            return _parseProducts(response.body);
          }
        } catch (_) {
          // If fallback fails, rethrow original error
        }
      }

      if (e is HttpException) rethrow;
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Fetches a single product by ID from the remote server.
  Future<Product> getProductById(int id) async {
    final url = Uri.parse('$host/products/$id');

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw HttpException(
          'Failed to load product. Server responded with status code ${response.statusCode}',
          uri: url,
        );
      }
    } catch (e) {
      // If local server is not running (Connection Refused), fallback to public dummyjson API
      if (host.contains('10.0.2.2') || host.contains('localhost')) {
        try {
          final fallbackUrl = Uri.parse('https://dummyjson.com/products/$id');
          final response = await _client.get(fallbackUrl);
          if (response.statusCode == 200) {
            return Product.fromJson(jsonDecode(response.body));
          }
        } catch (_) {}
      }

      if (e is HttpException) rethrow;
      throw Exception('Failed to fetch product: $e');
    }
  }

  List<Product> _parseProducts(String responseBody) {
    final Map<String, dynamic> data = jsonDecode(responseBody);
    final List<dynamic> productsJson = data['products'] as List<dynamic>? ?? [];

    return productsJson
        .whereType<Map<String, dynamic>>()
        .map((json) => Product.fromJson(json))
        .toList();
  }
}


