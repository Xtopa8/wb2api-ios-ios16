"""图标 v3：白底 + 大红球 + 小黑球。"""
from PIL import Image, ImageDraw
import os

S, SS = 1024, 4
W = S * SS
OUT = "/var/minis/shared/wb2api-ios/icon-candidates"

WHITE = (255, 255, 255)
RED = (211, 47, 47)        # 正红，饱和但不刺眼
BLACK = (18, 17, 16)


def save(img, name):
    img.resize((S, S), Image.LANCZOS).convert("RGB").save(f"{OUT}/{name}.png", "PNG", optimize=True)
    print(name)


# v3a · 纯白底，大球居左略下，小球右上
img = Image.new("RGB", (W, W), WHITE)
d = ImageDraw.Draw(img)
cx, cy = W * 0.47, W * 0.54
r1 = W * 0.225
r2 = W * 0.115
ox, oy = W * 0.27, -W * 0.21
d.ellipse([cx - r1, cy - r1, cx + r1, cy + r1], fill=RED)
d.ellipse([cx + ox - r2, cy + oy - r2, cx + ox + r2, cy + oy + r2], fill=BLACK)
save(img, "v3-white-red-black")

# v3b · 同构图，大球带轻微下深上浅（同色相，非跨色）
img2 = Image.new("RGB", (W, W), WHITE)
d = ImageDraw.Draw(img2)
# 手工纵向渐变的大球
bx0, by0, bx1, by1 = cx - r1, cy - r1, cx + r1, cy + r1
mask = Image.new("L", (W, W), 0)
ImageDraw.Draw(mask).ellipse([bx0, by0, bx1, by1], fill=255)
grad = Image.new("RGB", (W, W))
gd = ImageDraw.Draw(grad)
for y in range(int(by0), int(by1) + 1):
    t = (y - by0) / (by1 - by0)
    col = tuple(int((239, 110, 100)[k] + (RED[k] - (239, 110, 100)[k]) * t) for k in range(3))
    gd.line([(0, y), (W, y)], fill=col)
img2.paste(grad, (0, 0), mask)
d = ImageDraw.Draw(img2)
d.ellipse([cx + ox - r2, cy + oy - r2, cx + ox + r2, cy + oy + r2], fill=BLACK)
save(img2, "v3b-red-gradient")
