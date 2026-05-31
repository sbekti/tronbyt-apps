# Tronbyt Apps

Private Tronbyt apps for local use with Tronbyt Server.

Configure this repository in Tronbyt Server under Settings -> Content -> Custom Repository URL, then refresh content and add apps from the custom app list.

## Apps

- `nearby-flights-adsb`: closest aircraft near a configurable center point using adsb.lol.
- `compactstocks`: stock ticker showing prices & daily changes for 5 symbols using Yahoo Finance (no API key needed).

## Local Development

```sh
brew install pixlet
pixlet check apps/nearby-flights-adsb/nearby_flights_adsb.star
pixlet render apps/nearby-flights-adsb/nearby_flights_adsb.star center_lat=40.776927 center_lng=-73.873966 radius_nm=10
pixlet serve apps/nearby-flights-adsb/nearby_flights_adsb.star center_lat=40.776927 center_lng=-73.873966 radius_nm=10

# Compact Stocks
pixlet check apps/compactstocks/compactstocks.star
pixlet render apps/compactstocks/compactstocks.star symbol1=META symbol2=AAPL
pixlet serve apps/compactstocks/compactstocks.star symbol1=META symbol2=AAPL
```

## Testing Against Local Tronbyt

Set the API token in your shell. Do not commit the token.

```sh
export TRONBYT_API_TOKEN="replace-me"
```

The public `https://tronbyt.corp.bekti.com` hostname is protected by Authentik, so Pixlet API pushes should use a local port-forward to the in-cluster Tronbyt service during development.

```sh
kubectl port-forward svc/tronbyt 18080:8000
```

In another shell, list devices and render the app.

```sh
pixlet devices \
  -u http://127.0.0.1:18080 \
  -t "$TRONBYT_API_TOKEN"

pixlet render apps/lgaflights/lga_flights.star \
  center_lat=40.776927 \
  center_lng=-73.873966 \
  radius_nm=10
```

Push the rendered WebP as a foreground one-off test. Replace the device ID if `pixlet devices` reports a different one.

```sh
pixlet push \
  -u http://127.0.0.1:18080 \
  -t "$TRONBYT_API_TOKEN" \
  43e3610c \
  apps/lgaflights/lga_flights.webp
```

To keep a pushed image in rotation while testing, add an installation ID.

```sh
pixlet push \
  -u http://127.0.0.1:18080 \
  -t "$TRONBYT_API_TOKEN" \
  -i lga-flights-test \
  43e3610c \
  apps/lgaflights/lga_flights.webp
```

Before committing app changes, run:

```sh
# Nearby Flights
pixlet render apps/nearby-flights-adsb/nearby_flights_adsb.star \
  center_lat=40.776927 \
  center_lng=-73.873966 \
  radius_nm=10

# Compact Stocks
pixlet render apps/compactstocks/compactstocks.star \
  symbol1=META symbol2=AAPL symbol3=GOOGL symbol4=MSFT symbol5=AMZN
```

Push the rendered WebP as a foreground one-off test. Replace the device ID if `pixlet devices` reports a different one.

```sh
# Nearby Flights
pixlet push \
  -u http://127.0.0.1:18080 \
  -t "$TRONBYT_API_TOKEN" \
  43e3610c \
  apps/nearby-flights-adsb/nearby_flights_adsb.webp

# Compact Stocks
pixlet push \
  -u http://127.0.0.1:18080 \
  -t "$TRONBYT_API_TOKEN" \
  43e3610c \
  apps/compactstocks/compactstocks.webp
```

To keep a pushed image in rotation while testing, add an installation ID.

```sh
pixlet push \
  -u http://127.0.0.1:18080 \
  -t "$TRONBYT_API_TOKEN" \
  -i nearby-flights-test \
  43e3610c \
  apps/nearby-flights-adsb/nearby_flights_adsb.webp

pixlet push \
  -u http://127.0.0.1:18080 \
  -t "$TRONBYT_API_TOKEN" \
  -i compact-stocks-test \
  43e3610c \
  apps/compactstocks/compactstocks.webp
```

Before committing app changes, run:

```sh
pixlet lint apps/nearby-flights-adsb/nearby_flights_adsb.star
pixlet check apps/nearby-flights-adsb/nearby_flights_adsb.star
pixlet lint apps/compactstocks/compactstocks.star
pixlet check apps/compactstocks/compactstocks.star
```
