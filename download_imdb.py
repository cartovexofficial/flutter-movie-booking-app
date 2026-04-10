import urllib.request
import os
import time

urls = {
    "dhurandhar.jpg": "https://m.media-amazon.com/images/M/MV5BMjA5OWY4MTAtZTljNS00NDc5LTgxOWYtZmE5YzllOWFlMTlmXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg", # Animal poster for Dhurandhar
    "dhurandhar2.jpg": "https://m.media-amazon.com/images/M/MV5BM2QzM2JiNTMtYjU4OS00MDQzLWE2NjYtYWZiYjNiODhjOWQyXkEyXkFqcGc@._V1_.jpg", # Pathaan poster for Dhurandhar 2
    "pushpa2.jpg": "https://m.media-amazon.com/images/M/MV5BNmU2YmZlZmMtMmU4Ni00Zjk2LWFiMWItNzVlNzlhZTE2Zjg4XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "kalki.jpg": "https://m.media-amazon.com/images/M/MV5BMzZkNjY2YjYtOWUyMi00MjVjLTlhYWUtYTk5MDkwYzQzNDZkXkEyXkFqcGdeQXVyMTI1NDEyNTM5._V1_FMjpg_UX1000_.jpg",
    "fighter.jpg": "https://m.media-amazon.com/images/M/MV5BMjA5MWY1MzgtZmE3My00NDcyLTg0NTEtOGE0MTA4MjM3ZjIyXkEyXkFqcGdeQXVyMTE0MzY0NjE1._V1_FMjpg_UX1000_.jpg",
    "shaitaan.jpg": "https://m.media-amazon.com/images/M/MV5BNjE0MTM0Y2QtNGMzZS00OGJjLWJkMDQtZjNlZmVjMjlhYWQ3XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "crew.jpg": "https://m.media-amazon.com/images/M/MV5BYzA2ZDZkYWYtMTEzMy00ZmJjLWI2OWQtMmM1MjMwZjhlMGNiXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    "munjya.jpg": "https://m.media-amazon.com/images/M/MV5BN2RjNjQwNjQtZjE1OS00NDRmLThhMDgtMmNjNWViNTUzMmRiXkEyXkFqcGdeQXVyMjQyOTcyMg@@._V1_FMjpg_UX1000_.jpg",
    "chandu.jpg": "https://m.media-amazon.com/images/M/MV5BZDVjYWE1MmYtNTgyNS00Mzk5LWE2NTktZjQ4ODY1ZDEyZmFhXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
}

if not os.path.exists("assets"):
    os.makedirs("assets")

# Use a realistic browser User-Agent
opener = urllib.request.build_opener()
opener.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36')]
urllib.request.install_opener(opener)

for name, url in urls.items():
    print(f"Downloading {name}...")
    try:
        path = f"assets/{name}"
        urllib.request.urlretrieve(url, path)
        print(f"  -> SUCCESS")
    except Exception as e:
        print(f"  -> FAILED: {e}")
        # fallback to picsum if it fails so file exists
        try:
            urllib.request.urlretrieve(f"https://picsum.photos/seed/{name}/400/600", path)
            print("  -> Used fallback image")
        except:
            open(path, 'wb').close()
    time.sleep(1)
