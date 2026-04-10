import urllib.request
import json
import urllib.parse
import sys

API_KEY = "b90e166e" # known public free demo key

movies = [
    "Kalki 2898 AD",
    "Fighter",
    "Crew",
    "Shaitaan",
    "Munjya",
    "Article 370",
    "Bade Miyan Chote Miyan",
    "Maidaan",
    "Chandu Champion",
    "Madgaon Express",
]

for title in movies:
    url = f"http://www.omdbapi.com/?t={urllib.parse.quote(title)}&apikey={API_KEY}"
    try:
        response = urllib.request.urlopen(url).read().decode('utf-8')
        data = json.loads(response)
        if data.get("Response") == "True" and data.get("Poster") != "N/A":
            print(f"Movie(id: '{title.replace(' ', '').lower()}', title: '{data['Title']}', genre: '{data['Genre']}', year: '{data['Year']}', posterUrl: '{data['Poster']}'),")
        else:
            print(f"// NOT FOUND: {title}")
    except Exception as e:
        print(f"// ERROR {e}: {title}")
