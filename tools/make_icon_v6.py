"""图标方案 v6：参考 Clash / Shadowrocket / Loon / Surge 的做法——
白底、单一图形、粗壮轮廓、品牌紫渐变、带一点手感（高光 / 投影）。

三个方向：
  A 水滴 + 活力点   （"池"）
  B 三层叠盘        （额度 / 积分池）
  C 圆角 W 字标     （品牌）
"""
from PIL import Image, ImageDraw, ImageFilter
import math
import os

S = 1024
SS = 4
W = S * SS
OUT = "/var/minis/shared/wb2api-ios/icon-candidates"
os.makedirs(OUT, exist_ok=True)

TOP = (142, 122, 255)     # #8E7AFF
BOTTOM = (92, 61, 226)    # #5C3DE2
WHITE = (255, 255, 255)


def gradient(size, top=TOP, bottom=BOTTOM):
    """竖直线性渐变。"""
    g = Image.new("RGB", (1, size))
    px = g.load()
    for y in range(size):
        t = y / max(size - 1, 1)
        px[0, y] = (
            int(top[0] + (bottom[0] - top[0]) * t),
            int(top[1] + (bottom[1] - top[1]) * t),
            int(top[2] + (bottom[2] - top[2]) * t),
        )
    return g.resize((size, size)).convert("RGBA")


def glyph_mask(size):
    return Image.new("L", (size, size), 0)


def compose(mask, shadow=True, pad=0.0):
    """把蒙版填上渐变，加柔和高光与投影，贴到白底上。"""
    size = mask.size[0]
    grad = gradient(size)
    body = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    body.paste(grad, (0, 0), mask)

    # 左上高光：沿蒙版边缘往内一小块的浅色
    hi = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hi.paste(Image.new("RGBA", (size, size), (255, 255, 255, 60)), (0, 0), mask)
    hi = hi.filter(ImageFilter.GaussianBlur(size * 0.02))
    hl_mask = mask.filter(ImageFilter.GaussianBlur(size * 0.03)).point(lambda v: int(v * 0.55))
    body = Image.alpha_composite(body, Image.composite(hi, Image.new("RGBA", (size, size), (0, 0, 0, 0)), hl_mask).crop((0, 0, size, size)))

    out = Image.new("RGBA", (size, size), WHITE + (255,))
    if shadow:
        sh = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        sh.paste(Image.new("RGBA", (size, size), (60, 40, 140, 70)), (0, int(size * 0.012)), mask)
        sh = sh.filter(ImageFilter.GaussianBlur(size * 0.035))
        out = Image.alpha_composite(out, sh)
    out = Image.alpha_composite(out, body)
    return out.convert("RGB").resize((S, S), Image.LANCZOS)


# ---------------- A · 水滴 + 活力点 ----------------
mask = glyph_mask(W)
d = ImageDraw.Draw(mask)
cx, cy, r = W * 0.44, W * 0.56, W * 0.245
apex = (W * 0.62, W * 0.215)
# 切线连接：apex → 圆的两侧
tang = (W * 0.155)
d.polygon([
    (cx - tang, cy - r * 0.92),
    apex,
    (cx + tang * 0.98, cy - r * 0.80),
], fill=255)
d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
d.ellipse([apex[0] - W * 0.035, apex[1] - W * 0.035, apex[0] + W * 0.035, apex[1] + W * 0.035], fill=255)
compose(mask).resize((S, S), Image.LANCZOS).save(f"{OUT}/v6-a-drop.png")
print("v6-a-drop")

# ---------------- B · 三层叠盘 ----------------
mask = glyph_mask(W)
d = ImageDraw.Draw(mask)
cw, ch = W * 0.46, W * 0.145
x = (W - cw) / 2
base_y = W * 0.70
gap = W * 0.026
for i in range(3):
    y = base_y - i * (ch + gap)
    d.rounded_rectangle([x, y, x + cw, y + ch], radius=ch / 2, fill=255)
compose(mask).resize((S, S), Image.LANCZOS).save(f"{OUT}/v6-b-stack.png")
print("v6-b-stack")

# ---------------- C · 圆角 W ----------------
mask = glyph_mask(W)
d = ImageDraw.Draw(mask)
lw = int(W * 0.115)
pts = [
    (W * 0.235, W * 0.335),
    (W * 0.355, W * 0.665),
    (W * 0.500, W * 0.450),
    (W * 0.645, W * 0.665),
    (W * 0.765, W * 0.335),
]
for a, b in zip(pts, pts[1:]):
    d.line([a, b], fill=255, width=lw, joint="curve")
for p in pts:
    d.ellipse([p[0] - lw / 2, p[1] - lw / 2, p[0] + lw / 2, p[1] + lw / 2], fill=255)
compose(mask).resize((S, S), Image.LANCZOS).save(f"{OUT}/v6-c-w.png")
print("v6-c-w")
