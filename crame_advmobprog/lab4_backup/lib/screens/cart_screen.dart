import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'detail_screen.dart';

// ENHANCEMENT 1: Make a cart_screen in order to render the new API endpoint.
// The items on the cart_screen must be clickable going to the detail_screen.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();

  late Future<Cart> _cartFuture;
  final int _userId = 30; 

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  void _fetchCart() {
    setState(() {
      _cartFuture = _cartService.getCartByUserId(_userId);
    });
  }

  // ENHANCEMENT 3: Also try to use add to cart by passing the values of the product
  Future<void> _addToCart() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final newCart = await _cartService.addToCart(_userId, [
        {"id": 144, "quantity": 1} // adding a sample product
      ]);

      if (!mounted) return;
      Navigator.pop(context); // close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to cart! New total items: ${newCart.totalProducts}')),
      );

      // Refresh the cart UI
      _fetchCart();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item: $e')),
      );
    }
  }

  Future<void> _navigateToDetail(int productId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final product = await _productService.getProductById(productId);

      if (!mounted) return;
      Navigator.pop(context); // close dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load product details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: CustomText(text: 'Error: ${snapshot.error}', fontSize: 16.sp),
            );
          } else if (!snapshot.hasData || snapshot.data!.products.isEmpty) {
            return Center(
              child: CustomText(text: 'Your cart is empty', fontSize: 18.sp),
            );
          }

          final cart = snapshot.data!;

          return Container(
            color: const Color(0xFFF7F7F9),
            child: Column(
              children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: cart.products.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = cart.products[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () => _navigateToDetail(item.id),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            child: Row(
                              children: [
                                // Product Image
                                SizedBox(
                                  width: 70.w,
                                  height: 70.w,
                                  child: Image.network(
                                    item.thumbnail,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: item.title,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6.h),
                                      CustomText(
                                        text: '\$${item.price.toStringAsFixed(2)}',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      SizedBox(height: 6.h),
                                      CustomText(
                                        text: '${item.discountPercentage.toStringAsFixed(0)}% off • \$${item.total.toStringAsFixed(2)} total',
                                        fontSize: 11.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // Quantity Controls
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 28.w,
                                      height: 28.w,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(Icons.add, size: 16.sp, color: Colors.white),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.h),
                                      child: CustomText(
                                        text: '${item.quantity}',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      width: 28.w,
                                      height: 28.w,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(Icons.remove, size: 16.sp, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Subtotal:',
                            fontSize: 15.sp,
                            color: Colors.grey.shade500,
                          ),
                          CustomText(
                            text: '\$${cart.total.toStringAsFixed(2)}',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Delivery Fee:',
                            fontSize: 15.sp,
                            color: Colors.grey.shade500,
                          ),
                          CustomText(
                            text: '\$0.00',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          onPressed: _addToCart,
                          child: CustomText(
                            text: 'Confirm Order',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      ),
    );
  }
}
