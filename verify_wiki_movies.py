import urllib.request
import time

urls = {
    "Pushpa 2": "https://upload.wikimedia.org/wikipedia/en/1/1f/Pushpa_2_The_Rule_poster.jpg",
    "Kalki 2898 AD": "https://upload.wikimedia.org/wikipedia/en/4/4f/Kalki_2898_AD_release_poster.jpg",
    "Stree 2": "https://upload.wikimedia.org/wikipedia/en/0/05/Stree_2_poster.jpg",
    "Fighter": "https://upload.wikimedia.org/wikipedia/en/d/df/Fighter_film_teaser.jpg",
    "Singham Again": "https://upload.wikimedia.org/wikipedia/en/e/eb/Singham_Again_poster.jpg",
    "Bhool Bhulaiyaa 3": "https://upload.wikimedia.org/wikipedia/en/6/6f/Bhool_Bhulaiyaa_3_poster.jpg",
    "Munjya": "https://upload.wikimedia.org/wikipedia/en/4/4b/Munjya_film_poster.jpg",
    "Crew": "https://upload.wikimedia.org/wikipedia/en/1/1f/Crew_film_poster.jpg",
    "Kalki 2898 AD (alt)": "https://upload.wikimedia.org/wikipedia/en/thumb/4/4f/Kalki_2898_AD_release_poster.jpg/400px-Kalki_2898_AD_release_poster.jpg",
    "Singham Again (alt)": "https://upload.wikimedia.org/wikipedia/en/thumb/e/eb/Singham_Again_poster.jpg/400px-Singham_Again_poster.jpg",
    "Dunki": "https://upload.wikimedia.org/wikipedia/en/thumb/4/40/Dunki_film_poster.jpg/400px-Dunki_film_poster.jpg",
    "Chandu Champion": "https://upload.wikimedia.org/wikipedia/en/thumb/4/47/Chandu_Champion_poster.jpg/400px-Chandu_Champion_poster.jpg",
    "Bade Miyan Chote Miyan": "https://upload.wikimedia.org/wikipedia/en/thumb/2/22/Bade_Miyan_Chote_Miyan_2024_poster.jpg/400px-Bade_Miyan_Chote_Miyan_2024_poster.jpg",
    "Yodha": "https://upload.wikimedia.org/wikipedia/en/thumb/2/23/Yodha_2024_film_poster.jpg/400px-Yodha_2024_film_poster.jpg"
}

for name, url in urls.items():
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
        res = urllib.request.urlopen(req)
        print(f"OK: {name} -> {url}")
    except Exception as e:
        print(f"FAIL: {name} -> {e}")
    time.sleep(0.5)
