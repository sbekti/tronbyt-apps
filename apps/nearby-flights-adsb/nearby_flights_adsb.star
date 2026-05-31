"""
Applet: Nearby Flights ADSB
Summary: Aircraft near you
Description: Shows the closest ADS-B aircraft around a configurable center point.
Author: sbekti
"""

load("http.star", "http")
load("humanize.star", "humanize")
load("images/tail_aa.png", TAIL_AA_ASSET = "file")
load("images/tail_ac.png", TAIL_AC_ASSET = "file")
load("images/tail_af.png", TAIL_AF_ASSET = "file")
load("images/tail_ai.png", TAIL_AI_ASSET = "file")
load("images/tail_am.png", TAIL_AM_ASSET = "file")
load("images/tail_as.png", TAIL_AS_ASSET = "file")
load("images/tail_at.png", TAIL_AT_ASSET = "file")
load("images/tail_av.png", TAIL_AV_ASSET = "file")
load("images/tail_ay.png", TAIL_AY_ASSET = "file")
load("images/tail_az.png", TAIL_AZ_ASSET = "file")
load("images/tail_b6.png", TAIL_B6_ASSET = "file")
load("images/tail_ba.png", TAIL_BA_ASSET = "file")
load("images/tail_br.png", TAIL_BR_ASSET = "file")
load("images/tail_ca.png", TAIL_CA_ASSET = "file")
load("images/tail_ci.png", TAIL_CI_ASSET = "file")
load("images/tail_cm.png", TAIL_CM_ASSET = "file")
load("images/tail_cx.png", TAIL_CX_ASSET = "file")
load("images/tail_cz.png", TAIL_CZ_ASSET = "file")
load("images/tail_dl.png", TAIL_DL_ASSET = "file")
load("images/tail_ei.png", TAIL_EI_ASSET = "file")
load("images/tail_ek.png", TAIL_EK_ASSET = "file")
load("images/tail_et.png", TAIL_ET_ASSET = "file")
load("images/tail_ey.png", TAIL_EY_ASSET = "file")
load("images/tail_f9.png", TAIL_F9_ASSET = "file")
load("images/tail_fi.png", TAIL_FI_ASSET = "file")
load("images/tail_fz.png", TAIL_FZ_ASSET = "file")
load("images/tail_ha.png", TAIL_HA_ASSET = "file")
load("images/tail_hy.png", TAIL_HY_ASSET = "file")
load("images/tail_ib.png", TAIL_IB_ASSET = "file")
load("images/tail_ix.png", TAIL_IX_ASSET = "file")
load("images/tail_jl.png", TAIL_JL_ASSET = "file")
load("images/tail_ke.png", TAIL_KE_ASSET = "file")
load("images/tail_kl.png", TAIL_KL_ASSET = "file")
load("images/tail_km.png", TAIL_KM_ASSET = "file")
load("images/tail_kq.png", TAIL_KQ_ASSET = "file")
load("images/tail_ku.png", TAIL_KU_ASSET = "file")
load("images/tail_la.png", TAIL_LA_ASSET = "file")
load("images/tail_lh.png", TAIL_LH_ASSET = "file")
load("images/tail_lo.png", TAIL_LO_ASSET = "file")
load("images/tail_lx.png", TAIL_LX_ASSET = "file")
load("images/tail_ly.png", TAIL_LY_ASSET = "file")
load("images/tail_me.png", TAIL_ME_ASSET = "file")
load("images/tail_mh.png", TAIL_MH_ASSET = "file")
load("images/tail_ms.png", TAIL_MS_ASSET = "file")
load("images/tail_mu.png", TAIL_MU_ASSET = "file")
load("images/tail_n0.png", TAIL_N0_ASSET = "file")
load("images/tail_nh.png", TAIL_NH_ASSET = "file")
load("images/tail_nk.png", TAIL_NK_ASSET = "file")
load("images/tail_oz.png", TAIL_OZ_ASSET = "file")
load("images/tail_pd.png", TAIL_PD_ASSET = "file")
load("images/tail_pr.png", TAIL_PR_ASSET = "file")
load("images/tail_q4.png", TAIL_Q4_ASSET = "file")
load("images/tail_qf.png", TAIL_QF_ASSET = "file")
load("images/tail_qr.png", TAIL_QR_ASSET = "file")
load("images/tail_rj.png", TAIL_RJ_ASSET = "file")
load("images/tail_sk.png", TAIL_SK_ASSET = "file")
load("images/tail_sq.png", TAIL_SQ_ASSET = "file")
load("images/tail_sv.png", TAIL_SV_ASSET = "file")
load("images/tail_tg.png", TAIL_TG_ASSET = "file")
load("images/tail_tk.png", TAIL_TK_ASSET = "file")
load("images/tail_tn.png", TAIL_TN_ASSET = "file")
load("images/tail_tp.png", TAIL_TP_ASSET = "file")
load("images/tail_ts.png", TAIL_TS_ASSET = "file")
load("images/tail_u2.png", TAIL_U2_ASSET = "file")
load("images/tail_ua.png", TAIL_UA_ASSET = "file")
load("images/tail_ul.png", TAIL_UL_ASSET = "file")
load("images/tail_ux.png", TAIL_UX_ASSET = "file")
load("images/tail_vs.png", TAIL_VS_ASSET = "file")
load("images/tail_wn.png", TAIL_WN_ASSET = "file")
load("images/tail_ws.png", TAIL_WS_ASSET = "file")
load("images/tail_wy.png", TAIL_WY_ASSET = "file")
load("render.star", "render")
load("schema.star", "schema")

DEFAULT_CENTER_LAT = "40.776927"
DEFAULT_CENTER_LNG = "-73.873966"
DEFAULT_RADIUS_NM = "10"
MAX_RADIUS_NM = 250
DEFAULT_CACHE_SECONDS = 20
ROUTE_CACHE_SECONDS = 21600
MAX_ROUTE_CANDIDATES = 25
ADSB_POINT_URL = "https://api.adsb.lol/v2/lat/{lat}/lon/{lon}/dist/{radius}"
ROUTE_URL = "https://adsb.im/api/0/routeset"

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
    "AC": TAIL_AC_ASSET.readall(),
    "AF": TAIL_AF_ASSET.readall(),
    "AI": TAIL_AI_ASSET.readall(),
    "AM": TAIL_AM_ASSET.readall(),
    "AS": TAIL_AS_ASSET.readall(),
    "AT": TAIL_AT_ASSET.readall(),
    "AV": TAIL_AV_ASSET.readall(),
    "AZ": TAIL_AZ_ASSET.readall(),
    "BR": TAIL_BR_ASSET.readall(),
    "CA": TAIL_CA_ASSET.readall(),
    "CI": TAIL_CI_ASSET.readall(),
    "CM": TAIL_CM_ASSET.readall(),
    "CZ": TAIL_CZ_ASSET.readall(),
    "EI": TAIL_EI_ASSET.readall(),
    "ET": TAIL_ET_ASSET.readall(),
    "F9": TAIL_F9_ASSET.readall(),
    "FI": TAIL_FI_ASSET.readall(),
    "HA": TAIL_HA_ASSET.readall(),
    "HY": TAIL_HY_ASSET.readall(),
    "KE": TAIL_KE_ASSET.readall(),
    "KL": TAIL_KL_ASSET.readall(),
    "KQ": TAIL_KQ_ASSET.readall(),
    "KU": TAIL_KU_ASSET.readall(),
    "LH": TAIL_LH_ASSET.readall(),
    "LO": TAIL_LO_ASSET.readall(),
    "LX": TAIL_LX_ASSET.readall(),
    "LY": TAIL_LY_ASSET.readall(),
    "ME": TAIL_ME_ASSET.readall(),
    "MU": TAIL_MU_ASSET.readall(),
    "N0": TAIL_N0_ASSET.readall(),
    "NH": TAIL_NH_ASSET.readall(),
    "NK": TAIL_NK_ASSET.readall(),
    "PD": TAIL_PD_ASSET.readall(),
    "SV": TAIL_SV_ASSET.readall(),
    "TN": TAIL_TN_ASSET.readall(),
    "TP": TAIL_TP_ASSET.readall(),
    "TS": TAIL_TS_ASSET.readall(),
    "UX": TAIL_UX_ASSET.readall(),
    "VS": TAIL_VS_ASSET.readall(),
    "WN": TAIL_WN_ASSET.readall(),
    "WS": TAIL_WS_ASSET.readall(),
}

ICAO_TO_IATA = {
    "AAL": "AA",  # American Airlines
    "ACA": "AC",  # Air Canada
    "AEA": "UX",  # Air Europa
    "AFR": "AF",  # Air France
    "AIC": "AI",  # Air India
    "AMX": "AM",  # Aeromexico
    "ANA": "NH",  # All Nippon Airways
    "ASA": "AS",  # Alaska Airlines
    "ASH": "UA",  # Mesa Airlines (United Express)
    "AVA": "AV",  # Avianca
    "AWI": "AA",  # Air Wisconsin (American Eagle)
    "BAW": "BA",  # British Airways
    "BTA": "B6",  # JetBlue (callsign prefix)
    "CAL": "CI",  # China Airlines
    "CCA": "CA",  # Air China
    "CES": "MU",  # China Eastern
    "CMP": "CM",  # Copa Airlines
    "CPA": "CX",  # Cathay Pacific
    "CSN": "CZ",  # China Southern
    "DAL": "DL",  # Delta Air Lines
    "DLH": "LH",  # Lufthansa
    "EDV": "DL",  # Endeavor Air (Delta Connection)
    "EIN": "EI",  # Aer Lingus
    "ELY": "LY",  # El Al
    "ENY": "AA",  # Envoy Air (American Eagle)
    "ETD": "EY",  # Etihad
    "ETH": "ET",  # Ethiopian Airlines
    "EVA": "BR",  # EVA Air
    "EZY": "U2",  # easyJet
    "FFT": "F9",  # Frontier
    "FIN": "AY",  # Finnair
    "GJS": "UA",  # GoJet (United Express)
    "HAL": "HA",  # Hawaiian Airlines
    "IBE": "IB",  # Iberia
    "ICE": "FI",  # Icelandair
    "ITY": "AZ",  # ITA Airways
    "JAL": "JL",  # Japan Airlines
    "JBU": "B6",  # JetBlue
    "JIA": "AA",  # PSA Airlines (American Eagle)
    "JZA": "AC",  # Jazz (Air Canada Express)
    "KAC": "KU",  # Kuwait Airways
    "KAL": "KE",  # Korean Air
    "KLM": "KL",  # KLM
    "KQA": "KQ",  # Kenya Airways
    "LAN": "LA",  # LATAM
    "LOT": "LO",  # LOT Polish Airlines
    "MAS": "MH",  # Malaysia Airlines
    "MEA": "ME",  # Middle East Airlines
    "MSR": "MS",  # EgyptAir
    "NBT": "N0",  # Norse Atlantic
    "NKS": "NK",  # Spirit
    "PAL": "PR",  # Philippine Airlines
    "PDT": "AA",  # Piedmont (American Eagle)
    "POE": "PD",  # Porter Airlines
    "QFA": "QF",  # Qantas
    "QTR": "QR",  # Qatar Airways
    "RAM": "AT",  # Royal Air Maroc
    "RJA": "RJ",  # Royal Jordanian
    "ROU": "AC",  # Air Canada Rouge
    "RPA": "AA",  # Republic Airways (American Eagle)
    "SAS": "SK",  # SAS
    "SIA": "SQ",  # Singapore Airlines
    "SKW": "UA",  # SkyWest (United Express)
    "SVA": "SV",  # Saudia
    "SWA": "WN",  # Southwest
    "SWR": "LX",  # Swiss
    "TAP": "TP",  # TAP Air Portugal
    "THA": "TG",  # Thai Airways
    "THT": "TN",  # Air Tahiti Nui
    "THY": "TK",  # Turkish Airlines
    "TSC": "TS",  # Air Transat
    "UAE": "EK",  # Emirates
    "UAL": "UA",  # United Airlines
    "UCA": "UA",  # CommuteAir (United Express)
    "UZB": "HY",  # Uzbekistan Airways
    "VIR": "VS",  # Virgin Atlantic
    "WJA": "WS",  # WestJet
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

def split_callsign(callsign):
    alpha = ""
    number = ""
    suffix = ""
    in_number = False

    for i in range(len(callsign)):
        ch = callsign[i]
        if ch >= "0" and ch <= "9":
            number += ch
            in_number = True
        elif not in_number:
            alpha += ch
        else:
            suffix += ch

    stripped_number = ""
    found_nonzero = False
    for i in range(len(number)):
        ch = number[i]
        if ch != "0" or found_nonzero or i == len(number) - 1:
            stripped_number += ch
            found_nonzero = True
    number = stripped_number

    return [alpha, number, suffix]

def normalized_callsign(callsign):
    parts = split_callsign(callsign.strip().upper())
    if len(parts[0]) == 0 or len(parts[1]) == 0:
        return callsign.strip().upper()
    return parts[0] + parts[1] + parts[2]

def compact_callsign(plane):
    flight = plane.get("flight")
    if type(flight) == "string" and len(flight.strip()) > 0:
        return normalized_callsign(flight)

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

def tail_for_iata(iata):
    if iata in TAILS:
        return TAILS[iata]
    return TAILS["Q4"]

def iata_for_icao(icao):
    if type(icao) != "string":
        return None
    return ICAO_TO_IATA.get(icao.strip().upper())

def display_flight_number(route, callsign):
    airline_code = route.get("airline_code")
    number = route.get("number")
    iata = iata_for_icao(airline_code)
    if iata != None and number != None and str(number) != "":
        return iata + str(number)

    parts = split_callsign(callsign)
    iata = iata_for_icao(parts[0])
    if iata != None and len(parts[1]) > 0:
        return iata + parts[1] + parts[2]

    return callsign

def is_airborne(plane):
    alt = plane.get("alt_baro")
    if alt == "ground":
        return False

    speed = number_or_none(plane.get("gs"))
    if speed != None and speed < 30:
        return False

    return True

def is_rotorcraft(plane):
    if plane.get("category") == "A7":
        return True

    kind = aircraft_type(plane)
    return kind in ["B06", "B407", "B429", "H60", "R44", "R66", "S76"]

def route_string(route):
    direct = route.get("_airport_codes_iata")
    if type(direct) == "string" and len(direct) > 0:
        parts = direct.split("-")
        if len(parts) <= 2:
            return direct
        return parts[0] + "-" + parts[1] + "+"

    airports = route.get("_airports", [])
    if len(airports) < 2:
        return ""

    origin = airports[0].get("iata")
    dest = airports[1].get("iata")
    if type(origin) != "string" or type(dest) != "string":
        return ""

    if len(airports) > 2:
        return origin + "-" + dest + "+"
    return origin + "-" + dest

def route_for_callsign(routes, callsign):
    for route in routes:
        if route == None:
            continue
        if iata_for_icao(route.get("airline_code")) == None:
            continue
        route_callsign = route.get("callsign")
        if type(route_callsign) == "string" and normalized_callsign(route_callsign) == callsign:
            if route_string(route) != "":
                return route
    return None

def route_payload(candidates):
    planes = []
    for candidate in candidates[:MAX_ROUTE_CANDIDATES]:
        plane = candidate["plane"]
        planes.append({
            "callsign": candidate["callsign"],
            "lat": plane.get("lat"),
            "lng": plane.get("lon"),
        })

    return {"planes": planes}

def select_route_confirmed_aircraft(aircraft):
    candidates = []

    for plane in aircraft:
        dst = number_or_none(plane.get("dst"))
        if dst == None:
            continue
        if not is_airborne(plane):
            continue
        if is_rotorcraft(plane):
            continue

        callsign = compact_callsign(plane)
        if callsign == "UNKNOWN":
            continue

        candidates.append({
            "dst": dst,
            "callsign": callsign,
            "plane": plane,
        })

    candidates = sorted(candidates, key = lambda candidate: candidate["dst"])
    if len(candidates) == 0:
        return None

    response = http.post(
        url = ROUTE_URL,
        json_body = route_payload(candidates),
        ttl_seconds = ROUTE_CACHE_SECONDS,
    )
    if response.status_code != 200:
        return None

    routes = response.json()
    for candidate in candidates:
        route = route_for_callsign(routes, candidate["callsign"])
        if route != None:
            return {
                "plane": candidate["plane"],
                "callsign": candidate["callsign"],
                "route": route,
            }

    return None

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
                width = 31,
                child = render.Column(
                    children = [
                        render.Box(height = 1),
                        render.Image(tail),
                    ],
                ),
            ),
            render.Box(
                child = render.Column(
                    children = text,
                ),
            ),
        ],
    )

def info_text(content):
    return render.Text(content)

def empty_display(message):
    return render.Root(
        child = app_display(
            TAILS["Q4"],
            [
                info_text(message[0]),
                info_text(message[1]),
                info_text(message[2]),
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
    selection = select_route_confirmed_aircraft(aircraft)

    if selection == None:
        if hide_if_empty:
            return []
        return empty_display(["NO", "NEARBY", "FLIGHTS"])

    plane = selection["plane"]
    route = selection["route"]
    callsign = compact_callsign(plane)
    iata = iata_for_icao(route.get("airline_code"))
    tail = tail_for_iata(iata) if iata != None else tail_for_callsign(callsign)
    details = "%s %s %s %s" % (
        distance_label(plane),
        altitude_label(plane),
        speed_label(plane),
        heading_label(plane),
    )

    text = [
        info_text(display_flight_number(route, callsign)),
        info_text(route_string(route)),
        info_text(aircraft_type(plane)),
        render.Marquee(
            width = 32,
            child = info_text(details),
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
                desc = "Latitude for the search center.",
                icon = "locationDot",
                default = DEFAULT_CENTER_LAT,
            ),
            schema.Text(
                id = "center_lng",
                name = "Center longitude",
                desc = "Longitude for the search center.",
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
