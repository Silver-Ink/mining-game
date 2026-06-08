These sound are from https://freesound.org/


```bash
sudo apt install ffmpeg

# Convert the sound in original into the current folder in ogg
for f in ./original/*.wav; do ffmpeg -i "$f" -ab 128k "$(basename "$f" .wav).ogg"; done
```

TODO: Check the asset licence