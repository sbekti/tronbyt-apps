"""
Applet: NWS Weather
Summary: Weather forecast using NWS
Description: Weather forecasts for your location using the free National Weather Service API.
Authors: sbekti (Recreation of original by JeffLac, RichardD012, gabe565)
"""

load("animation.star", "animation")
load("encoding/json.star", "json")
load("http.star", "http")
load("i18n.star", "tr")
load("images/clear.png", CLEAR_IMAGE = "file")
load("images/clear@2x.png", CLEAR_IMAGE_2X = "file")
load("images/clear_full.png", CLEAR_FULL_IMAGE = "file")
load("images/clear_full@2x.png", CLEAR_FULL_IMAGE_2X = "file")
load("images/clouds.png", CLOUDS_IMAGE = "file")
load("images/clouds@2x.png", CLOUDS_IMAGE_2X = "file")
load("images/clouds_full.png", CLOUDS_FULL_IMAGE = "file")
load("images/clouds_full@2x.png", CLOUDS_FULL_IMAGE_2X = "file")
load("images/drizzle.png", DRIZZLE_IMAGE = "file")
load("images/drizzle@2x.png", DRIZZLE_IMAGE_2X = "file")
load("images/drizzle_full.png", DRIZZLE_FULL_IMAGE = "file")
load("images/drizzle_full@2x.png", DRIZZLE_FULL_IMAGE_2X = "file")
load("images/fog.png", FOG_IMAGE = "file")
load("images/fog@2x.png", FOG_IMAGE_2X = "file")
load("images/hail.png", HAIL_IMAGE = "file")
load("images/hail@2x.png", HAIL_IMAGE_2X = "file")
load("images/mist.png", MIST_IMAGE = "file")
load("images/mist@2x.png", MIST_IMAGE_2X = "file")
load("images/mist_full.png", MIST_FULL_IMAGE = "file")
load("images/mist_full@2x.png", MIST_FULL_IMAGE_2X = "file")
load("images/moon.png", MOON_IMAGE = "file")
load("images/moon@2x.png", MOON_IMAGE_2X = "file")
load("images/moonish.png", MOONISH_IMAGE = "file")
load("images/moonish@2x.png", MOONISH_IMAGE_2X = "file")
load("images/partly_sun.png", PARTLY_SUN_IMAGE = "file")
load("images/partly_sun@2x.png", PARTLY_SUN_IMAGE_2X = "file")
load("images/partly_sun_full.png", PARTLY_SUN_FULL_IMAGE = "file")
load("images/partly_sun_full@2x.png", PARTLY_SUN_FULL_IMAGE_2X = "file")
load("images/rain.png", RAIN_IMAGE = "file")
load("images/rain@2x.png", RAIN_IMAGE_2X = "file")
load("images/rain_full.png", RAIN_FULL_IMAGE = "file")
load("images/rain_full@2x.png", RAIN_FULL_IMAGE_2X = "file")
load("images/sleet.png", SLEET_IMAGE = "file")
load("images/sleet@2x.png", SLEET_IMAGE_2X = "file")
load("images/snow.png", SNOW_IMAGE = "file")
load("images/snow@2x.png", SNOW_IMAGE_2X = "file")
load("images/snow_full.png", SNOW_FULL_IMAGE = "file")
load("images/snow_full@2x.png", SNOW_FULL_IMAGE_2X = "file")
load("images/squall.png", SQUALL_IMAGE = "file")
load("images/squall@2x.png", SQUALL_IMAGE_2X = "file")
load("images/thunderstorm.png", THUNDERSTORM_IMAGE = "file")
load("images/thunderstorm@2x.png", THUNDERSTORM_IMAGE_2X = "file")
load("images/thunderstorm_full.png", THUNDERSTORM_FULL_IMAGE = "file")
load("images/thunderstorm_full@2x.png", THUNDERSTORM_FULL_IMAGE_2X = "file")
load("images/tornado.png", TORNADO_IMAGE = "file")
load("images/tornado@2x.png", TORNADO_IMAGE_2X = "file")
load("render.star", "canvas", "render")
load("schema.star", "schema")
load("time.star", "time")

DEFAULT_LOCATION = """
{
	"lat": "40.6781784",
	"lng": "-73.9441579",
	"description": "Brooklyn, NY, USA",
	"locality": "Brooklyn",
	"place_id": "ChIJCSF8lBZEwokRhngABHRcdoI",
	"timezone": "America/New_York"
}
"""

DEFAULT_CACHE_MINS = 5

NWS_POINTS_URL = "https://api.weather.gov/points/{lat},{lng}"
NWS_HEADERS = {
    "User-Agent": "tronbyt-nws-weather-app (https://github.com/sbekti/tronbyt-apps)",
    "Accept": "application/geo+json",
}

WEATHER_FULL_IMAGE = {
    "Thunderstorm": THUNDERSTORM_FULL_IMAGE,
    "Clear": CLEAR_FULL_IMAGE,
    "Clouds": CLOUDS_FULL_IMAGE,
    "Snow": SNOW_FULL_IMAGE,
    "Partly_Sun": PARTLY_SUN_FULL_IMAGE,
    "Mist": MIST_FULL_IMAGE,
    "Drizzle": DRIZZLE_FULL_IMAGE,
    "Rain": RAIN_FULL_IMAGE,
}

WEATHER_FULL_IMAGE_2X = {
    "Thunderstorm": THUNDERSTORM_FULL_IMAGE_2X,
    "Clear": CLEAR_FULL_IMAGE_2X,
    "Clouds": CLOUDS_FULL_IMAGE_2X,
    "Snow": SNOW_FULL_IMAGE_2X,
    "Partly_Sun": PARTLY_SUN_FULL_IMAGE_2X,
    "Mist": MIST_FULL_IMAGE_2X,
    "Drizzle": DRIZZLE_FULL_IMAGE_2X,
    "Rain": RAIN_FULL_IMAGE_2X,
}

def main(config):
    scale = 2 if canvas.is2x() else 1
    location = config.get("location", DEFAULT_LOCATION)
    loc = json.decode(location)

    lat = loc["lat"]
    lng = loc["lng"]
    timezone = loc.get("timezone", time.tz())
    units = config.get("units", "imperial")
    showthreeday = config.bool("showthreeday", False)
    image_scale = 1 if config.bool("force_1x_images") else scale

    cache_mins_str = config.str("cache_mins", str(DEFAULT_CACHE_MINS))
    cache_mins = int(cache_mins_str) if cache_mins_str.isdigit() else DEFAULT_CACHE_MINS

    daily_data = fetch_nws_weather(lat, lng, timezone, units, cache_mins)

    if not daily_data:
        return error_display("Weather API Error", scale)

    if showthreeday:
        return render_weather(daily_data, scale, image_scale)
    else:
        return render_single_day(daily_data, scale, image_scale)

def fetch_nws_weather(lat, lng, timezone, units, cache_mins):
    cache_sec = cache_mins * 60

    points_resp = http.get(
        NWS_POINTS_URL.format(lat = lat, lng = lng),
        headers = NWS_HEADERS,
        ttl_seconds = 86400,
    )
    if points_resp.status_code != 200:
        return None

    points_data = points_resp.json()
    props = points_data["properties"]
    office = props["cwa"]
    grid_x = props["gridX"]
    grid_y = props["gridY"]

    forecast_url = "https://api.weather.gov/gridpoints/{}/{},{}/forecast".format(office, grid_x, grid_y)
    forecast_resp = http.get(forecast_url, headers = NWS_HEADERS, ttl_seconds = cache_sec)
    if forecast_resp.status_code != 200:
        return None

    forecast_data = forecast_resp.json()
    periods = forecast_data["properties"]["periods"]

    buckets = {}
    for period in periods:
        start = time.parse_time(period["startTime"]).in_location(timezone)
        date_key = start.format("2006-01-02")

        if date_key not in buckets:
            buckets[date_key] = {"day": None, "night": None, "date": start}

        if period["isDaytime"]:
            buckets[date_key]["day"] = period
        else:
            buckets[date_key]["night"] = period

    sorted_dates = sorted(buckets.keys())
    daily_data = []

    for date_key in sorted_dates:
        if len(daily_data) >= 3:
            break
        bucket = buckets[date_key]
        day = bucket["day"]
        night = bucket["night"]

        if not day:
            continue

        temp_max = day["temperature"]
        temp_min = night["temperature"] if night else day["temperature"]

        if units == "metric":
            temp_max = (temp_max - 32) * 5 // 9
            temp_min = (temp_min - 32) * 5 // 9

        weather_cat = nws_short_forecast_to_category(day["shortForecast"], True)

        daily_data.append({
            "high": temp_max,
            "low": temp_min,
            "weather": weather_cat,
            "date": bucket["date"],
        })

    return daily_data

def nws_short_forecast_to_category(short_forecast, is_daytime):
    sf = short_forecast.lower()
    if "thunderstorm" in sf or "tornado" in sf:
        return "Thunderstorm"
    if "snow" in sf or "blizzard" in sf or "flurries" in sf or "frost" in sf:
        return "Snow"
    if "hail" in sf:
        return "Hail"
    if "freezing rain" in sf or "sleet" in sf or "ice" in sf:
        return "Sleet"
    if "rain" in sf or "shower" in sf or "drizzle" in sf:
        return "Rain"
    if "fog" in sf or "haze" in sf or "smoke" in sf or "mist" in sf:
        return "Mist"
    if "wind" in sf or "breezy" in sf:
        return "Clouds"
    if "partly" in sf or "mostly" in sf:
        return "Partly_Sun" if is_daytime else "Moonish"
    if "cloudy" in sf or "overcast" in sf:
        return "Clouds"
    if "sunny" in sf or "clear" in sf or "fair" in sf or "hot" in sf:
        return "Clear" if is_daytime else "Moon"
    return "Partly_Sun" if is_daytime else "Moonish"

def render_single_day(daily_data, scale = 1, image_scale = 1):
    if len(daily_data) < 2:
        return error_display("Weather API Error")

    day = daily_data[0]
    tomorrow = daily_data[1]

    day_abbr = _get_day_abbr(day["date"])
    tomorrow_abbr = _get_day_abbr(tomorrow["date"])
    slide_percentage = get_slide_percentage(day["weather"])
    should_render_day_at_top = get_should_render_day_at_top(day["weather"])

    delay_ms = 30
    total_frames = int(15000 / delay_ms)
    anim_frames = int(1500 / delay_ms)
    static_frames_before = int(2000 / delay_ms)
    bg_head_start = int(250 / delay_ms)
    slide_distance = int(64 * slide_percentage / 100) * scale

    bg_delay = static_frames_before - bg_head_start
    bg_duration = total_frames - bg_delay
    bg_anim_pct = (anim_frames + bg_head_start) * 1.0 / bg_duration

    content_delay = static_frames_before
    content_duration = total_frames - content_delay
    content_anim_pct = anim_frames * 1.0 / content_duration

    today_width = 42 * scale
    content_slide = 21 * scale
    tomorrow_width = get_forecast_width(tomorrow["high"], False) * scale if scale == 2 else 16
    day_offset = get_day_offset(day["high"]) * scale
    screen_width = 64 * scale
    screen_height = 32 * scale

    if should_render_day_at_top:
        day_label = render.Row(
            main_align = "start",
            cross_align = "start",
            expanded = True,
            children = [
                render.Padding(
                    pad = (-scale, 0, scale, 2 * scale),
                    child = render.Box(
                        width = 20 * scale,
                        height = 8 * scale,
                        color = "#00000000",
                        child = render.Text(
                            day_abbr,
                            font = "5x8" if scale == 1 else "terminus-16",
                            color = "#FFF",
                        ),
                    ),
                ),
            ],
        )
    else:
        day_label = render.Row(
            main_align = "start",
            cross_align = "end",
            expanded = True,
            children = [
                render.Padding(
                    pad = (scale, 0, 0, 2 * scale),
                    child = render.Box(
                        width = 14 * scale,
                        height = 8 * scale,
                        color = "#000000CC",
                        child = render.Text(
                            day_abbr,
                            font = "5x8" if scale == 1 else "terminus-16",
                            color = "#FFF",
                        ),
                    ),
                ),
            ],
        )

    if should_render_day_at_top:
        today_temps = render.Column(
            expanded = True,
            main_align = "start",
            cross_align = "start",
            children = [
                render.Row(
                    children = [render.Box(width = 20 * scale, height = 13 * scale)],
                ),
                render.Row(
                    children = [
                        render.Box(
                            width = today_width,
                            height = 19 * scale,
                            child = render_today_forecast(day, "", today_width - day_offset, "#00000000", scale),
                        ),
                    ],
                ),
            ],
        )
    else:
        today_temps = render.Column(
            expanded = True,
            main_align = "start",
            cross_align = "center",
            children = [
                render.Row(
                    children = [render.Box(width = 1 * scale, height = 13 * scale)],
                ),
                render.Row(
                    children = [
                        render.Box(
                            width = today_width,
                            height = 19 * scale,
                            child = render_today_forecast(day, "", today_width - day_offset, "#00000000", scale),
                        ),
                    ],
                ),
            ],
        )

    return render.Root(
        delay = delay_ms,
        child = render.Stack(
            children = [
                animation.Transformation(
                    child = render.Image(
                        src = get_weather_image(day["weather"], image_scale),
                        width = screen_width,
                        height = screen_height,
                    ),
                    duration = bg_duration,
                    delay = bg_delay,
                    width = screen_width,
                    height = screen_height,
                    keyframes = make_keyframes(0, -slide_distance, bg_anim_pct),
                ),
                render.Box(
                    width = screen_width,
                    height = screen_height,
                    child = render.Column(
                        expanded = True,
                        main_align = "end" if not should_render_day_at_top else "start",
                        children = [day_label],
                    ),
                ),
                animation.Transformation(
                    child = render.Box(
                        width = screen_width,
                        height = screen_height,
                        child = render.Row(
                            main_align = "start",
                            cross_align = "start",
                            expanded = True,
                            children = [
                                today_temps,
                                render.Row(
                                    children = [
                                        render.Padding(
                                            pad = (scale, 3 * scale, scale, 3 * scale),
                                            child = render.Box(
                                                width = 1 * scale,
                                                height = 26 * scale,
                                                color = "#FFFFFF1A",
                                            ),
                                        ),
                                    ],
                                ),
                                render.Column(
                                    main_align = "start",
                                    cross_align = "start",
                                    expanded = True,
                                    children = [
                                        render.Row(
                                            main_align = "start",
                                            cross_align = "start",
                                            expanded = True,
                                            children = [
                                                render.Box(
                                                    width = tomorrow_width,
                                                    height = 13 * scale,
                                                    child = render.Column(
                                                        main_align = "start",
                                                        cross_align = "center",
                                                        expanded = True,
                                                        children = [
                                                            render.Padding(
                                                                pad = (0, scale, 0, 0),
                                                                child = render.Text(
                                                                    tomorrow_abbr,
                                                                    font = "5x8" if scale == 1 else "terminus-16",
                                                                    color = "#FFF",
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                        render_forecast(tomorrow, False, scale),
                                    ],
                                ),
                            ],
                        ),
                    ),
                    duration = content_duration,
                    delay = content_delay,
                    width = screen_width,
                    height = screen_height,
                    keyframes = make_keyframes(content_slide, 0, content_anim_pct),
                ),
            ],
        ),
    )

def get_should_render_day_at_top(forecast):
    if forecast == "Snow":
        return True
    return False

def get_slide_percentage(forecast):
    slide_map = {
        "Clear": 10,
        "Clouds": 40,
        "Rain": 33,
        "Snow": 40,
        "Thunderstorm": 33,
        "Drizzle": 33,
        "Mist": 40,
        "Partly_Sun": 33,
    }
    return slide_map.get(forecast, 40)

def _get_day_abbr(date):
    abbr = date.format("Mon")[:3].upper()
    return tr(abbr)

def get_weather_image(forecast, scale = 1):
    image = None
    if scale == 2:
        image = WEATHER_FULL_IMAGE_2X.get(forecast)
    if not image:
        image = WEATHER_FULL_IMAGE.get(forecast)
    return image.readall() if image else ""

def render_today_forecast_column(day, day_abbr, today_width, day_top = False, scale = 1):
    day_offset = get_day_offset(day["high"]) * scale
    if day_top == True:
        return render.Column(
            expanded = True,
            main_align = "start",
            cross_align = "start",
            children = [
                render.Row(
                    children = [
                        render.Box(
                            width = 20 * scale,
                            height = 13 * scale,
                            child = render.Padding(
                                pad = (-scale, 0, scale, 2 * scale),
                                child = render.Box(
                                    width = 20 * scale,
                                    height = 8 * scale,
                                    color = "#00000000",
                                    child = render.Text(
                                        day_abbr,
                                        font = "5x8" if scale == 1 else "terminus-16",
                                        color = "#FFF",
                                    ),
                                ),
                            ),
                        ),
                    ],
                ),
                render.Row(
                    children = [
                        render.Box(
                            width = today_width,
                            height = 19 * scale,
                            child = render_today_forecast(day, "", today_width - day_offset, "#00000000", scale),
                        ),
                    ],
                ),
            ],
        )

    return render.Column(
        expanded = True,
        main_align = "start",
        cross_align = "center",
        children = [
            render.Row(
                children = [
                    render.Box(
                        width = 1 * scale,
                        height = 13 * scale,
                    ),
                ],
            ),
            render.Row(
                children = [
                    render.Box(
                        width = today_width,
                        height = 19 * scale,
                        child = render_today_forecast(day, day_abbr, today_width - day_offset, scale = scale),
                    ),
                ],
            ),
        ],
    )

def render_today_forecast(day, day_abbr, padding, color = "#000000CC", scale = 1):
    return render.Row(
        expanded = True,
        main_align = "space_evenly",
        cross_align = "end",
        children = [
            render.Padding(
                pad = (scale, 0, padding, 2 * scale),
                child = render.Box(
                    width = 14 * scale,
                    height = 8 * scale,
                    color = color,
                    child = render.Text(
                        day_abbr,
                        font = "5x8" if scale == 1 else "terminus-16",
                        color = "#FFF",
                    ),
                ),
            ),
            render_forecast(day, True, scale),
        ],
    )

def render_forecast(day, is_today, scale = 1):
    forecast_width = get_forecast_width(day["high"], is_today) * scale
    forecast_padding = get_forecast_padding(day["high"], is_today) * scale
    return render.Row(
        main_align = "center",
        cross_align = "start",
        expanded = True,
        children = [
            render.Box(
                width = forecast_width,
                height = 19 * scale,
                child = render.Column(
                    main_align = "start",
                    cross_align = "start",
                    expanded = True,
                    children = [
                        render.Padding(
                            pad = (0, scale, forecast_padding, 2 * scale),
                            child = render.Column(
                                cross_align = "end",
                                children = [
                                    render.Text(
                                        "%d°" % round_temp(day["high"]),
                                        font = "tb-8" if scale == 1 else "terminus-16",
                                        color = "#FFF",
                                    ),
                                    render.Text(
                                        "%d°" % round_temp(day["low"]),
                                        font = "tb-8" if scale == 1 else "terminus-16",
                                        color = "#888",
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        ],
    )

def get_forecast_padding(temp, is_today):
    temp = round_temp(temp)
    if temp >= 100 or temp <= -10:
        return 4
    if is_today:
        return 0
    return 0

def get_day_offset(temp):
    temp = round_temp(temp)
    if temp >= 100 or temp <= -10:
        return 38
    return 30

def get_forecast_width(temp, is_today):
    temp = round_temp(temp)
    if temp >= 100 or temp <= -10:
        return 24
    if is_today:
        return 16
    return 20

def round_temp(temp):
    return (temp * 10 + 5) // 10

WEATHER_ICONS = {
    "Clear": CLEAR_IMAGE,
    "Clouds": CLOUDS_IMAGE,
    "Drizzle": DRIZZLE_IMAGE,
    "Fog": FOG_IMAGE,
    "Hail": HAIL_IMAGE,
    "Mist": MIST_IMAGE,
    "Moon": MOON_IMAGE,
    "Moonish": MOONISH_IMAGE,
    "Partly_Sun": PARTLY_SUN_IMAGE,
    "Rain": RAIN_IMAGE,
    "Sleet": SLEET_IMAGE,
    "Snow": SNOW_IMAGE,
    "Squall": SQUALL_IMAGE,
    "Thunderstorm": THUNDERSTORM_IMAGE,
    "Tornado": TORNADO_IMAGE,
}

WEATHER_ICONS_2X = {
    "Clear": CLEAR_IMAGE_2X,
    "Clouds": CLOUDS_IMAGE_2X,
    "Drizzle": DRIZZLE_IMAGE_2X,
    "Fog": FOG_IMAGE_2X,
    "Hail": HAIL_IMAGE_2X,
    "Mist": MIST_IMAGE_2X,
    "Moon": MOON_IMAGE_2X,
    "Moonish": MOONISH_IMAGE_2X,
    "Partly_Sun": PARTLY_SUN_IMAGE_2X,
    "Rain": RAIN_IMAGE_2X,
    "Sleet": SLEET_IMAGE_2X,
    "Snow": SNOW_IMAGE_2X,
    "Squall": SQUALL_IMAGE_2X,
    "Thunderstorm": THUNDERSTORM_IMAGE_2X,
    "Tornado": TORNADO_IMAGE_2X,
}

def get_weather_icon(forecast, scale = 1):
    icon = None
    if scale == 2:
        icon = WEATHER_ICONS_2X.get(forecast)
    if not icon:
        icon = WEATHER_ICONS.get(forecast)
    return icon.readall() if icon else ""

def render_weather(daily_data, scale = 1, icon_scale = 1):
    DAY_WIDTH = 20 * scale
    DIVIDER_WIDTH = scale
    TOTAL_WIDTH = (DAY_WIDTH * 3) + (DIVIDER_WIDTH * 2)
    HEIGHT = 32 * scale
    SUFFIX = "°" if scale == 2 else ""

    columns = []
    for i, day in enumerate(daily_data):
        day_abbr = day["date"].format("Mon")[:3].upper()
        day_abbr = tr(day_abbr)

        day_column = render.Column(
            expanded = True,
            main_align = "space_around",
            cross_align = "center",
            children = [
                render.Image(
                    src = get_weather_icon(day["weather"], icon_scale),
                    width = 13 * scale,
                    height = 13 * scale,
                ),
                render.Text(
                    day_abbr,
                    font = "CG-pixel-4x5-mono" if scale == 1 else "terminus-12",
                    color = "#FF0",
                ),
                render.Text(
                    "%d" % round_temp(day["high"]) + SUFFIX,
                    font = "CG-pixel-4x5-mono" if scale == 1 else "terminus-12",
                    color = "#FFF",
                ),
                render.Text(
                    "%d" % round_temp(day["low"]) + SUFFIX,
                    font = "CG-pixel-4x5-mono" if scale == 1 else "terminus-12",
                    color = "#FFF",
                ),
            ],
        )

        columns.append(day_column)

        if i < 2:
            columns.append(
                render.Box(
                    width = DIVIDER_WIDTH,
                    height = HEIGHT,
                    color = "#444",
                ),
            )

    weather_display = render.Root(
        child = render.Stack(
            children = [
                render.Box(
                    width = TOTAL_WIDTH,
                    height = HEIGHT,
                    color = "#000",
                ),
                render.Row(
                    expanded = True,
                    main_align = "space_evenly",
                    children = columns,
                ),
            ],
        ),
    )

    return weather_display

def error_display(message, scale = 1):
    return render.Root(
        child = render.Text(message, font = "tb-8" if scale == 1 else "terminus-12"),
    )

def make_keyframes(start_x, end_x, anim_pct = 1.0):
    return [
        animation.Keyframe(
            percentage = 0.0,
            transforms = [animation.Translate(start_x, 0)],
            curve = "ease_in_out",
        ),
        animation.Keyframe(
            percentage = anim_pct,
            transforms = [animation.Translate(end_x, 0)],
        ),
        animation.Keyframe(
            percentage = 1.0,
            transforms = [animation.Translate(end_x, 0)],
        ),
    ]

def get_schema():
    options = [
        schema.Option(
            display = "Fahrenheit",
            value = "imperial",
        ),
        schema.Option(
            display = "Celsius",
            value = "metric",
        ),
    ]

    return schema.Schema(
        version = "1",
        fields = [
            schema.Location(
                id = "location",
                name = "Location",
                desc = "Location for the display of the weather.",
                icon = "locationDot",
            ),
            schema.Toggle(
                id = "showthreeday",
                name = "Show Three Day Forecast",
                desc = "Toggle between three day and single day display.",
                default = True,
                icon = "calendar",
            ),
            schema.Dropdown(
                id = "units",
                name = "Units",
                desc = "Display units.",
                default = options[0].value,
                options = options,
                icon = "calendar",
            ),
            schema.Text(
                id = "cache_mins",
                name = "Cache Duration",
                desc = "How long to cache weather data (in minutes)",
                icon = "clock",
                default = str(DEFAULT_CACHE_MINS),
            ),
            schema.Toggle(
                id = "force_1x_images",
                name = "Force 1x Images",
                desc = "The two-day forecast images have been upscaled to 2x. Enable this if you prefer the crispier look of the 1x images.",
                icon = "magnifyingGlass",
                default = False,
            ) if canvas.is2x() else None,
        ],
    )
