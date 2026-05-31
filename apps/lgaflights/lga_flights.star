"""
Applet: LGA Flights
Summary: Aircraft near LaGuardia
Description: Shows the closest ADS-B aircraft around a configurable center point.
Author: sbekti
"""

load("http.star", "http")
load("humanize.star", "humanize")
load("images/tail_aa.png", TAIL_AA_ASSET = "file")
load("images/tail_ay.png", TAIL_AY_ASSET = "file")
load("images/tail_b6.png", TAIL_B6_ASSET = "file")
load("images/tail_ba.png", TAIL_BA_ASSET = "file")
load("images/tail_cx.png", TAIL_CX_ASSET = "file")
load("images/tail_dl.png", TAIL_DL_ASSET = "file")
load("images/tail_ek.png", TAIL_EK_ASSET = "file")
load("images/tail_ey.png", TAIL_EY_ASSET = "file")
load("images/tail_fz.png", TAIL_FZ_ASSET = "file")
load("images/tail_ib.png", TAIL_IB_ASSET = "file")
load("images/tail_ix.png", TAIL_IX_ASSET = "file")
load("images/tail_jl.png", TAIL_JL_ASSET = "file")
load("images/tail_km.png", TAIL_KM_ASSET = "file")
load("images/tail_la.png", TAIL_LA_ASSET = "file")
load("images/tail_mh.png", TAIL_MH_ASSET = "file")
load("images/tail_ms.png", TAIL_MS_ASSET = "file")
load("images/tail_oz.png", TAIL_OZ_ASSET = "file")
load("images/tail_pr.png", TAIL_PR_ASSET = "file")
load("images/tail_q4.png", TAIL_Q4_ASSET = "file")
load("images/tail_qf.png", TAIL_QF_ASSET = "file")
load("images/tail_qr.png", TAIL_QR_ASSET = "file")
load("images/tail_rj.png", TAIL_RJ_ASSET = "file")
load("images/tail_sk.png", TAIL_SK_ASSET = "file")
load("images/tail_sq.png", TAIL_SQ_ASSET = "file")
load("images/tail_tg.png", TAIL_TG_ASSET = "file")
load("images/tail_tk.png", TAIL_TK_ASSET = "file")
load("images/tail_u2.png", TAIL_U2_ASSET = "file")
load("images/tail_ua.png", TAIL_UA_ASSET = "file")
load("images/tail_ul.png", TAIL_UL_ASSET = "file")
load("images/tail_wy.png", TAIL_WY_ASSET = "file")
load("render.star", "render")
load("schema.star", "schema")

DEFAULT_CENTER_LAT = "40.776927"
DEFAULT_CENTER_LNG = "-73.873966"
DEFAULT_RADIUS_NM = "10"
MAX_RADIUS_NM = 250
DEFAULT_CACHE_SECONDS = 20
ADSB_POINT_URL = "https://api.adsb.lol/v2/point/{lat}/{lon}/{radius}"

TAILS = {
    "AA": TAIL_AA_ASSET.readall(),
    "AY": TAIL_AY_ASSET.readall(),
    "B6": TAIL_B6_ASSET.readall(),
    "BA": TAIL_BA_ASSET.readall(),
    "CX": TAIL_CX_ASSET.readall(),
    "DL": TAIL_DL_ASSET.readall(),
    "EK": TAIL_EK_ASSET.readall(),
    "EY": TAIL_EY_ASSET.readall(),
    "FZ": TAIL_FZ_ASSET.readall(),
    "IB": TAIL_IB_ASSET.readall(),
    "IX": TAIL_IX_ASSET.readall(),
    "JL": TAIL_JL_ASSET.readall(),
    "KM": TAIL_KM_ASSET.readall(),
    "LA": TAIL_LA_ASSET.readall(),
    "MH": TAIL_MH_ASSET.readall(),
    "MS": TAIL_MS_ASSET.readall(),
    "OZ": TAIL_OZ_ASSET.readall(),
    "PR": TAIL_PR_ASSET.readall(),
    "Q4": TAIL_Q4_ASSET.readall(),
    "QF": TAIL_QF_ASSET.readall(),
    "QR": TAIL_QR_ASSET.readall(),
    "RJ": TAIL_RJ_ASSET.readall(),
    "SK": TAIL_SK_ASSET.readall(),
    "SQ": TAIL_SQ_ASSET.readall(),
    "TG": TAIL_TG_ASSET.readall(),
    "TK": TAIL_TK_ASSET.readall(),
    "U2": TAIL_U2_ASSET.readall(),
    "UA": TAIL_UA_ASSET.readall(),
    "UL": TAIL_UL_ASSET.readall(),
    "WY": TAIL_WY_ASSET.readall(),
}

ICAO_TO_IATA = {
    "AAL": "AA",
    "BAW": "BA",
    "CPA": "CX",
    "DAL": "DL",
    "ELY": "LY",
    "ETD": "EY",
    "EZY": "U2",
    "FIN": "AY",
    "IBE": "IB",
    "JAL": "JL",
    "JBU": "B6",
    "LAN": "LA",
    "MAS": "MH",
    "MSR": "MS",
    "PAL": "PR",
    "QFA": "QF",
    "QTR": "QR",
    "RJA": "RJ",
    "SAS": "SK",
    "SIA": "SQ",
    "THA": "TG",
    "THY": "TK",
    "UAE": "EK",
    "UAL": "UA",
}

def clamp(value, minimum, maximum):
    if value < minimum:
        return minimum
    if value > maximum:
        return maximum
    return value

def is_int_text(value):
    if type(value) != "string":
        return False
    value = value.strip()
    if len(value) == 0:
        return False
    for i in range(len(value)):
        ch = value[i]
        if ch < "0" or ch > "9":
            return False
    return True

def is_float_text(value):
    if type(value) != "string":
        return False
    value = value.strip()
    if len(value) == 0:
        return False

    found_digit = False
    found_dot = False
    for i in range(len(value)):
        ch = value[i]
        if ch == "-" and i == 0:
            continue
        if ch == "." and not found_dot:
            found_dot = True
            continue
        if ch >= "0" and ch <= "9":
            found_digit = True
            continue
        return False

    return found_digit

def int_from_config(config, field, default_value):
    value = config.str(field, default_value).strip()
    if not is_int_text(value):
        value = default_value
    return int(value)

def float_from_config(config, field, default_value):
    value = config.str(field, default_value).strip()
    if not is_float_text(value):
        value = default_value
    return float(value)

def number_or_none(value):
    if value == None:
        return None
    if type(value) == "int" or type(value) == "float":
        return float(value)
    if type(value) == "string" and is_float_text(value):
        return float(value)
    return None

def pad3(value):
    text = str(int(value))
    if len(text) == 1:
        return "00" + text
    if len(text) == 2:
        return "0" + text
    return text

def compact_callsign(plane):
    flight = plane.get("flight")
    if type(flight) == "string" and len(flight.strip()) > 0:
        return flight.strip().upper()

    registration = plane.get("r")
    if type(registration) == "string" and len(registration.strip()) > 0:
        return registration.strip().upper()

    hex_id = plane.get("hex")
    if type(hex_id) == "string" and len(hex_id.strip()) > 0:
        return hex_id.strip().upper()

    return "UNKNOWN"

def tail_for_callsign(callsign):
    if len(callsign) >= 3:
        iata = ICAO_TO_IATA.get(callsign[0:3])
        if iata != None and iata in TAILS:
            return TAILS[iata]

    if len(callsign) >= 2 and callsign[0:2] in TAILS:
        return TAILS[callsign[0:2]]

    return TAILS["Q4"]

def is_airborne(plane):
    alt = plane.get("alt_baro")
    if alt == "ground":
        return False

    speed = number_or_none(plane.get("gs"))
    if speed != None and speed < 30:
        return False

    return True

def select_aircraft(aircraft):
    closest = None
    closest_dst = None
    closest_airborne = None
    closest_airborne_dst = None

    for plane in aircraft:
        dst = number_or_none(plane.get("dst"))
        if dst == None:
            continue

        if closest == None or dst < closest_dst:
            closest = plane
            closest_dst = dst

        if is_airborne(plane) and (closest_airborne == None or dst < closest_airborne_dst):
            closest_airborne = plane
            closest_airborne_dst = dst

    if closest_airborne != None:
        return closest_airborne
    return closest

def aircraft_type(plane):
    kind = plane.get("t")
    if type(kind) == "string" and len(kind.strip()) > 0:
        return kind.strip().upper()

    registration = plane.get("r")
    if type(registration) == "string" and len(registration.strip()) > 0:
        return registration.strip().upper()

    return "AIRCRAFT"

def altitude_label(plane):
    alt = plane.get("alt_baro")
    if alt == "ground":
        return "GROUND"

    value = number_or_none(alt)
    if value == None:
        return "ALT ?"

    return "%s FT" % humanize.comma(int(value))

def heading_label(plane):
    heading = number_or_none(plane.get("track"))
    if heading == None:
        heading = number_or_none(plane.get("true_heading"))
    if heading == None:
        heading = number_or_none(plane.get("mag_heading"))
    if heading == None:
        return "HDG ?"

    return "%s DEG" % pad3(heading)

def speed_label(plane):
    speed = number_or_none(plane.get("gs"))
    if speed == None:
        return "SPD ?"
    return "%s KT" % humanize.float("#,###.", speed)

def distance_label(plane):
    dst = number_or_none(plane.get("dst"))
    if dst == None:
        return "? NM"
    return "%s NM" % humanize.float("#,###.#", dst)

def direction_label(plane):
    direction = number_or_none(plane.get("dir"))
    if direction == None:
        return ""
    return "%s DEG" % pad3(direction)

def app_display(tail, text):
    return render.Row(
        children = [
            render.Box(
                width = 32,
                child = render.Image(tail),
            ),
            render.Box(
                child = render.Column(
                    children = text,
                ),
            ),
        ],
    )

def empty_display(message):
    return render.Root(
        child = app_display(
            TAILS["Q4"],
            [
                render.Text(message[0]),
                render.Text(message[1]),
                render.Text(message[2]),
            ],
        ),
    )

def main(config):
    lat = float_from_config(config, "center_lat", DEFAULT_CENTER_LAT)
    lon = float_from_config(config, "center_lng", DEFAULT_CENTER_LNG)
    radius_nm = clamp(int_from_config(config, "radius_nm", DEFAULT_RADIUS_NM), 1, MAX_RADIUS_NM)
    hide_if_empty = config.bool("hide_if_empty", False)

    url = ADSB_POINT_URL.format(
        lat = str(lat),
        lon = str(lon),
        radius = str(radius_nm),
    )

    response = http.get(url = url, ttl_seconds = DEFAULT_CACHE_SECONDS)
    if response.status_code != 200:
        return empty_display(["ADSB", "HTTP", str(response.status_code)])

    data = response.json()
    aircraft = data.get("ac", [])
    plane = select_aircraft(aircraft)

    if plane == None:
        if hide_if_empty:
            return []
        return empty_display(["NO", "AIR", "LGA"])

    callsign = compact_callsign(plane)
    tail = tail_for_callsign(callsign)
    details = "%s %s %s FROM %s" % (
        distance_label(plane),
        speed_label(plane),
        heading_label(plane),
        direction_label(plane),
    )

    text = [
        render.Text(callsign),
        render.Text(aircraft_type(plane)),
        render.Text(altitude_label(plane)),
        render.Marquee(
            width = 32,
            child = render.Text(details),
        ),
    ]

    return render.Root(
        child = app_display(tail, text),
        show_full_animation = True,
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "center_lat",
                name = "Center latitude",
                desc = "Latitude for the search center. Defaults to LGA.",
                icon = "locationDot",
                default = DEFAULT_CENTER_LAT,
            ),
            schema.Text(
                id = "center_lng",
                name = "Center longitude",
                desc = "Longitude for the search center. Defaults to LGA.",
                icon = "locationDot",
                default = DEFAULT_CENTER_LNG,
            ),
            schema.Text(
                id = "radius_nm",
                name = "Radius",
                desc = "Search radius in nautical miles.",
                icon = "rulerHorizontal",
                default = DEFAULT_RADIUS_NM,
            ),
            schema.Toggle(
                id = "hide_if_empty",
                name = "Hide",
                desc = "Hide app when no aircraft are found.",
                icon = "gear",
                default = False,
            ),
        ],
    )
