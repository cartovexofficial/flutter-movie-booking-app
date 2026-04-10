import urllib.request
import json
import time
import urllib.parse

movies = [
    "Kalki 2898 AD",
    "Fighter (2024 film)",
    "Crew (film)",
    "Shaitaan (2024 film)",
    "Munjya (film)",
    "Article 370 (film)",
    "Bade Miyan Chote Miyan (2024 film)",
    "Maidaan",
    "Chandu Champion",
    "Teri Baaton Mein Aisa Uljha Jiya",
    "Madgaon Express",
    "Laapataa Ladies"
]

for title in movies:
    url = f"https://en.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(title)}&prop=pageimages&format=json&pithumbsize=600"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'MovieAppTester/1.0'})
        response = urllib.request.urlopen(req).read().decode('utf-8')
        data = json.loads(response)
        pages = data['query']['pages']
        for page_id in pages:
            if 'thumbnail' in pages[page_id]:
                print(f"Movie(id: '{title.replace(' ', '').lower()}', title: '{title.split(' (')[0]}', posterUrl: '{pages[page_id]['thumbnail']['source']}'),")
            else:
                print(f"// NOT FOUND: {title}")
    except Exception as e:
        print(f"// ERROR {e}: {title}")
    time.sleep(1)
