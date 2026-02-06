#!/usr/bin/env node
/**
 * Generate Below the Surface app icons from SVG
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

// Check if we have the required tools
async function checkTools() {
  try {
    // Check for sips (macOS built-in image processing tool)
    await execPromise('which sips');
    return 'sips';
  } catch (e) {
    console.error('❌ sips command not found');
    return null;
  }
}

// SVG content
const svgContent = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="oceanGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:#1E3A5F;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#2C5F8D;stop-opacity:1" />
        </linearGradient>
        
        <linearGradient id="waveGradient1" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:#3A7BC8;stop-opacity:0.9" />
            <stop offset="100%" style="stop-color:#2C5F8D;stop-opacity:0.7" />
        </linearGradient>
        
        <linearGradient id="waveGradient2" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:#4A90E2;stop-opacity:0.7" />
            <stop offset="100%" style="stop-color:#3A7BC8;stop-opacity:0.5" />
        </linearGradient>
        
        <linearGradient id="waveGradient3" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:#5BA3E8;stop-opacity:0.6" />
            <stop offset="100%" style="stop-color:#4A90E2;stop-opacity:0.4" />
        </linearGradient>
        
        <linearGradient id="circleGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style="stop-color:#7EC8E3;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#5BA3E8;stop-opacity:1" />
        </linearGradient>
    </defs>
    
    <rect width="1024" height="1024" fill="url(#oceanGradient)"/>
    
    <path d="M 0 650 Q 170 600 340 630 Q 510 660 680 610 Q 850 560 1024 590 L 1024 1024 L 0 1024 Z" 
          fill="url(#waveGradient1)"/>
    
    <path d="M 0 720 Q 128 680 256 710 Q 384 740 512 700 Q 640 660 768 700 Q 896 740 1024 710 L 1024 1024 L 0 1024 Z" 
          fill="url(#waveGradient2)"/>
    
    <path d="M 0 800 Q 102 770 204 790 Q 307 810 410 780 Q 512 750 614 775 Q 717 800 819 770 Q 921 740 1024 760 L 1024 1024 L 0 1024 Z" 
          fill="url(#waveGradient3)"/>
    
    <ellipse cx="340" cy="625" rx="40" ry="15" fill="#7EC8E3" opacity="0.3"/>
    <ellipse cx="680" cy="605" rx="35" ry="12" fill="#7EC8E3" opacity="0.3"/>
    <ellipse cx="256" cy="705" rx="30" ry="10" fill="#A8D5E2" opacity="0.4"/>
    <ellipse cx="512" cy="695" rx="35" ry="12" fill="#A8D5E2" opacity="0.4"/>
    <ellipse cx="768" cy="695" rx="30" ry="10" fill="#A8D5E2" opacity="0.4"/>
    
    <circle cx="512" cy="400" r="180" fill="url(#circleGradient)" opacity="0.3"/>
    <circle cx="512" cy="400" r="150" fill="url(#circleGradient)" opacity="0.4"/>
    <circle cx="512" cy="400" r="120" fill="url(#circleGradient)" opacity="0.6"/>
    <circle cx="512" cy="400" r="90" fill="#7EC8E3"/>
    
    <circle cx="512" cy="400" r="60" fill="#A8D5E2" opacity="0.8"/>
    <circle cx="512" cy="400" r="35" fill="#D4EBF2" opacity="0.9"/>
    
    <circle cx="512" cy="400" r="220" fill="none" stroke="#7EC8E3" stroke-width="3" opacity="0.3"/>
    <circle cx="512" cy="400" r="260" fill="none" stroke="#7EC8E3" stroke-width="2" opacity="0.2"/>
    <circle cx="512" cy="400" r="300" fill="none" stroke="#7EC8E3" stroke-width="1.5" opacity="0.1"/>
</svg>`;

// iOS icon sizes
const iconSizes = {
  '1024.png': 1024,
  '180.png': 180,
  '167.png': 167,
  '152.png': 152,
  '120.png': 120,
  '120 1.png': 120,
  '87.png': 87,
  '80.png': 80,
  '80 1.png': 80,
  '76.png': 76,
  '60.png': 60,
  '58.png': 58,
  '58 1.png': 58,
  '40.png': 40,
  '40 1.png': 40,
  '40 2.png': 40,
  '29.png': 29,
  '29 1.png': 29,
  '20.png': 20,
};

async function generateIcons() {
  console.log('🌊 Generating Below the Surface app icons with wave design...\n');
  
  const tool = await checkTools();
  if (!tool) {
    console.error('\n❌ No suitable image processing tool found.');
    console.log('\nPlease use one of these options:');
    console.log('1. Open app-icon-generator.html in a browser and download the icon');
    console.log('2. Use an online tool like https://appicon.co/ with the generated SVG');
    process.exit(1);
  }
  
  const basePath = path.join(__dirname, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset');
  const svgPath = path.join(__dirname, 'temp-icon.svg');
  const basePngPath = path.join(__dirname, 'temp-icon-1024.png');
  
  // Write SVG file
  fs.writeFileSync(svgPath, svgContent);
  console.log('✅ Created SVG file');
  
  // Convert SVG to PNG using qlmanage (macOS built-in)
  try {
    console.log('📐 Converting SVG to PNG...');
    await execPromise(`qlmanage -t -s 1024 -o ${__dirname} ${svgPath}`);
    
    // qlmanage creates filename.svg.png
    const qlOutputPath = path.join(__dirname, 'temp-icon.svg.png');
    if (fs.existsSync(qlOutputPath)) {
      fs.renameSync(qlOutputPath, basePngPath);
    }
    
    console.log('✅ Base PNG created\n');
    
    // Generate all sizes using sips
    let count = 0;
    for (const [filename, size] of Object.entries(iconSizes)) {
      const outputPath = path.join(basePath, filename);
      await execPromise(`sips -z ${size} ${size} ${basePngPath} --out "${outputPath}"`);
      count++;
      process.stdout.write(`\rGenerating icons... ${count}/${Object.keys(iconSizes).length}`);
    }
    
    console.log(`\n\n✅ Successfully generated ${count} icon files!`);
    
    // Clean up temp files
    fs.unlinkSync(svgPath);
    fs.unlinkSync(basePngPath);
    
    console.log('\n🎉 Icon generation complete!');
    console.log('\nNext steps:');
    console.log('1. Build and run the app in Xcode');
    console.log('2. Check the new wave-based icon design\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.log('\nFallback: Please open app-icon-generator.html in a browser');
  }
}

generateIcons();
