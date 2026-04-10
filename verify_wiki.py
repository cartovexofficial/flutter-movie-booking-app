import urllib.request

urls = [
    "https://upload.wikimedia.org/wikipedia/en/thumb/4/45/Pathaan_film_poster.jpg/400px-Pathaan_film_poster.jpg",
    "https://upload.wikimedia.org/wikipedia/en/thumb/3/39/Jawan_film_poster.jpg/400px-Jawan_film_poster.jpg",
    "https://upload.wikimedia.org/wikipedia/en/thumb/1/1f/Pushpa_2_The_Rule_poster.jpg/400px-Pushpa_2_The_Rule_poster.jpg",
    "https://upload.wikimedia.org/wikipedia/en/thumb/d/d7/RRR_Poster.jpg/400px-RRR_Poster.jpg",
    "https://upload.wikimedia.org/wikipedia/en/thumb/9/90/Animal_%282023_film%29_poster.jpg/400px-Animal_%282023_film%29_poster.jpg",
    "https://upload.wikimedia.org/wikipedia/en/thumb/4/4f/Kalki_2898_AD_release_poster.jpg/400px-Kalki_2898_AD_release_poster.jpg"
]

for url in urls:
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        res = urllib.request.urlopen(req)
        print(f"OK: {url}")
    except Exception as e:
        print(f"FAIL: {url} -> {e}")
