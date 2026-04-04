#!/usr/bin/env python3
"""
Placeholder Image Generator for VedantaTrade App Gallery
Creates placeholder images for the app gallery when actual screenshots are not available.
"""

import os
from PIL import Image, ImageDraw, ImageFont
import textwrap

def create_placeholder_image(width, height, text, filename, color_scheme='blue'):
    """Create a placeholder image with text"""
    
    # Color schemes
    colors = {
        'blue': {
            'bg': (52, 152, 219),
            'text': (255, 255, 255),
            'accent': (41, 128, 185)
        },
        'green': {
            'bg': (39, 174, 96),
            'text': (255, 255, 255),
            'accent': (34, 153, 84)
        },
        'purple': {
            'bg': (155, 89, 182),
            'text': (255, 255, 255),
            'accent': (142, 68, 173)
        },
        'orange': {
            'bg': (230, 126, 34),
            'text': (255, 255, 255),
            'accent': (211, 84, 0)
        },
        'red': {
            'bg': (231, 76, 60),
            'text': (255, 255, 255),
            'accent': (192, 57, 43)
        }
    }
    
    scheme = colors.get(color_scheme, colors['blue'])
    
    # Create image
    img = Image.new('RGB', (width, height), scheme['bg'])
    draw = ImageDraw.Draw(img)
    
    # Try to use a nice font, fallback to default
    try:
        font_large = ImageFont.truetype("arial.ttf", 48)
        font_medium = ImageFont.truetype("arial.ttf", 32)
        font_small = ImageFont.truetype("arial.ttf", 24)
    except:
        font_large = ImageFont.load_default()
        font_medium = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    # Add decorative elements
    # Corner accent
    draw.rectangle([0, 0, 100, 100], fill=scheme['accent'])
    
    # Bottom accent
    draw.rectangle([width-100, height-100, width, height], fill=scheme['accent'])
    
    # Main text
    lines = textwrap.wrap(text, width=30)
    y_position = height // 2 - (len(lines) * 30) // 2
    
    for line in lines:
        # Get text size
        bbox = draw.textbbox((0, 0), line, font=font_large)
        text_width = bbox[2] - bbox[0]
        x_position = (width - text_width) // 2
        
        draw.text((x_position, y_position), line, fill=scheme['text'], font=font_large)
        y_position += 60
    
    # Add version info
    version_text = "VedantaTrade v3.4.0"
    bbox = draw.textbbox((0, 0), version_text, font=font_small)
    text_width = bbox[2] - bbox[0]
    draw.text((width - text_width - 20, 20), version_text, fill=scheme['text'], font=font_small)
    
    # Add "Screenshot" label
    label_text = "UI Screenshot"
    bbox = draw.textbbox((0, 0), label_text, font=font_small)
    text_width = bbox[2] - bbox[0]
    draw.text((20, height - 40), label_text, fill=scheme['text'], font=font_small)
    
    # Save image
    img.save(filename, 'PNG', quality=95)
    print(f"Created placeholder: {filename}")

def generate_all_placeholders():
    """Generate all placeholder images for the gallery"""
    
    # Create directories
    directories = ['v34', 'v33', 'v32', 'v31', 'v30']
    for dir_name in directories:
        os.makedirs(f'assets/images/{dir_name}', exist_ok=True)
    
    # Generate hero screenshot
    create_placeholder_image(1200, 800, "VedantaTrade Dashboard", 
                          "assets/images/hero-screenshot.png", 'blue')
    
    # Version 3.4.0 screenshots
    v34_screenshots = [
        ("Enhanced Dashboard", "v34/dashboard.png", 'blue'),
        ("IRDN VAT Returns", "v34/vat-returns.png", 'green'),
        ("Expense Reconciliation", "v34/expense-reconciliation.png", 'purple'),
        ("Inventory Management", "v34/inventory-management.png", 'orange'),
        ("Checkout System", "v34/checkout-system.png", 'red'),
        ("Navigation Before", "v34/nav-before.png", 'blue'),
        ("Navigation After", "v34/nav-after.png", 'green'),
        ("Product Cards Before", "v34/cards-before.png", 'blue'),
        ("Product Cards After", "v34/cards-after.png", 'green'),
        ("Loading Before", "v34/loading-before.png", 'blue'),
        ("Loading After", "v34/loading-after.png", 'green'),
        ("Error Before", "v34/error-before.png", 'red'),
        ("Error After", "v34/error-after.png", 'green')
    ]
    
    for text, filename, color in v34_screenshots:
        create_placeholder_image(1200, 800, text, f"assets/images/{filename}", color)
    
    # Version 3.3.0 screenshots
    v33_screenshots = [
        ("CI/CD Pipeline", "v33/ci-cd.png", 'blue'),
        ("Advanced Monitoring", "v33/monitoring.png", 'green'),
        ("Container Deployment", "v33/container.png", 'purple'),
        ("Enhanced Dashboard", "v33/dashboard.png", 'orange')
    ]
    
    for text, filename, color in v33_screenshots:
        create_placeholder_image(1200, 800, text, f"assets/images/{filename}", color)
    
    # Version 3.2.0 screenshots
    v32_screenshots = [
        ("Glassmorphic UI", "v32/glassmorphic.png", 'blue'),
        ("Smooth Animations", "v32/animations.png", 'green'),
        ("Responsive Design", "v32/responsive.png", 'purple'),
        ("Skeleton Loading", "v32/loading.png", 'orange')
    ]
    
    for text, filename, color in v32_screenshots:
        create_placeholder_image(1200, 800, text, f"assets/images/{filename}", color)
    
    # Version 3.1.0 screenshots
    v31_screenshots = [
        ("Performance Monitor", "v31/performance.png", 'blue'),
        ("Security Features", "v31/security.png", 'green'),
        ("Authentication", "v31/auth.png", 'purple'),
        ("System Optimization", "v31/optimization.png", 'orange')
    ]
    
    for text, filename, color in v31_screenshots:
        create_placeholder_image(1200, 800, text, f"assets/images/{filename}", color)
    
    # Version 3.0.0 screenshots
    v30_screenshots = [
        ("Nepal Localization", "v30/localization.png", 'blue'),
        ("System Redesign", "v30/redesign.png", 'green'),
        ("Distribution Management", "v30/distribution.png", 'purple'),
        ("Checkout System", "v30/checkout.png", 'orange')
    ]
    
    for text, filename, color in v30_screenshots:
        create_placeholder_image(1200, 800, text, f"assets/images/{filename}", color)
    
    print("All placeholder images generated successfully!")

if __name__ == "__main__":
    try:
        from PIL import Image, ImageDraw, ImageFont
        generate_all_placeholders()
    except ImportError:
        print("PIL not installed. Install with: pip install Pillow")
        print("Alternatively, you can create placeholder images manually or use actual screenshots.")
