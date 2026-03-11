// Generate simple product images using Node.js Canvas
// Install: npm install canvas
// Run: node generate_images.js

const { createCanvas } = require('canvas');
const fs = require('fs');
const path = require('path');

function createPlaceholder() {
  const canvas = createCanvas(256, 256);
  const ctx = canvas.getContext('2d');
  
  // Gray background
  ctx.fillStyle = '#E0E0E0';
  ctx.fillRect(0, 0, 256, 256);
  
  // Box icon
  ctx.strokeStyle = '#9E9E9E';
  ctx.lineWidth = 3;
  ctx.strokeRect(80, 80, 96, 96);
  
  // Text
  ctx.fillStyle = '#757575';
  ctx.font = 'bold 20px Arial';
  ctx.textAlign = 'center';
  ctx.fillText('No Image', 128, 200);
  
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync('assets/images/products/placeholder.png', buffer);
  console.log('✓ Created: placeholder.png');
}

function createProductImage(name, label, color, folder) {
  const canvas = createCanvas(256, 256);
  const ctx = canvas.getContext('2d');
  
  // Background
  ctx.fillStyle = color + '33'; // 20% opacity
  ctx.fillRect(0, 0, 256, 256);
  
  // Product box
  ctx.fillStyle = '#FFFFFF';
  ctx.fillRect(64, 64, 128, 128);
  
  // Border
  ctx.strokeStyle = color;
  ctx.lineWidth = 4;
  ctx.strokeRect(64, 64, 128, 128);
  
  // Label
  ctx.fillStyle = color;
  ctx.font = 'bold 18px Arial';
  ctx.textAlign = 'center';
  const lines = label.split('\n');
  lines.forEach((line, i) => {
    ctx.fillText(line, 128, 110 + (i * 25));
  });
  
  const buffer = canvas.toBuffer('image/png');
  const filePath = `assets/images/products/${folder}/${name}.png`;
  fs.writeFileSync(filePath, buffer);
  console.log(`✓ Created: ${name}.png`);
}

console.log('🎨 Generating product images...\n');

// Create directories
['finished', 'traded'].forEach(dir => {
  const dirPath = path.join('assets', 'images', 'products', dir);
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
});

// Generate placeholder
createPlaceholder();

// Finished goods
const finished = [
  ['soap_100g', 'Soap\n100g', '#2196F3'],
  ['soap_200g', 'Soap\n200g', '#2196F3'],
  ['soap_500g', 'Soap\n500g', '#2196F3'],
  ['detergent_1kg', 'Detergent\n1kg', '#4CAF50'],
  ['detergent_5kg', 'Detergent\n5kg', '#4CAF50'],
];

finished.forEach(([name, label, color]) => {
  createProductImage(name, label, color, 'finished');
});

// Traded goods
const traded = [
  ['surf_1kg', 'Surf\nExcel', '#F44336'],
  ['vim_200g', 'Vim\nBar', '#FF9800'],
  ['rin_250g', 'Rin\nBar', '#2196F3'],
  ['harpic_500ml', 'Harpic\n500ml', '#9C27B0'],
  ['lizol_500ml', 'Lizol\n500ml', '#009688'],
];

traded.forEach(([name, label, color]) => {
  createProductImage(name, label, color, 'traded');
});

console.log('\n✅ All images generated!');
console.log('📦 Total: 11 images');
console.log('📁 Location: assets/images/products/');
