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

ICAO_AIRCRAFT_TYPES = {
    "A124": "An-124",  # Antonov An-124 Ruslan
    "A140": "An-140",  # Antonov An-140
    "A148": "An-148",  # Antonov An-148
    "A158": "An-158",  # Antonov An-158
    "A19N": "A319neo",  # Airbus A319neo
    "A20N": "A320neo",  # Airbus A320neo
    "A21N": "A321neo",  # Airbus A321neo/LR/XLR
    "A225": "An-225",  # Antonov An-225 Mriya
    "A306": "A300-600",  # Airbus A300-600
    "A30B": "A300B2",  # Airbus A300B2, A300B4 and A300C4
    "A310": "A310-200",  # Airbus A310-200
    "A318": "A318",  # Airbus A318
    "A319": "A319",  # Airbus A319
    "A320": "A320",  # Airbus A320
    "A321": "A321",  # Airbus A321
    "A332": "A330-200",  # Airbus A330-200
    "A333": "A330-300",  # Airbus A330-300
    "A337": "A330-700",  # Airbus A330-700 "BelugaXL"
    "A338": "A330-800",  # Airbus A330-800
    "A339": "A330-900",  # Airbus A330-900
    "A342": "A340-200",  # Airbus A340-200
    "A343": "A340-300",  # Airbus A340-300
    "A345": "A340-500",  # Airbus A340-500
    "A346": "A340-600",  # Airbus A340-600
    "A359": "A350-900",  # Airbus A350-900
    "A35K": "A350-10",  # Airbus A350-1000
    "A388": "A380-800",  # Airbus A380-800
    "A3ST": "Beluga",  # Airbus A300-600ST Super Transporter / Beluga
    "A400": "A400M",  # Airbus A400M Atlas
    "A748": "HS 748",  # Hawker Siddeley HS 748
    "AC90": "Commndr",  # Gulfstream/Rockwell (Aero) Turbo Commander 690
    "AJ27": "ARJ21",  # Comac ARJ21-700 / C909
    "AN12": "An-12",  # Antonov An-12
    "AN24": "An-24",  # Antonov An-24
    "AN26": "An-26",  # Antonov An-26
    "AN28": "An-28",  # Antonov An-28
    "AN30": "An-30",  # Antonov An-30
    "AN32": "An-32",  # Antonov An-32
    "AN72": "An-72",  # Antonov An-72 / An-74
    "AT43": "ATR42",  # Aerospatiale/Alenia ATR 42-300 / 320
    "AT45": "ATR42-5",  # Aerospatiale/Alenia ATR 42-500
    "AT46": "ATR42-6",  # Aerospatiale/Alenia ATR 42-600
    "AT72": "ATR72",  # Aerospatiale/Alenia ATR 72-201/-202
    "AT73": "ATR72-5",  # Aerospatiale/Alenia ATR 72-211/-212
    "AT75": "ATR72-5",  # Aerospatiale/Alenia ATR 72-212A (500)
    "AT76": "ATR72-6",  # Aerospatiale/Alenia ATR 72-212A (600)
    "ATP": "ATP",  # British Aerospace ATP
    "B190": "1900",  # Beechcraft 1900
    "B37M": "737MAX7",  # Boeing 737 MAX 7
    "B38M": "737MAX8",  # Boeing 737 MAX 8
    "B39M": "737MAX9",  # Boeing 737 MAX 9
    "B3XM": "737M10",  # Boeing 737 MAX 10
    "B461": "146-100",  # BAe 146-100
    "B462": "146-200",  # BAe 146-200
    "B463": "146-300",  # BAe 146-300
    "B52": "B-52",  # Boeing B-52 Stratofortress
    "B703": "707",  # Boeing 707
    "B712": "717",  # Boeing 717
    "B720": "720B",  # Boeing 720B
    "B721": "727-100",  # Boeing 727-100
    "B722": "727-200",  # Boeing 727-200
    "B732": "737-200",  # Boeing 737-200
    "B733": "737-300",  # Boeing 737-300
    "B734": "737-400",  # Boeing 737-400
    "B735": "737-500",  # Boeing 737-500
    "B736": "737-600",  # Boeing 737-600
    "B737": "737-700",  # Boeing 737-700 / Boeing 737-700ER
    "B738": "737-800",  # Boeing 737-800
    "B739": "737-900",  # Boeing 737-900 / Boeing 737-900ER
    "B741": "747-100",  # Boeing 747-100
    "B742": "747-200",  # Boeing 747-200
    "B743": "747-300",  # Boeing 747-300
    "B744": "747-400",  # Boeing 747-400 / Boeing 747-400ER
    "B748": "747-8I",  # Boeing 747-8I
    "B74R": "747SR",  # Boeing 747SR
    "B74S": "747SP",  # Boeing 747SP
    "B752": "757-200",  # Boeing 757-200
    "B753": "757-300",  # Boeing 757-300
    "B762": "767-200",  # Boeing 767-200 / Boeing 767-200ER
    "B763": "767-300",  # Boeing 767-300 / Boeing 767-300ER
    "B764": "767-400",  # Boeing 767-400ER
    "B772": "777-200",  # Boeing 777-200 / Boeing 777-200ER
    "B773": "777-300",  # Boeing 777-300
    "B778": "777-8",  # Boeing 777-8
    "B779": "777-9",  # Boeing 777-9
    "B77L": "777-200",  # Boeing 777-200 Freighter / 777-200LR
    "B77W": "777-300",  # Boeing 777-300ER
    "B788": "787-8",  # Boeing 787-8
    "B789": "787-9",  # Boeing 787-9
    "B78X": "787-10",  # Boeing 787-10
    "BA11": "BAC111",  # British Aerospace (BAC) One Eleven
    "BCS1": "A220-100",  # Bombardier CSeries CS100 / Airbus A220-100
    "BCS3": "A220-300",  # Bombardier CSeries CS300 / Airbus A220-300
    "BE20": "KA200",  # Beechcraft (Super) King Air 200
    "BE40": "400",  # Hawker 400
    "BE99": "99",  # Beechcraft Model 99
    "BELF": "SC-5",  # Shorts SC-5 Belfast
    "BER2": "Beriev",  # Beriev Be-200 Altair
    "BLCF": "Dreamlftr",  # Boeing 747-400 LCF Dreamlifter
    "C130": "Hercules",  # Lockheed L-182 / 282 / 382 (L-100) Hercules
    "C208": "208",  # Cessna 208 Caravan
    "C212": "C212",  # CASA / IPTN 212 Aviocar
    "C25A": "CJ2",  # Cessna Citation CJ2
    "C25B": "CJ3",  # Cessna Citation CJ3
    "C25C": "CJ4",  # Cessna Citation CJ4
    "C30J": "C-130J",  # Lockheed Martin C-130J Hercules
    "C408": "408",  # Cessna 408 SkyCourier
    "C500": "C500",  # Cessna Citation I
    "C510": "Mustang",  # Cessna Citation Mustang
    "C525": "CJet",  # Cessna CitationJet
    "C550": "C550",  # Cessna Citation II
    "C560": "C560",  # Cessna Citation V
    "C56X": "Excel",  # Cessna Citation Excel
    "C5M": "C-5M",  # Lockheed C-5M Super Galaxy
    "C650": "C650",  # Cessna Citation III, VI, VII
    "C680": "C680",  # Cessna Citation Sovereign
    "C68A": "Latitude",  # Cessna Citation Latitude
    "C700": "Longitude",  # Cessna Citation Longitude
    "C750": "X",  # Cessna Citation X
    "C919": "C919",  # Comac C919
    "CL2T": "415",  # Bombardier 415
    "CL30": "CL300",  # Bombardier BD-100 Challenger 300
    "CL35": "CL350",  # Bombardier BD-100 Challenger 350
    "CL60": "CL600",  # Canadair Challenger 600
    "CN35": "CN-235",  # CASA/IPTN CN-235
    "CRJ1": "CRJ-200",  # Canadair Regional Jet 100
    "CRJ2": "CRJ-200",  # Canadair Regional Jet 200
    "CRJ7": "CRJ-700",  # Canadair Regional Jet 700 / Regional Jet 550
    "CRJ9": "CRJ-900",  # Canadair Regional Jet 900
    "CRJX": "CRJ-1K",  # Canadair Regional Jet 1000
    "CVLT": "Convair",  # Convair CV-580, CV-600, CV-640
    "D228": "Do228",  # Dornier 228
    "D328": "Do.328",  # Fairchild Dornier Do.328
    "DC10": "DC-10",  # Douglas DC-10-10 / -15 Passenger
    "DC85": "DC-8-50",  # Douglas DC-8-50
    "DC86": "DC-8-62",  # Douglas DC-8-62
    "DC87": "DC-8-72",  # Douglas DC-8-72
    "DC91": "DC-9-10",  # Douglas DC-9-10
    "DC92": "DC-9-20",  # Douglas DC-9-20
    "DC93": "DC-9-30",  # Douglas DC-9-30
    "DC94": "DC-9-40",  # Douglas DC-9-40
    "DC95": "DC-9-50",  # Douglas DC-9-50
    "DH8A": "DHC8-1",  # De Havilland Canada DHC-8-100 Dash 8 / 8Q
    "DH8B": "DHC8-2",  # De Havilland Canada DHC-8-200 Dash 8 / 8Q
    "DH8C": "DHC8-3",  # De Havilland Canada DHC-8-300 Dash 8 / 8Q
    "DH8D": "DHC8-4",  # De Havilland Canada DHC-8-400 Dash 8Q
    "DHC5": "DHC-5",  # De Havilland Canada DHC-5 Buffalo
    "DHC6": "DHC-6",  # De Havilland Canada DHC-6 Twin Otter
    "DHC7": "DHC-7",  # De Havilland Canada DHC-7 Dash 7
    "E110": "EMB110",  # Embraer EMB 110 Bandeirante
    "E120": "EMB120",  # Embraer EMB 120 Brasilia
    "E135": "RJ135",  # Embraer RJ135
    "E145": "RJ145",  # Embraer RJ145
    "E170": "E170",  # Embraer 170
    "E190": "E190",  # Embraer 190 / Lineage 1000
    "E195": "E195",  # Embraer 195
    "E290": "E190-E2",  # Embraer E190-E2
    "E295": "E195-E2",  # Embraer E195-E2
    "E35L": "Legacy6",  # Embraer Legacy 600 / Legacy 650
    "E50P": "Phenom1",  # Embraer Phenom 100
    "E545": "Praetor5",  # Embraer Legacy 450 / Praetor 500
    "E550": "Praetor6",  # Embraer Legacy 500 / Praetor 600
    "E55P": "Phenom3",  # Embraer Phenom 300
    "E75L": "E175",  # Embraer 175 (long wing)
    "E75S": "E175",  # Embraer 175 (short wing)
    "EA50": "500",  # Eclipse 500
    "F100": "100",  # Fokker 100
    "F27": "F27",  # Fokker F27 Friendship
    "F28": "F28",  # Fokker F28 Fellowship
    "F2TH": "Falcon2K",  # Dassault Falcon 2000
    "F406": "F406",  # Reims-Cessna F406 Caravan II
    "F50": "50",  # Fokker 50
    "F70": "70",  # Fokker 70
    "F900": "Falcon9",  # Dassault Falcon 900
    "FA50": "Falcon50",  # Dassault Falcon 50
    "FA6X": "Falcon6X",  # Dassault Falcon 6X
    "FA7X": "Falcon7X",  # Dassault Falcon 7X
    "G159": "G-159",  # Gulfstream Aerospace G-159 Gulfstream I
    "G280": "G280",  # Gulfstream G280
    "G73T": "Grumman",  # Grumman G-73 Turbo Mallard
    "GA7C": "G700",  # Gulfstream G700
    "GL5T": "Global5",  # Bombardier Global 5000
    "GLEX": "GlobalEx",  # Bombardier Global Express / Raytheon Sentinel
    "GLF4": "G-IV",  # Gulfstream IV
    "GLF5": "G-V",  # Gulfstream V
    "GLF6": "G650",  # Gulfstream G650
    "H25B": "HS125",  # British Aerospace 125 series / Hawker 700/800/...
    "H25C": "HS125-1",  # British Aerospace 125-1000 series / Hawker 10...
    "HDJT": "HA-420",  # Honda HA-420
    "I114": "Il-114",  # Ilyushin Il-114
    "IL18": "Il-18",  # Ilyushin Il-18
    "IL62": "Il-62",  # Ilyushin Il-62
    "IL76": "Il-76",  # Ilyushin Il-76
    "IL86": "Il-86",  # Ilyushin Il-86
    "IL96": "Il-96",  # Ilyushin Il-96
    "J328": "328JET",  # Fairchild Dornier 328JET
    "JS31": "31",  # British Aerospace Jetstream 31
    "JS32": "32",  # British Aerospace Jetstream 32
    "JS41": "41",  # British Aerospace Jetstream 41
    "K35R": "KC-135",  # Boeing KC-135 Stratotanker
    "L101": "Tristar",  # Lockheed L-1011 Tristar
    "L188": "L-188",  # Lockheed L-188 Electra
    "L410": "410",  # LET 410
    "LJ35": "35",  # Learjet 35 / 36 / C-21A
    "LJ60": "60",  # Learjet 60
    "MD11": "MD-11",  # McDonnell Douglas MD-11
    "MD81": "MD-81",  # McDonnell Douglas MD-81
    "MD82": "MD-82",  # McDonnell Douglas MD-82
    "MD83": "MD-83",  # McDonnell Douglas MD-83
    "MD87": "MD-87",  # McDonnell Douglas MD-87
    "MD88": "MD-88",  # McDonnell Douglas MD-88
    "MD90": "MD-90",  # McDonnell Douglas MD-90
    "MU2": "Mu-2",  # Mitsubishi Mu-2
    "N262": "262",  # Aerospatiale (Nord) 262
    "NOMA": "N22B",  # Government Aircraft Factories N22B / N24A Nomad
    "P180": "P.180",  # Piaggio P.180 Avanti
    "P8": "P-8",  # Boeing P-8 Poseidon
    "PAY2": "PAY2",  # PIPER Cheyenne 2
    "PC12": "PC-12",  # Pilatus PC-12
    "PC24": "PC-24",  # Pilatus PC-24
    "RJ1H": "RJ100",  # Avro RJ100
    "RJ70": "RJ70",  # Avro RJ70
    "RJ85": "RJ85",  # Avro RJ85
    "S601": "SN.601",  # Aerospatiale SN.601 Corvette
    "SB20": "2000",  # Saab 2000
    "SC7": "SC-7",  # Shorts SC-7 Skyvan
    "SF34": "SF340A",  # Saab SF340A/B
    "SH33": "SD.330",  # Shorts SD.330
    "SH36": "SD.360",  # Shorts SD.360
    "SU95": "SSJ100",  # Sukhoi Superjet 100-95
    "SW4": "Metro",  # Fairchild Swearingen Metroliner
    "T134": "Tu-134",  # Tupolev Tu-134
    "T154": "Tu-154",  # Tupolev Tu-154
    "T204": "Tu-204",  # Tupolev Tu-204 / Tu-214
    "WW24": "Westwind",  # Israel Aircraft Industries 1124 Westwind
    "Y12": "Y-12",  # Harbin Y-12
    "YK40": "Yak-40",  # Yakovlev Yak-40
    "YK42": "Yak-42",  # Yakovlev Yak-42
    "YS11": "YS-11",  # NAMC YS-11
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
        code = kind.strip().upper()
        name = ICAO_AIRCRAFT_TYPES.get(code)
        if name:
            return name
        return code

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

def info_text(content, color = "#fff"):
    return render.Text(content, color = color)

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

    c1 = config.str("line1_color", "#fff")
    c2 = config.str("line2_color", "#fff")
    c3 = config.str("line3_color", "#fff")
    c4 = config.str("line4_color", "#fff")

    text = [
        info_text(display_flight_number(route, callsign), color = c1),
        info_text(route_string(route), color = c2),
        info_text(aircraft_type(plane), color = c3),
        render.Marquee(
            width = 32,
            child = info_text(details, color = c4),
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
            schema.Color(
                id = "line1_color",
                name = "Line 1 color",
                desc = "Color of the flight number line.",
                icon = "palette",
                default = "#fff",
            ),
            schema.Color(
                id = "line2_color",
                name = "Line 2 color",
                desc = "Color of the route line.",
                icon = "palette",
                default = "#fff",
            ),
            schema.Color(
                id = "line3_color",
                name = "Line 3 color",
                desc = "Color of the aircraft type line.",
                icon = "palette",
                default = "#fff",
            ),
            schema.Color(
                id = "line4_color",
                name = "Line 4 color",
                desc = "Color of the details line.",
                icon = "palette",
                default = "#fff",
            ),
        ],
    )
