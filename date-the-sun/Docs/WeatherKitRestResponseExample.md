# WeatherKit Rest Response Example

Get daily forecast.

URL `GET https://weatherkit.apple.com/api/v1/weather/en/51.5/-0.1?dataSets=forecastDaily&timezone=Europe/London&dailyStart=2026-06-05T01:55:05.703Z&dailyEnd=2026-06-06T01:55:05.704Z`


```json
{
  "forecastDaily": {
    "name": "DailyForecast",
    "metadata": {
      "attributionURL": "https://developer.apple.com/weatherkit/data-source-attribution/",
      "expireTime": "2026-06-05T02:53:58Z",
      "latitude": 51.5,
      "longitude": -0.1,
      "readTime": "2026-06-05T01:53:58Z",
      "reportedTime": "2026-06-05T00:05:35Z",
      "units": "m",
      "version": 1,
      "sourceType": "modeled"
    },
    "days": [
      {
        "forecastStart": "2026-06-04T23:00:00Z",
        "forecastEnd": "2026-06-05T23:00:00Z",
        "conditionCode": "MostlyCloudy",
        "maxUvIndex": 4,
        "moonPhase": "waningGibbous",
        "moonrise": "2026-06-04T23:36:47Z",
        "moonset": "2026-06-05T08:05:10Z",
        "precipitationAmount": 0,
        "precipitationChance": 0,
        "precipitationType": "clear",
        "snowfallAmount": 0,
        "solarMidnight": "2026-06-04T23:58:46Z",
        "solarNoon": "2026-06-05T11:59:01Z",
        "sunrise": "2026-06-05T03:46:24Z",
        "sunriseCivil": "2026-06-05T03:00:05Z",
        "sunriseNautical": "2026-06-05T01:50:58Z",
        "sunset": "2026-06-05T20:12:20Z",
        "sunsetCivil": "2026-06-05T20:58:35Z",
        "sunsetNautical": "2026-06-05T22:08:30Z",
        "temperatureMax": 18.07,
        "temperatureMin": 11.52,
        "windGustSpeedMax": 34.24,
        "windSpeedAvg": 12.48,
        "windSpeedMax": 16.56,
        "daytimeForecast": {
          "forecastStart": "2026-06-05T06:00:00Z",
          "forecastEnd": "2026-06-05T18:00:00Z",
          "cloudCover": 0.68,
          "conditionCode": "MostlyCloudy",
          "humidity": 0.56,
          "precipitationAmount": 0,
          "precipitationChance": 0,
          "precipitationType": "clear",
          "snowfallAmount": 0,
          "temperatureMax": 18.07,
          "temperatureMin": 12.07,
          "windDirection": 240,
          "windGustSpeedMax": 34.24,
          "windSpeed": 13.73,
          "windSpeedMax": 16.56
        },
        "overnightForecast": {
          "forecastStart": "2026-06-05T18:00:00Z",
          "forecastEnd": "2026-06-06T06:00:00Z",
          "cloudCover": 0.98,
          "conditionCode": "Drizzle",
          "humidity": 0.74,
          "precipitationAmount": 0.81,
          "precipitationChance": 0.49,
          "precipitationType": "rain",
          "snowfallAmount": 0,
          "temperatureMax": 16.65,
          "temperatureMin": 12.24,
          "windDirection": 167,
          "windGustSpeedMax": 37.56,
          "windSpeed": 12.02,
          "windSpeedMax": 16.96
        },
        "restOfDayForecast": {
          "forecastStart": "2026-06-05T01:53:58Z",
          "forecastEnd": "2026-06-05T23:00:00Z",
          "cloudCover": 0.68,
          "conditionCode": "MostlyCloudy",
          "humidity": 0.63,
          "precipitationAmount": 0,
          "precipitationChance": 0,
          "precipitationType": "clear",
          "snowfallAmount": 0,
          "temperatureMax": 18.07,
          "temperatureMin": 11.52,
          "windDirection": 233,
          "windGustSpeedMax": 34.24,
          "windSpeed": 12.67,
          "windSpeedMax": 16.56
        }
      }
    ]
  }
}
```
