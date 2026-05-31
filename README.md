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
pixlet lint apps/lgaflights/lga_flights.star
pixlet check apps/lgaflights/lga_flights.star
```
