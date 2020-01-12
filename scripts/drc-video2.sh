#!/usr/bin/env bash

# Use ImageMagick and ffmpeg to convert the sequences of images into an animation with fading between frames.

mkdir cache

convert -morph 5 04_drc_plotweek*.png cache/plotweek_converted_%04d.png
convert -morph 12 04_drc_hexmonth*.png cache/hexmonth_converted_%04d.png

ffmpeg -r 15 -i cache/plotweek_converted_%04d.png -profile:v baseline -level 3.0 -preset slow -crf 12 -vcodec h264 -pix_fmt yuv420p cache/04_drc_plotweek.mp4
ffmpeg -r 15 -i cache/hexmonth_converted_%04d.png -profile:v baseline -level 3.0 -preset slow -crf 12 -vcodec h264 -pix_fmt yuv420p cache/04_drc_hexmonth.mp4
