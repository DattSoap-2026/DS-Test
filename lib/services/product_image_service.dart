import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/types/product_types.dart';
import '../utils/app_logger.dart';

class ProductImageService {
  static final ProductImageService _instance = ProductImageService._internal();
  factory ProductImageService() => _instance;
  ProductImageService._internal();

  Map<String, String>? _imageMap;

  Future<void> loadImageMappings() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/product_images.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      _imageMap = {};
      
      // Load finished goods
      final finished = data['finished_goods'] as Map<String, dynamic>?;
      if (finished != null) {
        finished.forEach((key, value) {
          _imageMap![key] = value.toString();
        });
      }
      
      // Load traded goods
      final traded = data['traded_goods'] as Map<String, dynamic>?;
      if (traded != null) {
        traded.forEach((key, value) {
          _imageMap![key] = value.toString();
        });
      }
      
      AppLogger.success('Loaded ${_imageMap!.length} product image mappings', tag: 'ProductImage');
    } catch (e) {
      AppLogger.error('Failed to load product images', error: e, tag: 'ProductImage');
      _imageMap = {};
    }
  }

  String? getImagePath(Product product) {
    if (_imageMap == null) return null;
    
    // Try SKU first
    if (_imageMap!.containsKey(product.sku)) {
      return _imageMap![product.sku];
    }
    
    // Try product ID
    if (_imageMap!.containsKey(product.id)) {
      return _imageMap![product.id];
    }
    
    return null;
  }

  String getImagePathOrPlaceholder(Product product) {
    return product.localImagePath ?? 
           getImagePath(product) ?? 
           'assets/images/products/placeholder.webp';
  }
}
