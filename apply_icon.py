import os
import sys
from PIL import Image

def apply_icon(choice="B"):
    mapping = {
        "A": "icon_hex_fist.png",
        "B": "icon_roman_vi.png",
        "C": "icon_clash_strike.png",
        "D": "icon_master_shield.png",
    }
    file_name = mapping.get(choice.upper(), "icon_roman_vi.png")
    src_path = os.path.join(r"E:\SF6_Tracker\assets\images\icons", file_name)
    
    if not os.path.exists(src_path):
        print(f"Source icon {src_path} not found!")
        return
        
    img = Image.open(src_path).convert("RGBA")
    
    # Mipmap sizes
    mipmap_configs = [
        (r"E:\SF6_Tracker\android\app\src\main\res\mipmap-mdpi\ic_launcher.png", 48),
        (r"E:\SF6_Tracker\android\app\src\main\res\mipmap-hdpi\ic_launcher.png", 72),
        (r"E:\SF6_Tracker\android\app\src\main\res\mipmap-xhdpi\ic_launcher.png", 96),
        (r"E:\SF6_Tracker\android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png", 144),
        (r"E:\SF6_Tracker\android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png", 192),
    ]
    
    for dst, sz in mipmap_configs:
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        resized = img.resize((sz, sz), Image.Resampling.LANCZOS)
        resized.save(dst, "PNG")
        print(f"Saved {dst} ({sz}x{sz})")
        
    print(f"Successfully applied Icon Design [{choice}] to Android project!")

if __name__ == "__main__":
    choice = sys.argv[1] if len(sys.argv) > 1 else "B"
    apply_icon(choice)
