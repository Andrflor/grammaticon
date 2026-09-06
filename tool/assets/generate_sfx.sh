#!/usr/bin/env bash
# Synthesises the Forum sound cues with SoX (CC0, produced in this repository).
# The Amphitheatrum cues were produced the same way; see doc/assets_manifest.md.
set -euo pipefail
OUT="$(dirname "$0")/../../assets/audio"
# ōrātiō: a rising, breathy sweep — the argument leaves the orator's hand.
sox -n -r 44100 -c 1 "$OUT/oratio.wav" synth 0.28 sine 320:760 synth 0.28 pinknoise mix vol 0.35 fade q 0.02 0.28 0.12 gain -6
# plausus: applause — bursts of filtered noise with a soft decay.
sox -n -r 44100 -c 1 "$OUT/plausus.wav" synth 0.9 brownnoise band -n 1800 900 tremolo 22 70 fade t 0.03 0.9 0.5 gain -4
# refūtātiō: a short falling tone — the rebuttal lands.
sox -n -r 44100 -c 1 "$OUT/refutatio.wav" synth 0.32 sawtooth 420:180 lowpass 1200 fade q 0.01 0.32 0.18 gain -8
# murmur: the crowd's low, disapproving hum.
sox -n -r 44100 -c 1 "$OUT/murmur.wav" synth 0.8 brownnoise lowpass 420 tremolo 6 40 fade t 0.08 0.8 0.4 gain -6
echo "wrote oratio plausus refutatio murmur"
