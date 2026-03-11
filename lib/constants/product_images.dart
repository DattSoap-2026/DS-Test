class ProductImages {
  // Placeholder - Simple gray box with icon
  static const String placeholder = 'assets/images/products/placeholder.png';
  
  // Finished Goods - DattSoap Products
  static const Map<String, String> finishedGoods = {
    'SOAP-100G': 'assets/images/products/finished/soap_100g.png',
    'SOAP-200G': 'assets/images/products/finished/soap_200g.png',
    'SOAP-500G': 'assets/images/products/finished/soap_500g.png',
    'DET-1KG': 'assets/images/products/finished/detergent_1kg.png',
    'DET-5KG': 'assets/images/products/finished/detergent_5kg.png',
  };
  
  // Traded Goods - Resale Products
  static const Map<String, String> tradedGoods = {
    'SURF-1KG': 'assets/images/products/traded/surf_1kg.png',
    'VIM-200G': 'assets/images/products/traded/vim_200g.png',
    'RIN-250G': 'assets/images/products/traded/rin_250g.png',
    'HARPIC-500ML': 'assets/images/products/traded/harpic_500ml.png',
    'LIZOL-500ML': 'assets/images/products/traded/lizol_500ml.png',
  };
  
  static String getImagePath(String sku) {
    return finishedGoods[sku] ?? tradedGoods[sku] ?? placeholder;
  }
}
