#!/usr/bin/env python3
"""Placeholder art for the MC mechanics (vouchers, Masterwork Tag, Workshop packs)."""
from PIL import Image, ImageDraw, ImageFont
import os

OUT = os.path.join(os.path.dirname(__file__), '..', 'mod', 'assets')
PURPLE = (126, 87, 194, 255)
GOLD = (233, 177, 66, 255)
DARK = (40, 30, 60, 255)

def tile(w, h, base, label, scale):
    im = Image.new('RGBA', (w * scale, h * scale), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([1 * scale, 1 * scale, (w - 2) * scale, (h - 2) * scale], radius=4 * scale,
                        fill=base, outline=DARK, width=max(1, scale))
    try:
        font = ImageFont.load_default(size=int(w * scale * 0.35))
    except TypeError:
        font = ImageFont.load_default()
    d.text((w * scale / 2, h * scale / 2), label, fill=(255, 255, 255, 255), font=font, anchor='mm')
    return im

def sheet(name, w, h, tiles, scale):
    im = Image.new('RGBA', (w * len(tiles) * scale, h * scale), (0, 0, 0, 0))
    for i, (base, label) in enumerate(tiles):
        im.paste(tile(w, h, base, label, scale), (i * w * scale, 0))
    d = os.path.join(OUT, '%dx' % scale)
    os.makedirs(d, exist_ok=True)
    im.save(os.path.join(d, name))

for scale in (1, 2):
    sheet('bplus_vouchers.png', 71, 95, [(PURPLE, 'C+'), (GOLD, 'M+')], scale)
    sheet('bplus_tags.png', 34, 34, [(GOLD, 'M+')], scale)
    sheet('bplus_boosters.png', 71, 95,
          [(PURPLE, 'W'), (PURPLE, 'W'), (PURPLE, 'WJ'), (PURPLE, 'WM')], scale)
