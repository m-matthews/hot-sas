#!/usr/bin/env bash

# Use ImageMagick to convert the sequences of images into an animation with fading between frames.

convert -delay 10 -morph 12 04_drc_hexmonth*.png -loop 0 miff:- | convert - 04_drc_hexmonth.mov

convert -delay 5 -morph 5 04_drc_plotweek*.png -loop 0 miff:- | convert - 04_drc_plotweek.mov

