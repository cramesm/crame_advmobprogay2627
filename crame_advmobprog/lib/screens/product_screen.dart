import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// models
import '../models/product.dart';

// services
import '../services/product_service.dart';

// widgets
import '../widgets/custom_text.dart';

// screens
import 'detail_screen.dart';

class ProductScreen extends StatefulWidget {
  final ProductService? productService;

  const ProductScreen({super.key, this.productService});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final ProductService _productService;
  late Future<List<Product>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();

  // ENHANCEMENT 1: Search Query State Variable
  // Stores the user's active search query input string.

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productService = widget.productService ?? ProductService();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    _productsFuture = _productService.getAllProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar positioned directly above the article/product list
              _buildSearchBar(),
              SizedBox(height: 16.h),
              _buildProductGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // Search Bar UI Component
  // Renders an interactive search input text field above the product list.

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search premium products...',
          prefixIcon: Icon(Icons.search, size: 22.sp, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildProductGrid() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.r),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  CustomText(
                    text: 'Error: ${snapshot.error}',
                    fontSize: 14.sp,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: _refreshProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final allProducts = snapshot.data ?? [];

        //  Real-Time List Filtering Function
        // Filters the list of products according to the search query.

        final filteredProducts = _searchQuery.isEmpty
            ? allProducts
            : allProducts.where((product) {
                final query = _searchQuery.toLowerCase();
                return product.title.toLowerCase().contains(query) ||
                    product.category.toLowerCase().contains(query) ||
                    product.brand.toLowerCase().contains(query);
              }).toList();

        if (filteredProducts.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: CustomText(
                text: _searchQuery.isEmpty
                    ? 'No products found.'
                    : 'No products matching "$_searchQuery".',
                fontSize: 14.sp,
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            return _buildProductCard(filteredProducts[index]);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: Container(
                    color: Colors.white,
                    child: Image.network(
                      product.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, size: 32.sp, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: product.title,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    CustomText(
                      text: '\$${product.price.toStringAsFixed(2)}',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



