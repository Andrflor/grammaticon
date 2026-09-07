#!/usr/bin/env bash
# Synthesises the menu / navigation cues with SoX (CC0, produced in this repository).
# The Amphitheatrum, Forum and Theatrum cues were produced the same way; see doc/assets_manifest.md.
set -euo pipefail
OUT="$(dirname "$0")/../../assets/audio"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# tuba: the bout begins — a quick rising arpeggio (C5 E5 G5 C6) of plucked
# notes landing on a soft, held bell chord.
pl() { sox -n -r 44100 -c 1 "$2" synth 0.42 pluck "$1" fade q 0 0.42 0.28 pad "$3" gain -8; }
pl C5 "$TMP/t1.wav" 0
pl E5 "$TMP/t2.wav" 0.08
pl G5 "$TMP/t3.wav" 0.16
pl C6 "$TMP/t4.wav" 0.24
sox -n -r 44100 -c 1 "$TMP/chord.wav" synth 0.7 sine C5 sine mix E5 sine mix G5 sine mix C6 vol 0.35 fade q 0.05 0.7 0.5 pad 0.30 gain -10
sox -m "$TMP/t1.wav" "$TMP/t2.wav" "$TMP/t3.wav" "$TMP/t4.wav" "$TMP/chord.wav" "$OUT/tuba.wav" reverb 20 35 50 gain -n -5

# folium: a sheet unfolds — a brief paper rustle.
sox -n -r 44100 -c 1 "$OUT/folium.wav" synth 0.24 whitenoise band -n 3200 2600 tremolo 40 30 fade t 0.02 0.24 0.16 gain -16

# vetitum: not allowed — a dull, falling double buzz.
sox -n -r 44100 -c 1 "$OUT/vetitum.wav" synth 0.09 square 190 synth 0.09 square mix 95 vol 0.5 lowpass 700 fade q 0.004 0.09 0.03 : synth 0.16 square 130 synth 0.16 square mix 65 vol 0.5 lowpass 600 fade q 0.004 0.16 0.1 gain -12

echo "wrote tuba folium vetitum"
