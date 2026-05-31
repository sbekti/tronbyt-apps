# Tronbyt Apps

Private Tronbyt apps for local use with Tronbyt Server.

Configure this repository in Tronbyt Server under Settings -> Content -> Custom Repository URL, then refresh content and add apps from the custom app list.

## Apps

- `lgaflights`: closest aircraft near LaGuardia Airport using adsb.lol.

## Local Development

```sh
brew install pixlet
pixlet check apps/lgaflights/lga_flights.star
pixlet render apps/lgaflights/lga_flights.star center_lat=40.776927 center_lng=-73.873966 radius_nm=10
pixlet serve apps/lgaflights/lga_flights.star center_lat=40.776927 center_lng=-73.873966 radius_nm=10
```
