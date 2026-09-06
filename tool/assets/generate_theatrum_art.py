#!/usr/bin/env python3
"""Provisional stylised art of the Theatrum (Roman theatre), SVG → PNG via
rsvg-convert, in the same manner and palette as generate_art.py and
generate_forum_art.py, whose helpers it reuses. Like the rest of the
procedural art these assets are provisional placeholders produced in this
repository (CC0), meant to be replaced by final illustrations with the same
dimensions, pivots and transparency (see doc/assets_manifest.md).

  cd tool/assets && python3 generate_theatrum_art.py

Produces: bld_theatrum (city building), theatrum_bg (stage backdrop),
histrio_* (the player as an actor), actor_* (opposing actors) and persona
(golden mask projectile).
"""
import math, random
from generate_art import (write, lg, rg, ellipse, rect, path, circle, poly, columns, roof, banner, laurel, STROKE, DEFS_COMMON)
# The Forum script defines the chibi figure pieces (legs, head, arms, hands,
# staff, toga, shadow). Reusing them keeps the actors on the same proportions
# and foot line as the orators and the hero.
from generate_forum_art import (DEFS as FORUM_DEFS, _legs, _head, _arm, _open_hand, _fist, _staff, _toga, _shadow)

DEFS = FORUM_DEFS + (lg('saffron', '#ffd76a', '#e09a2a') + lg('dark', '#4a3560', '#221733') + lg('wood', '#d09a58', '#9a6a32') +
    lg('woodDark', '#7a4a20', '#4a2a10') + lg('teal', '#6fd6cc', '#1f8a86') + lg('crimson', '#d63a48', '#7a1024') +
    lg('curtain', '#8d4be0', '#4b2288') + lg('veil', 'rgba(236,214,255,0.9)', 'rgba(190,150,240,0.35)') +
    lg('maskFace', '#fbe6c4', '#e6c091') + lg('boot', '#9a3a3a', '#5a1a1a'))

STROKE2 = 'stroke="#3a2a1a" stroke-width="2"'

# ---------------------------------------------------------------- theatre mask
def mask(cx, cy, r, kind='comic', fill='url(#maskFace)', hair=None, rot=0):
    """Theatre mask centred on (cx, cy), face half-width r.
    kind: 'comic' (grin, curly fringe), 'tragic' (tall onkos, downturned mouth),
    'closed' (serene pantomime mask with a closed mouth)."""
    sw = 3 if r >= 40 else (2 if r >= 20 else 1.4)
    st = f'stroke="#3a2a1a" stroke-width="{sw}" stroke-linejoin="round"'
    line = f'stroke="#3a2a1a" stroke-width="{sw*1.6:.1f}" stroke-linecap="round" fill="none"'
    s = f'<g transform="rotate({rot} {cx} {cy})">'
    if kind == 'tragic':
        # onkos: the high domed hairpiece of tragic masks
        s += path(f'M{cx-r*0.95:.1f},{cy-r*0.2:.1f} Q{cx-r*1.15:.1f},{cy-r*1.9:.1f} {cx:.1f},{cy-r*2.05:.1f} Q{cx+r*1.15:.1f},{cy-r*1.9:.1f} {cx+r*0.95:.1f},{cy-r*0.2:.1f} Z', hair or '#3a2a1a', st)
        for i in range(-2, 3):
            x = cx + i*r*0.3
            s += f'<path d="M{x:.1f},{cy-r*0.7:.1f} Q{x-r*0.08:.1f},{cy-r*1.3:.1f} {x:.1f},{cy-r*1.8+abs(i)*r*0.14:.1f}" stroke="rgba(255,255,255,0.35)" stroke-width="{sw:.1f}" fill="none" stroke-linecap="round"/>'
    elif kind == 'comic':
        for i in range(7):
            a = math.pi*(1.1 + i*0.8/6)
            s += circle(cx + r*1.0*math.cos(a), cy + r*1.05*math.sin(a), r*0.24, hair or '#c8502a', st)
    else:  # closed: smooth hair cap with a gold band
        s += path(f'M{cx-r:.1f},{cy-r*0.1:.1f} Q{cx-r*1.05:.1f},{cy-r*1.35:.1f} {cx:.1f},{cy-r*1.4:.1f} Q{cx+r*1.05:.1f},{cy-r*1.35:.1f} {cx+r:.1f},{cy-r*0.1:.1f} Q{cx:.1f},{cy-r*0.75:.1f} {cx-r:.1f},{cy-r*0.1:.1f} Z', hair or '#3a2a1a', st)
    s += ellipse(cx, cy, r, r*1.12, fill, st)
    if kind == 'comic':
        for sd in (-1, 1):
            s += ellipse(cx + sd*r*0.42, cy - r*0.18, r*0.2, r*0.16, '#3a2a1a')
            s += f'<path d="M{cx+sd*r*0.66:.1f},{cy-r*0.42:.1f} Q{cx+sd*r*0.42:.1f},{cy-r*0.66:.1f} {cx+sd*r*0.18:.1f},{cy-r*0.42:.1f}" {line}/>'
            s += circle(cx + sd*r*0.62, cy + r*0.25, r*0.14, 'rgba(255,120,120,0.4)')
        s += ellipse(cx, cy + r*0.12, r*0.12, r*0.1, 'rgba(120,60,30,0.35)')
        s += path(f'M{cx-r*0.55:.1f},{cy+r*0.3:.1f} Q{cx:.1f},{cy+r*0.5:.1f} {cx+r*0.55:.1f},{cy+r*0.3:.1f} Q{cx:.1f},{cy+r*1.0:.1f} {cx-r*0.55:.1f},{cy+r*0.3:.1f} Z', '#3a2a1a', st)
    elif kind == 'tragic':
        for sd in (-1, 1):
            s += ellipse(cx + sd*r*0.42, cy - r*0.15, r*0.18, r*0.24, '#3a2a1a')
            s += f'<path d="M{cx+sd*r*0.7:.1f},{cy-r*0.36:.1f} L{cx+sd*r*0.2:.1f},{cy-r*0.6:.1f}" {line}/>'
        s += path(f'M{cx-r*0.5:.1f},{cy+r*0.55:.1f} Q{cx:.1f},{cy+r*0.15:.1f} {cx+r*0.5:.1f},{cy+r*0.55:.1f} Q{cx:.1f},{cy+r*0.9:.1f} {cx-r*0.5:.1f},{cy+r*0.55:.1f} Z', '#3a2a1a', st)
    else:
        for sd in (-1, 1):
            s += ellipse(cx + sd*r*0.4, cy - r*0.15, r*0.2, r*0.09, '#3a2a1a')
        s += f'<path d="M{cx-r*0.3:.1f},{cy+r*0.5:.1f} q{r*0.3:.1f},{r*0.16:.1f} {r*0.6:.1f},0" {line}/>'
        s += rect(cx - r*0.95, cy - r*0.78, r*1.9, r*0.14, '#e0b24a', r=r*0.07)
    return s + '</g>'

def _arch(x, y, w, h, fill, extra=''):
    r = w / 2
    return path(f'M{x},{y+h} L{x},{y+r} A{r},{r} 0 0 1 {x+w},{y+r} L{x+w},{y+h} Z', fill, extra)

# ---------------------------------------------------------------- city building
def bld_theatrum():
    """Roman theatre seen from outside/above at 3/4: the arcaded outer wall of
    the semicircular cavea faces the viewer, the tiers descend to the orchestra
    and the stage building (scaenae frons) closes the far side."""
    w, h = 560, 420
    b = ellipse(280, 392, 250, 28, 'rgba(40,20,60,0.25)')
    # stage building at the back, its facade turned towards the cavea
    b += rect(70, 126, 420, 120, 'url(#wall)', r=6, extra=STROKE)
    b += columns(80, 136, 400, 108, 7)
    b += rect(60, 112, 440, 18, 'url(#marble)', r=4, extra=STROKE)
    b += roof(50, 36, 460, 78)
    # banner with the comic and tragic masks
    b += rect(190, 150, 180, 40, '#6a2fb0', r=6, extra='stroke="#3d1a66" stroke-width="2"') + rect(186, 146, 188, 8, '#e0b24a', r=3)
    b += mask(250, 174, 15, 'comic', 'url(#gold)', hair='#d9a02a') + mask(310, 174, 15, 'tragic', 'url(#gold)', hair='#d9a02a')
    # wooden stage (pulpitum) along the diameter of the cavea
    b += rect(60, 240, 440, 22, 'url(#wood)', r=4, extra=STROKE)
    # tiers: nested half-ellipses hanging from the diameter line y=260
    tiers = [(250, 80, '#f4ecd8'), (232, 74, '#e9dcbb'), (204, 65, '#dccca6'), (176, 56, '#e9dcbb'), (148, 47, '#dccca6'), (120, 38, '#e9dcbb')]
    for rx, ry, col in tiers:
        b += path(f'M{280-rx},260 A{rx},{ry} 0 0 0 {280+rx},260 Z', col, STROKE2)
    for deg in (30, 60, 90, 120, 150):  # radial aisles
        a = math.radians(deg)
        b += f'<line x1="280" y1="260" x2="{280 - 232*math.cos(a):.1f}" y2="{260 + 74*math.sin(a):.1f}" stroke="#b9a882" stroke-width="2"/>'
    random.seed(17)
    for _ in range(46):  # a sprinkling of spectators on the seats
        a = math.radians(random.uniform(12, 168)); k = random.randint(1, 5)
        rx = (tiers[k][0] + tiers[k+1][0]) / 2 if k < 5 else 106
        ry = rx * 74 / 232
        x, y = 280 - rx*math.cos(a), 260 + ry*math.sin(a)
        b += rect(x-3, y-7, 6, 9, random.choice(['#ffffff', '#e0333f', '#6a2fb0', '#3bb8e8']), r=2)
    b += path('M188,260 A92,29 0 0 0 372,260 Z', 'url(#sand)', STROKE2)  # orchestra
    # outer facade with one row of arcades
    b += path('M30,260 A250,80 0 0 0 530,260 L530,330 A250,80 0 0 1 30,330 Z', 'url(#wall)', STROKE)
    for i in range(14):
        a = math.pi*(i + 0.5)/14
        x, yt = 280 - 250*math.cos(a), 260 + 80*math.sin(a)
        aw = 22*(0.45 + 0.55*math.sin(a))
        b += rect(x - aw/2, yt + 14, aw, 44, '#5a3a55', r=aw/2)
        b += rect(x - aw/2 + 3, yt + 17, aw - 6, 38, '#8a6a85', r=aw/2, extra='opacity="0.35"')
    b += path('M30,296 A250,80 0 0 0 530,296', 'none', 'stroke="#c9b88f" stroke-width="4"')
    b += banner(46, 266, 26, 54, '#b02a3a') + banner(488, 266, 26, 54, '#b02a3a')
    return write('bld_theatrum', w, h, b, DEFS)

# ---------------------------------------------------------------- stage backdrop
def _door(x, y, w, h, n):
    """Arched doorway of the scaenae frons with parted crimson curtains and a
    purple pelmet, clipped to the arch. Returns (svg, defs)."""
    r = w / 2
    arch = f'M{x},{y+h} L{x},{y+r} A{r},{r} 0 0 1 {x+w},{y+r} L{x+w},{y+h} Z'
    defs = f'<clipPath id="door{n}"><path d="{arch}"/></clipPath>'
    s = _arch(x-14, y-14, w+28, h+14, 'url(#marble)', STROKE)
    s += path(arch, '#2a1a3a', STROKE2)
    s += f'<g clip-path="url(#door{n})">'
    for side in (0, 1):
        u = (lambda t: x + t*w) if side == 0 else (lambda t: x + (1-t)*w)
        s += path(f'M{u(0)},{y} L{u(0.6)},{y} Q{u(0.55)},{y+h*0.25} {u(0.15)},{y+h*0.5} Q{u(0.36)},{y+h*0.7} {u(0.3)},{y+h} L{u(0)},{y+h} Z', 'url(#crimson)', STROKE)
        s += circle(u(0.13), y + h*0.5, 9, '#e0b24a', STROKE2)
    s += rect(x, y, w, 34, 'url(#curtain)')
    for k in range(6):
        px = x + k*w/6
        s += path(f'M{px},{y+32} Q{px+w/12},{y+52} {px+w/6},{y+32} Z', 'url(#curtain)', 'stroke="#3d1a66" stroke-width="2"')
    s += '</g>'
    return s, defs

def _spectator(x, y, s, col, arms=False):
    out = ''
    if arms:  # arms raised in applause
        for sd in (-1, 1):
            out += rect(x + sd*16*s - 4*s, y - 12*s, 8*s, 24*s, '#ffd9b3', r=4*s, extra=STROKE2 + f' transform="rotate({sd*25} {x+sd*16*s} {y+12*s})"')
    out += rect(x - 12*s, y, 24*s, 40*s, col, r=8*s, extra=STROKE2)
    out += circle(x, y - 10*s, 11*s, '#ffd9b3', STROKE2)
    return out

def _wing(seed):
    """Left wing of the cavea: five curved tiers rising towards the outer edge
    of the picture, with chibi spectators. Mirrored for the right wing."""
    X = 360
    s = ''
    random.seed(seed)
    rows = [(600 + i*96, 780 + i*50) for i in range(5)]
    for i, (yo, yi) in enumerate(rows):
        c = (200, yo + (yi - yo)*0.35)
        if i + 1 < len(rows):
            yo2, yi2 = rows[i+1]; c2 = (200, yo2 + (yi2 - yo2)*0.35)
            d = f'M0,{yo} Q{c[0]},{c[1]} {X},{yi} L{X},{yi2} Q{c2[0]},{c2[1]} 0,{yo2} Z'
        else:
            d = f'M0,{yo} Q{c[0]},{c[1]} {X},{yi} L{X},1080 L0,1080 Z'
        s += path(d, '#e9dcbb' if i % 2 == 0 else '#dccca6', 'stroke="#3a2a1a" stroke-width="3"')
        x = 26 + random.randint(0, 20)
        while x < X - 24:
            t = x / X
            y = (1-t)**2*yo + 2*(1-t)*t*c[1] + t*t*yi
            sc = 1.15 - 0.4*t
            col = random.choice(['#ffffff', '#f4ecd8', '#e0333f', '#6a2fb0', '#3bb8e8', '#f2d7a0', '#5fb37a'])
            s += _spectator(x, y - 4*sc, sc, col, arms=random.random() < 0.35)
            x += int(44 + 14*(1-t))
    s += rect(X-6, 776, 14, 304, 'url(#marble)', r=3, extra=STROKE)  # parapet pier against the stage
    return s

def theatrum_bg():
    """The stage seen from the orchestra: two-storey scaenae frons with three
    curtained doors, sunny sky above, cavea wings with spectators on the lower
    sides, wooden stage floor. The band at 40-45 % of the height (cornice and
    plain attic) stays calm because the RECTE!/ERRAT… line is drawn there;
    actors stand at ~86 % of the height."""
    w, h = 1920, 1080
    defs = DEFS
    b = rect(0, 0, w, h, 'url(#sky)')
    b += circle(1600, 105, 56, '#fff6c8') + circle(1600, 105, 100, 'url(#glow)')
    random.seed(21)
    for i in range(6):
        x = random.randint(60, 1860); y = random.randint(40, 150); s = random.uniform(0.6, 1.1)
        b += ellipse(x, y, 90*s, 28*s, 'rgba(255,255,255,0.85)') + ellipse(x+50*s, y-12*s, 60*s, 26*s, 'rgba(255,255,255,0.85)') + ellipse(x-50*s, y-8*s, 55*s, 22*s, 'rgba(255,255,255,0.85)')
    # golden masks as acroteria on the roof line
    b += mask(660, 168, 30, 'comic', 'url(#gold)', hair='#d9a02a') + mask(1260, 168, 30, 'tragic', 'url(#gold)', hair='#d9a02a')
    # tiled roof of the stage building and its cornice
    b += rect(0, 200, 1920, 56, 'url(#roof)', extra='stroke="#3a2a1a" stroke-width="3"')
    for i in range(1, 4):
        b += f'<line x1="0" y1="{200+i*14}" x2="1920" y2="{200+i*14}" stroke="#8f3a24" stroke-width="2" opacity="0.5"/>'
    for k in range(24, 1920, 48):
        b += f'<line x1="{k}" y1="200" x2="{k}" y2="256" stroke="#8f3a24" stroke-width="2" opacity="0.3"/>'
    b += rect(0, 250, 1920, 18, 'url(#marble)', extra='stroke="#3a2a1a" stroke-width="3"')
    # upper storey: wall, niches with statues, colonnade
    b += rect(0, 268, 1920, 156, 'url(#wall)', extra='stroke="#3a2a1a" stroke-width="3"')
    for k in range(1, 12):
        nx = 160*k
        b += _arch(nx-30, 300, 60, 104, '#6a4a66', STROKE2)
        b += rect(nx-12, 334, 24, 66, '#f4ecd8', r=6, extra=STROKE2) + circle(nx, 326, 11, '#f4ecd8', STROKE2)
    b += columns(0, 292, 1920, 118, 12)
    # purple valance hanging from the cornice
    b += rect(0, 268, 1920, 20, 'url(#curtain)')
    for x in range(0, 1920, 60):
        b += path(f'M{x},286 Q{x+30},330 {x+60},286 Z', 'url(#curtain)', 'stroke="#3d1a66" stroke-width="2"')
        b += circle(x+30, 318, 5, '#e0b24a')
    b += rect(0, 266, 1920, 6, '#e0b24a')
    # cornice + plain attic + plain central pediment: the calm zone for the feedback line
    b += rect(0, 420, 1920, 22, 'url(#marble)', extra='stroke="#3a2a1a" stroke-width="3"')
    b += rect(0, 440, 1920, 62, 'url(#wall)', extra='stroke="#3a2a1a" stroke-width="3"')
    b += poly([(700, 500), (960, 446), (1220, 500)], 'url(#marble)', STROKE)
    # lower storey: wall, three doors with curtains, columns
    b += rect(0, 500, 1920, 300, 'url(#wall)', extra='stroke="#3a2a1a" stroke-width="3"')
    for n, (x, y, dw, dh) in enumerate([(860, 540, 200, 260), (540, 600, 150, 200), (1230, 600, 150, 200)]):
        s, d = _door(x, y, dw, dh, n); b += s; defs += d
    b += mask(615, 556, 28, 'comic', 'url(#gold)', hair='#d9a02a') + mask(1305, 556, 28, 'tragic', 'url(#gold)', hair='#d9a02a')
    for x in (460, 760, 1160, 1460):
        b += rect(x-24, 520, 48, 270, 'url(#col)', r=7)
        b += rect(x-32, 514, 64, 12, '#c9b88f', r=3) + rect(x-32, 780, 64, 12, '#c9b88f', r=3)
    b += rect(0, 788, 1920, 14, 'url(#marble)', extra='stroke="#3a2a1a" stroke-width="3"')
    # wooden stage floor and its front face (pulpitum)
    b += rect(0, 800, 1920, 212, 'url(#wood)')
    for i in range(1, 7):
        b += f'<line x1="0" y1="{800 + i*30}" x2="1920" y2="{800 + i*30}" stroke="#8a5a2a" stroke-width="2" opacity="0.55"/>'
        for k in range(8):
            jx = k*260 + (i % 2)*130 + 40
            b += f'<line x1="{jx}" y1="{800 + (i-1)*30}" x2="{jx}" y2="{800 + i*30}" stroke="#8a5a2a" stroke-width="2" opacity="0.45"/>'
    b += rect(0, 1010, 1920, 70, 'url(#woodDark)', extra='stroke="#3a2a1a" stroke-width="3"')
    for x in range(120, 1920, 240):
        b += circle(x, 1045, 14, 'url(#gold)', STROKE2)
    # small altar (thymele) at the front centre of the stage
    b += rect(915, 950, 90, 44, 'url(#marble)', r=6, extra=STROKE) + rect(905, 942, 110, 14, 'url(#marble)', r=4, extra=STROKE)
    b += path('M944,942 q16,-40 32,0 q-8,-14 -16,-30 q-8,16 -16,30 Z', '#ff9a3c')
    # cavea wings with the audience, left and right
    b += _wing(7)
    b += '<g transform="translate(1920 0) scale(-1 1)">' + _wing(8) + '</g>'
    return write('theatrum_bg', w, h, b, defs)

# ---------------------------------------------------------------- figure pieces
def _eyes_left(cx, hy, stern=False):
    """Eyes with pupils turned to the left (towards the player)."""
    s = ''
    for dx in (-36, 36):
        s += ellipse(cx+dx, hy, 16, 14 if stern else 20, '#ffffff', STROKE)
        s += circle(cx+dx-5, hy+3, 9, '#3a2a1a') + circle(cx+dx-2, hy-2, 3, '#ffffff')
    if stern:
        s += f'<path d="M{cx-58},{hy-26} l40,8 M{cx+58},{hy-26} l-40,8" stroke="#3a2a1a" stroke-width="7" stroke-linecap="round"/>'
    return s

def _masked_head(cx, cy, kind, r=92, fill='url(#maskFace)', hair=None):
    """Neck and head with a theatre mask worn over the face."""
    s = rect(cx-26, 220, 52, 40, 'url(#skin)', r=14, extra=STROKE)
    s += circle(cx, cy, 90, 'url(#skin)', STROKE)
    s += mask(cx, cy, r, kind, fill, hair)
    return s

def _stage_tunic(cx, fill='url(#saffron)', trim='#6a2fb0'):
    """Saffron stage tunic with purple clavi and hem and a gold belt."""
    s = path(f'M{cx-82},260 L{cx+82},260 L{cx+98},420 L{cx-98},420 Z', fill, STROKE)
    for dx in (-34, 34):
        s += rect(cx+dx-6, 262, 12, 150, trim, r=3)
    s += rect(cx-98, 400, 196, 22, trim, r=4)
    s += rect(cx-84, 320, 168, 16, '#e0b24a', r=6)
    return s

def _held_mask(x, y):
    return circle(x, y, 22, 'url(#skin)', STROKE) + mask(x, y-14, 34, 'comic')

def _slipping_mask(x, y):
    return _open_hand(x, y) + mask(x+16, y+46, 34, 'comic', rot=40)

def _lyre(x, y):
    s = ''
    for sd in (-1, 1):
        s += path(f'M{x+sd*30},{y+20} Q{x+sd*42},{y-50} {x+sd*14},{y-70} L{x+sd*8},{y-60} Q{x+sd*28},{y-40} {x+sd*18},{y+4} Z', 'url(#gold)', STROKE)
    s += rect(x-24, y-66, 48, 8, 'url(#gold)', r=3, extra=STROKE)
    s += ellipse(x, y+14, 30, 18, 'url(#bronze)', STROKE)
    for k in range(5):
        s += f'<line x1="{x-12+k*6}" y1="{y-58}" x2="{x-12+k*6}" y2="{y+2}" stroke="#fff3c4" stroke-width="1.5"/>'
    return s

def _boots(cx):
    """Cothurni: the high platform boots of tragic actors."""
    s = ''
    for dx in (-30, 30):
        s += rect(cx+dx-20, 400, 40, 96, 'url(#boot)', r=10, extra=STROKE)
        for k in range(4):
            s += f'<path d="M{cx+dx-12},{418+k*16} l24,8 M{cx+dx+12},{418+k*16} l-24,8" stroke="#e0b24a" stroke-width="2.5" fill="none"/>'
        s += rect(cx+dx-26, 480, 52, 18, '#3a2a1a', r=6, extra=STROKE)
    return s

# ---------------------------------------------------------------- the player as actor
def histrio(pose):
    """Same Roman boy as hero_*/orator_* in a saffron stage tunic, holding a
    comic mask in his left hand. Poses: idle, gesture, hurt, victory, defeat."""
    w, h = 420, 540
    cx = 210
    b = _shadow(cx)
    if pose == 'defeat':
        # slumped on the floor: splayed legs, lowered torso, the mask dropped beside him
        for dx in (-1, 1):
            px = cx + dx*30
            b += f'<g transform="rotate({-dx*62} {px} 430)">' + rect(px-18, 420, 36, 90, 'url(#skin)', r=14, extra=STROKE) + rect(px-24, 490, 48, 24, '#8a5a2a', r=8, extra=STROKE) + '</g>'
        g = '<g transform="translate(0 60)">'
        g += _stage_tunic(cx)
        g += _arm(cx-84, -28, _open_hand, 'url(#saffron)')
        g += _arm(cx+84, 28, _fist, 'url(#saffron)')
        g += _head(cx, 170, laurel_on=True, eyes='sad', mouth='sad')
        g += '</g>'
        g += f'<g transform="translate({cx+130} 486) scale(1 0.55) translate({-(cx+130)} -486)">' + mask(cx+130, 486, 30, 'comic') + '</g>'
        return write('histrio_defeat', w, h, b + g, DEFS)
    if pose == 'victory':
        # theatrical bow: the upper body tilts towards the audience, the mask raised high
        b += _legs(cx)
        g = f'<g transform="rotate(18 {cx} 410)">'
        g += _stage_tunic(cx)
        g += _arm(cx-84, 160, _held_mask, 'url(#saffron)')
        g += _arm(cx+84, -40, _fist, 'url(#saffron)')
        g += _head(cx, 170, laurel_on=True, eyes='open', mouth='speak')
        g += '</g>'
        return write('histrio_victory', w, h, b + g, DEFS)
    lean = {'idle': 0, 'gesture': -10, 'hurt': 14}[pose]
    arm_r = {'idle': 10, 'gesture': -120, 'hurt': 40}[pose]
    arm_l = {'idle': -10, 'gesture': 20, 'hurt': -40}[pose]
    eyes = {'idle': 'open', 'gesture': 'open', 'hurt': 'hurt'}[pose]
    mouth = {'idle': 'smile', 'gesture': 'shout', 'hurt': 'hurt'}[pose]
    g = f'<g transform="translate({lean} 0) rotate({lean*0.4} {cx} 380)">'
    g += _legs(cx)
    g += _stage_tunic(cx)
    g += _arm(cx-84, arm_l, _slipping_mask if pose == 'hurt' else _held_mask, 'url(#saffron)')
    g += _arm(cx+84, arm_r, _open_hand if pose == 'gesture' else _fist, 'url(#saffron)')
    g += _head(cx, 170, laurel_on=True, eyes=eyes, mouth=mouth)
    g += '</g>'
    return write(f'histrio_{pose}', w, h, b + g, DEFS)

# ---------------------------------------------------------------- opposing actors
def actor(kind):
    """Opponents of the Theatrum, facing left towards the player."""
    w, h = 480, 540
    cx = 240
    defs = DEFS
    b = _shadow(cx)
    if kind == 'comoedus':      # comic actor: grinning mask, padded belly, red and white striped tunic
        b += _legs(cx)
        tun = f'M{cx-84},260 L{cx+84},260 Q{cx+140},340 {cx+112},420 L{cx-112},420 Q{cx-140},340 {cx-84},260 Z'
        defs += f'<clipPath id="comTunic"><path d="{tun}"/></clipPath>'
        b += path(tun, '#ffffff', STROKE)
        b += '<g clip-path="url(#comTunic)">' + ''.join(rect(cx-150, 268 + i*32, 300, 16, '#e0333f') for i in range(5)) + '</g>'
        b += path(tun, 'none', STROKE)
        b += rect(cx-118, 336, 236, 16, '#8a5a2a', r=6)
        b += _arm(cx-84, 85, _open_hand, '#ffffff')
        b += _arm(cx+84, -25, _fist, '#ffffff')
        b += _masked_head(cx, 170, 'comic', hair='#c8502a')
    elif kind == 'tragoedus':   # tragic actor: tall onkos mask, long dark robe, high cothurni
        b += _boots(cx)
        b += path(f'M{cx-84},260 L{cx+84},260 L{cx+110},450 L{cx-110},450 Z', 'url(#dark)', STROKE)
        b += rect(cx-110, 432, 220, 18, '#e0b24a', r=4)
        b += rect(cx-8, 262, 16, 170, '#e0b24a', r=3)
        for dx in (-50, 50):
            b += f'<path d="M{cx+dx},270 L{cx+dx*1.2},440" stroke="#221733" stroke-width="3" opacity="0.6"/>'
        b += _arm(cx-84, 70, _open_hand, 'url(#dark)')
        b += _arm(cx+84, -140, _open_hand, 'url(#dark)')
        b += _masked_head(cx, 178, 'tragic', r=84)
    elif kind == 'mimus':       # mime: patchwork cloak, pointed hood, painted face, no mask
        b += _legs(cx)
        cloak = f'M{cx-92},258 Q{cx-150},360 {cx-130},470 L{cx+130},470 Q{cx+150},360 {cx+92},258 Z'
        defs += f'<clipPath id="mimCloak"><path d="{cloak}"/></clipPath>'
        b += path(cloak, '#e0333f', STROKE)
        random.seed(13)
        cols = ['#e0333f', '#3bb8e8', '#ffd166', '#5fb37a', '#8d4be0', '#ff9a3c']
        b += '<g clip-path="url(#mimCloak)">'
        for row in range(6):
            for col in range(8):
                b += rect(cx-160 + col*42 + (row % 2)*21, 250 + row*40, 42, 40, random.choice(cols), extra=STROKE2)
        b += '</g>'
        b += path(cloak, 'none', STROKE)
        b += _arm(cx-84, 60, _open_hand, '#ffd166')
        b += _arm(cx+84, -30, _open_hand, '#5fb37a')
        hy = 170
        b += rect(cx-26, 220, 52, 40, 'url(#skin)', r=14, extra=STROKE) + circle(cx, hy, 92, 'url(#skin)', STROKE)
        b += circle(cx, hy+8, 66, '#fbf7ee', 'stroke="#e6d6c6" stroke-width="2"')  # white face paint
        b += path(f'M{cx-92},{hy-10} Q{cx-104},{hy-100} {cx-30},{hy-108} Q{cx+40},{hy-140} {cx+130},{hy-160} Q{cx+80},{hy-110} {cx+92},{hy-10} Q{cx+70},{hy-40} {cx+40},{hy-52} Q{cx},{hy-30} {cx-40},{hy-52} Q{cx-70},{hy-40} {cx-92},{hy-10} Z', '#5fb37a', STROKE)
        b += circle(cx+130, hy-160, 9, 'url(#gold)', STROKE2)
        for dx in (-36, 36):
            b += poly([(cx+dx, hy-30), (cx+dx+24, hy), (cx+dx, hy+30), (cx+dx-24, hy)], '#1c73b8')
        b += _eyes_left(cx, hy)
        b += circle(cx, hy+22, 12, '#e0333f', STROKE)
        b += path(f'M{cx-30},{hy+40} q30,40 60,0 Z', '#7a2a3a', 'stroke="#3a2a1a" stroke-width="5" stroke-linecap="round"')
        b += circle(cx-60, hy+30, 14, 'rgba(255,90,90,0.5)') + circle(cx+60, hy+30, 14, 'rgba(255,90,90,0.5)')
    elif kind == 'pantomimus':  # pantomime dancer: closed-mouth mask, long teal robe, flowing veil
        b += path(f'M{cx+20},110 Q{cx+230},160 {cx+220},420 Q{cx+120},330 {cx+70},300 Q{cx+30},220 {cx+20},110 Z', 'url(#veil)', 'stroke="#9a5cf0" stroke-width="2"')
        b += _legs(cx)
        b += path(f'M{cx-80},260 L{cx+80},260 L{cx+96},480 L{cx-96},480 Z', 'url(#teal)', STROKE)
        b += rect(cx-96, 462, 192, 18, '#e0b24a', r=4) + rect(cx-80, 300, 160, 14, '#e0b24a', r=6)
        b += _arm(cx-84, 95, _open_hand, 'url(#teal)')
        b += _arm(cx+84, -160, _open_hand, 'url(#teal)')
        b += _masked_head(cx, 170, 'closed', hair='#3a2a1a')
        b += path(f'M{cx-200},262 Q{cx-270},330 {cx-210},470 Q{cx-150},380 {cx-120},300 Z', 'url(#veil)', 'stroke="#9a5cf0" stroke-width="2"')
    elif kind == 'chorus':      # chorus leader: white robe with gold border, lyre, singing
        b += _legs(cx)
        b += _toga(cx, 'url(#toga)', '#e0b24a')
        b += rect(cx-84, 320, 168, 16, '#e0b24a', r=6)
        b += _arm(cx-84, 15, _lyre)
        b += _arm(cx+84, -70, _open_hand)
        b += _head(cx, 170, hair='#5c2f12', eyes='none', mouth='speak') + _eyes_left(cx, 170)
        b += rect(cx-92, 96, 184, 12, 'url(#gold)', r=6, extra=STROKE2)
    elif kind == 'dominus':     # dominus gregis: purple cloak, staff, stern, two masks at the belt
        b += _legs(cx)
        b += _toga(cx, 'url(#togaPurple)', '#e0b24a')
        b += rect(cx-98, 322, 196, 18, 'url(#brown)', r=6)
        for dx, mk in ((38, 'comic'), (86, 'tragic')):  # on his right side, clear of the staff arm
            b += f'<line x1="{cx+dx}" y1="336" x2="{cx+dx}" y2="360" stroke="#3a2a1a" stroke-width="3"/>'
            b += mask(cx+dx, 380, 20, mk)
        b += _arm(cx-84, -8, _staff, 'url(#togaPurple)')
        b += _arm(cx+84, -30, _fist, 'url(#togaPurple)')
        b += _head(cx, 170, hair='url(#grey)', beard=True, old=True, eyes='none', mouth='flat') + _eyes_left(cx, 170, stern=True)
    return write(f'actor_{kind}', w, h, b, defs)

# ---------------------------------------------------------------- mask projectile
def persona():
    w = h = 128
    b = circle(64, 64, 56, 'url(#glow)')
    for sd in (-1, 1):
        b += f'<path d="M{64+sd*34},40 q{sd*16},10 {sd*12},28" stroke="#b02a3a" stroke-width="4" stroke-linecap="round" fill="none"/>'
    b += mask(64, 68, 40, 'comic', 'url(#gold)', hair='#d9a02a')
    b += circle(100, 26, 7, '#ffffff', 'opacity="0.9"')
    return write('persona', w, h, b, DEFS)

if __name__ == '__main__':
    bld_theatrum()
    theatrum_bg()
    for p in ('idle', 'gesture', 'hurt', 'victory', 'defeat'):
        histrio(p)
    for k in ('comoedus', 'tragoedus', 'mimus', 'pantomimus', 'chorus', 'dominus'):
        actor(k)
    persona()
