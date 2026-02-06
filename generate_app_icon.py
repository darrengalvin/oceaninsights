#!/usr/bin/env python3
"""Generate Below the Surface app icon with realistic wave design"""

import os
from pathlib import Path

# Try to import required libraries
try:
    from PIL import Image, ImageDraw
    import cairosvg
except ImportError:
    print("Installing required packages...")
    os.system("pip3 install pillow cairosvg")
    from PIL import Image, ImageDraw
    import cairosvg

# SVG content with improved wave design
svg_content = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
    <!-- Background gradient -->
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
    
    <!-- Background -->
    <rect width="1024" height="1024" fill="url(#oceanGradient)"/>
    
    <!-- Wave layers with more natural curves (representing ocean waves) -->
    <!-- Back wave - larger, slower curve -->
    <path d="M 0 650 Q 170 600 340 630 Q 510 660 680 610 Q 850 560 1024 590 L 1024 1024 L 0 1024 Z" 
          fill="url(#waveGradient1)"/>
    
    <!-- Middle wave - medium curve with foam-like top -->
    <path d="M 0 720 Q 128 680 256 710 Q 384 740 512 700 Q 640 660 768 700 Q 896 740 1024 710 L 1024 1024 L 0 1024 Z" 
          fill="url(#waveGradient2)"/>
    
    <!-- Front wave - more dynamic crests -->
    <path d="M 0 800 Q 102 770 204 790 Q 307 810 410 780 Q 512 750 614 775 Q 717 800 819 770 Q 921 740 1024 760 L 1024 1024 L 0 1024 Z" 
          fill="url(#waveGradient3)"/>
    
    <!-- Wave highlights/foam effects on crests -->
    <ellipse cx="340" cy="625" rx="40" ry="15" fill="#7EC8E3" opacity="0.3"/>
    <ellipse cx="680" cy="605" rx="35" ry="12" fill="#7EC8E3" opacity="0.3"/>
    <ellipse cx="256" cy="705" rx="30" ry="10" fill="#A8D5E2" opacity="0.4"/>
    <ellipse cx="512" cy="695" rx="35" ry="12" fill="#A8D5E2" opacity="0.4"/>
    <ellipse cx="768" cy="695" rx="30" ry="10" fill="#A8D5E2" opacity="0.4"/>
    
    <!-- Center breathing circle (represents calm/meditation) -->
    <circle cx="512" cy="400" r="180" fill="url(#circleGradient)" opacity="0.3"/>
    <circle cx="512" cy="400" r="150" fill="url(#circleGradient)" opacity="0.4"/>
    <circle cx="512" cy="400" r="120" fill="url(#circleGradient)" opacity="0.6"/>
    <circle cx="512" cy="400" r="90" fill="#7EC8E3"/>
    
    <!-- Inner glow effect -->
    <circle cx="512" cy="400" r="60" fill="#A8D5E2" opacity="0.8"/>
    <circle cx="512" cy="400" r="35" fill="#D4EBF2" opacity="0.9"/>
    
    <!-- Subtle ripple rings (representing mindfulness/awareness) -->
    <circle cx="512" cy="400" r="220" fill="none" stroke="#7EC8E3" stroke-width="3" opacity="0.3"/>
    <circle cx="512" cy="400" r="260" fill="none" stroke="#7EC8E3" stroke-width="2" opacity="0.2"/>
    <circle cx="512" cy="400" r="300" fill="none" stroke="#7EC8E3" stroke-width="1.5" opacity="0.1"/>
</svg>'''

# iOS icon sizes
icon_sizes = {
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
}

def generate_icons():
    """Generate all required icon sizes"""
    base_path = Path(__file__).parent / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    
    print(f"Generating icons in: {base_path}")
    
    # Generate base 1024x1024 PNG from SVG
    print("Converting SVG to PNG...")
    png_data = cairosvg.svg2png(bytestring=svg_content.encode('utf-8'), output_width=1024, output_height=1024)
    
    # Load as PIL Image
    from io import BytesIO
    base_image = Image.open(BytesIO(png_data))
    
    # Generate all sizes
    for filename, size in icon_sizes.items():
        print(f"Generating {filename} ({size}x{size})...")
        resized = base_image.resize((size, size), Image.Resampling.LANCZOS)
        output_path = base_path / filename
        resized.save(output_path, 'PNG')
    
    print(f"\n✅ Successfully generated {len(icon_sizes)} icon files!")
    print("\nNext steps:")
    print("1. Build and run the app in Xcode")
    print("2. Check the new wave-based icon design")

if __name__ == '__main__':
    generate_icons()
