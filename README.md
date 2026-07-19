# 🌤️ Weather App

A polished, open-source weather app built with Flutter — search any city or use your
current location to see live conditions, an hourly outlook, and a 7-day forecast.

Built as a portfolio piece to demonstrate a clean, layered Flutter architecture with
**Provider** state management, a fully mocked test suite, and zero API keys to manage.

> Live conditions powered by [Open-Meteo](https://open-meteo.com/) — a free,
> open-source weather API that requires no API key, which keeps this public repo
> free of secrets.

<!--
  Add screenshots here once you have them, e.g.:
  <p align="center">
    <img src="docs/screenshot_home.png" width="260" />
    <img src="docs/screenshot_search.png" width="260" />
    <img src="docs/screenshot_dark.png" width="260" />
  </p>
-->

## Features

- 🔍 **City search** — debounced search-as-you-type against Open-Meteo's geocoding API
- 📍 **Current location** — one-tap weather for wherever you are, via `geolocator`
- 🌡️ **Current conditions** — temperature, feels-like, humidity, wind, precipitation
- ⏱️ **Hourly forecast** — next 24 hours, horizontally scrollable
- 📅 **7-day forecast** — daily highs/lows and precipitation chance
- 🕘 **Recent cities** — quick-switch chips, persisted locally
- 🌓 **Light / dark theme** — Material 3, toggleable and persisted
- 🌡️ **°C / °F toggle** — unit preference persisted and requested directly from the API
- ↻ **Pull to refresh** and clear, actionable error states (no connection, no results, etc.)

## Architecture

The app follows a small, lightweight layered architecture — no code generation,
no DI framework, just plain constructor injection wired up in `main.dart`.

```
lib/
├── core/                     # Cross-cutting concerns, no Flutter widgets besides theme
│   ├── constants/            # API endpoints, field lists, enums (units, view status)
│   ├── errors/                # Exceptions (data layer) -> Failures (UI layer)
│   ├── location/              # Thin wrapper around Geolocator
│   ├── network/                # ApiClient: http.Client wrapper with typed error handling
│   ├── theme/                  # Light/dark Material 3 ThemeData
│   └── utils/                   # WMO weather-code mapping, date formatting
│
├── data/
│   ├── models/                # City, CurrentWeather, HourlyWeather, DailyWeather, WeatherReport
│   └── weather_repository.dart # WeatherRepository interface + Open-Meteo implementation
│
└── presentation/
    ├── provider/              # WeatherProvider (fetch/status/recents), SettingsProvider (theme/unit)
    ├── screens/                # HomeScreen, CitySearchScreen
    └── widgets/                 # CurrentWeatherCard, Hourly/DailyForecastList, ErrorView, ...
```

**Data flow:** widgets call into a `ChangeNotifier` provider → the provider calls
`WeatherRepository` → the repository calls `ApiClient` → raw JSON is parsed into
immutable model classes. Network/parsing failures are thrown as typed `AppException`s
in the data layer and mapped to UI-friendly `Failure`s in the provider, so widgets
only ever branch on a small `ViewStatus` enum (`initial`, `loading`, `refreshing`,
`success`, `error`) plus a `Failure` message — never on raw exceptions.

`SettingsProvider` and `WeatherProvider` are connected with a
`ChangeNotifierProxyProvider`: toggling the temperature unit automatically
refetches the current city's weather in the new unit.

## Why Open-Meteo instead of OpenWeatherMap?

The original version of this project called OpenWeatherMap with an API key
hardcoded in source. For a project meant to live in a **public** GitHub repo,
that's a real problem — anyone can lift the key. Open-Meteo's forecast and
geocoding endpoints are free for non-commercial use and require no key at all,
so this rewrite drops the secret entirely instead of working around how to hide it.

## Tech stack

| Concern            | Package                                                          |
| ------------------- | ---------------------------------------------------------------- |
| State management    | [`provider`](https://pub.dev/packages/provider)                  |
| Networking           | [`http`](https://pub.dev/packages/http)                          |
| Location             | [`geolocator`](https://pub.dev/packages/geolocator)               |
| Local persistence    | [`shared_preferences`](https://pub.dev/packages/shared_preferences)|
| Value equality       | [`equatable`](https://pub.dev/packages/equatable)                 |
| Date formatting      | [`intl`](https://pub.dev/packages/intl)                           |
| Testing              | `flutter_test`, [`mocktail`](https://pub.dev/packages/mocktail)    |

## Getting started

```bash
git clone https://github.com/IMWaqasFarooq/weather_app.git
cd weather_app
flutter pub get
flutter run
```

No API keys, no `.env` file, no secrets — it runs as soon as dependencies are fetched.

### Supported platforms

iOS, Android, macOS, and web are all supported by Flutter's target list; this app
adds location permission strings for iOS/macOS/Android. On the web, "use current
location" relies on the browser's geolocation permission prompt.

## Testing

The test suite covers every layer without hitting the network or the filesystem:
HTTP calls are mocked with `mocktail`, and preferences use
`SharedPreferences.setMockInitialValues`.

```bash
flutter test
```

| Layer         | What's covered                                                                 |
| ------------- | ------------------------------------------------------------------------------- |
| `data/models`  | JSON (de)serialization, equality, edge cases (missing fields, defaults)         |
| `data`         | `WeatherRepositoryImpl` against a mocked `http.Client` — success and error paths |
| `presentation/provider` | `WeatherProvider` and `SettingsProvider` state transitions, persistence, unit-change refetch |
| `presentation/screens`  | `HomeScreen` rendering for empty, loading, error, and success states       |

## Project structure at a glance

```
lib/main.dart              # Composition root: builds ApiClient, repository, providers
lib/app.dart                # MaterialApp + theme wiring
lib/core/...                 # Framework-agnostic helpers (network, errors, location, theme, utils)
lib/data/...                  # Models + repository (the only layer that knows about Open-Meteo)
lib/presentation/...           # Providers, screens, widgets (the only layer that knows about Flutter UI)
test/...                       # Mirrors lib/, one test file per unit under test
```

## License

This project is open source and available for anyone to use as a learning reference
or portfolio starting point.
