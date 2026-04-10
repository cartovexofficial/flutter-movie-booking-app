import urllib.request
import json
import urllib.parse

movies = [
    "Jawan",
    "Pathaan",
    "RRR",
    "Baahubali",
    "KGF",
    "Dangal",
    "Fighter",
    "War",
    "Sanju",
    "Kabir Singh",
    "Brahmastra",
    "Uri"
]

base_url = "https://itunes.apple.com/search?term={}&entity=movie&country=in&limit=1"

for m in movies:
    query = urllib.parse.quote(m)
    try:
        req = urllib.request.Request(base_url.format(query), headers={'User-Agent': 'Mozilla/5.0'})
        response = urllib.request.urlopen(req)
        data = json.loads(response.read())
        if data['resultCount'] > 0:
            art = data['results'][0]['artworkUrl100']
            art_high_res = art.replace("100x100bb", "600x600bb")
            print(f"    '{m}': '{art_high_res}',")
        else:
            print(f"    '{m}': 'Not found',")
    except Exception as e:
        print(f"    '{m}': 'Error {e}',")
