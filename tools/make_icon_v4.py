"""图标 v4：白底 + 品牌紫大球（#7C5CFF）+ 小黑球。

v3 用的是正红，v4 按品牌强调色改为紫色；构图与尺寸保持不变，便于对比。
运行：python3 tools/make_icon_v4.py
输出：WB2API/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
"""
from PIL import Image, ImageDraw
import os

S, SS = 1024, 4
W = S * SS
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "WB2API/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
PREVIEW = os.path.join(ROOT, "icon-candidates/v4-white-purple-black.png")

WHITE = (255, 255, 255)
PURPLE = (124, 92, 255)   # #7C5CFF 品牌紫
BLACK = (18, 17, 16)


def main() -> None:
    img = Image.new("RGB", (W, W), WHITE)
    d = ImageDraw.Draw(img)
    cx, cy = W * 0.47, W * 0.54
    r1, r2 = W * 0.225, W * 0.115
    ox, oy = W * 0.27, -W * 0.21
    d.ellipse([cx - r1, cy - r1, cx + r1, cy + r1], fill=PURPLE)
    d.ellipse([cx + ox - r2, cy + oy - r2, cx + ox + r2, cy + oy + r2], fill=BLACK)

    icon = img.resize((S, S), Image.LANCZOS).convert("RGB")
    icon.save(OUT, "PNG", optimize=True)
    os.makedirs(os.path.dirname(PREVIEW), exist_ok=True)
    icon.save(PREVIEW, "PNG", optimize=True)
    print("written:", OUT)


if __name__ == "__main__":
    main()
