#!/usr/bin/env bash

cp baked.png unbaked.png
for i in {0..3}; do
	magick unbaked.png -crop 100%x50% +repage split%d.png
	magick split1.png split0.png +append -resize 50%x200% unbaked.png
done
rm -rf split*.png

