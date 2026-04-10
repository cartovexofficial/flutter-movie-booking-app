import urllib.request
import os
import time

urls = {
    "pushpa2.jpg": "https://upload.wikimedia.org/wikipedia/en/1/1f/Pushpa_2_The_Rule_poster.jpg",
    "kalki.jpg": "https://upload.wikimedia.org/wikipedia/en/4/4f/Kalki_2898_AD_release_poster.jpg",
    "stree2.jpg": "https://upload.wikimedia.org/wikipedia/en/0/05/Stree_2_poster.jpg",
    "fighter.jpg": "https://upload.wikimedia.org/wikipedia/en/d/df/Fighter_film_teaser.jpg",
    "singham.jpg": "https://upload.wikimedia.org/wikipedia/en/e/eb/Singham_Again_poster.jpg",
    "bhool.jpg": "https://upload.wikimedia.org/wikipedia/en/6/6f/Bhool_Bhulaiyaa_3_poster.jpg",
    "munjya.jpg": "https://upload.wikimedia.org/wikipedia/en/4/4b/Munjya_film_poster.jpg",
    "crew.jpg": "https://upload.wikimedia.org/wikipedia/en/1/1f/Crew_film_poster.jpg",
    "chhaava.jpg": "https://upload.wikimedia.org/wikipedia/en/f/f6/Chhaava_poster.jpg",
    "animal.jpg": "https://upload.wikimedia.org/wikipedia/en/9/90/Animal_%282023_film%29_poster.jpg"
}

opener = urllib.request.build_opener()
opener.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)')]
urllib.request.install_opener(opener)

for name, url in urls.items():
    try:
        urllib.request.urlretrieve(url, f"assets/{name}")
        print(f"Downloaded: {name}")
    except Exception as e:
        print(f"Failed: {name} -> {e}")
        # dummy file if failed so it doesn't crash app
        with open(f"assets/{name}", "wb") as f:
            f.write(b"")
    time.sleep(0.5)
