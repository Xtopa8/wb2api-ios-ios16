"""生成 App 图标终选（1024×1024，无透明通道）。"""
from PIL import Image, ImageDraw
import math, os

S, SS = 1024, 4
W = S * SS
OUT = "/var/minis/shared/wb2api-ios/icon-candidates"
os.makedirs(OUT, exist_ok=True)

INK = (26, 24, 21)
PAPER = (250, 248, 244)
CREAM = (245, 241, 233)
TERRA = (194, 84, 47)
TERRA_DEEP = (150, 58, 30)
TERRA_LIGHT = (222, 118, 80)


def gradient(size, c1, c2):
    img = Image.new("RGB", (size, size))
    d = ImageDraw.Draw(img)
    for y in range(size):
        t = y / (size - 1)
        col = tuple(int(c1[k] + (c2[k] - c1[k]) * t) for k in range(3))
        d.line([(0, y), (size, y)], fill=col)
    return img


def dots(draw, cx, cy, r, big, small, gap=0.30, ratio=0.70):
    off = r * gap
    r2 = r * ratio
    draw.ellipse([cx + off - r2, cy - r2, cx + off + r2, cy + r2], fill=small)
    draw.ellipse([cx - off - r, cy - r, cx - off + r, cy + r], fill=big)


def save(img, name):
    img = img.resize((S, S), Image.LANCZOS).convert("RGB")
    img.save(f"{OUT}/{name}.png", "PNG", optimize=True)
    print(name, img.size)


# ── 1 · Terracotta：暖渐变底 + 奶白双点
a = gradient(W, TERRA_LIGHT, TERRA_DEEP)
d = ImageDraw.Draw(a)
dots(d, W * 0.46, W * 0.50, W * 0.205, CREAM, (255, 252, 246), gap=0.30, ratio=0.66)
save(a, "1-terracotta")

# ── 2 · Paper：暖纸底 + 墨/赤陶双点 + 发丝环
b = Image.new("RGB", (W, W), PAPER)
d = ImageDraw.Draw(b)
ring_w = int(W * 0.010)
d.ellipse([W * 0.13, W * 0.13, W * 0.87, W * 0.87],
          outline=(230, 223, 212), width=ring_w)
dots(d, W * 0.46, W * 0.50, W * 0.185, INK, TERRA, gap=0.32, ratio=0.62)
save(b, "2-paper")

# ── 3 · Gauge：暖纸底 + 赤陶 270° 仪表弧 + 双点
c = Image.new("RGB", (W, W), PAPER)
d = ImageDraw.Draw(c)
box = [W * 0.13, W * 0.13, W * 0.87, W * 0.87]
d.arc(box, start=135, end=405, fill=TERRA, width=int(W * 0.075))
dots(d, W * 0.46, W * 0.50, W * 0.135, INK, TERRA, gap=0.34, ratio=0.60)
save(c, "3-gauge")
