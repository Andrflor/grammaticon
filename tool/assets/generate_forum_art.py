#!/usr/bin/env python3
"""Provisional stylised art of the Forum (SVG → PNG via rsvg-convert), in the
same manner and palette as generate_art.py, whose helpers it reuses. Produced
in this repository (CC0). See doc/assets_manifest.md for dimensions, pivots
and replacement specifications.

  python3 tool/assets/generate_forum_art.py
"""
import math, random
from generate_art import (write, lg, rg, ellipse, rect, path, circle, poly, columns, roof, banner, laurel, STROKE, DEFS_COMMON)

DEFS = DEFS_COMMON + (lg('toga', '#fbf7ee', '#d9d2c2') + lg('togaPurple', '#7a3ccf', '#4b2288') + lg('grey', '#e6e6ea', '#a7a7b3') +
    lg('floor', '#e8dcc3', '#c9b894') + lg('parchment', '#fff4d6', '#e9cf95') + lg('red', '#e0333f', '#8a1030') +
    lg('green', '#5fb37a', '#2c6a44') + lg('brown', '#8a5a2a', '#5c3a12'))

# ---------------------------------------------------------------- background
def forum_bg():
    w, h = 1920, 1080
    b = rect(0, 0, w, h, 'url(#sky)')
    b += circle(1620, 150, 64, '#fff6c8') + circle(1620, 150, 110, 'url(#glow)')
    # distant hills and temple
    b += path('M0,420 Q300,330 600,400 Q900,470 1200,380 Q1500,300 1920,410 L1920,520 L0,520 Z', '#b9c9a2')
    b += rect(760, 250, 400, 170, 'url(#wall)', extra='stroke="#3a2a1a" stroke-width="3"')
    b += columns(770, 262, 380, 150, 7)
    b += roof(740, 170, 440, 90)
    # basilica colonnade behind the speakers
    b += rect(0, 430, 1920, 250, 'url(#wall)', extra='stroke="#3a2a1a" stroke-width="3"')
    b += columns(0, 440, 1920, 230, 14)
    b += rect(0, 420, 1920, 26, 'url(#marble)', extra='stroke="#3a2a1a" stroke-width="3"')
    for x in (300, 960, 1620):
        b += banner(x - 34, 460, 68, 130, '#6a2fb0' if x != 960 else '#b02a3a')
        b += laurel(x, 515, 28, '#fff3c4')
    # Small plaque, as in the arena: the feedback line is drawn over this zone.
    b += rect(900, 452, 120, 40, 'url(#marble)', r=6, extra='stroke="#3a2a1a" stroke-width="2"')
    b += f'<text x="960" y="482" font-family="serif" font-size="28" font-weight="bold" text-anchor="middle" fill="#6a2fb0">SPQR</text>'
    # steps of the basilica where the audience stands
    for i, y in enumerate((620, 660, 700, 740)):
        b += rect(0, y, 1920, 44, '#e9dcbb' if i % 2 == 0 else '#dccca6', extra='stroke="#3a2a1a" stroke-width="2"')
    # audience: two rows of citizens on the steps
    random.seed(7)
    for row, (y, scale) in enumerate([(640, 0.85), (700, 1.0)]):
        for k in range(42):
            x = 30 + k * 46 + (23 if row else 0)
            yy = y + random.randint(-5, 5)
            col = random.choice(['#ffffff', '#f4ecd8', '#e0333f', '#6a2fb0', '#3bb8e8', '#f2d7a0'])
            b += rect(x - 12*scale, yy, 24*scale, 40*scale, col, r=8*scale, extra='stroke="#3a2a1a" stroke-width="2"')
            b += circle(x, yy - 10*scale, 11*scale, '#ffd9b3', 'stroke="#3a2a1a" stroke-width="2"')
    # steps and rostra floor
    b += rect(0, 760, 1920, 40, 'url(#marble)', extra='stroke="#3a2a1a" stroke-width="3"')
    b += rect(0, 800, 1920, 280, 'url(#floor)')
    for i in range(1, 8):
        b += f'<line x1="0" y1="{800 + i*36}" x2="1920" y2="{800 + i*36}" stroke="#b9a882" stroke-width="2" opacity="0.6"/>'
    for i in range(1, 12):
        b += f'<line x1="{i*175}" y1="800" x2="{i*175}" y2="1080" stroke="#b9a882" stroke-width="2" opacity="0.5"/>'
    # rostra (speaker's platforms) on both sides
    for x in (460, 1460):
        b += ellipse(x, 935, 280, 40, 'rgba(40,20,60,0.18)')
        b += rect(x - 250, 900, 500, 28, 'url(#marble)', r=6, extra=STROKE)
        b += rect(x - 220, 880, 440, 26, 'url(#marble)', r=6, extra=STROKE)
    # statue and brazier
    b += rect(940, 700, 40, 100, 'url(#marble)', r=4, extra=STROKE) + circle(960, 680, 20, '#f4ecd8', STROKE) + rect(944, 696, 32, 34, '#f4ecd8', r=8, extra=STROKE)
    for x in (120, 1800):
        b += rect(x - 8, 660, 16, 100, 'url(#bronze)', r=4, extra=STROKE)
        b += path(f'M{x-16},660 q16,-46 32,0 q-8,-16 -16,-34 q-8,18 -16,34 Z', '#ff9a3c')
    return write('forum_bg', w, h, b, DEFS)

# ---------------------------------------------------------------- shared figure pieces
def _legs(cx, y=400):
    s = ''
    for dx in (-30, 30):
        s += rect(cx+dx-18, y, 36, 90, 'url(#skin)', r=14, extra=STROKE)
        s += rect(cx+dx-24, y+70, 48, 26, '#8a5a2a', r=8, extra=STROKE)
    return s

def _toga(cx, fill='url(#toga)', border='#8d4be0', top=250):
    # tunic body with a draped toga fold over the left shoulder
    s = path(f'M{cx-82},{top+10} L{cx+82},{top+10} L{cx+98},420 L{cx-98},420 Z', fill, STROKE)
    s += path(f'M{cx-90},{top} Q{cx-30},{top+90} {cx+20},{top+180} Q{cx-10},{top+40} {cx-60},{top+10} Z', fill, STROKE)
    s += path(f'M{cx-90},{top} Q{cx-30},{top+90} {cx+20},{top+180}', 'none', f'stroke="{border}" stroke-width="10" stroke-linecap="round"')
    s += rect(cx-98, 400, 196, 22, border, r=4)
    return s

def _head(cx, hy, hair='url(#hair)', laurel_on=False, beard=False, old=False, bald=False, mouth='smile', eyes='open'):
    s = rect(cx-26, hy+50, 52, 40, 'url(#skin)', r=14, extra=STROKE)
    s += circle(cx, hy, 92, 'url(#skin)', STROKE)
    if not bald:
        s += path(f'M{cx-92},{hy-10} Q{cx-100},{hy-110} {cx},{hy-112} Q{cx+100},{hy-110} {cx+92},{hy-10} Q{cx+70},{hy-40} {cx+40},{hy-52} Q{cx},{hy-30} {cx-40},{hy-52} Q{cx-70},{hy-40} {cx-92},{hy-10} Z', hair, STROKE)
    else:
        s += path(f'M{cx-92},{hy-10} Q{cx-96},{hy-60} {cx-60},{hy-70} Q{cx-80},{hy-30} {cx-92},{hy-10} Z', hair, STROKE)
        s += path(f'M{cx+92},{hy-10} Q{cx+96},{hy-60} {cx+60},{hy-70} Q{cx+80},{hy-30} {cx+92},{hy-10} Z', hair, STROKE)
    if beard:
        s += path(f'M{cx-70},{hy+20} Q{cx-60},{hy+110} {cx},{hy+112} Q{cx+60},{hy+110} {cx+70},{hy+20} Q{cx+40},{hy+70} {cx},{hy+60} Q{cx-40},{hy+70} {cx-70},{hy+20} Z', hair, STROKE)
    if laurel_on:
        s += laurel(cx, hy+6, 96, '#e0b24a', a0=-1.35, step=0.13)
    if eyes == 'open':
        for dx in (-36, 36):
            s += ellipse(cx+dx, hy, 16, 20, '#ffffff', STROKE)
            s += circle(cx+dx+3, hy+3, 9, '#3a2a1a') + circle(cx+dx+6, hy-2, 3, '#ffffff')
    elif eyes == 'hurt':
        s += f'<path d="M{cx-52},{hy-2} l30,14 M{cx+52},{hy-2} l-30,14" stroke="#3a2a1a" stroke-width="6" stroke-linecap="round"/>'
    elif eyes == 'sad':
        s += f'<path d="M{cx-52},{hy+8} l30,-10 M{cx+52},{hy+8} l-30,-10" stroke="#3a2a1a" stroke-width="6" stroke-linecap="round"/>'
    elif eyes == 'stern':
        for dx in (-36, 36):
            s += ellipse(cx+dx, hy+2, 16, 14, '#ffffff', STROKE)
            s += circle(cx+dx+2, hy+4, 8, '#3a2a1a')
        s += f'<path d="M{cx-58},{hy-26} l40,8 M{cx+58},{hy-26} l-40,8" stroke="#3a2a1a" stroke-width="7" stroke-linecap="round"/>'
    if old:
        s += f'<path d="M{cx-60},{hy+30} q10,6 20,0 M{cx+40},{hy+30} q10,6 20,0" stroke="#c98a5a" stroke-width="3" fill="none"/>'
    mouths = {
        'smile': (f'M{cx-18},{hy+44} q18,14 36,0', 'none'),
        'speak': (f'M{cx-22},{hy+40} q22,26 44,0 Z', '#7a2a3a'),
        'shout': (f'M{cx-26},{hy+36} q26,34 52,0 Z', '#7a2a3a'),
        'hurt': (f'M{cx-14},{hy+50} q14,-10 28,0', 'none'),
        'sad': (f'M{cx-16},{hy+52} q16,-12 32,0', 'none'),
        'flat': (f'M{cx-18},{hy+46} l36,0', 'none'),
    }
    d, fill = mouths[mouth]
    s += path(d, fill, 'stroke="#3a2a1a" stroke-width="5" stroke-linecap="round"')
    s += circle(cx-60, hy+30, 12, 'rgba(255,120,120,0.35)') + circle(cx+60, hy+30, 12, 'rgba(255,120,120,0.35)')
    return s

def _arm(x, rot, item, sleeve='url(#toga)'):
    s = f'<g transform="rotate({rot} {x} 275)">'
    s += rect(x-22, 262, 44, 40, sleeve, r=12, extra=STROKE)
    s += rect(x-20, 290, 40, 100, 'url(#skin)', r=18, extra=STROKE)
    s += item(x, 395)
    return s + '</g>'

def _open_hand(x, y):
    s = circle(x, y, 22, 'url(#skin)', STROKE)
    for i, a in enumerate((-0.9, -0.45, 0, 0.45)):
        s += rect(x - 6 + i*4 - 6, y - 6, 12, 36, 'url(#skin)', r=6, extra=f'{STROKE} transform="rotate({a*40} {x} {y})"')
    return s

def _fist(x, y):
    return circle(x, y, 22, 'url(#skin)', STROKE)

def _scroll(x, y):
    s = rect(x-14, y-40, 28, 90, 'url(#parchment)', r=6, extra=STROKE)
    s += rect(x-20, y-46, 40, 14, '#c9a86a', r=6, extra=STROKE) + rect(x-20, y+42, 40, 14, '#c9a86a', r=6, extra=STROKE)
    for i in range(3):
        s += rect(x-8, y-24 + i*16, 16, 4, '#6a2fb0', r=2)
    return s

def _staff(x, y):
    return rect(x-6, y-160, 12, 220, 'url(#brown)', r=5, extra=STROKE) + circle(x, y-164, 12, 'url(#gold)', STROKE)

def _tablet(x, y):
    return rect(x-30, y-40, 60, 80, '#8a5a2a', r=6, extra=STROKE) + rect(x-22, y-32, 44, 64, '#e9dcbb', r=3) + rect(x-14, y-20, 28, 4, '#3a2a1a') + rect(x-14, y-8, 20, 4, '#3a2a1a') + rect(x-14, y+4, 26, 4, '#3a2a1a')

def _fasces(x, y):
    s = ''
    for dx in (-8, 0, 8):
        s += rect(x+dx-4, y-150, 8, 200, 'url(#brown)', r=3, extra=STROKE)
    s += rect(x-16, y-100, 32, 12, '#e0333f', r=3) + rect(x-16, y-40, 32, 12, '#e0333f', r=3)
    s += path(f'M{x+10},{y-150} l26,-10 l0,40 l-26,-6 Z', 'url(#stone)', STROKE)
    return s

def _shadow(cx):
    return ellipse(cx, 512, 110, 22, 'rgba(40,20,60,0.3)')

# ---------------------------------------------------------------- the player as orator
def orator(pose):
    w, h = 420, 540
    cx = 210
    lean = {'idle': 0, 'gesture': -10, 'hurt': 14, 'victory': 0, 'defeat': 0}[pose]
    arm_r = {'idle': 10, 'gesture': -120, 'hurt': 40, 'victory': -150, 'defeat': 30}[pose]
    arm_l = {'idle': -10, 'gesture': 20, 'hurt': -40, 'victory': 150, 'defeat': -30}[pose]
    body_y = 40 if pose == 'defeat' else 0
    eyes = {'idle': 'open', 'gesture': 'open', 'hurt': 'hurt', 'victory': 'open', 'defeat': 'sad'}[pose]
    mouth = {'idle': 'smile', 'gesture': 'speak', 'hurt': 'hurt', 'victory': 'shout', 'defeat': 'sad'}[pose]
    g = f'<g transform="translate({lean} {body_y}) rotate({lean*0.4} {cx} 380)">'
    g += _legs(cx)
    g += _toga(cx, 'url(#toga)', '#8d4be0')
    g += rect(cx-84, 320, 168, 16, '#e0b24a', r=6)
    g += _arm(cx-84, arm_l, _scroll)
    g += _arm(cx+84, arm_r, _open_hand if pose in ('gesture', 'victory') else _fist)
    g += _head(cx, 170, laurel_on=True, eyes=eyes, mouth=mouth)
    g += '</g>'
    return write(f'orator_{pose}', w, h, _shadow(cx) + g, DEFS)

# ---------------------------------------------------------------- opposing speakers
def rhetor(kind):
    w, h = 480, 540
    cx = 240
    b = _shadow(cx)
    if kind == 'rhetor':      # Greek rhetorician: pale blue chiton, scroll, curly dark hair
        b += _legs(cx)
        b += _toga(cx, 'url(#sky)', '#1c73b8')
        b += _arm(cx-84, 15, _scroll, 'url(#sky)')
        b += _arm(cx+84, -60, _open_hand, 'url(#sky)')
        b += _head(cx, 170, hair='#3a2a1a', beard=True, mouth='speak')
    elif kind == 'senator':   # old senator: white toga with purple stripe, grey hair, staff
        b += _legs(cx)
        b += _toga(cx, 'url(#toga)', '#6a2fb0')
        b += _arm(cx-84, -8, _staff)
        b += _arm(cx+84, -30, _fist)
        b += _head(cx, 170, hair='url(#grey)', old=True, mouth='flat', eyes='stern')
        b += rect(cx-8, 262, 16, 160, '#6a2fb0', r=4)
    elif kind == 'causidicus':  # cunning advocate: green cloak, wax tablet, smirk
        b += _legs(cx)
        b += _toga(cx, 'url(#green)', '#e0b24a')
        b += _arm(cx-84, 10, _tablet, 'url(#green)')
        b += _arm(cx+84, -40, _open_hand, 'url(#green)')
        b += _head(cx, 170, hair='#8a4b22', mouth='smile', eyes='stern')
    elif kind == 'philosophus':  # Stoic philosopher: grey cloak, bald, long beard, staff
        b += _legs(cx)
        b += _toga(cx, 'url(#grey)', '#605070')
        b += _arm(cx-84, -8, _staff, 'url(#grey)')
        b += _arm(cx+84, -50, _open_hand, 'url(#grey)')
        b += _head(cx, 170, hair='url(#grey)', beard=True, bald=True, old=True, mouth='flat')
    elif kind == 'censor':    # stern censor: purple toga, laurel, fasces
        b += _legs(cx)
        b += _toga(cx, 'url(#togaPurple)', '#e0b24a')
        b += _arm(cx-84, -6, _fasces, 'url(#togaPurple)')
        b += _arm(cx+84, -20, _fist, 'url(#togaPurple)')
        b += _head(cx, 170, hair='#3a2a1a', laurel_on=True, mouth='shout', eyes='stern')
    # ----- opponents of the nominal Forum (declensions, adjectives, pronouns…)
    elif kind == 'grammaticus':  # schoolmaster: brown cloak, wax tablet, greying beard
        b += _legs(cx)
        b += _toga(cx, 'url(#brown)', '#e0b24a')
        b += _arm(cx-84, 12, _tablet, 'url(#brown)')
        b += _arm(cx+84, -70, _open_hand, 'url(#brown)')
        b += _head(cx, 170, hair='#5a4632', beard=True, mouth='flat', eyes='stern')
    elif kind == 'poeta':     # elegant poet: parchment toga with red hem, laurel, scroll
        b += _legs(cx)
        b += _toga(cx, 'url(#parchment)', '#b02a3a')
        b += _arm(cx-84, 20, _scroll, 'url(#parchment)')
        b += _arm(cx+84, -110, _open_hand, 'url(#parchment)')
        b += _head(cx, 170, hair='#c07a3a', laurel_on=True, mouth='speak')
    elif kind == 'matrona':   # learned matron: red palla with gold hem, letter in hand
        b += _legs(cx)
        b += _toga(cx, 'url(#red)', '#e0b24a')
        b += rect(cx-90, 236, 180, 30, '#e0b24a', r=10, extra=STROKE)
        b += _arm(cx-84, 6, _scroll, 'url(#red)')
        b += _arm(cx+84, -35, _open_hand, 'url(#red)')
        b += _head(cx, 170, hair='#3a2a1a', mouth='smile')
    elif kind == 'sophista':  # Greek sophist: pale chiton with blue hem, bald, both hands open
        b += _legs(cx)
        b += _toga(cx, 'url(#marble)', '#1c73b8')
        b += _arm(cx-84, -55, _open_hand, 'url(#marble)')
        b += _arm(cx+84, -55, _open_hand, 'url(#marble)')
        b += _head(cx, 170, hair='url(#grey)', beard=True, bald=True, mouth='smile', eyes='stern')
    elif kind == 'iurisconsultus':  # jurist: white toga with crimson stripe, tablet, grey hair
        b += _legs(cx)
        b += _toga(cx, 'url(#toga)', '#8a1030')
        b += rect(cx-8, 262, 16, 160, '#8a1030', r=4)
        b += _arm(cx-84, 10, _tablet)
        b += _arm(cx+84, -25, _fist)
        b += _head(cx, 170, hair='url(#grey)', old=True, mouth='flat', eyes='stern')
    return write(f'rhetor_{kind}', w, h, b, DEFS)

# ---------------------------------------------------------------- argument scroll icon
def argumentum():
    w = h = 128
    b = rect(28, 18, 72, 92, 'url(#parchment)', r=8, extra=STROKE)
    b += rect(18, 10, 92, 18, '#c9a86a', r=8, extra=STROKE) + rect(18, 100, 92, 18, '#c9a86a', r=8, extra=STROKE)
    for i in range(4):
        b += rect(40, 38 + i*14, 48 - (i % 2)*16, 6, '#6a2fb0', r=3)
    b += circle(96, 30, 10, '#ffe08a', 'opacity="0.9"')
    return write('argumentum', w, h, b, DEFS)

RHETORES = ('rhetor', 'senator', 'causidicus', 'philosophus', 'censor', 'grammaticus', 'poeta', 'matrona', 'sophista', 'iurisconsultus')

if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        # Render only the named opponents (e.g. new ones), leaving other assets untouched.
        for k in sys.argv[1:]:
            rhetor(k)
        raise SystemExit
    forum_bg()
    for p in ('idle', 'gesture', 'hurt', 'victory', 'defeat'):
        orator(p)
    for k in ('rhetor', 'senator', 'causidicus', 'philosophus', 'censor'):
        rhetor(k)
    argumentum()
