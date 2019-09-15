#!/bin/bash
# Returns zero if we have daylight at current location.

python <<'EoF'
from __future__ import print_function
from astral import Location
import urllib2, json, arrow

# Automatically geolocate the connecting IP
f = urllib2.urlopen('http://freegeoip.net/json/')
json_string = f.read(); f.close()
loc = json.loads(json_string)

l = Location((loc['city'], loc['country_name'], loc['latitude'], loc['longitude'], loc['time_zone'], 0))
srise, sset = (
    arrow.get( l.sunrise() ).shift(hours=+1),
    arrow.get( l.sunset()  ).shift(hours=-1)
)

print(srise,sset)

now = arrow.utcnow().to(loc['time_zone'])

if now > sset or now < srise:
    exit(1)
EoF

[ "$?" == '0' ] && brgt='1' || brgt='0.7'

xrandr --output HDMI1 --brightness "$brgt"
