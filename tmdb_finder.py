import urllib.request
import re
import urllib.parse
import time

movies = ["Pathaan", "Kalki 2898 AD", "Jawan", "Pushpa The Rule", "Fighter", "Dhurandhar", "Dhurandhar 2", "Devara Part 1"]

for m in movies:
    url = "https://html.duckduckgo.com/html/?q=" + urllib.parse.quote(f"{m} movie poster tmdb image.tmdb.org/t/p/w500")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
    try:
        html = urllib.request.urlopen(req).read().decode('utf-8')
        match = re.search(r'(https://image\.tmdb\.org/t/p/w[0-9]+/[a-zA-Z0-9_-]+\.jpg)', html)
        if match:
            print(f"{m}: {match.group(1)}")
        else:
            # try finding it from the first result snippet text that has /something.jpg
            match2 = re.search(r'(/t/p/w500/[a-zA-Z0-9_-]+\.jpg)', html)
            if match2:
                print(f"{m}: https://image.tmdb.org{match2.group(1)}")
            else:
                print(f"{m}: NOT FOUND")
    except Exception as e:
        print(f"{m}: FAIL {e}")
    time.sleep(1)
