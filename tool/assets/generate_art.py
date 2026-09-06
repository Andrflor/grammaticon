#!/usr/bin/env python3
"""Generates the provisional stylised art of Grammaticon as SVG and rasterises
it to PNG with rsvg-convert. Everything here is authored procedurally in this
repository (CC0). See doc/assets_manifest.md for dimensions, pivots and the
specifications for replacing each asset with final art.
"""
import os, subprocess, math, random

OUT = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'images')
SVG = os.path.join(os.path.dirname(__file__), 'svg')
os.makedirs(OUT, exist_ok=True); os.makedirs(SVG, exist_ok=True)

def write(name, w, h, body, defs=''):
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><defs>{defs}</defs>{body}</svg>'
    p = os.path.join(SVG, name + '.svg')
    open(p, 'w').write(svg)
    subprocess.run(['rsvg-convert', '-w', str(w), '-h', str(h), '-o', os.path.join(OUT, name + '.png'), p], check=True)
    print('wrote', name, w, h)

def lg(id, c1, c2, x1=0, y1=0, x2=0, y2=1):
    return f'<linearGradient id="{id}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}"><stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient>'
def rg(id, c1, c2, cx=0.5, cy=0.5, r=0.6):
    return f'<radialGradient id="{id}" cx="{cx}" cy="{cy}" r="{r}"><stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></radialGradient>'

def ellipse(cx, cy, rx, ry, fill, extra=''):
    return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{fill}" {extra}/>'
def rect(x, y, w, h, fill, r=0, extra=''):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}" {extra}/>'
def path(d, fill, extra=''):
    return f'<path d="{d}" fill="{fill}" {extra}/>'
def circle(cx, cy, r, fill, extra=''):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}" {extra}/>'
def poly(pts, fill, extra=''):
    return f'<polygon points="{" ".join(f"{x},{y}" for x,y in pts)}" fill="{fill}" {extra}/>'

STROKE = 'stroke="#3a2a1a" stroke-width="3" stroke-linejoin="round"'
SHADOW = 'fill="rgba(40,20,60,0.28)"'

# ---------------------------------------------------------------- shared pieces
def columns(x, y, w, h, n, color='#f4ecd8', dark='#c9b88f'):
    out = ''
    gap = w / n
    cw = gap * 0.42
    for i in range(n):
        cx = x + gap * (i + 0.5)
        out += rect(cx - cw/2, y, cw, h, f'url(#col)', r=cw*0.15)
        out += rect(cx - cw*0.62, y - 6, cw*1.24, 10, dark, r=3)
        out += rect(cx - cw*0.62, y + h - 6, cw*1.24, 10, dark, r=3)
    return out

def roof(x, y, w, h, tile='#c85a3a', dark='#8f3a24'):
    out = poly([(x, y+h), (x+w/2, y), (x+w, y+h)], f'url(#roof)', STROKE)
    step = 14
    for i in range(1, int(h/step)):
        yy = y + i*step
        frac = i*step/h
        xl = x + w/2 - (w/2)*frac
        xr = x + w/2 + (w/2)*frac
        out += f'<line x1="{xl}" y1="{yy}" x2="{xr}" y2="{yy}" stroke="{dark}" stroke-width="2" opacity="0.5"/>'
    return out

def banner(x, y, w, h, color='#6a2fb0'):
    return poly([(x, y), (x+w, y), (x+w, y+h*0.78), (x+w/2, y+h), (x, y+h*0.78)], color, 'stroke="#3d1a66" stroke-width="2"') + \
        rect(x-4, y-4, w+8, 8, '#e0b24a', r=3) + circle(x+w/2, y+h*0.45, w*0.22, '#e0b24a', 'opacity="0.9"')

def laurel(cx, cy, r, color='#e0b24a', a0=math.pi*0.15, step=0.16):
    out = ''
    for side in (-1, 1):
        for i in range(7):
            a = a0 + i*step
            x = cx + side*r*math.cos(a)
            y = cy + r*math.sin(a) - r*0.1
            rot = side*(-55 + i*10)
            out += f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{r*0.16:.1f}" ry="{r*0.07:.1f}" fill="{color}" transform="rotate({rot} {x:.1f} {y:.1f})"/>'
    return out

DEFS_COMMON = (lg('col', '#fffaf0', '#d9c9a3', 0,0,1,0) + lg('roof', '#e07a55', '#b6482c') +
    lg('marble', '#fbf6ea', '#d8cbb0') + lg('wall', '#f2e6cf', '#c8b48d') + lg('sky', '#6fc3ff', '#dff4ff') +
    lg('grass', '#8fd25a', '#4f9a3a') + lg('sea', '#3bb8e8', '#1c73b8') + lg('sand', '#f2d7a0', '#d9b578') +
    rg('glow', 'rgba(255,255,255,0.9)', 'rgba(255,255,255,0)') + lg('gold', '#ffe08a', '#d9a02a') +
    lg('purple', '#8d4be0', '#5a2a9c') + lg('gem', '#ff7ae8', '#b0189a') + lg('gemg', '#7dff9a', '#12a04a') +
    lg('skin', '#ffd9b3', '#e8b088') + lg('hair', '#8a4b22', '#5c2f12') + lg('tunic', '#ffffff', '#d8d3e6') +
    lg('cape', '#9a5cf0', '#5a2a9c') + lg('stone', '#c9d3d6', '#7f8f94') + lg('bronze', '#d59a4a', '#8a5a1e') +
    lg('lion', '#e9b25a', '#b8762a') + lg('mane', '#a8541e', '#6e3210') + lg('scale', '#5fb37a', '#2c6a44'))

# ---------------------------------------------------------------- buildings
def amphitheatrum():
    w, h = 640, 440
    b = ellipse(320, 400, 300, 34, 'rgba(40,20,60,0.25)')
    # outer ring body
    b += path(f'M40,300 Q40,150 320,130 Q600,150 600,300 L600,330 Q600,400 320,420 Q40,400 40,330 Z', 'url(#wall)', STROKE)
    # arcade rows
    for row, (y, hh, n, rad) in enumerate([(150, 60, 14, 0.98), (225, 62, 14, 1.0), (300, 60, 14, 1.0)]):
        for i in range(n):
            t = (i + 0.5) / n
            x = 60 + 520 * t
            depth = 1 - abs(t - 0.5) * 1.2
            aw = 22 * (0.55 + depth * 0.45)
            b += rect(x - aw/2, y + (1-depth)*8, aw, hh - (1-depth)*10, '#5a3a55', r=aw/2)
            b += rect(x - aw/2 + 3, y + (1-depth)*8 + 3, aw - 6, hh - (1-depth)*10 - 6, '#8a6a85', r=aw/2, extra='opacity="0.35"')
        b += rect(40, y + hh + 2, 560, 8, '#c9b88f')
    # inner rim & sand
    b += ellipse(320, 140, 250, 40, '#e9dcbb', STROKE)
    b += ellipse(320, 140, 210, 28, 'url(#sand)')
    b += banner(90, 205, 34, 70, '#b02a3a') + banner(516, 205, 34, 70, '#b02a3a')
    b += banner(302, 128, 36, 76, '#6a2fb0')
    return write('bld_amphitheatrum', w, h, b, DEFS_COMMON)

def forum():
    w, h = 560, 420
    b = ellipse(280, 392, 250, 28, 'rgba(40,20,60,0.25)')
    b += rect(60, 340, 440, 40, 'url(#marble)', r=6, extra=STROKE)  # steps
    b += rect(80, 320, 400, 26, 'url(#marble)', r=6, extra=STROKE)
    b += rect(100, 140, 360, 190, 'url(#wall)', r=8, extra=STROKE)  # body
    b += columns(110, 150, 340, 170, 6)
    b += rect(90, 128, 380, 20, 'url(#marble)', r=4, extra=STROKE)
    b += roof(80, 40, 400, 96)
    b += rect(200, 88, 160, 34, '#f6eed9', r=4, extra='stroke="#3a2a1a" stroke-width="2"')
    b += f'<text x="280" y="114" font-family="serif" font-size="26" font-weight="bold" text-anchor="middle" fill="#6a2fb0">SPQR</text>'
    # statues
    for x in (70, 490):
        b += rect(x-18, 250, 36, 90, 'url(#marble)', r=4, extra=STROKE)
        b += circle(x, 230, 16, '#f4ecd8', STROKE) + rect(x-14, 244, 28, 30, '#f4ecd8', r=6, extra=STROKE)
    b += banner(150, 170, 30, 66, '#6a2fb0') + banner(380, 170, 30, 66, '#6a2fb0')
    # awning stall
    b += rect(30, 300, 70, 60, '#c8a26a', r=4, extra=STROKE)
    for i in range(4):
        b += rect(30 + i*17.5, 288, 17.5, 16, '#e0333f' if i % 2 == 0 else '#ffffff')
    return write('bld_forum', w, h, b, DEFS_COMMON)

# The Thermae building was replaced by the Theatrum (tool/assets/generate_theatrum_art.py).

def templum():
    w, h = 520, 440
    b = ellipse(260, 410, 230, 26, 'rgba(40,20,60,0.25)')
    for i, (y, ww) in enumerate([(370, 460), (350, 430), (330, 400)]):
        b += rect(260 - ww/2, y, ww, 24, 'url(#marble)', r=5, extra=STROKE)
    b += rect(80, 160, 360, 172, 'url(#wall)', r=6, extra=STROKE)
    b += columns(90, 170, 340, 154, 7)
    b += rect(70, 146, 380, 20, 'url(#marble)', r=4, extra=STROKE)
    b += roof(60, 40, 400, 106)
    b += circle(260, 102, 22, '#e0b24a', STROKE)  # pediment disc
    b += laurel(260, 102, 30, '#fff3c4')
    # eagle silhouette on top
    b += path('M260,20 l-26,14 l14,2 l-10,10 l22,-6 l22,6 l-10,-10 l14,-2 Z', '#e0b24a', 'stroke="#3a2a1a" stroke-width="2"')
    # braziers
    for x in (60, 460):
        b += rect(x-10, 300, 20, 40, 'url(#bronze)', r=4, extra=STROKE)
        b += path(f'M{x-14},300 q14,-40 28,0 q-8,-14 -14,-30 q-6,16 -14,30 Z', '#ff9a3c')
    return write('bld_templum', w, h, b, DEFS_COMMON)

# ---------------------------------------------------------------- city background
def city_bg():
    w, h = 1920, 1080
    b = rect(0, 0, w, h, 'url(#sky)')
    # sun & clouds
    b += circle(1620, 150, 70, '#fff6c8') + circle(1620, 150, 110, 'url(#glow)')
    random.seed(3)
    for i in range(9):
        x = random.randint(0, w); y = random.randint(40, 300); s = random.uniform(0.7, 1.4)
        b += ellipse(x, y, 90*s, 30*s, 'rgba(255,255,255,0.85)') + ellipse(x+50*s, y-14*s, 60*s, 28*s, 'rgba(255,255,255,0.85)') + ellipse(x-50*s, y-8*s, 55*s, 24*s, 'rgba(255,255,255,0.85)')
    # far hills
    b += path('M0,420 Q300,300 600,400 T1200,380 T1920,420 L1920,600 L0,600 Z', '#a6d8f0')
    b += path('M0,470 Q400,360 800,460 T1500,430 T1920,480 L1920,700 L0,700 Z', '#7cc06a')
    # sea inlet on the left
    b += path('M0,560 Q200,520 420,600 Q520,660 380,760 Q200,860 0,820 Z', 'url(#sea)')
    for i in range(14):
        x = 40 + i*26; y = 620 + (i % 3)*50
        b += f'<path d="M{x},{y} q12,-6 24,0" stroke="rgba(255,255,255,0.6)" stroke-width="3" fill="none"/>'
    # boat
    b += rect(218, 610, 5, 100, '#5c3a1a') + poly([(224, 616), (286, 700), (224, 700)], '#fff5e0', STROKE)
    b += path('M150,700 q70,40 150,0 l-14,26 q-60,16 -122,0 Z', '#8a5a2a', STROKE)
    # ground plates
    b += path('M0,700 L1920,600 L1920,1080 L0,1080 Z', 'url(#grass)')
    b += path('M300,1080 Q700,780 1200,760 Q1600,740 1920,700 L1920,780 Q1600,800 1250,830 Q800,860 480,1080 Z', '#e9d8b5')  # road
    b += path('M300,1080 Q700,780 1200,760 Q1600,740 1920,700 L1920,780 Q1600,800 1250,830 Q800,860 480,1080 Z', 'none', 'stroke="#cbb58c" stroke-width="4" stroke-dasharray="14 18"')
    # plaza
    b += ellipse(1000, 900, 300, 90, '#efe3c8', 'stroke="#cbb58c" stroke-width="4"')
    for i in range(6):
        b += ellipse(1000, 900, 300 - i*48, 90 - i*14, 'none', 'stroke="#d9c7a1" stroke-width="2"')
    # fountain
    b += ellipse(1000, 900, 70, 24, '#3bb8e8', STROKE) + rect(990, 850, 20, 50, '#f4ecd8', extra=STROKE) + circle(1000, 846, 12, '#8fd0ff')
    # cypresses
    random.seed(11)
    for x, y, s in [(120, 980, 1.2), (250, 860, 0.9), (700, 720, 0.8), (1500, 680, 0.7), (1800, 760, 0.9), (1650, 1000, 1.3), (380, 700, 0.7), (1400, 1020, 1.2), (560, 940, 1.0)]:
        b += ellipse(x, y, 30*s, 8*s, 'rgba(40,20,60,0.25)')
        b += path(f'M{x-34*s:.1f},{y} Q{x-40*s:.1f},{y-90*s:.1f} {x:.1f},{y-170*s:.1f} Q{x+40*s:.1f},{y-90*s:.1f} {x+34*s:.1f},{y} Z', '#2f7a3a', STROKE)
        b += path(f'M{x-16*s:.1f},{y} Q{x-24*s:.1f},{y-90*s:.1f} {x-2*s:.1f},{y-150*s:.1f} Q{x+4*s:.1f},{y-90*s:.1f} {x+6*s:.1f},{y} Z', '#4f9a3a')
    # small houses
    for x, y, s in [(1350, 900, 1.0), (1480, 940, 1.1), (1250, 1000, 0.9), (700, 1010, 1.0), (820, 980, 0.8)]:
        ww, hh = 110*s, 70*s
        b += rect(x, y - hh, ww, hh, 'url(#wall)', r=4, extra=STROKE)
        b += poly([(x-8, y-hh), (x+ww/2, y-hh-40*s), (x+ww+8, y-hh)], '#c85a3a', STROKE)
        b += rect(x+ww*0.4, y-hh*0.6, ww*0.2, hh*0.6, '#5a3a55', r=4)
    # citizens (dots)
    random.seed(5)
    for i in range(18):
        x = random.randint(700, 1300); y = random.randint(850, 960)
        col = random.choice(['#ffffff', '#e0333f', '#6a2fb0', '#f2d7a0'])
        b += ellipse(x, y+12, 8, 3, 'rgba(40,20,60,0.3)') + rect(x-6, y-14, 12, 22, col, r=5) + circle(x, y-20, 6, '#ffd9b3')
    return write('city_bg', w, h, b, DEFS_COMMON)

# ---------------------------------------------------------------- arena background
def arena_bg():
    w, h = 1920, 1080
    b = rect(0, 0, w, h, 'url(#sky)')
    b += circle(300, 140, 60, '#fff6c8') + circle(300, 140, 100, 'url(#glow)')
    # stands
    for i, (y, col) in enumerate([(260, '#e9dcbb'), (340, '#dccca6'), (420, '#cdbb93')]):
        b += path(f'M0,{y+60} Q960,{y-80} 1920,{y+60} L1920,{y+150} Q960,{y+10} 0,{y+150} Z', col, 'stroke="#3a2a1a" stroke-width="3"')
        random.seed(20 + i)
        for k in range(70):
            x = 20 + k*27.5
            yy = y + 60 - 70 * (1 - abs(x - 960)/960) ** 0.9 * 1.0 + random.randint(-6, 6) + 20
            col2 = random.choice(['#ffffff', '#e0333f', '#6a2fb0', '#f2d7a0', '#3bb8e8'])
            b += rect(x-6, yy, 12, 22, col2, r=5) + circle(x, yy-6, 6, '#ffd9b3')
    # arcade wall behind
    b += rect(0, 560, 1920, 120, 'url(#wall)', extra='stroke="#3a2a1a" stroke-width="3"')
    for k in range(16):
        x = 60 + k*120
        b += rect(x, 575, 60, 90, '#5a3a55', r=30) + rect(x+6, 581, 48, 78, '#8a6a85', r=24, extra='opacity="0.35"')
    for x in (200, 960, 1720):
        b += banner(x-30, 470, 60, 120, '#6a2fb0' if x != 960 else '#b02a3a')
        b += laurel(x, 520, 26, '#fff3c4')
    b += f'<text x="960" y="560" font-family="serif" font-size="30" font-weight="bold" text-anchor="middle" fill="#fff3c4">SPQR</text>'
    # sand floor
    b += path('M0,680 L1920,680 L1920,1080 L0,1080 Z', 'url(#sand)')
    b += ellipse(960, 900, 720, 150, '#eccf94', 'opacity="0.8"')
    b += ellipse(960, 900, 560, 110, 'none', 'stroke="#d9b578" stroke-width="6"')
    b += ellipse(960, 900, 380, 74, 'none', 'stroke="#d9b578" stroke-width="4" stroke-dasharray="20 16"')
    # torches
    for x in (120, 1800):
        b += rect(x-8, 600, 16, 90, 'url(#bronze)', r=4, extra=STROKE)
        b += path(f'M{x-16},600 q16,-46 32,0 q-8,-16 -16,-34 q-8,18 -16,34 Z', '#ff9a3c')
    return write('arena_bg', w, h, b, DEFS_COMMON)

# ---------------------------------------------------------------- hero (Roman boy)
def hero(pose):
    w, h = 420, 540
    cx = 210
    b = ellipse(cx, 512, 110, 22, 'rgba(40,20,60,0.3)')
    # pose parameters
    lean = {'idle': 0, 'attack': -14, 'hurt': 16, 'victory': 0, 'defeat': 0}[pose]
    arm_r = {'idle': 20, 'attack': -70, 'hurt': 40, 'victory': -150, 'defeat': 30}[pose]
    arm_l = {'idle': -20, 'attack': 30, 'hurt': -40, 'victory': 150, 'defeat': -30}[pose]
    body_y = 40 if pose == 'defeat' else 0
    g = f'<g transform="translate({lean} {body_y}) rotate({lean*0.4} {cx} 380)">'
    # cape
    g += path(f'M{cx-70},250 Q{cx-120},380 {cx-60},470 L{cx+40},470 Q{cx+90},380 {cx+60},250 Z', 'url(#cape)', STROKE)
    # legs & sandals
    for dx in (-30, 30):
        g += rect(cx+dx-18, 400, 36, 90, 'url(#skin)', r=14, extra=STROKE)
        g += rect(cx+dx-24, 470, 48, 26, '#8a5a2a', r=8, extra=STROKE)
        g += f'<path d="M{cx+dx-14},440 l28,0 M{cx+dx-14},456 l28,0" stroke="#8a5a2a" stroke-width="4"/>'
    # tunic
    g += path(f'M{cx-80},260 L{cx+80},260 L{cx+96},420 L{cx-96},420 Z', 'url(#tunic)', STROKE)
    g += rect(cx-96, 400, 192, 22, '#8d4be0', r=4)  # purple hem
    g += rect(cx-84, 320, 168, 16, '#e0b24a', r=6)   # belt
    # arms
    def arm(x, rot, hand_item):
        s = f'<g transform="rotate({rot} {x} 275)">'
        s += rect(x-20, 265, 40, 120, 'url(#skin)', r=18, extra=STROKE)
        s += rect(x-22, 350, 44, 22, '#8a5a2a', r=8, extra=STROKE)  # bracer
        s += hand_item(x, 395)
        return s + '</g>'
    def sword(x, y):
        return rect(x-6, y-10, 12, 130, 'url(#stone)', r=4, extra=STROKE) + rect(x-26, y-14, 52, 14, 'url(#gold)', r=4, extra=STROKE) + circle(x, y-24, 12, 'url(#gold)', STROKE)
    def shield(x, y):
        return rect(x-44, y-40, 88, 110, '#b02a3a', r=22, extra=STROKE) + circle(x, y+15, 18, 'url(#gold)', STROKE) + laurel(x, y+15, 30, '#ffe9a8')
    g += arm(cx-84, arm_l, shield)
    g += arm(cx+84, arm_r, sword)
    # head
    hy = 170
    g += rect(cx-26, 220, 52, 40, 'url(#skin)', r=14, extra=STROKE)  # neck
    g += circle(cx, hy, 92, 'url(#skin)', STROKE)
    # hair
    g += path(f'M{cx-92},{hy-10} Q{cx-100},{hy-110} {cx},{hy-112} Q{cx+100},{hy-110} {cx+92},{hy-10} Q{cx+70},{hy-40} {cx+40},{hy-52} Q{cx},{hy-30} {cx-40},{hy-52} Q{cx-70},{hy-40} {cx-92},{hy-10} Z', 'url(#hair)', STROKE)
    for i in range(5):
        a = -1.2 + i*0.6
        g += circle(cx + 70*math.cos(a-1.57), hy-60 + 40*math.sin(a-1.57)*0.6, 22, 'url(#hair)', STROKE)
    g += laurel(cx, hy+6, 96, '#e0b24a', a0=-1.35, step=0.13)
    # face
    eye_dy = 0
    if pose == 'hurt':
        g += f'<path d="M{cx-52},{hy-2} l30,14 M{cx+52},{hy-2} l-30,14" stroke="#3a2a1a" stroke-width="6" stroke-linecap="round"/>'
    elif pose == 'defeat':
        g += f'<path d="M{cx-52},{hy+8} l30,-10 M{cx+52},{hy+8} l-30,-10" stroke="#3a2a1a" stroke-width="6" stroke-linecap="round"/>'
    else:
        for dx in (-36, 36):
            g += ellipse(cx+dx, hy+eye_dy, 16, 20, '#ffffff', STROKE)
            g += circle(cx+dx+3, hy+eye_dy+3, 9, '#3a2a1a') + circle(cx+dx+6, hy+eye_dy-2, 3, '#ffffff')
    mouth = {'idle': f'M{cx-18},{hy+44} q18,14 36,0', 'attack': f'M{cx-22},{hy+40} q22,26 44,0 Z', 'hurt': f'M{cx-14},{hy+50} q14,-10 28,0', 'victory': f'M{cx-26},{hy+38} q26,30 52,0 Z', 'defeat': f'M{cx-16},{hy+52} q16,-12 32,0'}[pose]
    g += path(mouth, '#7a2a3a' if pose in ('attack', 'victory') else 'none', 'stroke="#3a2a1a" stroke-width="5" stroke-linecap="round"')
    g += circle(cx-60, hy+30, 12, 'rgba(255,120,120,0.35)') + circle(cx+60, hy+30, 12, 'rgba(255,120,120,0.35)')
    g += '</g>'
    return write(f'hero_{pose}', w, h, b + g, DEFS_COMMON)

# ---------------------------------------------------------------- enemies
def enemy_statua():
    w, h = 480, 540; cx = 240
    b = ellipse(cx, 512, 130, 24, 'rgba(40,20,60,0.3)')
    b += rect(cx-120, 440, 240, 60, 'url(#marble)', r=10, extra=STROKE)  # plinth
    for dx in (-50, 50):
        b += rect(cx+dx-34, 330, 68, 120, 'url(#stone)', r=20, extra=STROKE)
    b += path(f'M{cx-110},180 L{cx+110},180 L{cx+130},350 L{cx-130},350 Z', 'url(#stone)', STROKE)  # torso
    for dx, rot in ((-140, 20), (140, -20)):
        b += f'<g transform="rotate({rot} {cx+dx} 200)">' + rect(cx+dx-34, 190, 68, 150, 'url(#stone)', r=24, extra=STROKE) + circle(cx+dx, 350, 40, 'url(#stone)', STROKE) + '</g>'
    b += circle(cx, 120, 80, 'url(#stone)', STROKE)
    b += laurel(cx, 80, 66, '#c9d3d6')
    for dx in (-30, 30):
        b += ellipse(cx+dx, 118, 16, 12, '#22e4ff') + ellipse(cx+dx, 118, 26, 20, 'url(#glow)')
    b += path(f'M{cx-20},160 q20,10 40,0', 'none', 'stroke="#3a2a1a" stroke-width="5" stroke-linecap="round"')
    # cracks & glowing runes
    b += f'<path d="M{cx-60},220 l20,40 l-14,30 M{cx+40},260 l10,30 l20,10" stroke="#5a6a70" stroke-width="4" fill="none" stroke-linecap="round"/>'
    b += f'<text x="{cx}" y="290" font-family="serif" font-size="44" text-anchor="middle" fill="#22e4ff" opacity="0.9">SPQR</text>'
    return write('enemy_statua', w, h, b, DEFS_COMMON)

def enemy_gladiator():
    w, h = 480, 540; cx = 240
    b = ellipse(cx, 512, 120, 22, 'rgba(40,20,60,0.3)')
    for dx in (-36, 36):
        b += rect(cx+dx-20, 400, 40, 92, 'url(#skin)', r=14, extra=STROKE) + rect(cx+dx-26, 470, 52, 28, '#8a5a2a', r=8, extra=STROKE)
    b += path(f'M{cx-90},250 L{cx+90},250 L{cx+104},420 L{cx-104},420 Z', '#c8a26a', STROKE)  # leather tunic
    b += rect(cx-104, 396, 208, 26, '#8a5a2a', r=6)
    # arms: trident and shield
    b += f'<g transform="rotate(-25 {cx+90} 270)">' + rect(cx+70, 260, 42, 130, 'url(#skin)', r=18, extra=STROKE) + rect(cx+86, 120, 10, 280, 'url(#bronze)', r=4, extra=STROKE) + path(f'M{cx+66},130 l0,-40 l8,0 l0,30 l14,0 l0,-50 l8,0 l0,50 l14,0 l0,-30 l8,0 l0,40 Z', 'url(#stone)', STROKE) + '</g>'
    b += f'<g transform="rotate(20 {cx-90} 270)">' + rect(cx-112, 260, 42, 130, 'url(#skin)', r=18, extra=STROKE) + rect(cx-150, 300, 110, 130, '#1c73b8', r=18, extra=STROKE) + circle(cx-95, 365, 20, 'url(#gold)', STROKE) + '</g>'
    b += rect(cx-26, 210, 52, 44, 'url(#skin)', r=14, extra=STROKE)
    b += circle(cx, 150, 84, 'url(#skin)', STROKE)
    # helmet with grille
    b += path(f'M{cx-92},150 Q{cx-96},50 {cx},44 Q{cx+96},50 {cx+92},150 L{cx+92},176 L{cx-92},176 Z', 'url(#bronze)', STROKE)
    b += rect(cx-70, 120, 140, 58, '#3a2a1a', r=10)
    for i in range(6):
        b += rect(cx-66 + i*24, 122, 8, 54, 'url(#bronze)')
    b += path(f'M{cx-40},60 Q{cx},0 {cx+40},60 Q{cx},40 {cx-40},60 Z', '#b02a3a', STROKE)  # crest
    for dx in (-30, 30):
        b += circle(cx+dx, 146, 8, '#ffe08a')
    return write('enemy_gladiator', w, h, b, DEFS_COMMON)

def enemy_leo():
    w, h = 520, 520; cx = 260
    b = ellipse(cx, 490, 170, 26, 'rgba(40,20,60,0.3)')
    b += ellipse(cx+40, 360, 170, 110, 'url(#lion)', STROKE)  # body
    for dx in (-80, -20, 90, 150):
        b += rect(cx+dx-22, 400, 44, 84, 'url(#lion)', r=16, extra=STROKE)
    b += path(f'M{cx+200},330 q60,-80 20,-130 q-10,30 10,60 q-20,30 -40,50 Z', 'url(#lion)', STROKE)  # tail
    b += circle(cx+220, 200, 22, 'url(#mane)', STROKE)
    # mane & head
    for i in range(14):
        a = i / 14 * 2 * math.pi
        b += ellipse(cx-60 + 120*math.cos(a), 250 + 120*math.sin(a), 40, 30, 'url(#mane)', STROKE + f' transform="rotate({a*57.3} {cx-60 + 120*math.cos(a)} {250 + 120*math.sin(a)})"')
    b += circle(cx-60, 250, 96, 'url(#lion)', STROKE)
    b += ellipse(cx-60, 300, 46, 34, '#f2d7a0', STROKE)  # muzzle
    b += ellipse(cx-60, 288, 22, 14, '#3a2a1a')
    b += path(f'M{cx-78},318 q18,14 36,0', 'none', 'stroke="#3a2a1a" stroke-width="5" stroke-linecap="round"')
    for dx in (-32, 32):
        b += ellipse(cx-60+dx, 236, 16, 18, '#ffffff', STROKE) + circle(cx-60+dx, 240, 8, '#3a2a1a')
        b += path(f'M{cx-60+dx-18},214 l36,-8', 'none', 'stroke="#3a2a1a" stroke-width="6" stroke-linecap="round"')  # brows
    for dx in (-44, 44):
        b += ellipse(cx-60+dx, 168, 22, 26, 'url(#lion)', STROKE)
    return write('enemy_leo', w, h, b, DEFS_COMMON)

def enemy_sphinx():
    w, h = 500, 540; cx = 250
    b = ellipse(cx, 512, 160, 24, 'rgba(40,20,60,0.3)')
    b += rect(cx-160, 430, 320, 60, 'url(#sand)', r=10, extra=STROKE)
    b += ellipse(cx+30, 380, 160, 90, 'url(#gold)', STROKE)  # body
    for dx in (-90, -30, 80, 140):
        b += rect(cx+dx-22, 400, 44, 60, 'url(#gold)', r=14, extra=STROKE)
    # wings
    for side in (-1, 1):
        b += path(f'M{cx+30},330 q{side*160},-120 {side*220},-40 q-{side*80},-10 -{side*120},30 q{side*40},0 {side*70},20 Z', '#1c73b8', STROKE)
    b += rect(cx-30, 250, 60, 60, 'url(#skin)', r=14, extra=STROKE)
    b += circle(cx, 190, 84, 'url(#skin)', STROKE)
    # headdress
    b += path(f'M{cx-100},220 L{cx-80},90 Q{cx},60 {cx+80},90 L{cx+100},220 L{cx+70},230 L{cx+64},130 L{cx-64},130 L{cx-70},230 Z', '#1c73b8', STROKE)
    for i in range(5):
        b += rect(cx-100 + i*4, 130 + i*20, 200 - i*8, 8, '#e0b24a')
    for dx in (-32, 32):
        b += ellipse(cx+dx, 186, 18, 14, '#ffffff', STROKE) + circle(cx+dx, 188, 8, '#3a2a1a')
        b += path(f'M{cx+dx-20},170 l40,0', 'none', 'stroke="#1c73b8" stroke-width="6" stroke-linecap="round"')
    b += path(f'M{cx-16},232 q16,-8 32,0', 'none', 'stroke="#3a2a1a" stroke-width="5" stroke-linecap="round"')
    b += f'<text x="{cx}" y="112" font-family="serif" font-size="30" text-anchor="middle" fill="#fff3c4">?</text>'
    return write('enemy_sphinx', w, h, b, DEFS_COMMON)

def enemy_cyclops():
    w, h = 500, 560; cx = 250
    b = ellipse(cx, 530, 150, 26, 'rgba(40,20,60,0.3)')
    for dx in (-50, 50):
        b += rect(cx+dx-32, 400, 64, 110, '#7fb87a', r=20, extra=STROKE) + rect(cx+dx-38, 490, 76, 28, '#5a3a2a', r=8, extra=STROKE)
    b += path(f'M{cx-130},210 L{cx+130},210 L{cx+150},420 L{cx-150},420 Z', '#8fd08a', STROKE)
    b += path(f'M{cx-110},300 L{cx+110},300 L{cx+120},420 L{cx-120},420 Z', '#8a5a2a', STROKE)  # fur skirt
    for dx, rot in ((-160, 30), (160, -40)):
        b += f'<g transform="rotate({rot} {cx+dx} 230)">' + rect(cx+dx-38, 220, 76, 170, '#8fd08a', r=30, extra=STROKE) + circle(cx+dx, 400, 46, '#7fb87a', STROKE) + '</g>'
    b += rect(cx+130, 60, 30, 260, '#8a5a2a', r=10, extra=STROKE + ' transform="rotate(-40 400 230)"')  # club
    b += rect(cx-40, 180, 80, 40, '#8fd08a', r=12, extra=STROKE)
    b += circle(cx, 120, 100, '#8fd08a', STROKE)
    b += ellipse(cx, 116, 44, 40, '#ffffff', STROKE) + circle(cx+4, 120, 22, '#ff9a3c') + circle(cx+4, 120, 10, '#3a2a1a') + circle(cx+12, 110, 5, '#ffffff')
    b += path(f'M{cx-50},80 q50,-30 100,0', 'none', 'stroke="#3a2a1a" stroke-width="8" stroke-linecap="round"')
    b += path(f'M{cx-40},178 q40,26 80,0 l-10,-12 l-20,8 l-20,-8 l-20,8 Z', '#7a2a3a', STROKE)
    for dx in (-104, 104):
        b += ellipse(cx+dx, 110, 16, 24, '#8fd08a', STROKE)
    return write('enemy_cyclops', w, h, b, DEFS_COMMON)

def enemy_hydra():
    w, h = 560, 560; cx = 280
    b = ellipse(cx, 530, 190, 26, 'rgba(40,20,60,0.3)')
    b += ellipse(cx, 430, 170, 90, 'url(#scale)', STROKE)
    for dx in (-100, 0, 100):
        b += rect(cx+dx-26, 460, 52, 60, 'url(#scale)', r=16, extra=STROKE)
    for i, (dx, top, rot) in enumerate([(-170, 120, -30), (-60, 60, -10), (60, 60, 10), (170, 120, 30)]):
        neck = f'M{cx+dx*0.3},400 Q{cx+dx*0.8},{top+120} {cx+dx},{top+40}'
        b += f'<path d="{neck}" stroke="#3a2a1a" stroke-width="54" fill="none" stroke-linecap="round"/>'
        b += f'<path d="{neck}" stroke="#4f9a5a" stroke-width="46" fill="none" stroke-linecap="round"/>'
        hx, hy = cx+dx, top+30
        b += f'<g transform="rotate({rot} {hx} {hy})">' + ellipse(hx, hy, 52, 40, 'url(#scale)', STROKE) + ellipse(hx+30, hy+10, 34, 20, '#7fd08a', STROKE)
        b += circle(hx-8, hy-12, 12, '#ffe08a', STROKE) + circle(hx-6, hy-12, 5, '#3a2a1a')
        b += path(f'M{hx+10},{hy+18} l14,10 l6,-12 l10,10 l6,-12', 'none', 'stroke="#ffffff" stroke-width="4"') + '</g>'
        for k in range(3):
            b += ellipse(hx - 20 + k*14, top - 6 - k*4, 8, 16, '#b02a3a', STROKE)
    return write('enemy_hydra', w, h, b, DEFS_COMMON)

# ---------------------------------------------------------------- icons
def gem(name, grad, edge):
    w = h = 128
    b = poly([(64, 8), (112, 46), (64, 120), (16, 46)], f'url(#{grad})', f'stroke="{edge}" stroke-width="5" stroke-linejoin="round"')
    b += poly([(64, 8), (88, 46), (64, 60), (40, 46)], 'rgba(255,255,255,0.55)')
    b += poly([(16, 46), (40, 46), (64, 120)], 'rgba(0,0,0,0.18)')
    b += poly([(88, 46), (112, 46), (64, 120)], 'rgba(255,255,255,0.25)')
    b += circle(46, 30, 6, '#ffffff', 'opacity="0.9"')
    return write(name, w, h, b, DEFS_COMMON)

def heart(name, fill, edge):
    w = h = 96
    b = path('M48,86 C10,58 4,34 18,20 C30,8 44,14 48,26 C52,14 66,8 78,20 C92,34 86,58 48,86 Z', fill, f'stroke="{edge}" stroke-width="5" stroke-linejoin="round"')
    if fill != 'none':
        b += ellipse(32, 30, 8, 6, 'rgba(255,255,255,0.7)')
    return write(name, w, h, b, DEFS_COMMON)

def impact():
    w = h = 256
    pts = []
    for i in range(16):
        r = 120 if i % 2 == 0 else 60
        a = i * math.pi / 8
        pts.append((128 + r*math.cos(a), 128 + r*math.sin(a)))
    b = poly(pts, '#ffe08a', 'stroke="#ff9a3c" stroke-width="6" stroke-linejoin="round"')
    pts2 = [(128 + (70 if i % 2 == 0 else 32)*math.cos(i*math.pi/8 + 0.2), 128 + (70 if i % 2 == 0 else 32)*math.sin(i*math.pi/8 + 0.2)) for i in range(16)]
    b += poly(pts2, '#ffffff')
    return write('impact', w, h, b, DEFS_COMMON)

def laurel_icon():
    w = h = 128
    return write('laurel', w, h, laurel(64, 64, 50, '#e0b24a'), DEFS_COMMON)

def tabula_icon():
    w = h = 128
    b = rect(16, 20, 96, 88, '#d9b578', r=8, extra=STROKE)
    b += rect(28, 32, 72, 64, '#f6eed9', r=4)
    for i in range(4):
        b += rect(36, 42 + i*14, 56 - (i % 2)*20, 6, '#6a2fb0', r=3)
    return write('tabula_icon', w, h, b, DEFS_COMMON)

if __name__ == '__main__':
    amphitheatrum(); forum(); templum(); city_bg(); arena_bg()
    for p in ('idle', 'attack', 'hurt', 'victory', 'defeat'):
        hero(p)
    enemy_statua(); enemy_gladiator(); enemy_leo(); enemy_sphinx(); enemy_cyclops(); enemy_hydra()
    gem('gem', 'gem', '#7a1070'); gem('gem_green', 'gemg', '#0a6a30')
    heart('heart', '#ff4d6d', '#8a1030'); heart('heart_empty', 'none', '#8a1030')
    impact(); laurel_icon(); tabula_icon()
