#!/usr/bin/env python
import re, codecs, json, requests
from bs4 import BeautifulSoup

filename = "employeelist.html"
html = codecs.open(filename, 'r', 'utf-8')

soup = BeautifulSoup(html)

tables = soup.find_all("td", "name", text=True)
users = []

for td in tables:
	display_name = td.a.find(text=True)
	display_name = (' '.join((display_name.split(',')[::-1])).strip())
	if re.search(r" \w$", display_name):
		display_name += "."
	email = re.sub(r"^.*?user=", "", td.a.get('href').lower(), re.I) + "@apigee.com"
	users.append({"email":email, "display_name":display_name})

url = "https://api.usergrid.com/apigee-ignite/checkin/employees/8961aafa-aee5-11e3-9ad6-f939d2de7289?client_id=YXA6i4qEcIlAEeOue9GPXnp09A&client_secret=YXA6AYwq-U-tEjir1tndg33DgCBk244"

r = requests.put(url, data=json.dumps({"list":users}))
print r