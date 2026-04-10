import urllib.request
import json
import urllib.parse

movies = ["Fighter", "Crew", "Yodha", "Bastar", "Shaitaan", "Munjya", "Chandu Champion", "Kalki", "Stree 2", "Kill", "Sirf Ek Bandaa Kaafi Hai", "Jawan", "Animal", "Dunki"]

for m in movies:
    url = f"https://itunes.apple.com/search?term={urllib.parse.quote(m)}&entity=movie&country=in&limit=1"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla'})
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        if data['resultCount'] > 0:
            pic = data['results'][0]['artworkUrl100'].replace("100x100bb", "600x600bb")
            print(f"OK: {m} -> {pic}")
        else:
            print(f"N/A: {m}")
    except Exception as e:
        print(f"ERR {e}: {m}")
