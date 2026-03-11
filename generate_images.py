#!/usr/bin/env python3
"""
Generate optimized product images in WebP format
Requires: pip install pillow
Usage: python generate_images.py
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_placeholder():
    """Create placeholder image"""
    size = 256
    img = Image.new('RGB', (size, size), '#E0E0E0')
    draw = ImageDraw.Draw(img)
    
    # Draw box icon
    box_size = int(size * 0.4)
    box_pos = (size - box_size) // 2
    draw.rectangle(
        [box_pos, box_pos, box_pos + box_size, box_pos + box_size],
        outline='#9E9E9E',
        width=3
    )
    
    # Draw text
    try:
        font = ImageFont.truetype("arial.ttf", 24)
    except:
        font = ImageFont.load_default()
    
    text = "No Image"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    text_pos = ((size - text_width) // 2, int(size * 0.7))
    draw.text(text_pos, text, fill='#757575', font=font)
    
    # Save as WebP with high compression
    output = 'assets/images/products/placeholder.webp'
    img.save(output, 'WEBP', quality=80, method=6)
    print(f'✓ Created: {output} ({os.path.getsize(output)} bytes)')

def create_product_image(name, label, color, folder):
    """Create product image with label"""
    size = 256
    img = Image.new('RGB', (size, size), color)
    draw = ImageDraw.Draw(img)
    
    # Draw product box
    box_size = int(size * 0.5)
    box_pos = (size - box_size) // 2
    box_y = int(size * 0.35)
    draw.rounded_rectangle(
        [box_pos, box_y, box_pos + box_size, box_y + box_size],
        radius=12,
        fill='white'
    )
    
    # Draw label
    try:
        font = ImageFont.truetype("arial.ttf", 20)
    except:
        font = ImageFont.load_default()
    
    lines = label.split('\n')
    y_offset = box_y + box_size // 2 - len(lines) * 15
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        text_width = bbox[2] - bbox[0]
        x = (size - text_width) // 2
        draw.text((x, y_offset), line, fill=color, font=font)
        y_offset += 30
    
    # Save as WebP
    output = f'assets/images/products/{folder}/{name}.webp'
    img.save(output, 'WEBP', quality=75, method=6)
    print(f'✓ Created: {output} ({os.path.getsize(output)} bytes)')

def main():
    print('🎨 Generating optimized product images...\n')
    
    # Create directories
    os.makedirs('assets/images/products/finished', exist_ok=True)
    os.makedirs('assets/images/products/traded', exist_ok=True)
    
    # Generate placeholder
    create_placeholder()
    
    # Finished goods
    finished = [
        ('soap_bar_100g', 'Soap\n100g', '#2196F3'),
        ('soap_bar_200g', 'Soap\n200g', '#2196F3'),
        ('soap_bar_500g', 'Soap\n500g', '#2196F3'),
        ('detergent_powder_1kg', 'Detergent\n1kg', '#4CAF50'),
        ('detergent_powder_5kg', 'Detergent\n5kg', '#4CAF50'),
    ]
    
    for name, label, color in finished:
        create_product_image(name, label, color, 'finished')
    
    # Traded goods
    traded = [
        ('surf_excel_1kg', 'Surf\nExcel', '#F44336'),
        ('vim_bar_200g', 'Vim\nBar', '#FF9800'),
        ('rin_bar_250g', 'Rin\nBar', '#2196F3'),
        ('harpic_500ml', 'Harpic\n500ml', '#9C27B0'),
        ('lizol_500ml', 'Lizol\n500ml', '#009688'),
    ]
    
    for name, label, color in traded:
        create_product_image(name, label, color, 'traded')
    
    # Calculate total size
    total_size = 0
    for root, dirs, files in os.walk('assets/images/products'):
        for file in files:
            if file.endswith('.webp'):
                total_size += os.path.getsize(os.path.join(root, file))
    
    print(f'\n✅ All images generated!')
    print(f'📦 Total size: {total_size // 1024}KB for 11 images')
    print(f'📁 Location: assets/images/products/')

if __name__ == '__main__':
    main()
