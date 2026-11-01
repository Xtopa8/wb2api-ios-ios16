"""图标 v2：加大小圆差异与间隙，小尺寸可辨。"""
from PIL import Image, ImageDraw
import math, os

S, SS = 1024, 4
W = S * SS
OUT = "/var/minis/shared/wb2api-ios/icon-candidates"

CREAM = (247, 243, 236)
TERRA_LIGHT = (224, 118, 80)
TERRA = (194, 84, 47)
TERRA_DEEP = (146, 55, 28)


def gradient(size, c1, c2):
    img = Image.new("RGB", (size, size))
    d = ImageDraw.Draw(img)
    for y in range(size):
        t = y / (size - 1)
        col = tuple(int(c1[k] + (c2[k] - c1[k]) * t) for k in range(3))
        d.line([(0, y), (size, y)], fill=col)
    return img


def save(img, name):
    img.resize((S, S), Image.LANCZOS).convert("RGB").save(f"{OUT}/{name}.png", "PNG", optimize=True)
    print(name)


# v2 · 双点：大点左、小点右上明显分离（gap 0.42 / ratio 0.52）
img = gradient(W, TERRA_LIGHT, TERRA_DEEP)
d = ImageDraw.Draw(img)
cx, cy = W * 0.48, W * 0.52
r1 = W * 0.215          # 大点
r2 = W * 0.112          # 小点（约一半）
ox, oy = W * 0.245, -W * 0.175   # 小点偏右上
# 小点带一点深色描边增加分离感
d.ellipse([cx+ox-r2-W*0.008, cy+oy-r2-W*0.008, cx+ox+r2+W*0.008, cy+oy+r2+W*0.008],
          fill=TERRA_DEEP)
d.ellipse([cx+ox-r2, cy+oy-r2, cx+ox+r2, cy+oy+r2], fill=CREAM)
d.ellipse([cx-r1, cy-r1, cx+r1, cy+r1], fill=CREAM)
save(img, "v2-separated")
