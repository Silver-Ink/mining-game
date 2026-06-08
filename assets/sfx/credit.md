These sound are from https://freesound.org/


```bash
sudo apt install ffmpeg

# Convert all sound in original into the current folder in ogg
for f in ./original/*.wav; do ffmpeg -i "$f" -ab 128k "$(basename "$f" .wav).ogg"; done


ffmpeg -i 654499__bigal13__pickaxe-striking-hard-rock.wav -b:a 128k 654499__bigal13__pickaxe-striking-hard-rock.ogg
```

TODO: Check the asset licence