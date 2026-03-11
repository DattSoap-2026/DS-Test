import 'package:flutter/material.dart';
import '../../models/types/product_types.dart';
import '../../constants/product_images.dart';

class ProductImageWidget extends StatelessWidget {
  final Product product;
  final double size;
  final BoxFit fit;

  const ProductImageWidget({
    super.key,
    required this.product,
    this.size = 80,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Priority: 1. product.localImagePath, 2. SKU mapping, 3. placeholder
    final imagePath = product.localImagePath ?? 
                      ProductImages.getImagePath(product.sku);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Icon(
                Icons.inventory_2_outlined,
                size: size * 0.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
    );
  }
}
