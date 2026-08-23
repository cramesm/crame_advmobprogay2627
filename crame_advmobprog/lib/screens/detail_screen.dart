import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 2: Dedicated Product/Article Details Screen
// Displays the complete details of a selected product/article card.

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: product.title,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Product Image Display
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    color: Colors.white,
                    child: Image.network(
                      product.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Title and Price Display Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomText(
                    text: product.title,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: CustomText(
                    text: '\$${product.price.toStringAsFixed(2)}',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Category & Rating Badges
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.category, size: 16.sp, color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: product.category.toUpperCase(),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 16.sp, color: Colors.amber.shade700),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: '${product.rating} / 5.0',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            const Divider(),
            SizedBox(height: 8.h),

            // Full Product Description Section
            CustomText(
              text: 'Description',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: product.description.isNotEmpty
                  ? product.description
                  : 'No description available for this product.',
              fontSize: 14.sp,
            ),
            SizedBox(height: 16.h),

            // Detailed Specifications Section
            CustomText(
              text: 'Specifications',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            _buildSpecRow('Brand', product.brand.isNotEmpty ? product.brand : 'Generic'),
            _buildSpecRow('SKU', product.sku.isNotEmpty ? product.sku : 'N/A'),
            _buildSpecRow('Stock Status', '${product.stock} items available (${product.availabilityStatus})'),
            _buildSpecRow('Weight', '${product.weight} kg'),
            _buildSpecRow(
              'Dimensions',
              '${product.dimensions.width} x ${product.dimensions.height} x ${product.dimensions.depth} cm',
            ),
            _buildSpecRow('Warranty', product.warrantyInformation.isNotEmpty ? product.warrantyInformation : 'Standard Warranty'),
            _buildSpecRow('Shipping', product.shippingInformation.isNotEmpty ? product.shippingInformation : 'Standard Shipping'),
            _buildSpecRow('Return Policy', product.returnPolicy.isNotEmpty ? product.returnPolicy : '30-day Return Policy'),

            SizedBox(height: 16.h),
            const Divider(),
            SizedBox(height: 8.h),

            // Customer Reviews Section
            if (product.reviews.isNotEmpty) ...[
              CustomText(
                text: 'Customer Reviews (${product.reviews.length})',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 8.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: product.reviews.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final review = product.reviews[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        review.reviewerName.isNotEmpty ? review.reviewerName[0].toUpperCase() : 'U',
                      ),
                    ),
                    title: CustomText(
                      text: review.reviewerName,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              starIndex < review.rating ? Icons.star : Icons.star_border,
                              size: 14.sp,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        CustomText(text: review.comment, fontSize: 13.sp),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }


  // Helper Function
  // Formats technical metadata (Brand, SKU, Weight, Dimensions, etc.)
  
  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: CustomText(
              text: label,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

