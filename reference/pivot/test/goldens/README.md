# Original interface references

Source: commit `9bc4ad137078aa87efe30112db6919eb11703f66`, before the JSON migration. These PNGs were rendered from its original Flutter widgets, not from the replacement interface.

Six screens at 1600 × 900 and 420 × 900: city, selection, settings, progress, introduction, and battle. Both builds use the shipped fonts and assets, an empty profile, and the same authored question fixture. Scene animation is paused, actor scale is set to its base pose, and the scene is explicitly repainted before capture. This removes time-dependent breathing differences without changing the source animation.

`visual_restoration_test.dart` uses strict Flutter golden comparison. Do not regenerate these references from the current implementation merely to accept a mismatch. Changing the intended interface requires an explicit design decision.
