"""App 图标生成：Phosphor Icons 的 dog-fill（MIT），品牌紫 #7C5CFF + 白底。

流程：拉原始 SVG → 改成品牌紫 → 渲染成 2048 → 按紫色像素包围盒裁切 →
缩到画布 78%（iOS 图标安全区）→ 居中贴到 1024 白底。

依赖：curl、imagemagick（msvg 内置渲染器即可）、Pillow
运行：python3 tools/make_icon_dog.py
"""
import os
import subprocess
import tempfile
from urllib.request import urlopen

from PIL import Image

PURPLE = "#7C5CFF"
SIZE = 1024
CONTENT_RATIO = 0.78
SRC = "https://raw.githubusercontent.com/phosphor-icons/core/main/assets/fill/dog-fill.svg"
MIRROR = "https://gh.llkk.cc/" + SRC

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "WB2API/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")


def fetch_svg() -> str:
    for url in (MIRROR, SRC):
        try:
            with urlopen(url, timeout=20) as resp:
                return resp.read().decode("utf-8")
        except Exception:
            continue
    raise RuntimeError("下载图标 SVG 失败（直连与镜像都不可用）")


def main() -> None:
    svg = fetch_svg().replace('fill="currentColor"', f'fill="{PURPLE}"')
    # 兜底：把其它 fill 也统一成品牌紫
    import re
    svg = re.sub(r'fill="(?!none)[^"]+"', f'fill="{PURPLE}"', svg)

    with tempfile.TemporaryDirectory() as tmp:
        svg_path = os.path.join(tmp, "dog.svg")
        big_path = os.path.join(tmp, "dog_big.png")
        with open(svg_path, "w", encoding="utf-8") as fh:
            fh.write(svg)
        subprocess.run(
            ["magick", f"msvg:{svg_path}", "-background", "white", "-resize", "2048x2048", big_path],
            check=True,
        )
        img = Image.open(big_path).convert("RGB")

    # 按紫色像素包围盒裁切（避免不同导出器的留白差异）
    px = img.load()
    w, h = img.size
    minx, miny, maxx, maxy = w, h, 0, 0
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            r, g, b = px[x, y]
            if b > 150 and r < 200 and g < 180:
                minx, miny = min(minx, x), min(miny, y)
                maxx, maxy = max(maxx, x), max(maxy, y)
    glyph = img.crop((minx, miny, maxx + 1, maxy + 1))

    target = int(SIZE * CONTENT_RATIO)
    scale = target / max(glyph.size)
    glyph = glyph.resize(
        (max(1, int(glyph.width * scale)), max(1, int(glyph.height * scale))),
        Image.LANCZOS,
    )
    canvas = Image.new("RGB", (SIZE, SIZE), (255, 255, 255))
    canvas.paste(glyph, ((SIZE - glyph.width) // 2, (SIZE - glyph.height) // 2))
    canvas.save(OUT, "PNG", optimize=True)
    print("written:", OUT, glyph.size)


if __name__ == "__main__":
    main()
