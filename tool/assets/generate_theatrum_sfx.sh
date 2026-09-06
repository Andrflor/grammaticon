#!/usr/bin/env bash
# Synthesises the Theatrum sound cues with SoX (CC0, produced in this repository).
# The Amphitheatrum and Forum cues were produced the same way; see doc/assets_manifest.md.
set -euo pipefail
OUT="$(dirname "$0")/../../assets/audio"
# tībia: a short rising double-reed flourish — the actor's cue to deliver the line.
sox -n -r 44100 -c 1 "$OUT/tibia.wav" synth 0.34 sine 660:990 sine mix 1320:1980 vol 0.5 tremolo 9 25 fade q 0.02 0.34 0.12 gain -8
# sībilus: the cavea hisses — bright filtered noise with a wavering decay.
sox -n -r 44100 -c 1 "$OUT/sibilus.wav" synth 0.6 whitenoise band -n 4200 1800 tremolo 14 60 fade t 0.05 0.6 0.3 gain -12
echo "wrote tibia sibilus"
