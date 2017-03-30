#! /bin/bash
cd /Users/"$USER"/Desktop/photos;
i=1; for x in *; do mv $x $i.jpg; let i=i+1; done
/usr/local/bin/ffmpeg -framerate 15 -i /Users/"$USER"/Desktop/photos/%d.jpg -c libx264 -vf transpose=1 -s /Users/"$USER"/Desktop/output/"`date +%m%d_%H%M%S`".mp4;
mkdir /Users/"$USER"/Desktop/output/"`date +%m%d_%H%M%S`";
mv /Users/"$USER"/Desktop/photos/* /Users/"$USER"/Desktop/output/"`date +%m%d_%H%M%S`";
open /Users/"$USER"/Desktop/output;
