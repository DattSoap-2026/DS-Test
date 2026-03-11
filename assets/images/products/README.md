# Product Images

## Structure
- `finished/` - Finished goods images (DattSoap products)
- `traded/` - Traded goods images (resale products)
- `placeholder.png` - Default fallback image

## Image Specifications
- Format: PNG with transparency
- Size: 512x512px (square)
- Max file size: 50KB per image
- Background: Transparent or white

## Naming Convention
- Use lowercase with underscores
- Include size/variant in name
- Example: `soap_bar_100g.png`, `detergent_powder_1kg.png`

## Sample Products

### Finished Goods (DattSoap)
1. soap_bar_100g.png
2. soap_bar_200g.png
3. soap_bar_500g.png
4. detergent_powder_1kg.png
5. detergent_powder_5kg.png

### Traded Goods (Resale)
1. surf_excel_1kg.png
2. vim_bar_200g.png
3. rin_bar_250g.png
4. harpic_500ml.png
5. lizol_500ml.png

## Adding New Images
1. Create/optimize image to 512x512px, <50KB
2. Save in appropriate folder (finished/ or traded/)
3. Update product in database with localImagePath
4. Rebuild app

## Placeholder
Create a simple icon-based placeholder image at:
`assets/images/products/placeholder.png`

Use a generic product box icon or soap bar silhouette.
