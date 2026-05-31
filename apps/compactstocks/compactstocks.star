"""
Applet: Compact Stocks
Summary: Compact stock ticker app
Description: A stock ticker app that shows the current prices & daily changes for 5 stocks of your choice using Yahoo Finance data.
Author: sbekti
"""

load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")

YAHOO_URL = "https://query1.finance.yahoo.com/v8/finance/chart"
TTL_SECONDS = 300

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
}

def fetch_quote(symbol):
    url = YAHOO_URL + "/" + symbol
    rep = http.get(url, headers = HEADERS, params = {
        "interval": "1d",
        "range": "1d",
    }, ttl_seconds = TTL_SECONDS)
    if rep.status_code != 200:
        print("Yahoo Finance request failed with status %d" % rep.status_code)
        return None

    data = rep.json()
    if not data or "chart" not in data or "result" not in data["chart"] or len(data["chart"]["result"]) == 0:
        print("Invalid response: %s" % data)
        return None

    meta = data["chart"]["result"][0]["meta"]
    price = meta.get("regularMarketPrice")
    prev_close = meta.get("chartPreviousClose")
    display_symbol = meta.get("symbol", symbol)
    short_name = meta.get("shortName", symbol)

    if price == None or prev_close == None:
        return None

    change = price - prev_close
    change_pct = (change / prev_close) * 100

    return {
        "symbol": display_symbol,
        "name": short_name,
        "price": price,
        "change": change,
        "change_pct": change_pct,
    }

def format_price(price):
    value = int(price * 100 + 0.5) / 100.0
    parts = str(value).split(".")
    if len(parts) == 1:
        s = parts[0] + ".00"
    elif len(parts[1]) == 1:
        s = parts[0] + "." + parts[1] + "0"
    else:
        s = parts[0] + "." + parts[1][:2]
    if len(s) < 7:
        s = " " * (7 - len(s)) + s
    return s

def format_change_pct(pct):
    whole = int(abs(pct))
    frac = int((abs(pct) - whole) * 100 + 0.5)
    s = str(whole) + "." + ("0" + str(frac) if frac < 10 else str(frac)) + "%"
    if len(s) < 7:
        s = " " * (7 - len(s)) + s
    return s

def pad_symbol(symbol):
    if len(symbol) < 4:
        return symbol + " " * (4 - len(symbol))
    return symbol[:4]

def render_entry(symbol, color, price, change, change_pct):
    change_color = "#0f0" if change >= 0 else "#f00"
    return render.Row(
        main_align = "space_between",
        expanded = True,
        children = [
            render.Column(
                cross_align = "start",
                children = [
                    render.Text(pad_symbol(symbol), font = "tom-thumb", color = color),
                ],
            ),
            render.Column(
                cross_align = "end",
                children = [
                    render.Text(format_price(price), font = "tom-thumb", color = "#fff"),
                ],
            ),
            render.Column(
                cross_align = "end",
                children = [
                    render.Text(format_change_pct(change_pct), font = "tom-thumb", color = change_color),
                ],
            ),
        ],
    )

def main(config):
    symbol_list = [
        (config.str("symbol1", "_EX1"), config.str("color1", "#fff")),
        (config.str("symbol2", "_EX2"), config.str("color2", "#fff")),
        (config.str("symbol3", "_EX1"), config.str("color3", "#fff")),
        (config.str("symbol4", "_EX2"), config.str("color4", "#fff")),
        (config.str("symbol5", "_EX1"), config.str("color5", "#fff")),
    ]
    columns = []

    for pair in symbol_list:
        symbol, color = pair
        if symbol.startswith("_"):
            example = symbol == "_EX1"
            columns.append(render_entry(
                "XMP1" if example else "XM2",
                "#8ff" if example else "#f8f",
                114.5 if example else 33.8,
                1.4 if example else -6.6,
                1.4 if example else -6.6,
            ))
            continue

        quote = fetch_quote(symbol)
        if not quote:
            return render.Root(
                child = render.Box(
                    child = render.WrappedText("Failed to fetch %s" % symbol, color = "#f00"),
                ),
            )
        columns.append(render_entry(
            quote["symbol"],
            color,
            quote["price"],
            quote["change"],
            quote["change_pct"],
        ))

    return render.Root(
        child = render.Column(
            children = columns,
            main_align = "center",
            expanded = True,
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "symbol1",
                name = "Symbol 1",
                desc = "The 1st stock symbol to display",
                icon = "arrowTrendUp",
            ),
            schema.Color(
                id = "color1",
                name = "Color 1",
                desc = "The color of the 1st stock symbol",
                icon = "palette",
                default = "#fff",
            ),
            schema.Text(
                id = "symbol2",
                name = "Symbol 2",
                desc = "The 2nd stock symbol to display",
                icon = "arrowTrendDown",
            ),
            schema.Color(
                id = "color2",
                name = "Color 2",
                desc = "The color of the 2nd stock symbol",
                icon = "palette",
                default = "#fff",
            ),
            schema.Text(
                id = "symbol3",
                name = "Symbol 3",
                desc = "The 3rd stock symbol to display",
                icon = "arrowTrendUp",
            ),
            schema.Color(
                id = "color3",
                name = "Color 3",
                desc = "The color of the 3rd stock symbol",
                icon = "palette",
                default = "#fff",
            ),
            schema.Text(
                id = "symbol4",
                name = "Symbol 4",
                desc = "The 4th stock symbol to display",
                icon = "arrowTrendDown",
            ),
            schema.Color(
                id = "color4",
                name = "Color 4",
                desc = "The color of the 4th stock symbol",
                icon = "palette",
                default = "#fff",
            ),
            schema.Text(
                id = "symbol5",
                name = "Symbol 5",
                desc = "The 5th stock symbol to display",
                icon = "arrowTrendUp",
            ),
            schema.Color(
                id = "color5",
                name = "Color 5",
                desc = "The color of the 5th stock symbol",
                icon = "palette",
                default = "#fff",
            ),
        ],
    )
